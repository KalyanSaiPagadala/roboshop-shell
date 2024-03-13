#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MYSQL_HOST=mysql.dawshub.cloud

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

dnf install maven -y
VALIDATE $? "installing maven"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "adding roboshop user"
else
    echo -e "roboshop user is already exist $Y Skipping $N"
fi

mkdir /app
VALIDATE $? "addiing the /app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip
VALIDATE $? "downloading the shipping code"

cd /app

unzip -o /tmp/shipping.zip
VALIDATE $? "unzipping the shipping code"

mvn clean package
VALIDATE $? "installing clean packages maven"

mv target/shipping-1.0.jar shipping.jar
VALIDATE $? "installing the jar file"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "installing maven"

systemctl daemon-reload
VALIDATE $? "daemon-reloading"

systemctl enable shipping 
VALIDATE $? "enabling shipping"

systemctl start shipping
VALIDATE $? "starting shipping"

dnf install mysql -y
VALIDATE $? "installing mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/schema/shipping.sql 
VALIDATE $? "setting up the root password"

systemctl restart shipping
VALIDATE $? "restarting shipping"