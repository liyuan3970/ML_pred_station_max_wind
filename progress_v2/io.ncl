begin
;>---------------------------------------<
;             读取数据
;>---------------------------------------<
diri = "/home/liyuan3970/ML_pred_station_max_wind/progress/test_data/"
date = "200628"
files = systemfunc ("ls "+ diri + date+"*")
;print(files)
ncol = 10

n =dimsizes(files)
;print(n)
data = new((/n,721*1441/), "float")
do i=0,dimsizes(files)-1
   ; print(i)
   data_one=ndtooned(readAsciiTable(files(i),10,"float", 2))
   data(i,:)=data_one(0:1038960)
end do
printVarSummary(data)


data_latlon = reshape(data, (/n,721,1441/))


lon = fspan(0,180,1441)
lat = fspan(80,-10,721)
time = fspan(1,n,n)
time!0 = "time"
lon!0 = "lon"
lat!0 = "lat"

lon@long_name  = "lon"
lon@units      = "degrees-east"
lon&lon        = lon
lat@long_name  = "lat"
lat@units      = "degrees_north"
lat&lat        = lat
data_latlon!2 = "lon"
data_latlon!1 = "lat"
data_latlon&lon= lon
data_latlon&lat= lat

data_latlon!0 = "time"
data_latlon&time=time

printVarSummary(data_latlon)
;截取浙江的经纬度内的数据，并输出成单唯数据
data_zj = data_latlon({time|:},{lat|31:27},{lon|118:123})
printVarSummary(data_zj)

data_lon = new((/33,41/), "float")
data_lat = new((/33,41/), "float")
printVarSummary(data_lat)
printVarSummary(data_zj&lat)
do i=0,32
data_lon(i,:) = data_zj&lon
end do
do i=0,40
data_lat(:,i) = data_zj&lat
end do
data_one_lon = ndtooned(data_lon)
data_one_lat = ndtooned(data_lat)
;>---------------------------------------<
;           插值成站点数据
;>---------------------------------------<

lat_point=(/28.52,28.52,29.07,29.09,28.22,28.37,28.08,28.49,28.05/)
lon_point=(/121.12,120.43,121.23,120.58,121.22,121.25,121.14,120.56,121.31/)

data_zj_one = reshape(data_zj, (/n,33*41/))


;9是9个站点
data_zj_multi = new((/n,9/), "float")
do i = 0,n-1
    nnpntinit(data_one_lat,data_one_lon,data_zj_one(i,:))
    data_zj_multi(i,:) = nnpnt(lat_point,lon_point)
    nnpntend()
end do
printVarSummary(data_zj_multi)
;>---------------------------------------<
;           线性关系
;>---------------------------------------<
a = 1.0
b = 0.0
data_zj_multi = a*data_zj_multi+b


;>---------------------------------------<
;           插值成站点数据
;>---------------------------------------<
lon_net = fspan(119.8,122.4,16);2.6
lat_net = fspan(27.5,29.8,15);2.3
zi = natgrid(lon_point, lat_point, data_zj_multi, lon_net, lat_net)
printVarSummary(zi)

;>---------------------------------------<
;           数组转置
;>---------------------------------------<
net_grid  = transpose(zi)

time!0 = "time"


lon_net!0          = "lon"
lon_net@long_name  = "lon"
lon_net@units      = "degrees-east"
lon_net&lon        = lon_net
lat_net!0          = "lat"
lat_net@long_name  = "lat"
lat_net@units      = "degrees_north"
lat_net&lat        = lat_net
net_grid!1 = "lon"
net_grid!0 = "lat"
net_grid!2 = "time"
net_grid&time=time
net_grid&lon= lon_net
net_grid&lat= lat_net
printVarSummary(net_grid)
;>---------------------------------------<
;           输出成nc数据
;>---------------------------------------<


f = addfile("upload/"+date+".nc", "c")
f->fy = net_grid({time|:},{lat|:},{lon|:})
end