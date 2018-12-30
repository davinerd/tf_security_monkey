#!/bin/bash

DBUSER="${db_user}"
DBPASSWD="${db_passwd}"
DBNAME="${db_name}"
DBHOSTNAME="${db_hostname}"
REDISHOSTNAME="${redis_hostname}"

CONFIG_FILE="/usr/local/src/security_monkey/env-config/config.py"

sed -i "/SQLALCHEMY_DATABASE_URI/c\SQLALCHEMY_DATABASE_URI = 'postgresql://$DBUSER:$DBPASSWD@$DBHOSTNAME:5432/$DBNAME'" /usr/local/src/security_monkey/env-config/config.py
sed -i "s/localhost/$REDISHOSTNAME/g" /usr/local/src/security_monkey/security_monkey/celeryconfig.py

cp /usr/local/src/security_monkey/supervisor/security_monkey_scheduler.conf /etc/supervisor/conf.d/security_monkey_scheduler.conf

# configuring SES (eventually...)
sed -i "/SES_REGION =/c\SES_REGION = '${ses_region}'" $CONFIG_FILE
if ! [[ "${ses_mail_from}" == "void@email.no" ]]; then
  sed -i "/MAIL_DEFAULT_SENDER =/c\MAIL_DEFAULT_SENDER = '${ses_mail_from}'" $CONFIG_FILE
fi

systemctl restart supervisor

# redoing since it seems like permissions get reset
chown -R ubuntu:www-data /var/log/security_monkey/
chown www-data:www-data /var/log/security_monkey/securitymonkey.log
chmod 644 /var/log/security_monkey/securitymonkey.log
