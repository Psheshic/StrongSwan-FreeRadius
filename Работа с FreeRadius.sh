sudo apt-get update -y


sudo apt install apache2 -y


sudo systemctl start apache2
sudo systemctl enable apache2



sudo apt install software-properties-common mariadb-server mariadb-client -y


sudo systemctl start mysql
sudo systemctl enable mysql



sudo mysql_secure_installation # Ставим свой пароль и везде отвечаем Y


sudo systemctl status mariadb # Проеверяем, все ли работает

# ctrl-C

sudo add-apt-repository ppa:ondrej/php # Добавляем репозиторий с пхп


sudo apt update -y


sudo apt install php5.6 libapache2-mod-php5.6 php5.6-gd php5.6-mysql php5.6-xml php5.6-xml php5.6-mbstring php5.6-curl  -y

sudo apt install php-mail php-mail-mime php-pear php-db -y


# sudo apt install php8.0 libapache2-mod-php8.0

# sudo apt install php-gd php-mail php-mail-mime php-mysql php-xml php8.0-xml php-pear php-db php-mbstring php-curl # Накатываем PHP 8.0 и все необходимые модули

php -v

sudo pear install DB

sudo systemctl restart apache2 # Рестартуем апач



sudo apt-get install freeradius freeradius-mysql freeradius-utils -y

sudo freeradius -X # Проверяем



sudo mysql -u root -p

CREATE DATABASE radius;
GRANT ALL ON radius.* TO radius@localhost IDENTIFIED BY "Qwerty1"; # Создаем таблицу для FreeRadius
FLUSH PRIVILEGES;
quit;



sudo -i
mysql -u root -p radius < /etc/freeradius/3.0/mods-config/sql/main/mysql/schema.sql # Добавляем схемы из радиуса в таблицы
exit
cd


sudo ln -s /etc/freeradius/3.0/mods-available/sql /etc/freeradius/3.0/mods-enabled/



sudo chgrp -h freerad /etc/freeradius/3.0/mods-available/sql
sudo chown -R freerad:freerad /etc/freeradius/3.0/mods-enabled/sql



sudo ufw allow to any port 1812 proto udp
sudo ufw allow to any port 1813 proto udp # Открываем необходимые порты



sudo apt install unzip


wget https://github.com/lirantal/daloradius/archive/refs/tags/1.1-2.zip # Скачиваем и устанавливаем DoloRadius

unzip 1.1-2.zip

sudo mv daloradius-1.1-2 /var/www/html/daloradius


cd /var/www/html/daloradius

sudo mysql -u root -p radius< contrib/db/fr2-mysql-daloradius-and-freeradius.sql

sudo mysql -u root -p radius< contrib/db/mysql-daloradius.sql



cd /var/www/html/daloradius/library/ # Изменяем разрешения необходимых каталогов и вытаскиваем файл конфигурации

sudo mv daloradius.conf.php.sample daloradius.conf.php

sudo chown -R www-data:www-data /var/www/html/daloradius/

sudo chmod 664 /var/www/html/daloradius/library/daloradius.conf.php



sudo nano /var/www/html/daloradius/library/daloradius.conf.php # Редактируем файл конфигурации


$configValues['CONFIG_DB_USER'] = 'radius';
$configValues['CONFIG_DB_PASS'] = 'Qwerty1';
$configValues['CONFIG_DB_NAME'] = 'radius';


sudo systemctl restart freeradius
sudo systemctl restart apache2




# Переходим на вебморду http://IPADRESS/daloradius/login.php
# username: administrator
# password: radius


E: Unable to locate package php5.6-mail
E: Couldn't find any package by glob 'php5.6-mail'
E: Unable to locate package php5.6-mail-mime
E: Couldn't find any package by glob 'php5.6-mail-mime'
E: Unable to locate package php5.6-pear
E: Couldn't find any package by glob 'php5.6-pear'
E: Unable to locate package php5.6-db
E: Couldn't find any package by glob 'php5.6-db'
ubuntu@ip-172-31-8-171:~$ sudo apt find php db


sudo apt install php5.6 libapache2-mod-php5.6

sudo apt install php5.6-gd php5.6-mysql php5.6-xml php5.6-xml php5.6-mbstring php5.6-curl

sudo apt install php-mail php-mail-mime php-pear php-db