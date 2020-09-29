FROM debian:buster-slim
MAINTAINER fastsol

ADD start.sh /root/start.sh

RUN apt-get update && \
apt-get install apache2 wget git-core curl locales locales-all openssl openssh-server nano cron apt-transport-https lsb-release ca-certificates pbzip2 libzip4 unzip ghostscript poppler-utils -y --allow-unauthenticated && \
systemctl enable apache2 && \
echo "SetEnv PROJECT_RUN_MODE production" >> /etc/apache2/apache2.conf && \
echo "PROJECT_RUN_MODE=production" >> /etc/environment && \
sed -i 's|^ServerTokens.*|ServerTokens Prod|' /etc/apache2/conf-available/security.conf && \
sed -i 's|^ServerSignature.*|ServerSignature Off|' /etc/apache2/conf-available/security.conf && \
ln -s /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled/headers.load && \
ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load && \
ln -s /etc/apache2/mods-available/socache_shmcb.load /etc/apache2/mods-enabled/socache_shmcb.load && \
ln -s /etc/apache2/mods-available/ssl.conf /etc/apache2/mods-enabled/ssl.conf && \
ln -s /etc/apache2/mods-available/ssl.load /etc/apache2/mods-enabled/ssl.load && \
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
apt-get update && apt-get install php7.4 php7.4-common php7.4-apcu php7.4-curl php7.4-gd php7.4-imagick php7.4-json php7.4-mbstring php7.4-mysql php7.4-readline php7.4-soap php7.4-xml php7.4-zip php7.4-redis php7.4-intl php7.4-sqlite3 php7.4-bcmath -y && \
sed -i 's|^short_open_tag.*|short_open_tag = On|' /etc/php/7.4/apache2/php.ini && \
sed -i 's|^max_execution_time.*|max_execution_time = 300|' /etc/php/7.4/apache2/php.ini && \
sed -i 's|^max_input_time.*|max_input_time = 600|' /etc/php/7.4/apache2/php.ini && \
sed -i 's|^error_reporting.*|error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_NOTICE \& ~E_STRICT|' /etc/php/7.4/apache2/php.ini && \
sed -i 's|^;date.timezone.*|date.timezone = Europe/Moscow|' /etc/php/7.4/apache2/php.ini && \
sed -i 's|^short_open_tag.*|short_open_tag = On|' /etc/php/7.4/cli/php.ini && \
sed -i 's|^;error_log.*|error_log = /var/log/php_cli_errors.log|' /etc/php/7.4/cli/php.ini && \
sed -i 's|^error_reporting.*|error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_NOTICE \& ~E_STRICT|' /etc/php/7.4/cli/php.ini && \
sed -i 's|^;date.timezone.*|date.timezone = Europe/Moscow|' /etc/php/7.4/cli/php.ini && \
echo "apc.shm_size=64M" >> /etc/php/7.4/mods-available/apcu.ini && \
ln -snf /usr/share/zoneinfo/Europe/Moscow /etc/localtime && echo "Europe/Moscow" > /etc/timezone && \
echo -e 'LANG="ru_RU.UTF-8"\nLANGUAGE="ru_RU.UTF-8"\n' > /etc/default/locale && sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && dpkg-reconfigure --frontend=noninteractive locales && \
mv /etc/apache2 /etc/apache2-orig && rm -f /etc/ssh/sshd_config && \
apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y && \
rm -rf /var/cache/debconf/*-old && rm -rf /var/lib/apt/lists/* && rm -rf /usr/share/doc/*

ADD apache2-prefork.conf /etc/apache2-orig/mods-available/mpm_prefork.conf
ADD sshd_config /etc/ssh/sshd_config

RUN chmod +x /root/start.sh
CMD ["/bin/bash", "/root/start.sh"]

VOLUME ["/var/www", "/etc/apache2", "/data"]
EXPOSE 80 22
