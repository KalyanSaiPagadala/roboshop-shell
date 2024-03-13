#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

dnf install python36 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "installing python 3.6 "

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user added "
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app  &>> $LOGFILE
VALIDATE $? "creating app directory "

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "downloading the payment app"

cd /app 

unzip -o /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "unzipping the payment app"

pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "installing dependencies"

cp /home/centos/rboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "coping the payment service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon reloading "

systemctl enable payment &>> $LOGFILE
VALIDATE $? "enabling payment "

systemctl start payment &>> $LOGFILE
VALIDATE $? "starting payment "