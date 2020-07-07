import schedule
import time
import datetime
import os
from datetime import datetime, date, timedelta



down_time ='05:00'
yesterday = (date.today() + timedelta(days = -1)).strftime("%Y-%m-%d")    # 昨天日期
year = yesterday[2:4]
month =yesterday[5:7]
day = yesterday[8:10]


del_time = '06:50'
file_path ='io.ncl'
line_num = 6
Contents = "date = "+'"'+str(year)+str(month)+str(day)+'"'


run_time = '07:00'



up_time = '15:50'
ip = "192.168.8.135"
port = 22
name ="liyuan3970"
password = "123456"
local_path = '/home/liyuan3970/test_demo/time/'
remote_path = '/home/liyuan3970/demo/'
filename ='a.txt'
remote_file_name='b.txt'

def download():
    '''处理时间函数'''
    print("Job4:每天06:00自动下载前一天20时向后预报一天的M4 10米风数据")
    os.system('java -jar GDSJavaClient.jar 10.135.29.64 8080 samba ECMWF_HR/10_METRE_WIND_GUST_IN_THE_LAST_3_HOURS'+' '+year+month+day+'20.027'+' '+year+month+day+'20.048'+' '+'diamond')
    time.sleep(20)
    print('job finshed------------------------------------------------------------------------')



def Del_line(): #file_path:文件名；line_num：行号；Contents：修改后的内容
    with open(file_path,"r") as f:
        res = f.readlines() #res 为列表
    res[line_num-1]=(Contents+"\n")  #删除行，因为索引是从 0 开始的，所以需要  -1
    with open(file_path,"w") as f:
        f.write("".join(res))  #将 res 转换为 字符串重写写入到文本
    return
#Del_line("test.ncl",2,"wwwwwwww") #将第二行修改为 wwwwwwww



def run_ncl():
    os.system("ncl io.ncl")
    time.sleep(20)
    print('ncl finshed------------------------------------------------------------------------')




def upload():
    transport = paramiko.Transport((ip, port))    # 获取Transport实例
    transport.connect(username=name, password=password)    # 建立连接
    # 创建sftp对象，SFTPClient是定义怎么传输文件、怎么交互文件
    sftp = paramiko.SFTPClient.from_transport(transport)
    # 将本地 a.txt 上传至服务器 /www/test.py。文件上传并重命名为b.txt
    sftp.put(local_path+filename, remote_path+remote_file_name)
    # 关闭连接
    transport.close()




if __name__ == '__main__':
    print("主程序",Contents,type(Contents))

    schedule.every().day.at(down_time).do(download)
    schedule.every().day.at(del_time).do(Del_line)
    schedule.every().day.at(run_time).do(run_ncl)
    schedule.every().day.at(up_time).do(upload)    
    while True:
        schedule.run_pending()
