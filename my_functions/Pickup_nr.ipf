#pragma TextEncoding = "Shift_JIS"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


function Pickup_nr(xsize, xNum1,xNum2,yNum1,yNum2, oriwv)
wave oriwv
variable xsize, xNum1,xNum2,yNum1,yNum2;
variable pts;
variable i,cts,first, last;

Silent 1; PauseUpdate
pts=dimsize(oriwv,0)
make /o/n=(pts) tempnrwv
tempnrwv=0;
cts=0;

first = xsize * (yNum1-1) + xNum1
last = xsize*(yNum2-1) + xNum2

i=first
do	
	tempnrwv[]+=oriwv[p][i]
	cts+=1
	i+=1
while(i<last)
tempnrwv/=cts
matrixop/o tempnr = colrepeat(tempnrwv, 100)

end
