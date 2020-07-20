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
day_now = today[8:10]
# 修改ncl文件的位置
file_path ='/home/liyuan3970/ML_pred_station_max_wind/progress_v3/io_new.ncl'
line_num = 6 # 更改文件中第六行（时间）的
Contents = "date = "+'"'+str(year)+str(month)+str(day)+'"'

line_num2 = 7 # 更改文件中第六行（时间）的
Contents2 = "today = "+'"'+str(year)+str(month)+str(day_now)+'"'





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
    os.system('java -jar GDSJavaClient.jar 10.135.29.64 8080 samba ECMWF_HR/10_METRE_WIND_GUST_IN_THE_LAST_3_HOURS'+' '+year+month+day+'20.027'+' '+year+month+day+'20.048'+' '+'diamond')
    time.sleep(5)
    os.system('java -jar GDSJavaClient.jar 10.135.29.64 8080 samba ECMWF_HR/UGRD_10M'+' '+year+month+day+'20.027'+' '+year+month+day+'20.048'+' '+'diamond')
    time.sleep(5)
    os.system('java -jar GDSJavaClient.jar 10.135.29.64 8080 samba ECMWF_HR/VGRD_10M'+' '+year+month+day+'20.027'+' '+year+month+day+'20.048'+' '+'diamond')
    #time.sleep(5)


    '''处理极大风速'''   
    download_path_max_wind = '/home/liyuan3970/ML_pred_station_max_wind/progress_v3/samba/ECMWF_HR/10_METRE_WIND_GUST_IN_THE_LAST_3_HOURS/'
    save_max_path = '/home/liyuan3970/ML_pred_station_max_wind/progress_v3/nc_data/max/'
    file_day_max = search(download_path_max_wind,year+month+day)
    file_day_max.sort()
    print(file_day_max)
    file_zj_max = []
    for file in file_day_max:
        d_zj_max=read_m4(file)
        file_zj_max.append(d_zj_max)
    print("search max is ok")
    data_max =xr.concat(file_zj_max,dim='time')
    data_max.to_netcdf(save_max_path+str(year)+str(month)+str(day)+"_fy.nc")


    '''处理U分量'''   
    download_path_u_wind = '/home/liyuan3970/ML_pred_station_max_wind/progress_v3/samba/ECMWF_HR/UGRD_10M/'
    save_u_path = '/home/liyuan3970/ML_pred_station_max_wind/progress_v3/nc_data/u/'
    file_day_u = search(download_path_u_wind,year+month+day)
    file_day_u.sort()
    file_zj_u = []
    for file in file_day_u:
        d_zj_u=read_m4(file)
        file_zj_u.append(d_zj_u)
    print("search u is ok")
    data_u =xr.concat(file_zj_u,dim='time')
    data_u.to_netcdf(save_u_path+str(year)+str(month)+str(day)+"_u.nc")


    '''处理V分量'''   
    download_path_v_wind = '/home/liyuan3970/ML_pred_station_max_wind/progress_v3/samba/ECMWF_HR/UGRD_10M/'
    save_v_path = '/home/liyuan3970/ML_pred_station_max_wind/progress_v3/nc_data/v/'
    file_day_v = search(download_path_v_wind,year+month+day)
    file_day_v.sort()
    file_zj_v = []
    for file in file_day_v:
        d_zj_v=read_m4(file)
        file_zj_v.append(d_zj_v)
    print("search v is ok")
    data_v =xr.concat(file_zj_v,dim='time')
    data_v.to_netcdf(save_v_path+str(year)+str(month)+str(day)+"_v.nc")


    '''更改ncl文件的时间'''
    with open(file_path,"r") as f:
        res = f.readlines() #res 为列表
    res[line_num-1]=(Contents+"\n")  #删除行，因为索引是从 0 开始的，所以需要  -1
    with open(file_path,"w") as f:
        f.write("".join(res))  #将 res 转换为 字符串重写写入到文本
        f.close()
    time.sleep(5)

    with open(file_path,"r") as f:
        res = f.readlines() #res 为列表
    res[line_num2-1]=(Contents2+"\n")  #删除行，因为索引是从 0 开始的，所以需要  -1
    with open(file_path,"w") as f:
        f.write("".join(res))  #将 res 转换为 字符串重写写入到文本
        f.close()
    time.sleep(5)
    #return
    '''运行ncl文件'''
    #os.system("ncl io.ncl")
    #time.sleep(20)
    #print('job finshed------------------------------------------------------------------------')









if __name__ == '__main__':
    print("主程序",Contents,type(Contents),today)
    download()



