#!/bin/bash
set -e 
set -x

/usr/bin/mysqld_safe > /dev/null 2>&1 &

set +x
echo "Waiting for mysqld to start"
RET=1
while [[ RET -ne 0 ]]; do
	sleep 5
	mysql -uroot -e "status" > /dev/null 2>&1
	RET=$?
done
set -x

mysql -uroot <<- EOF
	CREATE USER 'admin'@'%' IDENTIFIED BY 'admin';
	GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION
EOF

mysqladmin -uroot shutdown

# Configure the database to use our data dir.
sed -i "s|datadir.*=.*|datadir = $DATA_DIR|g" /etc/mysql/my.cnf
# Configure the database to accept connections from any IP
sed -i "s|bind-address.*=.*|bind-address = 0.0.0.0|g" /etc/mysql/my.cnf

chown -R mysql:mysql $DATA_DIR 
