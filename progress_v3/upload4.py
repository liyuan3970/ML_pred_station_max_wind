# coding: utf-8
from ftplib import FTP
import time
# !/usr/bin/python
# -*- coding: utf-8 -*-
import tarfile
import os
import time
import datetime
import os
from datetime import datetime, date, timedelta

from ftplib import FTP

yesterday = (date.today() + timedelta(days = -1)).strftime("%Y-%m-%d")    # 昨天日期
today =(date.today()).strftime("%Y-%m-%d") 
year = yesterday[0:4]

month =yesterday[5:7]
day = yesterday[8:10]
day_now = today[8:10]


def ftpconnect(host, username, password):
    ftp = FTP()
    # ftp.set_debuglevel(2)
    ftp.connect(host, 21)
    ftp.login(username, password)
    return ftp

#从ftp下载文件
def downloadfile(ftp, remotepath, localpath):
    bufsize = 1024
    fp = open(localpath, 'wb')
    ftp.retrbinary('RETR ' + remotepath, fp.write, bufsize)
    ftp.set_debuglevel(0)
    fp.close()

#从本地上传文件到ftp
def uploadfile(ftp, remotepath, localpath):
    bufsize = 1024
    fp = open(localpath, 'rb')
    ftp.storbinary('STOR ' + remotepath, fp, bufsize)
    ftp.set_debuglevel(0)
    fp.close()

if __name__ == "__main__":
    ftp = ftpconnect("172.21.129.108", "sxb", "sxb1")
    #downloadfile(ftp, "Faint.mp4", "C:/Users/Administrator/Desktop/test.mp4")
    #调用本地播放器播放下载的视频
    #os.system('start "C:\Program Files\Windows Media Player\wmplayer.exe" "C:/Users/Administrator/Desktop/test.mp4"')
    uploadfile(ftp, '/sxb/YBJS/'+'ZJGRID.331000'+'.'+str(year)+str(month)+str(day_now)+'20'+'.'+'Wind03'+'.nc','/pub/progress/'++'ZJGRID.331000'+'.'+str(year)+str(month)+str(day_now)+'20'+'.'+'Wind03'+'.nc')
    time.sleep(3)
    uploadfile(ftp, '/sxb/YBJS/'+'ZJGRID.331000'+'.'+str(year)+str(month)+str(day_now)+'20'+'.'+'Wind24'+'.nc','/pub/progress/'++'ZJGRID.331000'+'.'+str(year)+str(month)+str(day_now)+'20'+'.'+'Wind24'+'.nc')
    ftp.quit()