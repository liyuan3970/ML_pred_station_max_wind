begin
;>-----------------------------------------------------------------------------<
;                           读取数据(读取当天的数据，并计算uv风量)
;>-----------------------------------------------------------------------------<
filepath = "/home/liyuan3970/ML_pred_station_max_wind/progress_v3/nc_data/"
date = "200719"
today = "200720"
fy = addfile(filepath+"max/"+date+"_fy.nc", "r")
wind_max =fy->data
wind_max = doubletofloat(wind_max)
printVarSummary(wind_max)

dims=dimsizes(wind_max)
ntime = dims(0);8
nlat = dims(1);48
nlon = dims(2);56
lat =wind_max&lat
lon = wind_max&lat
doubletofloat(lat)
doubletofloat(lon)   
;print(lat)
;>-----------------------------------------------------------------------------<
;                             
;>-----------------------------------------------------------------------------<
data_lon = new((/nlat,nlon/), "double")
data_lat = new((/nlat,nlon/), "double")
do i=0,nlat-1
data_lon(i,:) = wind_max&lon
end do
do i=0,nlon-1
data_lat(:,i) = wind_max&lat
end do
data_one_lon = ndtooned(data_lon)
data_one_lat = ndtooned(data_lat)
;>----------------------------------------------------------<
;           插值成站点数据,只需额外添加站点经纬度即可
;>----------------------------------------------------------<

lat_point=(/28.52,28.52,29.07,29.09,28.22,28.37,28.08,28.49,28.05,28.4,28.37,28.34,28.34,28.28,28.51,29.03,29.04,29.00,28.56/)
lon_point=(/121.12,120.43,121.23,120.58,121.22,121.25,121.14,120.56,121.31,121.17,121.10,120.57,121.21,121.32,121.27,120.48,120.9,121.19,121.35/)

data_zj_one = reshape(wind_max, (/ntime,nlat*nlon/))


;9是9个站点
n_staton = dimsizes(lon_point)

data_zj_multi = new((/ntime,n_staton/), "float")
do i = 0,ntime-1
    nnpntinit(data_one_lat,data_one_lon,data_zj_one(i,:))
    data_zj_multi(i,:) = nnpnt(lat_point,lon_point)
    nnpntend()
end do
printVarSummary(data_zj_multi)

;>---------------------------------------<
;           线性关系得到风速
;>---------------------------------------<
a = 1.0
b = 0.0
data_zj_multi = a*data_zj_multi+b
printVarSummary(data_zj_multi)

;>-------------------------------------------------------<
;           读取固定站点的风向数据                           ；
;>-------------------------------------------------------<

fu = addfile(filepath+"u/"+date+"_u.nc", "r")
fv = addfile(filepath+"v/"+date+"_v.nc", "r")
uwind =fu->data
vwind =fv->data
uwind = doubletofloat(uwind)
printVarSummary(uwind)

u_station = new((/ntime,n_staton/), "double")

do i = 0,ntime-1 
    do j = 0,n_staton-1
        lat_station = lat_point(j)
        lon_station = lon_point(j)
        u_station(i,j) =uwind({time|i},{lat|lat_station},{lon|lon_station})
    end do 
end do

v_station = new((/ntime,n_staton/), "double")

do i = 0,ntime-1 
    do j = 0,n_staton-1
        lat_station = lat_point(j)
        lon_station = lon_point(j)
        v_station(i,j) =vwind({time|i},{lat|lat_station},{lon|lon_station})
    end do 
end do

wind_dir = wind_direction(u_station, v_station, 0)
;print(wind_dir)

uv   = wind_component(data_zj_multi,wind_dir,0)
printVarSummary(uv)

;>---------------------------------------<
;           插值成网格数据
;>---------------------------------------<
lon_net = fspan(119.8,122.4,52);2.6
lat_net = fspan(27.5,29.8,46);2.3
u_net = natgrid(lon_point, lat_point, uv(0,:,:), lon_net, lat_net)
v_net = natgrid(lon_point, lat_point, uv(1,:,:), lon_net, lat_net)
printVarSummary(u_net)


net_grid_u  = transpose(u_net)

time = fspan(1,ntime,ntime)
time!0 = "time"
time@long_name  = "Time"
day = stringtocharacter(today)

time@units      = "hours since 20"+day(0:1)+"-"+day(2:3)+"-"+day(4:5)+" "+"20:00:00"

lon_net!0          = "lon"
lon_net@long_name  = "Longitude"
lon_net@units      = "degrees-east"
lon_net&lon        = lon_net
lon_net@add_offset = "0.f"
lon_net@scale_factor = "1.f"

lat_net!0          = "lat"
lat_net@long_name  = "Latitude"
lat_net@units      = "degrees_north"
lat_net&lat        = lat_net
lat_net@add_offset = "0.f"
lat_net@scale_factor = "1.f"
net_grid_u!1 = "lon"
net_grid_u!0 = "lat"
net_grid_u!2 = "time"
net_grid_u&time=time
net_grid_u&lon= lon_net
net_grid_u&lat= lat_net
net_grid_u@units      = "m/s"
net_grid_u@long_name      = "Max wind above 10m ground"
printVarSummary(net_grid_u)

net_grid_v  = transpose(v_net)
copy_VarCoords(net_grid_u, net_grid_v)
net_grid_v@units      = "m/s"
net_grid_v@long_name      = "Max wind above 10m ground"
printVarSummary(net_grid_v)

;>---------------------------------------<
;           处理-----24小时极大风
;>---------------------------------------<
u3 = net_grid_u({time|:},{lat|:},{lon|:})
v3 = net_grid_v({time|:},{lat|:},{lon|:})

u24 = dim_max_n(u3, 0)
v24 = dim_max_n(v3, 0)
copy_VarCoords(u3(0,:,:), u24)
copy_VarCoords(v3(0,:,:), v24)
printVarSummary(u24)
;>---------------------------------------<
;           输出成nc数据
;>---------------------------------------<
f = addfile("/home/liyuan3970/ML_pred_station_max_wind/progress_v3/upload/"+date+".nc", "c")
f->u10 = net_grid_u({time|:},{lat|:},{lon|:})
f->v10 = net_grid_v({time|:},{lat|:},{lon|:})



end 