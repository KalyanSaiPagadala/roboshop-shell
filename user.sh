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
VALIDATE $? "disabling nodejs"

dnf module enable nodejs:18 -y
VALIDATE $? "enabling nodejs:18"

dnf install nodejs -y
VALIDATE $? "installing nodejs"

id roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop
    VALIDATE $? "adding roboshop user"
else 
    echo -e "roboshop user alredy exit .....$Y Skipping $N"
fi

mkdir -p /app
VALIDATE $? "creating /app directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip
VALIDATE $? "downloading user app code"

cd /app

unzip -o /tmp/user.zip
VALIDATE $? "unzipping the user code"

npm install 
VALIDATE $? "installing dependencies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service
VALIDATE $? "copied the user service"

systemctl daemon-reload
VALIDATE $? "daemon reloding "

systemctl enable user 
VALIDATE $? "enabling user"

systemctl start user
VALIDATE $? "starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "coping mongo repo"

dnf install mongodb-org-shell -y
VALIDATE $? "installing mongodb client"

mongo --host $MONGODB_HOST </app/schema/user.js
VALIDATE $? "loading schema"

