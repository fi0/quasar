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
sudo -u postgres psql -c "CREATE ROLE root LOGIN ENCRYPTED PASSWORD '$PASSWORD' NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;"

# create new database "database"
sudo -u postgres psql -c "CREATE DATABASE database"

sudo service postgresql restart

# Install MySQL
sudo debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password password password'
sudo debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password_again password password'
sudo apt-get -y install mysql-server-5.7

# Set Timezone (Server/MySQL)
sudo ln -sf /usr/share/zoneinfo/UTC /etc/localtime
sudo mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql --user=root --password=password mysql

# Allow connections from outside the vagrant box
sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
echo "Updated bind address to accept connections from all hosts"

mysql -uroot -ppassword -e "GRANT ALL ON *.* to 'root'@'%' identified by 'password';"
mysql -uroot -ppassword -e "FLUSH PRIVILEGES;"
echo "[mysqld]" > /etc/mysql/conf.d/quasar.cnf
echo "sql-mode=\"NO_ENGINE_SUBSTITUTION\"" >> /etc/mysql/conf.d/quasar.cnf
sudo /etc/init.d/mysql restart

MIGRATIONS=/vagrant/data/sql/migrations/*
for file in $MIGRATIONS
do
    mysql -uroot -ppassword < $file
done
