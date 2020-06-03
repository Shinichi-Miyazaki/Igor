#pragma rtGlobals=1		// Use modern global access method.
function SumFromImage_MS(refwv,discri,oriwv)
wave refwv, oriwv;
variable discri;

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
		if(refwv[i][j]>discri)
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
