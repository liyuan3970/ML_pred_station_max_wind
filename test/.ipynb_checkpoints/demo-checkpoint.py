# -*- coding: UTF-8 -*-

 

def Del_line(file_path,line_num,Contents): #file_path:文件名；line_num：行号；Contents：修改后的内容

    with open(file_path,"r") as f:

        res = f.readlines() #res 为列表

    res[line_num-1]=(Contents+"\n")  #删除行，因为索引是从 0 开始的，所以需要  -1

 

    with open(file_path,"w") as f:

        f.write("".join(res))  #将 res 转换为 字符串重写写入到文本

    return

 

Del_line("test.ncl",2,"wwwwwwww") #将第二行修改为 wwwwwwww
