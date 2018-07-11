export DEBIAN_FRONTEND=noninteractive

echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' >> /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get -y update

# Install Basics: Utilities and some Python dev tools
sudo apt-get -y install build-essential git vim curl wget unzip postgresql-10

# listen for localhost connections
POSTGRE_VERSION=10
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/$POSTGRE_VERSION/main/postgresql.conf

# identify users via "md5", rather than "ident", allowing us to make postgres
# users separate from system users. "md5" lets us simply use a password
echo "host    all             all             0.0.0.0/0               md5" | sudo tee -a /etc/postgresql/$POSTGRE_VERSION/main/pg_hba.conf
sudo service postgresql start

# create new user "root" with defined password "root" not a superuser
PASSWORD=password
sudo -u postgres psql -c "CREATE ROLE root LOGIN ENCRYPTED PASSWORD '$PASSWORD' SUPERUSER CREATEDB CREATEROLE INHERIT;"

# create new database "database"
sudo -u postgres psql -c "CREATE DATABASE database"

sudo service postgresql restart
