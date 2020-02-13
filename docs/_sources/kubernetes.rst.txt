==========
Kubernetes
==========

Prerequisites
-------------

 - Datajoint
 - Docker


Introduction
------------

Typically docker works great for small scale applications, such as deploying to your own personal machine, however often times there is a need to massively scale up which creates a problem.
Docker by itself is a bit clucky to deploy to mutiple machines, thus at Google they develop a tool call Kubernetes, a container orchsertration solution.

Kubernetes is basically a giant system that handles scheduling, deploying, and managing many containers from many users with different requirements. 
With this a single user can easily scale up their applications to use all the resources avliable on the cluster with only a .yaml file and a one line command.


Setup Your Account
------------------

Before starting, please message Daniel Sitonic on slack to get an K8 account, he will create an account for you on master node of the cluster which is at-kubemaster1.

Upon your account creation, you will be able ssh in and being using K8

K8 Terminology

- Cluster: A group of machines networked together with kubernetes consistent of a least one master node and a number of worker nodes
- Nodes: A machine or virtual machine with compute resources (CPUs, Mem, GPUs, Storage)
- Pods: A K8 environment that encapsulate a container that specifies the requirements of running container such as number of GPUs, memory, volumes to be mounted, etc.
- Containers: (Docker in this case)