import schedule
import time
import datetime
import os
from datetime import datetime, date, timedelta
import paramiko
import xarray as xr
import numpy as np
import os, logging, pdb
from nmc_met_io.read_micaps import  read_micaps_4

down_time ='05:00'
yesterday = (date.today() + timedelta(days = -1)).strftime("%Y-%m-%d")    # 昨天日期
today =(date.today()).strftime("%Y-%m-%d") 
year = yesterday[2:4]
month =yesterday[5:7]
day = yesterday[8:10]
file_path ='io.ncl'
line_num = 6 # 更改文件中第六行（时间）的
Contents = "date = "+'"'+str(year)+str(month)+str(day)+'"'







filename = str(year)+str(month)+str(day)+'.nc'




#download_path =''      # 指明被遍历的文件夹
def search(download_path,s):

    l = []
 
    #三个参数：分别返回1.父目录 2.所有文件夹名字（不含路径） 3.所有文件名字
    for parent, dirnames, filenames in os.walk(download_path):
         for filename in filenames:      # 输出文件信息
            # print "filename is:" + filename
            if filename.find(s) != -1:
                #print("the full path of the file is:" + os.path.abspath(os.path.join(parent,filename))) # 输出文件路径信息
                l.append(os.path.abspath(os.path.join(parent,filename)))
    return l

def read_m4(file):
    data = read_micaps_4(file)
    print(type(data))
    lat = data.lat.data
    lon = data.lon.data
    lat_start = list(np.where(lat ==26))[0][0]
    lat_end = list(np.where(lat ==32))[0][0]
    lon_start = list(np.where(lon ==117))[0][0]
    lon_end = list(np.where(lon ==124))[0][0]
    # 获取浙江数据 
    data_zj = data.data[:,lat_start:lat_end,lon_start:lon_end]
    return data_zj


def download():
    '''下载必要的数据'''
    #print("Job4:每天06:00自动下载前一天20时向后预报一天的M4 10米风数据")
    #os.system('java -jar GDSJavaClient.jar 10.135.29.64 8080 samba ECMWF_HR/10_METRE_WIND_GUST_IN_THE_LAST_3_HOURS'+' '+year+month+day+'20.027'+' '+year+month+day+'20.048'+' '+'diamond')
    #time.sleep(5)
    #os.system('java -jar GDSJavaClient.jar 10.135.29.64 8080 samba ECMWF_HR/UGRD_10M'+' '+year+month+day+'20.027'+' '+year+month+day+'20.048'+' '+'diamond')
    #time.sleep(5)
    #os.system('java -jar GDSJavaClient.jar 10.135.29.64 8080 samba ECMWF_HR/VGRD_10M'+' '+year+month+day+'20.027'+' '+year+month+day+'20.048'+' '+'diamond')
    #time.sleep(5)


    '''批量读取数据'''   
    download_path_max_wind = '/home/liyuan3970/ML_pred_station_max_wind/progress_v3/samba/ECMWF_HR/10_METRE_WIND_GUST_IN_THE_LAST_3_HOURS/'
    file_day = search(download_path_max_wind,year+month+day)
    file_day.sort()
    file_zj = []
    for file in file_day:
        d_zj=read_m4(file)
        file_zj.append(d_zj)
    print("search is ok")
    data =xr.concat(file_zj,dim='time')
    data.to_netcdf("fytest.nc")



    '''更改ncl文件的时间'''
    with open(file_path,"r") as f:
        res = f.readlines() #res 为列表
    res[line_num-1]=(Contents+"\n")  #删除行，因为索引是从 0 开始的，所以需要  -1
    with open(file_path,"w") as f:
        f.write("".join(res))  #将 res 转换为 字符串重写写入到文本
        f.close()
    time.sleep(20)
    #return
    '''运行ncl文件'''
    #os.system("ncl io.ncl")
    #time.sleep(20)
    #print('job finshed------------------------------------------------------------------------')









if __name__ == '__main__':
    print("主程序",Contents,type(Contents),today)
    download()



