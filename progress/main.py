import schedule
import time
import datetime
import os
from datetime import datetime, date, timedelta


def job_download():
    '''处理时间函数'''
    print("Job4:每天06:00自动下载前一天20时向后预报一天的M4 10米风数据")
    os.system('java -jar GDSJavaClient.jar 10.135.29.64 8080 samba ECMWF_HR/10_METRE_WIND_GUST_IN_THE_LAST_3_HOURS'+' '+year+month+day+'20.000'+' '+year+month+day+'20.024'+' '+'diamond')
    time.sleep(20)
    print('job finshed------------------------------------------------------------------------')









if __name__ == '__main__':
    print("主程序")
    schedule.every().day.at(runtime).do(job_download)
    while True:
        schedule.run_pending()
