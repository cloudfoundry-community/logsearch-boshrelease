# OPS Files for Logsearch deployment
There are a couple of OPS files that would be helpful for your deployments. Please read a short description for each of them. 

## scale-to-one-az.yml
Intended to use for learning purposes. It significantly decreases a number of used  VM's by scaling down to single Availability Zone. Additionaly, it allows to be store data on Master node, which is usually not recommended. Please do not use that in production!

## aws-lb.yml
Registers `ls-router` VMs on AWS Load Balancer. Please note, that LB is have to be created in advance. If you're using [BBL](https://github.com/cloudfoundry/bosh-bootloader) to spin up environment - you can use override files from [bbl](bbl/) directory.

Here are example:

```
$ bbl plan --lb-type concourse

$ cp -r <logsearch-boshrelease path>/deployment/operations/bbl/* .

$ bbl up

$ bosh upload-stemcell https://bosh.io/d/stemcells/bosh-aws-xen-hvm-ubuntu-trusty-go_agent

$ cd <logsearch-boshrelease path>/deployment

$ bosh -d logsearch deploy logsearch-deployment.yml -o operations/aws-lb.yml
```