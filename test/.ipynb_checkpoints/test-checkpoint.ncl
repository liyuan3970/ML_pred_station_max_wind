begin
;>---------------------------------------<
;             读取数据
;>---------------------------------------<

ncol = 10
data = readAsciiTable("20062520.009", ncol, "float", 2)
one = ndtooned(data)
data_one = one(0:1038960)
data_latlon = reshape(one(0:1038960), (/721,1441/))
;数组的经纬度赋值
lon = fspan(0,180,1441)
lat = fspan(80,-10,721)
lon!0 = "lon"
lat!0 = "lat"
lon@long_name  = "lon"
lon@units      = "degrees-east"
lon&lon        = lon
lat@long_name  = "lat"
lat@units      = "degrees_north"
lat&lat        = lat
data_latlon!1 = "lon"
data_latlon!0 = "lat"
data_latlon&lon= lon
data_latlon&lat= lat
printVarSummary(data_latlon)

;f= addfile("test.nc", "c")
;f->data = data_latlon

;截取浙江的经纬度内的数据，并输出成单唯数据
data_zj = data_latlon({lat|31:27},{lon|118:123})
data_zj_one = ndtooned(data_zj)
printVarSummary(data_zj)
data_lon = new((/33,41/), "float")
data_lat = new((/33,41/), "float")
do i=0,32
data_lon(i,:) = data_zj&lon
end do
do i=0,40
data_lat(:,i) = data_zj&lat
end do
data_one_lon = ndtooned(data_lon)
data_one_lat = ndtooned(data_lat)
printVarSummary(data_one_lon)
printVarSummary(data_one)
;>---------------------------------------<
;           插值成站点数据
;>---------------------------------------<
;;latlon 是站点的经纬度
lat_point=(/29.17,29.12,28.87,28.85,28.37,28.62,28.08,28.81,28.66,29.01,28.72,28.1,28.27,28.62,28.59,28.46,28.85,28.71,29.05,29.06,29,28.93,28.71,28.7/)
lon_point=(/120.98,121.38,120.72,121.13,121.37,121.42,121.27,120.92,121.51,121.71,121.91,121.52,121.62,121.17,120.96,121.53,121.45,121.64,120.79,120.97,121.31,121.58,120.83,120.33/)
print(dimsizes(lat_point))
print(dimsizes(lon_point))
; z1是站点数据
nnpntinit(data_one_lon,data_one_lat,data_zj_one)
z1 = nnpnt(lon_point,lat_point)
nnpntend()
printVarSummary(z1)
print("ok")

;>---------------------------------------<
;           线性关系
;>---------------------------------------<
a = 1
b = 0
z2 = a*z1+b
;>---------------------------------------<
;           插值成网格点    
;>---------------------------------------<
;分辨率可能要调整 50 40
lon_net = fspan(120.1,121.56,5)
lat_net = fspan(29.2,28.1,10)
zi = natgrid(lon_point, lat_point, z2, lon_net, lat_net)
;>---------------------------------------<
;           输出成格点数据
;>---------------------------------------<
printVarSummary(zi)
lon_net!0          = "lon"
lon_net@long_name  = "lon"
lon_net@units      = "degrees-east"
lon_net&lon        = lon_net
lat_net!0          = "lat"
lat_net@long_name  = "lat"
lat_net@units      = "degrees_north"
lat_net&lat        = lat_net
zi!1 = "lon_net"
zi!0 = "lat_net"
printVarSummary(zi)
f = addfile("test_net.nc", "c")
f->v = zi





end