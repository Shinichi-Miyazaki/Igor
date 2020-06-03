#pragma rtGlobals=1		// Use modern global access method.
function SumFromImage_MS2(refwv,discri,refwv2,discri2,oriwv)
wave refwv,refwv2, oriwv;
variable discri, discri2;

wave wav;
variable pts,xNum,yNum;
variable i,j,cts;

Silent 1; PauseUpdate
pts=dimsize(oriwv,0)
//obtain number of the spectral data (1340)
xNum=dimsize(oriwv,1)
//get x data number
yNum=dimsize(oriwv, 2)
//get y data number

make /o/n=(pts) temp00
temp00=0
cts=0;

i=0
do
	j=0
	do	
		if(refwv2[i][j]<discri2 && refwv[i][j]>discri)
		//if a data at spatial position [i][j] > threshold, execute below
			temp00[]+=oriwv[p][i][j][0] 
			//p = 0, 1, 2, 3,,,,,,
			cts+=1
		endif
		j+=1
	while(j<yNum)
	i+=1
while(i<xNum)
temp00/=cts

end


function ImageSum_MS(xNum1,xNum2,yNum1,yNum2, oriwv)
wave oriwv
variable xNum1,xNum2,yNum1,yNum2;
variable pts;
variable i,j,cts;

Silent 1; PauseUpdate
pts=dimsize(oriwv,0)
make /o/n=(pts) temp00
temp00=0;
cts=0;

i=xNum1
do
	j=yNum1
	do	
		temp00[]+=oriwv[p][i][j][0]
		cts+=1
		j+=1
	while(j<yNum2)
	i+=1
while(i<xNum2)
temp00/=cts

end
