#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGODB_HOST=mongodb.dawshub.cloud

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

dnf module disable nodejs -y
VALIDATE $? "disable nodejs"

dnf module enable nodejs:18 -y
VALIDATE $? "enable nodejs:18"

id roboshop
if [ $? ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user added "
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir  -p /app
VALIDATE $? "created /app dir"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE $? "downloaded the catalogue application"

cd /app 

unzip  -o /tmp/catalogue.zip
VALIDATE $? "unziped the catalogue application"

npm install 
VALIDATE $? "dependencies installed "

cp Downloads/dop/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? " copying catalogue service"

systemctl daemon-reload
VALIDATE $? "daemon reload"

systemctl enable catalogue
VALIDATE $? "enabled catalogue" 

systemctl start catalogue
VALIDATE $? "started catalogue"

cp Downloads/dop/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copied mongo.repo"

dnf install mongodb-org-shell -y
VALIDATE $? "installation of mongodb-client"

mongo --host $MONGODB_HOST </app/schema/catalogue.js
VALIDATE $? "loading schema"

