# Logsearch

A scalable stack of [Elasticsearch](http://www.elasticsearch.org/overview/elasticsearch/),
[Logstash](http://www.elasticsearch.org/overview/logstash/), and
[Kibana](http://www.elasticsearch.org/overview/kibana/) for your
own [BOSH](http://docs.cloudfoundry.org/bosh/)-managed infrastructure.

## BREAKING CHANGES

Logsearch < v23.0.0 was based on Elasticsearch 1.x and Kibana 3.

Logsearch > v200 is based on Elasticsearch 2.x and Kibana 4.

There is NO upgrade path from Elasticsearch 1.x to 2.x.  Sorry :(

Logsearch > v204.0.0 is based on Elasticsearch 5.x and Kibana 5.

For upgrade procedure from Elasticsearch 2.x please refer to [v205.0.0 release notes](https://github.com/cloudfoundry-community/logsearch-boshrelease/releases/tag/v205.0.0#component-updates).

## Getting Started

This repo contains Logsearch Core; which deploys an ELK cluster that can receive and parse logs via syslog
that contain JSON.

Most users will want to combine Logsearch Core with a Logsearch Addon to customise their cluster for a
particular type of logs.  Its likely you want to be following an Addon installation guides - see below
for a list of the common Addons:

  * [Logsearch for CloudFoundry](https://github.com/cloudfoundry-community/logsearch-for-cloudfoundry)


## Installing Logsearch Core
   
Before starting deployment, make sure your BOSH environment is ready, and all `BOSH_` evironment variables are set. We suggest you to use [BBL](https://github.com/cloudfoundry/bosh-bootloader) tool to spin up the BOSH environment.

```
$ cd deployment
$ bosh -d logsearch deploy logsearch-deployment.yml
```
## Common customisations:

0. Adding new parsing rules:

        logstash_parser:
          filters: |
             # Put your additional Logstash filter config here, eg:
             json {
                source => "@message"
                remove_field => ["@message"]
             }


### Release Channels

 * The latest stable, final release will be soon available on [bosh.io](http://bosh.io/releases)
 * **develop** - The develop branch in this repo is deployed to our test environments.  It is occasionally broken - use with care!

## Known issues

#### VMs lose connectivity to each other after VM recreation (eg. instance type upgrade)

While this issue is not specific to this boshrelease, it is worth noting.

On certain IAAS'es, (AWS confirmed), the bosh-agent fails to flush the ARP cache of the VMs in the deployment which, in rare cases, results in VMs not being able to communicate with each other after some of them has been recreated. The symptoms of when this happens are varied depending on the affected VMs. It could be anything from HAproxy reporting it couldn't find any backends (eg. Kibana) or the parsers failing to connect to the queue.

To prevent stale ARP entries, set the `director.flush_arp` property of your BOSH deployment to `true`.

The issue, if occurs, should fix itself as the kernel updates incomplete ARP entries, which **should** happen within minutes

This can also be done manually if an immediate manual fix is preferred. This should be done on the VMs that are trying to talk to the VM that has been recreated.

```
arp -d $recreated_vm_ip
```

## License

[Apache License 2.0](./LICENSE)
