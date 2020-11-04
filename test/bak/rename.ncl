begin

filename = "ZJGRID.331000.2020102620.Wind03.nc"
f =addfile(filename, "r")

u10 = f->u10
v10 = f->v10
time = f->time 

time@units      = "hours since 2020-10-26 20:00:00"

u10&time=time
v10&time=time
printVarSummary(time)

f2 = addfile("data/"+filename, "c")
f2->u10 = u10
f2->v10 = v10
end