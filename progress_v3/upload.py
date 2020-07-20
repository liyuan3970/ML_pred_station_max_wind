# coding:utf8
import schedule
import time
import datetime
import os
from datetime import datetime, date, timedelta
import paramiko

yesterday = (date.today() + timedelta(days = -1)).strftime("%Y-%m-%d")    # 昨天日期
today =(date.today()).strftime("%Y-%m-%d") 
year = yesterday[0:4]

month =yesterday[5:7]
day = yesterday[8:10]
day_now = today[8:10]
 
transport = paramiko.Transport(("172.21.129.108", 22))    # 获取Transport实例
transport.connect(username="sxb", password="sxb1")    # 建立连接
 
# 创建sftp对象，SFTPClient是定义怎么传输文件、怎么交互文件
sftp = paramiko.SFTPClient.from_transport(transport)
 
# 将本地 api.py 上传至服务器 /www/test.py。文件上传并重命名为test.py
sftp.put("/home/liyuan3970/ML_pred_station_max_wind/progress_v3/upload/"+str(year)+str(month)+str(day)+".nc", '/sxb/YBJS/'+'ZJGRID.331000'+'.'+str(year)+str(month)+str(day_now)+'20'+'.'+'Wind03'+'.nc')
 
# 将服务器 /www/test.py 下载到本地 aaa.py。文件下载并重命名为aaa.py
#sftp.get("/www/test.py", "E:/test/aaa.py")
 
# 关闭连接
transport.close()