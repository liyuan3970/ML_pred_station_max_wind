begin

date = "201021"
today = "201022"
file_csv = (/"58660pred.csv","58660pred1.csv","58660pred2.csv","58660pred3.csv","58660pred4.csv","58660pred5.csv","58660pred6.csv","58660pred7.csv","58660pred8.csv","58660pred9.csv","58660pred10.csv","58660pred11.csv"/)
nlat = (/27.9,28.0,28.1,28.2,28.2,28.3,28.4,28.5,28.6,28.7,28.8,28.9/)
nlon = (/119.9,120.0,120.1,120.2,120.3,120.4,120.5,120.6,120.7,120.8,120.9,121/)
num_station = dimsizes(file_csv)
num_time = 8
num_lat = dimsizes(nlat)
num_lon = dimsizes(nlon)



;data = asciiread(file_csv(0),-1,"float")/10
print(num_station)

data_csv = new((/num_time,num_station/), "float")

do i =0,num_station-1
    data_csv(:,i) = asciiread(file_csv(i),-1,"float")/10
end do
print(data_csv(:,11))
printVarSummary(data_csv)


;>-------------------------------------------------------<
;           读取固定站点的风向数据                           ；
;>-------------------------------------------------------<

fu = addfile("u/"+date+"_u.nc", "r")
fv = addfile("v/"+date+"_v.nc", "r")

uwind =fu->data
vwind =fv->data
uwind = doubletofloat(uwind)
;printVarSummary(uwind)

u_station = new((/num_time,num_station/), "double")

do i = 0,num_time-1 
    do j = 0,num_station-1
        lat_station = nlat(j)
        lon_station = nlon(j)
        u_station(i,j) =uwind({time|i},{lat|lat_station},{lon|lon_station})
    end do 
end do

v_station = new((/num_time,num_station/), "double")

do i = 0,num_time-1 
    do j = 0,num_station-1
        lat_station = nlat(j)
        lon_station = nlon(j)
        v_station(i,j) =vwind({time|i},{lat|lat_station},{lon|lon_station})
    end do 
end do
wind_dir = wind_direction(u_station, v_station, 0)
;print(wind_dir)

uv   = wind_component(data_csv,wind_dir,0)
printVarSummary(uv)




;>---------------------------------------<
;           插值成网格数据
;>---------------------------------------<
lon_net = fspan(119.8,122.4,52);2.6
lat_net = fspan(27.5,29.8,46);2.3
u_net = natgrid(nlon, nlat, uv(0,:,:), lon_net, lat_net)
v_net = natgrid(nlon, nlat, uv(1,:,:), lon_net, lat_net)
printVarSummary(u_net)


net_grid_u  = transpose(u_net)

time = fspan(1,num_time,num_time)
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

n_net = dimsizes(u3)
n_lat = n_net(1)
n_lon = n_net(2)


u24_t = new((/1,n_lat,n_lon/), "double")

v24_t = new((/1,n_lat,n_lon/), "double")

u24_t(0,:,:)=u24
v24_t(0,:,:)=v24
copy_VarCoords(v3(0,:,:), u24_t(0,:,:))

u24_t!0 = "time"
time2=(/1/)
time2!0 = "time"
time2@long_name  = "Time"
day = stringtocharacter(today)
time2@units      = "hours since 20"+day(0:1)+"-"+day(2:3)+"-"+day(4:5)+" "+"20:00:00"
u24_t&time=time2

copy_VarCoords(u24_t, v24_t)
printVarSummary(u3)
printVarSummary(u24_t)
printVarSummary(v24_t)
printVarSummary(u24)


;>---------------------------------------<
;           输出成nc数据
;>---------------------------------------<
u03_test = doubletofloat(net_grid_u)
v03_test = doubletofloat(net_grid_v)
copy_VarCoords(net_grid_v,v03_test)
copy_VarCoords(net_grid_u,u03_test)
printVarSummary(u03_test)

u24_test = doubletofloat(u24_t)
v24_test = doubletofloat(v24_t)
copy_VarCoords(u24_t,u24_test)
copy_VarCoords(v24_t,v24_test)

f = addfile("upload/"+"ZJGRID.331000.20"+today+"20.Wind03"+".nc", "c")
f->u10 = u03_test({time|:},{lat|:},{lon|:})
f->v10 = v03_test({time|:},{lat|:},{lon|:})

f2 = addfile("upload/"+"ZJGRID.331000.20"+today+"20.Wind24"+".nc", "c")
f2->u10 = u24_test({time|:},{lat|:},{lon|:})
f2->v10 = v24_test({time|:},{lat|:},{lon|:})
end