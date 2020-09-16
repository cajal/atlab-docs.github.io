FROM python:slim-buster

RUN apt-get update && apt-get install python3-sphinx -y
RUN pip3 install sphinx-rtd-theme --no-cache

WORKDIR /src