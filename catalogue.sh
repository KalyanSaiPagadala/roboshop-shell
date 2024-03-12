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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "disable nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "enable nodejs:18"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "installing  nodejs:18" 

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user added "
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir  -p /app
VALIDATE $? "created /app dir"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "downloaded the catalogue application"

cd /app 

unzip  -o /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "unziped the catalogue application"


npm install  &>> $LOGFILE
VALIDATE $? "dependencies installed "

cp /Users/saikalyan/Downloads/dop/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service 
VALIDATE $? " copying catalogue service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon reload"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "enabled catalogue" 

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "started catalogue"

cp Downloads/dop/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copied mongo.repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "installation of mongodb-client"

mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "loading schema"

