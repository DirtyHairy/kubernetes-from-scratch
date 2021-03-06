# What is this?

This is the infrastructure and material for my talk "Kubernetes from Scratch".
It gives you two VMs that are provisioned to work as a lab for setting up
a simple Kubernetes cluster with two nodes.

# Prerequesites

The VMs are based on Debian Bullseye and are managed with Vagrant. I am using
an Apple Silicon Mac, so the `Vagrantfile` is written for Parallels and uses a
custom built arm64 Bullseye box, but you should be able to swap in any other
provider and (Bullseye) box at your leasure. However, **do not change** the
IPs that are assigned to the hostonly interfaces without changing the cluster
configuration accordingly.

The VMs are provisioned with Ansible. The corresponding `playbook.yaml` is set
up to install all required dependencies (and a few more for convenience) and
prepares the nodes for following through the steps of this talk. Again, the
playbook pulls in the arm64 versions of all packages, but you should be able
to apply this to any other architecture by changing the `arch` variable.

For the talk I ssh into the machines with `vagrant ssh`, `sudo bash` to root
and then run everything inside a `tmux` session for convenience. Also, I `source`
the shell scripts (rather than executing them) as a convenient way to have
the name of the daemon in the tmux tab. I source the  `setup.sh` script on order
to access the cluster with `kubectl` running on the host.

# WARNING

This is a lab for experimenting with Kubernetes. All configuration has been
chosen to be a simple as possible, not to be suited for production. In particular,
the cluster does not have any security configured, everything has full permissions
to mess with everything else.

**DO NOT EVEN THINK OF USING THIS FOR PRODUCTION.**

# Kubernetes from scratch

## 1. The foundation: container runtime & kubelet

### Setup docker as the container runtime

Start `cri-dockerd`:

```
    $ source /vagrant/script/cri-dockerd.sh
```

### Lauch kubelet

Copy kubelet config:

```
    $ cp /vagrant/config/kubelet-config.yaml /etc/kubernetes
```

Launch `kubelet`:

```
    $ source /vagrant/script/kubelet-bare.sh
```

### Static pods

Copy nginx manifest:

```
    $ cp /vagrant/manifests/pod-nginx.yaml /etc/kubernetes/manifests
```


Delete manifest again:

```
    $ rm /etc/kubernetes/manifests/pod-nginx.yaml
```

## 2. The backbone: API server and etcd

### Setup etcd

Launch `etcd`:

```
    $ source /vagrant/script/etcd
```

### Launch kube-apiserver

Launch `kube-apiserver`

```
    $ source /vagrant/script/apiserver.sh
```

Relaunch `kubelet` with kubeconfig:

```
    $ source /vagrant/script/kubelet.sh
```

### Deploy and inspect a pod

Deploy pod manifest (pinned to node as we have no scheduler yet):

```
    $ kubectl apply -f manifests/pod-nginx-pinned.yaml
```

## 3. The brains: scheduler & controller-manager

### Launch the scheduler

Launch the `kube-scheduler`:

```
    $ source /vagrant/script/scheduler.sh
```

### Pod revisited: dynamic scheduling

Deploy the (non-pinned pod manifest):

```
    $ kubectl apply -f manifests/pod-nginx.yaml
```

Remove the `NoSchedule` taint from node manually (as we don't have `controller-manager`
running yet):

```
    $ kubectl taint node kube-control-plane node.kubernetes.io/not-ready:NoSchedule-
```

### Let's scale: the controller-manager

Remove the pod and deploy the deployment manifest:

```
    $ kubectl apply -f manifests/deployment-nginx.yaml
```

Launch `controller-manager`:

```
    $ source /vagrant/script/controller-manager.sh
```

## 4. Intercom

### Services and kube-proxy

Deploy the ClusterIP service:

```
    $ kubectl -f manifests/service-nginx-clusterip.yaml
```

Launch the kube proxy:

```
    $ source /vagrant/script/kube-proxy.sh
```

### ClusterIP

With the proxy running nginx is now reachable with curl on the service cluster IP.
Check iptables (NAT table) to see how connections to the cluster IP are resolved
using DNAT.

### NodePort

Deploy the NodePort service:

```
    $ kubectl -f manifests/service-nginx-nodeport.yaml
```

Nginx is now reachable from the host on port 30001 (on the node). Check iptables
(NAT) to see how connections to the node port are resolved using DNAT.

## 5. Misery loves company: another node

### Launch cri-dockerd, kubelet and proxy

See above.

### Scale to two nodes

Scale nginx to two replicas:

```
    $ kubectl scale deployment nginx --replicas 2
```

Show that each node is now running a pod / docker container, and that nginx can be
reached on each node on port `30001`.

## 6. Cluster networking

### Houston, our service is broken!

Scale nginx back to one replica:

```
    $ kubectl scale deployment nginx --replicas 1
```

Observe how the service is not reachable anymore on one node. Check iptables and
show the root cause of the problem: the node port is DNATed to the pod's IP, which
is not reachable anymore from the broken node.

Explain how Kubernetes expects all pods to reside on a cluster-wide network on which
they are reachable on any node, and how CNI plugins are responsible of achieving
this during pod creation.

### Setup an overlay network with Flannel

Remove deployment and service, shutdown kubelet, `cri-dockerd` and the proxy on each
node.

Write the flanneld config to etcd:

```
    $ source /vagrant/script/etcd-flannel-config.sh
```

On each node, launch flanneld and restart the services:

```
    $ source /vagrant/script/flanneld.sh
    $ source /vagrant/script/cri-dockerd-cni.sh
    $ source /vagrant/script/kubelet.sh
    $ source /vagrant/script/proxy.sh
```

### All is well again: seamless networking over two nodes

Redeploy deployment and service. Demonstrate how the pods now get IPs on the `10.2.0.0/16`
subnet, and how each node can ping those IPs. Show how a single pod can now be reached via
the node port on every node.

## 7. Is there anybody out there? Service discovery & Cluster DNS

### Setup CoreDNS

Shutdown `kubelet` on each node, augment the kubelet config with `clusterDNS` and restart
`kuebelt`. Deploy the coredns manifest into the cluster.

### DNS entries for pods and services

Demonstrate how both `www.google.de` and `nginx.default.svc.cluster.local` can now be resolved
over `10.1.1.2`. Demonstrate how `kubelet` now configures name resolution inside the pods to
use coredns running on the cluster.

# Credits

* https://www.ulam.io/blog/kubernetes-scratch
* https://github.com/kelseyhightower/kubernetes-the-hard-way
