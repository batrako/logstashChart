# Logstash Helm Chart

This functionality is developed by Iván Alvarez.

This helm chart is a lightweight way to configure and run  official [Logstash docker image](https://www.elastic.co/guide/en/logstash/current/docker.html)

## Requirements

* [Helm](https://helm.sh/) >= 2.8.0
* Kubernetes 1.8/1.9/1.10/1.11.
* Minimum cluster requirements include the following to run this chart with default settings. All of these settings are configurable.
  * Three Kubernetes nodes to respect the default "hard" affinity settings or use "soft" inestead.
  * 1GB of RAM for the JVM heap

## Usage notes and getting started
* This repo includes a number of [example](./examples) configurations which can be used as a reference. They are also used in the automated testing of this chart

* The default storage class  is `standard`. This is network attached storage and will not perform as well as local storage. If you are using Kubernetes version 1.10 or greater you can use [Local PersistentVolumes](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/local-ssd) for increased performance
* The chart deploys a statefulset and by default will do an automated rolling update of your cluster. It does this by waiting for the cluster health to become green after each instance is updated. If you prefer to update manually you can set [`updateStrategy: OnDelete`](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#on-delete)
* It is important to verify that the JVM heap size in `esJavaOpts` and to set the CPU/Memory `resources` to something suitable for your cluster

* We have designed this chart to be very un-opinionated about how to configure Logstash. It exposes ways to set environment variables and mount secrets inside of the container. Doing this makes it much easier for this chart to support multiple versions with minimal changes.

## Installing

* `helm package logstash`
* `helm upgrade --wait --timeout=600 --install --values your_values_file.yml charts/logstash-1.0.0.tgz`

## Configuration

| Parameter                 | Description                                                                                                                                                                                                                                                                                                                | Default                                                                                                                   |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |

| `clusterName`             | This will be used as the Logstash identifier                      | `logstash`                                                                                                           |
| `nodePort`             | Enable or disable external access to elasticsearch. The name of servise exposed               will be `es-env-idegar-svc`             | `enabled`
| `environment`             | 3 chars environment code (dev/pre/pro)              | `dev`
| `replicas`              | Kubernetes replica count for the statefulset (i.e. how many pods)    | `1`
| `configReloadAutomatic`              | Logstash default config type. If `configReloadAutomatic` is enabled, Logstash try load pipeline when pipeline config files are updated    | `true`
| `extraEnvs`               | Extra [environment variables](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/#using-environment-variables-inside-of-your-config) which will be appended to the `env:` definition for the container                                                                         | `{}`                                                                                                                      |
| `secretMounts`            | Allows you easily mount a secret as a file inside the statefulset. Useful for mounting certificates and other secrets. See [values.yaml](./values.yaml) for an example                                                                                                                                                     | `{}`                                                                                                                      |
| `image`                   | The Elasticsearch docker image                                                                                                                                                                                                                                                                                             | `docker.elastic.co/elasticsearch/elasticsearch`                                                                           |
| `imageTag`                | The Elasticsearch docker image tag                                                                                                                                                                                                                                                                                         | `6.5.3`                                                                                                                   |
| `imagePullPolicy`         | The Kubernetes [imagePullPolicy](https://kubernetes.io/docs/concepts/containers/images/#updating-images) value                                                                                                                                                                                                             | `IfNotPresent`                                                                                                            |
| `lsJavaOpts`              | Java options for Logstash. This is where you should configure the jvm heap size                                                                | `-Xmx1g -Xms1g`                                                                                                           |
| `resources`               | Allows you to set the [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) for the statefulset                                                                                                                                                                               | `requests.cpu: 100m`<br>`requests.memory: 2Gi`<br>`limits.cpu: 1000m`<br>`limits.memory: 2Gi`                             |
| `networkHost`             | Value for the [network.host Logstash setting](https://www.elastic.co/guide/en/elasticsearch/reference/current/network.host.html)                                                                                                                                                                                      | `0.0.0.0`                                                                                       
| `antiAffinityTopologyKey` | The [anti-affinity topology key](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity). By default this will prevent multiple Elasticsearch nodes from running on the same Kubernetes node                                                                                        | `kubernetes.io/hostname`                                                                                                  |
| `antiAffinity`            | Setting this to hard enforces the [anti-affinity rules](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity). If it is set to soft it will be done "best effort"                                                                                                                 | `hard`                                                                                                                    |
| `podManagementPolicy`     | By default Kubernetes [deploys statefulsets serially](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#pod-management-policies). This deploys them in parralel so that they can discover eachother                                                                                                   | `Parallel`                                                                                                                |
| `protocol`                | The protocol that will be used for the readinessProbe.                                                                                                                                             | `http`                                                                                                                    |
| `httpPort`                | The http port that Kubernetes will use for the healthchecks and the service. If you change this you will also need to set [http.port](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-http.html#_settings_2) in `extraEnvs`                                                                        | `9200`                                                                                                                    |
| `updateStrategy`          | The [updateStrategy](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/#updating-statefulsets) for the statefulset. By default Kubernetes will wait for the cluster to be green after upgrading each pod. Setting this to `OnDelete` will allow you to manually delete each pod during upgrades | `RollingUpdate`                                                                                                           |
| `maxUnavailable`          | The [maxUnavailable](https://kubernetes.io/docs/tasks/run-application/configure-pdb/#specifying-a-poddisruptionbudget) value for the pod disruption budget. By default this will prevent Kubernetes from having more than 1 unhealthy pod in the node group                                                                | `1`                                                                                                                       |
| `fsGroup`                 | The Group ID (GID) for [securityContext.fsGroup](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) so that the Elasticsearch user can read from the persistent volume                                                                                                                            | `1000`                                                                                                                    |
| `terminationGracePeriod`  | The [terminationGracePeriod](https://kubernetes.io/docs/concepts/workloads/pods/pod/#termination-of-pods) in seconds used when trying to stop the pod                                                                                                                                                                      | `120`                                                                                                                     |
| `readinessProbe`          | Configuration for the [readinessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)                                                                                                                                                                                      | `failureThreshold: 3`<br>`initialDelaySeconds: 10`<br>`periodSeconds: 10`<br>`successThreshold: 3`<br>`timeoutSeconds: 5` |
| `imagePullSecrets`        | Configuration for [imagePullSecrets](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-pod-that-uses-your-secret) so that you can use a private registry for your image                                                                                                       | `[]`                                                                                                                      |
| `nodeSelector`            | Configurable [nodeSelector](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector) so that you can target specific nodes for your Elasticsearch cluster                                                                                                                                          | `{}`                                                                                                                      |
| `tolerations`             | Configurable [tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/)                                                                                                                                                                                                                        | `[]`                                                                                                                      |
| `ingress`                 | Configurable [ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) to expose the Elasticsearch service. See [`values.yaml`](./values.yaml) for an example                                                                                                                                            | `enabled: false`                                                                                                          |

## Try it out

In [examples/](./examples/logstash) you will find some example configurations. These examples are used for the automated testing of this helm chart

### tiny

To deploy a cluster with one logstash node.

```
cd examples/logstash/tiny
make 
```

To remove cluster

```
cd examples/logstash/tiny
make clean 
```


### Security

A Logstash deployment with X-Pack security enabled

* Deploy!
  ```
  cd examples/logstash/security
  make
  ```

* Purge

```
cd examples/logstash/security
make clean 
```

### Minikube

In order to properly support the required persistent volume claims for the Logstash `StatefulSet`, the `default-storageclass` and `storage-provisioner` minikube addons must be enabled.

```
minikube addons enable default-storageclass
minikube addons enable storage-provisioner
```

Note that if `helm` or `kubectl` timeouts occur, you may consider creating a minikube VM with more CPU cores or memory allocated.

