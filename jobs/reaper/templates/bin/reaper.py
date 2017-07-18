#/usr/bin/python3

import argparse
import curator
import datetime
import logging

from elasticsearch import Elasticsearch
from time import sleep

logging.basicConfig(format='[%(asctime)s] [%(lineno)d] - %(message)s', level=logging.WARN, datefmt='%Y-%m-%d %X %Z')
parser = argparse.ArgumentParser()
parser.add_argument("threshold", type=int, help="percentage where index prunring will take place")
parser.add_argument("ip", help="IP address of the eleasticseach API node")
parser.add_argument("skip", help="comma seperated list of indices to skip")
args = parser.parse_args()
clusters = [
    {'env': 'default', 'ip': args.ip}
]

threshold = args.threshold
skip_arg = args.skip
skip_index = (skip_arg.replace(' ', '')).split(',')


class DataNode:

    def __init__(self, name, node_id, info):
        self.name = name
        self.node_id = node_id
        self.total_in_bytes = info['total_in_bytes']
        self.free_in_bytes = info['free_in_bytes']
        self.used_in_bytes = self.total_in_bytes - self.free_in_bytes
        self.indices = []

    def used_percentage(self):
        return (self.used_in_bytes / self.total_in_bytes) * 100

    def refresh(self, cluster):
        self.total_in_bytes = cluster.nodes.stats()['nodes'][self.node_id]['fs']['data'][0]['total_in_bytes']
        self.free_in_bytes = cluster.nodes.stats()['nodes'][self.node_id]['fs']['data'][0]['free_in_bytes']
        self.used_in_bytes = self.total_in_bytes - self.free_in_bytes
        self.indices = []


def get_nodes(cluster):
    node_list = []
    for node in cluster.nodes.stats()['nodes']:
        node_data = cluster.nodes.stats()['nodes'][node]
        if node_data['indices']['docs']['count'] > 0:
            node_info = node_data['fs']['data'][0]
            data_node = DataNode(name=node_data['name'], node_id=node, info=node_info)
            assign_index(cluster, data_node)
            node_list.append(data_node)

    return node_list


def assign_index(cluster, node):
    for index in cluster.cluster.state()['routing_nodes']['nodes'][node.node_id]:
        if index['index'] not in skip_index:
            if index['index'] not in node.indices:
                node.indices.append(index['index'])


def getKey(item):
    return item[0]


def identify_index_for_del(index_list, indices):
    indices_creation = []
    for index in index_list:
        index_tup = (index, indices.index_info[index]['age']['creation_date'])
        indices_creation.append(index_tup)
    index_for_del = sorted(indices_creation, key=getKey)[0][0]
    creation_time = datetime.datetime.utcfromtimestamp(sorted(indices_creation, key=getKey)[0][1])

    return index_for_del, creation_time


def delete_index(cluster, del_index):
    logging.warn("Deleting index %s" % del_index)
    try:
        cluster.indices.delete(index=del_index)
    except Exception:
        logging.error("Can't delete index %s" % del_index)
    sleep(60)  # Allow time for cluster to normalise


def main():
    for cluster in clusters:
        logging.warn("Skip index includes: %s" % skip_index)
        logging.warn("Checking nodes in %s" % cluster['env'])
        env_cluster = Elasticsearch(hosts=cluster['ip'])
        nodes = get_nodes(env_cluster)
        indices = curator.IndexList(env_cluster)

        del_index_lst = []
        for node in nodes:
            if len(node.indices) > 0:
                old_index, index_created = identify_index_for_del(node.indices, indices)
                if old_index in del_index_lst:
                    logging.warn('refreshing data on node %s as disk usage stats may be out of date' % node.name)
                    node.refresh(cluster=env_cluster)
                    assign_index(env_cluster, node)
                if node.used_percentage() > threshold:
                    logging.warn("node %s over quota: %f" % (node.name, node.used_percentage()))
                    logging.warn("indices on %s (%s): %s" % (node.name, node.node_id, node.indices))
                    logging.warn("Oldest index on the node is %s created at %s" % (old_index, index_created))
                    delete_index(env_cluster, old_index)
                    if old_index not in del_index_lst:
                        del_index_lst.append(old_index)
                        logging.warn(del_index_lst)
                    else:
                        logging.error('Index %s already deleted' % old_index)
                else:
                    logging.warn("node %s under quota: %f%%" % (node.name, node.used_percentage()))
            else:
                logging.warn("no indices associated to node %s" % node.name)
        logging.warn('-----------------')


if __name__ == '__main__':
    main()
