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
VALIDATE $? "disabling nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "enabling nodejs:18"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "installing nodejs"

id roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop
    VALIDATE $? "adding roboshop user"
else 
    echo -e "roboshop user alredy exit .....$Y Skipping $N"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "creating /app directory"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "downloading cart app code"

cd /app

unzip -o /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "unzipping the cart code"

npm install &>> $LOGFILE
VALIDATE $? "installing dependencies"

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? "copied the user service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon reloding "

systemctl enable cart  &>> $LOGFILE
VALIDATE $? "enabling cart"

systemctl start cart &>> $LOGFILE
VALIDATE $? "starting cart"