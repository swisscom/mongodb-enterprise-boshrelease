# BOSH Release for MongoDB Enterprise

This repo is a [BOSH](https://bosh.io) release for deploying MongoDB Enterprise](https://www.mongodb.com/). It requires an existing [OpsManager](https://www.mongodb.com/de/products/ops-manager) instalation.

VMs deployed with this BOSH release will download and run the latest automation agent version found on OpsManager.
If a specific version is required it can specified in the deployment manifest under `mms-automation-agent.version`.
You find the apropriate version information in your OpsManager installation under `Deployments / Agents / Downloads & Settings`. Select `Other Linux - TAR` and copy the version string.

##### Example:
Release specified in OpsManager: 

```
mongodb-mms-automation-agent-3.2.11.2025-1.linux_x86_64
```

Version string: 

```
3.2.11.2025-1
```

Please read [this wiki page](https://github.com/swisscom/mongodb-enterprise-boshrelease/wiki/Consul-Integration) about the consul integration.

## Usage

To use this bosh release, first upload it to your bosh:

```
bosh target BOSH_HOST
git clone https://gitgub.com/swisscom/mongodb-enterprise-boshrelease.git
cd mongodb-enterprise-boshrelease
bosh upload release releases/mongodb-enterprise-1.0.0.yml
```

For [bosh-lite](https://github.com/cloudfoundry/bosh-lite), you can quickly create a deployment by using the existing example manifests located in `templates`.


### Development

As a developer of this release, create new releases and upload them:

```
bosh create release && bosh -n upload release
```

### Final releases

To share final releases:

```
bosh create release --final
```

By default the version number will be bumped to the next major number. You can specify alternate versions:


```
bosh create release --final --version 1.0.0 --with-tarball
```

