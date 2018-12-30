sudo mkdir /var/log/security_monkey

if ! [ -d /var/www ]; then
  sudo mkdir /var/www
fi

sudo chown -R `whoami`:www-data /var/log/security_monkey/
sudo chmod 775 /var/log/security_monkey/
sudo chown www-data /var/www

git clone https://github.com/Netflix/security_monkey.git
# for some reason failing in cloning the repo does not trigger
# packer stop&cleanup routine. Since the whole thing is useless
# without repo, we force the termination of the provisioner with the following
# 3 lines
if [ $? -ne 0 ]; then
  exit 1
fi

sudo mv security_monkey /usr/local/src/

sudo chown -R `whoami`:www-data /usr/local/src/security_monkey
cd /usr/local/src/security_monkey
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
virtualenv venv
source venv/bin/activate
pip install --upgrade setuptools
pip install --upgrade pip
pip install --upgrade urllib3[secure]   # to prevent InsecurePlatformWarning

python setup.py develop

# Get the Google Linux package signing key.
curl https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

# Set up the location of the stable repository.
cd ~
curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > dart_stable.list
sudo mv dart_stable.list /etc/apt/sources.list.d/dart_stable.list
sudo apt-get update
sudo apt-get install -y dart=1.24.* --allow-unauthenticated

# Modify the config file
secret_key=`openssl rand -base64 16`
password_salt=`openssl rand -base64 16`
sed -i "/SECRET_KEY =/c\SECRET_KEY = '$secret_key'" /usr/local/src/security_monkey/env-config/config.py
sed -i "/SECURITY_PASSWORD_SALT =/c\SECURITY_PASSWORD_SALT = '$password_salt'" /usr/local/src/security_monkey/env-config/config.py
# Change the default port just in case
sed -i "/API_PORT =/c\API_PORT = '$API_PORT'" /usr/local/src/security_monkey/env-config/config.py

# Build the Web UI
cd /usr/local/src/security_monkey/dart
/usr/lib/dart/bin/pub get
/usr/lib/dart/bin/pub build

# Copy the compiled Web UI to the appropriate destination
sudo mkdir -p /usr/local/src/security_monkey/static/
sudo /bin/cp -R /usr/local/src/security_monkey/dart/build/web/* /usr/local/src/security_monkey/static/
sudo chgrp -R www-data /usr/local/src/security_monkey

# Generate self signed certificate for webui
CERT_PASSWD=`openssl rand -base64 16`
openssl genrsa -aes128 -passout pass:$CERT_PASSWD -out server.pass.key 2048
openssl rsa -passin pass:$CERT_PASSWD -in server.pass.key -out server.key

rm server.pass.key

openssl req -new -key server.key -out server.csr \
  -subj "/C=US/ST=California/L=California/O=DB/OU=Security/CN=DB.net"

openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

sudo mv server.crt /etc/ssl/certs
sudo mv server.key /etc/ssl/private

sudo chown root.root /etc/ssl/private/server.key
sudo chmod 660 /etc/ssl/private/server.key

if [ "$API_PORT" ]; then
  sudo sed -i "s/5000/$API_PORT/g" /etc/nginx/sites-available/security_monkey.conf
fi

sudo systemctl enable supervisor
