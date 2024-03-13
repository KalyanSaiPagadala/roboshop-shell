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

dnf install maven -y &>> $LOGFILE
VALIDATE $? "installing maven"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "adding roboshop user"
else
    echo -e "roboshop user is already exist $Y Skipping $N"
fi

mkdir /app &>> $LOGFILE
VALIDATE $? "addiing the /app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "downloading the shipping code"

cd /app

unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "unzipping the shipping code"

mvn clean package &>> $LOGFILE
VALIDATE $? "installing clean packages maven"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "installing the jar file"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "installing maven"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon-reloading"

systemctl enable shipping  &>> $LOGFILE
VALIDATE $? "enabling shipping"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "starting shipping"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "installing mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? "setting up the root password"

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "restarting shipping"