import os, logging, pdb
 
def search(s):
    rootdir = '/home/liyuan3970/ML_pred_station_max_wind/progress_v3/test_data/'       # 指明被遍历的文件夹
    l = []
 
    #三个参数：分别返回1.父目录 2.所有文件夹名字（不含路径） 3.所有文件名字
    for parent, dirnames, filenames in os.walk(rootdir):
         for filename in filenames:      # 输出文件信息
            # print "filename is:" + filename
            if filename.find(s) != -1:
                #print("the full path of the file is:" + os.path.abspath(os.path.join(parent,filename))) # 输出文件路径信息
                l.append(os.path.abspath(os.path.join(parent,filename)))
    return l
 
if __name__ == '__main__':
    search('2006')
    print(l)

'''
这是全路径的java代码
java -jar /home/liyuan3970/ML_pred_station_max_wind/progress_v3/GDSJavaClient.jar 10.135.29.64 8080 samba ECMWF_HR/UGRD_10M 20071620.024 20071620.048

'''




