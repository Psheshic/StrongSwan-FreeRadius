# Установка Freeradius с web-интерфейсом Daloradius
> Рекомендую брать команды [отсюдова](https://github.com/Psheshic/StrongSwan-FreeRadius/blob/main/Installation%20FreeRadius.sh), чтобы все было норм. Здесь инструкция с картинками :)

ㅤ

## Установка FreeRadius и MariaDB

Устанавливаем и запускаем Apache и MariaDB

    sudo  apt-get  update  -y
    
    sudo  apt  install  apache2  -y
    
    sudo  systemctl  start  apache2
    
    sudo  systemctl  enable  apache2
    
    sudo  apt  install  software-properties-common  mariadb-server  mariadb-client  -y
    
    sudo  systemctl  start  mysql
    
    sudo  systemctl  enable  mysql

Устанавливаем пароль и везде отвечаем **Y**

    sudo  mysql_secure_installation


Проеверяем, все ли работает

    sudo  systemctl  status  mariadb

Добавляем репозиторий с пхп

    sudo  add-apt-repository  ppa:ondrej/php
    
    sudo  apt  update  -y

Устанавливаем PHP 5.6 и все, что необходимо для работы FreeRadius и Daloradius

    sudo  apt  install  php5.6  libapache2-mod-php5.6  php5.6-gd  php5.6-mysql  php5.6-xml  php5.6-xml  php5.6-mbstring  php5.6-curl  -y
    
    sudo  apt  install  php-mail  php-mail-mime  php-pear  php-db  -y
    
    sudo  pear  install  DB

  

Проверяем версию PHP, пока что должна быть **5.6**

    php  -v

Рестартуем апач

    sudo  systemctl  restart  apache2

Устанавливаем FreRadius

    sudo  apt-get  install  freeradius  freeradius-mysql  freeradius-utils  -y

Создаем таблицу для FreeRadius

    sudo  mysql  -u  root  -p



    CREATE  DATABASE  freeradiusdb;
    
    GRANT  ALL  ON  freeradiusdb.*  TO  freeradiususer@localhost  IDENTIFIED  BY  "RadiusDatabasePassword";
    
    FLUSH  PRIVILEGES;
    
    quit;

![enter image description here](https://adamtheautomator.com/wp-content/uploads/2022/04/image-218.png)
 ㅤ
 ㅤ
 
Останавливаем FreeRadius, проверяем

    sudo  systemctl  stop  freeradius
    
    sudo  systemctl  status  freeradius
![enter image description here](https://adamtheautomator.com/wp-content/uploads/2022/04/image-220.png)
ㅤ
ㅤ
Добавляем схемы из радиуса в БД

    sudo  -i
    
    mysql  -u  root  -p  freeradiusdb  <  /etc/freeradius/3.0/mods-config/sql/main/mysql/schema.sql
    
    exit
    
    cd

Добавляем ссылку

    sudo  ln  -s  /etc/freeradius/3.0/mods-available/sql  /etc/freeradius/3.0/mods-enabled/


Проверяем, что все добавилось

    mysqlshow  freeradiusdb
![enter image description here](https://adamtheautomator.com/wp-content/uploads/2022/04/image-222.png)
  
  ㅤ
  ㅤ
Открываем конфиг для работы с MySQL БД

    sudo  nano  /etc/freeradius/3.0/mods-available/sql

Меняем следующие параметры:

    sql  {
    
    dialect  =  "mysql"
    
    #driver = "rlm_sql_null"
    
    driver  =  "rlm_sql_${dialect}"
![enter image description here](https://adamtheautomator.com/wp-content/uploads/2022/04/image-223.png)
ㅤ
ㅤ

Комментим строчки связанные с TLS:

    # If any of the files below are set, TLS encryption is enabled
    
    # tls {
    
    # ca_file = "/etc/ssl/certs/my_ca.crt"
    
    # ca_path = "/etc/ssl/certs/"
    
    # certificate_file = "/etc/ssl/certs/private/client.crt"
    
    # private_key_file = "/etc/ssl/certs/private/client.key"
    
    # cipher = "DHE-RSA-AES256-SHA:AES128-SHA"
    
      
    
    # tls_required = yes
    
    # tls_check_cert = no
    
    # tls_check_cert_cn = no
    
    # }
![enter image description here](https://adamtheautomator.com/wp-content/uploads/2022/04/image-224.png)
  ㅤ
  ㅤ

Доходим до **`# Connection info`**, изменяем:

    server  =  "localhost"
    
    port  =  3306
    
    login  =  "freeradiususer"
    
    password  =  "RadiusDatabasePassword"

  
Ниже меняем название на нашу БД

    radius_db  =  "freeradiusdb"
![enter image description here](https://adamtheautomator.com/wp-content/uploads/2022/04/image-225.png)
  
  ㅤ
  ㅤ
Еще ниже находим и раскомментируем строку:

    read_clients  =  yes

 ![enter image description here](https://adamtheautomator.com/wp-content/uploads/2022/04/image-226.png)

ㅤ
ㅤ
Активируем MySQL модуль FreeRADIUS

    sudo  ln  -s  /etc/freeradius/3.0/mods-available/sql  /etc/freeradius/3.0/mods-enabled/

Меняем права

    sudo  chown  -h  freerad.freerad  /etc/freeradius/3.0/mods-enabled/sql

  

Стартуем радиус

    sudo  systemctl  start  freeradius

  

Проверяем радиус, должен быть active (running). В противном случае что-то пошло не так.

    sudo  systemctl  status  freeradius
    
![enter image description here](https://adamtheautomator.com/wp-content/uploads/2022/04/image-227.png)
  ㅤ
  ㅤ
  ㅤ
### Установка Daloradius

  
Переходим: 

    cd  /var/www/html

  

Скачиваем Daloradius, разархивируем и переименовываем

    wget  https://github.com/lirantal/daloradius/archive/refs/tags/1.3.tar.gz
    
    tar  -xf  1.3.tar.gz
    
    mv  daloradius-1.3  daloradius

  

Проверяем, все ли правильно

    ls
    
![enter image description here](https://adamtheautomator.com/wp-content/uploads/2022/04/image-228.png)
ㅤ
ㅤ

Импортируем схему Daloradius в БД

    mysql  -u  root  -p  freeradiusdb  <  /var/www/html/daloradius/contrib/db/fr2-mysql-daloradius-and-freeradius.sql

  

Проверяем, добавились ли новые таблицы

    mysqlshow  freeradiusdb
    
![enter image description here](https://adamtheautomator.com/wp-content/uploads/2022/04/image-229.png)
  ㅤ
  ㅤ
  

Копируем конфигурацию Daloradius в ***`/var/www/html/daloradius/library/daloradius.conf.php`***

    cp  /var/www/html/daloradius/library/daloradius.conf.php.sample  /var/www/html/daloradius/library/daloradius.conf.php

  
  
  

Открываем конфиг Daloradius и меняем следующие значения:

    $configValues['CONFIG_DB_USER']  =  'freeradiususer';
    
    $configValues['CONFIG_DB_PASS']  =  'RadiusDatabasePassword';
    
    $configValues['CONFIG_DB_NAME']  =  'freeradiusdb';
   
![enter image description here](https://adamtheautomator.com/wp-content/uploads/2022/04/image-230.png)

ㅤ
ㅤ
Выдаем необходимые права

    sudo  chown  -R  www-data:www-data  /var/www/html/daloradius/
    
    sudo  chmod  0664  /var/www/html/daloradius/library/daloradius.conf.php

  

Ну и рестартуем FreeRadius

    sudo  systemctl  restart  freeradius

  

Далее можно сразу добавить сервак, который будет пользоваться Radius аутентификацией

    sudo  nano  /etc/freeradius/3.0/clients.conf

  

Находим строки ниже:

    # client private-network-1 {
    # ipaddr = 192.0.2.0/24
    # secret = testing123-1
    #}

  

 И сразу после них добавляем наш сервер, как на примере:

    client  Strongswan  {
    ipaddr  =  172.0.0.0
    secret  =  testing123
    }

  

### Готово! Осталось настроить только сам серв, который будет использовать аутентификацию.

ㅤ

## Установка StrongSwan VPN

Скачиваем скрипт с Git

    sudo wget https://raw.githubusercontent.com/Psheshic/StrongSwan-FreeRadius/main/Custom_StrongSwan.sh

Даем права на исполнение 

    sudo chmod +x Custom_Strongswan.sh

Запускаем 

    sudo ./Custom_Strongswan.sh

Далее необходимо заполнить данные для подключения стандартного пользователя **VPN**


| | |
|--|--|
|Hostname for VPN: |  domainpshe.com|
|VPN username: |  VPNuser|
|VPN password (no quotes, please): |VPNpassword|
|Timezone (default: Europe/London):|Europe/Moscow|
| | |


После скрипт предложит создать нового SSH пользователя, этот шаг **нельзя** пропускать, далее нужно будет использовать именно этого юзера. **Под стандартным мы залогиниться уже не сможем!**
Когда скрипт предложит скопировать ключ на нового пользователя - соглашаемся.

Проверяем, точно ли нормально скопировался ключ:

    sudo su
    nano /home/newsshuser/.ssh/authorized_keys
Должна быть только одна строка как на примере:

    ssh-ed25519 AAAAG0Y1OFGVKHIU5OOOOIGAeHerMoRZHoviU1Tsdgsd41EFDgDtG+Kam1NaD1eM4lmF47 UserKey
Рекомендую сразу перелогиниться, дабы проверить, нормально ли создался новый SSH юзер

ㅤ
ㅤ
## Настраиваем подключение StrongSwan'а к FreeRadius'у

### Включаем плагин аутентификации в конфиге `strongswan.conf`

    sudo nano /etc/strongswan.conf

И приводим его в вот такой вид по примеру: 


    charon {
      filelog {
        charon {
          path = /var/log/charon.log
          time_format = %b %e %T
          ike_name = yes
          append = no
          default = 2
          flush_line = yes
        }
        stderr {
          ike = 2
          knl = 3
        }
      }
    
            load_modular = yes
            plugins {
    
                     include strongswan.d/charon/*.conf
                eap-radius {
          servers {
            server-a {
              address = 172.1.1.1
              auth_port = 1812   # default
              acct_port = 1813   # default
              secret = testing123
          # nas_identifier = ipsec-gateway
        }
      }
        }
            }
    }
    
    include strongswan.d/*.conf


Где `address = 172.1.1.1`  -- адрес нашего Radius сервера

А `secret = testing123` -- секрет, который мы указали в настройках `clients.conf` при конфигурации **Radius** сервера

> Включение плагина **filelog** просто для удобства работы в будущем.

ㅤ
ㅤ
ㅤ
### Включаем плагин `eap-radius` в конфиге `swanctl.conf`

    sudo nano /etc/swanctl/swanctl.conf

И в конце, после строки `include conf.d/*.conf` прописываем: 

    connections.roadwarrior.remote.auth = eap-radius

Где ***roadwarrior*** -- название нашего соединения по умолчанию. 
ㅤ
ㅤ
ㅤ
 ### Включаем плагин `eap-radius` в конфиге `swanctl.conf`

Находим строку `rightauth=` и прописываем: 

    rightauth=eap-radius

Перезапускаем `ipsec`

    sudo ipsec restart

ㅤ
### Готово! Теперь наш StrongSwan сервер будет Radius для аутентификации пользователей VPN.
ㅤ


## Добавление пользователей в веб-интерфейсе Daloradius
ㅤ
В браузере открываем:

    http://172.1.1.1/daloradius
Где `172.1.1.1` -- адрес нашего FreeRadius сервера 

![enter image description here](https://adamtheautomator.com/wp-content/uploads/2022/04/image-231.png)

Стандартный пароль от  Daloradius -- **radius**

> Рекомендую сразу изменить пароль на более сложный по пути --  http://172.1.1.1/daloradius/config-operators-list.php

ㅤ
ㅤ

Переходим по пути `http://172.1.1.1/daloradius/mng-new.php`

И создаем пользователя заполняя первые два поля:

![enter image description here](https://adamtheautomator.com/wp-content/uploads/2022/04/image-233.png)

ㅤ

Сразу проверим работоспособность только созданного пользователя

Переходим по пути `http://172.1.1.1/daloradius/mng-list-all.php`, жмякаем на пользователя и `edit user`:

![enter image description here](https://adamtheautomator.com/wp-content/uploads/2022/04/image-234.png)


ㅤ

Кликаем на **Test Connectivity**

![enter image description here](https://adamtheautomator.com/wp-content/uploads/2022/04/image-235.png)

ㅤ
Нажимаем на **Perform Test** и должны увидеть подобный результат: 

![enter image description here](https://adamtheautomator.com/wp-content/uploads/2022/04/image-236.png)



### Поздравляю! Вы только что настроили StrongSwan, FreeRadius и DaloRadius. Можете переходить к использованию серверваков.
