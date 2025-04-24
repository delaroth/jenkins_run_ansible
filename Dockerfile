
FROM python:3.9-slim


RUN apt-get update && apt-get install -y openssh-client && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir ansible python-consul


WORKDIR /home/jenkins/agent/workspace
