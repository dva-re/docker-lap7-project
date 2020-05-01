FROM fastsol/lap-project
MAINTAINER fastsol

RUN apt-get update && \
apt-get install php-xdebug -y --allow-unauthenticated && \
apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y && \
rm -rf /var/cache/debconf/*-old && rm -rf /var/lib/apt/lists/* && rm -rf /usr/share/doc/*