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

dnf install nginx -y  &>> $LOGFILE
VALIDATE $? "installing Nginx"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "enabling Nginx"

systemctl start nginx  
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "removing the default content"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "downloading the frontend content"

cd /usr/share/nginx/html &>> $LOGFILE
VALIDATE $? "moving to nginx html"

unzip -o /tmp/web.zip &>> $LOGFILE
VALIDATE $? "extracting the content"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
VALIDATE $? "copying the reverse proxy config"

systemctl restart nginx &>> $LOGFILE 
VALIDATE $? "restarting the NGINX"
