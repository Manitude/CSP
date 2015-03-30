for vhost in `sudo -E -u rabbitmq -H /bin/sh -c 'rabbitmqctl -q list_vhosts'`; do sudo -E -u rabbitmq -H /bin/sh -c 'rabbitmqctl list_queues -p $vhost'; done
