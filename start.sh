#!/bin/bash

stop_requested=false
trap "stop_requested=true" TERM INT

wait_signal() {
    while ! $stop_requested; do
        sleep 1
    done
}

wait_exit() {
    while pidof $1; do
        sleep 1
    done
}

chown -R www-data:www-data /var/www/

if [ ! -d /data/.ssh ]; then
    mkdir /data/.ssh
    touch /data/.ssh/authorized_keys
    chmod 600 /data/.ssh/authorized_keys*
fi

if [ ! -d /data/git ]; then
    mkdir /data/git
fi

if [ ! -d /data/apache_logs ]; then
    mkdir /data/apache_logs
fi

if [ ! -s /etc/apache2/magic ]; then
    cp -r /etc/apache2-orig/* /etc/apache2/
fi

service ssh start
service apache2 restart
service cron start

wait_signal

echo "Try to exit properly"
service apache2 stop
service cron stop
service ssh stop

wait_exit "apache2 cron sshd"
