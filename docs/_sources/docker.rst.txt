======
Docker
======

Prerequisites
-------------

 - DockerHub account: https://hub.docker.com/

Why Use Docker
--------------

Often times a code packages has various unique dependencies that it requires to operate. If it was 
just one or two code packages then it wouldn't be a much a problem, but typically orginizations have hundreds of different code packages, all with their own specific requirements.

Naturally the questions arises, how can I run my code without screwing over someone else stuff on a machine that is not mine, like a shared a server.

The solution for this in the old days was to run a virtual machine that provided an virtual enviorment for each code package to run it, allowing it not to effect anything on the host systems
or fellow virutal machine instances. This however, has one glaring issue which is that the emulation of hardware done by virtual machines tends to be very expensive and not scable in the long run.

Docker solves this problem by only emulation what is needed, AKA the software packages and etc. and not the entire system like with virtual machines, thus making it a lot cheaper to run.

Installing Docker
-----------------
https://docs.docker.com/install/linux/docker-ce/ubuntu/

Docker Terminology
------------------

- Container: A self-containe enviorment for the user application to run in.

- DockerFile: An instruction file on how to build Docker Image

- DockerImage: A built copy of the Docker container, tend to be uploaded to DockerHub and downloaded to run stuff. Could also be used as a base for a new docker file

- DockerImage Tag: This is a name for the docker image, typically define during the build command, and is used to uniquely identify an image when uploaded to DockerHub

- DockerHub: A free docker image repository that allows users to host 1 free private image, and unlimited public images.

Writing a DockerFile
---------------------

Typically one never really write a docker file from scratch, instead we select a base docker image to build off, then add commands additional libaries that we need.
The commands typically used are very similar if not the same we for the Linux base system.

**Note: Due to the fact that we use Kuberenetes along with docker, the general recommendation is to build the docker file with only public libaries. All private code will be handle at run time via Kuberenetes.**

.. code-block:: DockerFile
    :linenos:

    FROM nvidia/cuda:10.0-runtime-ubuntu18.04 # Base Ubuntu Docker Image that we are building off of
    LABEL maintainer="Synicix"

    # Ubuntu OS Requirements
    RUN apt-get -y update
    RUN apt-get install python3-pip -y
    RUN python3 -m pip install --upgrade pip
    RUN apt-get -y install git

    # OpenCV2 dependencies
    RUN apt-get install -y libsm6 libxext6 libxrender-dev

    # Install python dependices
    RUN pip3 install h5py opencv-python seaborn pandas scipy imageio imageio-ffmpeg datajoint

    # Pytorch
    RUN pip3 install torch torchvision

    # Apex FP16 pytorch libaray
    RUN pip3 install git+https://www.github.com/nvidia/apex


Building a DockerFile
---------------------
To build a DockerFile:

- make sure the file is name DockerFile
- cd to the directory containing
- run docker build command with the approrate tag: 

**(In this case <dockerhub username>/<image-tag-name>)**

.. code-block:: DockerFile
    :linenos:

    docker build . -t synicix/pytorch-fp16-base


Uploading the Built Docker Image to DockerHub
---------------------------------------------
After building the docker image, we need to uploaded to DockerHub so it will be avaliable to any computer that has a connection to DockerHub (Currently the image is only the machine that built it)

To do so, we must first make sure that we are logged in on the docker machine that built the image via:

.. code-block:: DockerFile
    :linenos:

    docker login

Once we confirm that we have logged in successfully, the next step is to push our build image into DockerHub by running the following command with the correct image tag name:

.. code-block:: DockerFile
    :linenos:

    docker push synicix/pytorch-fp16-base

After image is pushed successfully, it should show up on DockerHub under your account like as such:

.. image:: images/docker_hub_image_example.png
    :align: center

This means now the image is avaliable publically and any computer with a connection to DockerHub can download the image an launch it,
which is intergral part for deploying jobs to Kuberenetes.