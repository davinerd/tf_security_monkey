#!/bin/bash

DBUSER="${db_user}"
DBPASSWD="${db_passwd}"
DBNAME="${db_name}"
DBHOSTNAME="${db_hostname}"
FQDN="${fqdn}"

CONFIG_FILE="/usr/local/src/security_monkey/env-config/config.py"

sed -i "/SQLALCHEMY_DATABASE_URI/c\SQLALCHEMY_DATABASE_URI = 'postgresql://$DBUSER:$DBPASSWD@$DBHOSTNAME:5432/$DBNAME'" $CONFIG_FILE
sed -i "/FQDN =/c\FQDN = '$FQDN'" $CONFIG_FILE

if [ "${sso_enabled}" -eq 1 ]; then
  sed -i "/ACTIVE_PROVIDERS =/c\ACTIVE_PROVIDERS = [\"google\"]" $CONFIG_FILE
  sed -i "/GOOGLE_CLIENT_ID =/c\GOOGLE_CLIENT_ID = '${client_id}'" $CONFIG_FILE
  sed -i "/GOOGLE_AUTH_ENDPOINT =/c\GOOGLE_AUTH_ENDPOINT = '${auth_endpoint}'" $CONFIG_FILE
  sed -i "/GOOGLE_SECRET =/c\GOOGLE_SECRET = '${g_secret}'" $CONFIG_FILE
fi

cp /usr/local/src/security_monkey/supervisor/security_monkey_ui.conf /etc/supervisor/conf.d/security_monkey_ui.conf

cp /usr/local/src/security_monkey/nginx/security_monkey.conf /etc/nginx/sites-available/security_monkey.conf
ln -s /etc/nginx/sites-available/security_monkey.conf /etc/nginx/sites-enabled/security_monkey.conf
rm /etc/nginx/sites-enabled/default

systemctl restart nginx
systemctl restart supervisor

# redoing since it seems like permissions get reset
chown -R ubuntu:www-data /var/log/security_monkey/
chown www-data:www-data /var/log/security_monkey/securitymonkey.log

cd /usr/local/src/security_monkey
./venv/bin/python /usr/local/src/security_monkey/venv/bin/monkey db upgrade
