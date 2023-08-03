sudo apt-get update -y


sudo apt install apache2 -y

sudo systemctl start apache2
sudo systemctl enable apache2



sudo apt install software-properties-common mariadb-server mariadb-client -y

sudo systemctl start mysql
sudo systemctl enable mysql

# Ставим свой пароль и везде отвечаем Y
sudo mysql_secure_installation 

# Проеверяем, все ли работает
sudo systemctl status mariadb 


# Добавляем репозиторий с пхп
sudo add-apt-repository ppa:ondrej/php 

sudo apt update -y



sudo apt install php5.6 libapache2-mod-php5.6 php5.6-gd php5.6-mysql php5.6-xml php5.6-xml php5.6-mbstring php5.6-curl  -y

sudo apt install php-mail php-mail-mime php-pear php-db -y

sudo pear install DB

# Проверяем версию PHP, пока что должна быть 5.6
php -v 


# Рестартуем апач
sudo systemctl restart apache2 



sudo apt-get install freeradius freeradius-mysql freeradius-utils -y

# Проверяем
sudo freeradius -X 


# Создаем таблицу для FreeRadius
sudo mysql -u root -p

    CREATE DATABASE freeradiusdb;
    GRANT ALL ON freeradiusdb.* TO freeradiususer@localhost IDENTIFIED BY "RadiusDatabasePassword";
    FLUSH PRIVILEGES;
    quit;


# Останавливаем Радиус
sudo systemctl stop freeradius
# На всякий проверяем, точно ли остановился
sudo systemctl status freeradius 


# Добавляем схемы из радиуса в БД
sudo -i
mysql -u root -p freeradiusdb < /etc/freeradius/3.0/mods-config/sql/main/mysql/schema.sql
exit
cd



sudo ln -s /etc/freeradius/3.0/mods-available/sql /etc/freeradius/3.0/mods-enabled/

# Проверяем, что все добавилось
mysqlshow freeradiusdb 


# Открываем конфиг для работы с MySQL БД
sudo nano /etc/freeradius/3.0/mods-available/sql

# Меняем следующие параметры: 
            sql {
			    dialect = "mysql"
			
			    #driver = "rlm_sql_null"
			    driver = "rlm_sql_${dialect}"

# Комментим строчки связанные с TLS: 
                # If any of the files below are set, TLS encryption is enabled
                #tls {
                #       ca_file = "/etc/ssl/certs/my_ca.crt"
                #       ca_path = "/etc/ssl/certs/"
                #       certificate_file = "/etc/ssl/certs/private/client.crt"
                #       private_key_file = "/etc/ssl/certs/private/client.key"
                #       cipher = "DHE-RSA-AES256-SHA:AES128-SHA"

                #       tls_required = yes
                #       tls_check_cert = no
                #       tls_check_cert_cn = no
                #}

# Доходим до # Connection info изменяем:
                server = "localhost"
                port = 3306
                login = "freeradiususer"
                password = "RadiusDatabasePassword"

                radius_db = "freeradiusdb"

# Ниже находим и раскоментируем строку:
                read_clients = yes



# Активируем MySQL модуль FreeRADIUS
sudo ln -s /etc/freeradius/3.0/mods-available/sql /etc/freeradius/3.0/mods-enabled/

# Меняем права
sudo chown -h freerad.freerad /etc/freeradius/3.0/mods-enabled/sql

# Стартуем радиус
sudo systemctl start freeradius

# Проверяем радиус, должен быть active (running). В противном случае что-то пошло не так.
sudo systemctl status freeradius




# Установка Daloradius

cd /var/www/html

# Скачиваем Daloradius, разархивируем и переименовываем
wget https://github.com/lirantal/daloradius/archive/refs/tags/1.3.tar.gz
tar -xf 1.3.tar.gz
mv daloradius-1.3 daloradius

# Проверяем, все ли правильно 
ls



# Импортируем схему Daloradius в БД
mysql -u root -p freeradiusdb < /var/www/html/daloradius/contrib/db/fr2-mysql-daloradius-and-freeradius.sql

# Проверяем, добавились ли новые таблицы
mysqlshow freeradiusdb

# Копируем конфигурацию Daloradius в /var/www/html/daloradius/library/daloradius.conf.php
cp /var/www/html/daloradius/library/daloradius.conf.php.sample /var/www/html/daloradius/library/daloradius.conf.php



# Открываем конфиг Daloradius и меняем следующие значения:
            $configValues['CONFIG_DB_USER'] = 'freeradiususer';
            $configValues['CONFIG_DB_PASS'] = 'RadiusDatabasePassword';
            $configValues['CONFIG_DB_NAME'] = 'freeradiusdb';



# Выдаем необходимые права
sudo chown -R www-data:www-data /var/www/html/daloradius/
sudo chmod 0664 /var/www/html/daloradius/library/daloradius.conf.php

# Ну и рестартуем FreeRadius
sudo systemctl restart freeradius

# Далее можно сразу добавить сервак, который будет пользоваться Radius аутентификацией 
sudo nano /etc/freeradius/3.0/clients.conf

# Находим строки ниже:
            #client private-network-1 {
            #       ipaddr          = 192.0.2.0/24
            #       secret          = testing123-1
            #}

# И сразу после них добавляем наш сервер, как на примере:
            client Strongswan {
                    ipaddr = 172.0.0.0
                    secret = testing123
            }

# Готово, осталось настроить только серв, который будет использовать аутентификацию
