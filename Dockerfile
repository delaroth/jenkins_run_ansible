
FROM jenkins/jenkins:lts


ARG DOCKER_HOST_GID=999 # Default GID if not provided by docker-compose


USER root


RUN apt-get update && apt-get install -y \
    ansible \
    python3-consul \
    docker.io \
    ca-certificates \
    gnupg \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*


RUN groupadd -g ${DOCKER_HOST_GID} docker || true

RUN usermod -aG docker jenkins

USER jenkins
