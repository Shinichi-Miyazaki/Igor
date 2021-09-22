#pragma TextEncoding = "Shift_JIS"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function region_analysis(wv, roiwv, znum)
    wave wv, roiwv;
    variable znum
    variable pts, xNum, yNum;
    variable i, j;
    //get x and y range
    pts = dimsize(wv, 0)
    xNum = dimsize(wv, 1)
    yNum = dimsize(wv, 2)

    //extract z position = znum 
    duplicate/O/R=[0,*][0,*][0,*][znum] wv tempwv

    //inverse roiwv
    matrixop/O temproi = -(roiwv-1)
    
    //make new wave 
    make/o/n=(pts, xNum, yNum) extractedwv

    // loop
    i=0
    do
        j=0
        do
            extractedwv[][i][j] = tempwv[p][i][j][0] * temproi[i][j]
            j+=1
        while(j<yNUm)
        i+=1
    while(i<xNum)
    
    matrixop/o temp = sumrows(extractedwv)
    matrixop/o roinum = sum(temproi)
    matrixop/o average_wv = sumbeams(temp)/roinum[0]
end






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

function SumFromImage_MS(wv, discri, oriwv)
wave wv,oriwv;
variable discri;

wave imchi3_data
wave wav;
variable pts,xyNum,pixnum;
variable i,j,cts;


Silent 1; PauseUpdate
pts=dimsize(oriwv,0)
make /o/n=(pts) temp00
temp00=0;
cts=0;

i=0
do
	j=0
	do
		if(wv[i][j]>discri)
		//if(imchi3_data[pixnum][i][j][0]>discri)
			temp00[]+=oriwv[p][i][j][0]
			cts+=1
		endif
		j+=1
	while(j<xyNum)
	i+=1
while(i<xyNum)
temp00/=cts

end


function SumfromImage_MS3(xNum1,xNum2,yNum1,yNum2,oriwv)
wave oriwv
variable xNum1,xNum2,yNum1,yNum2;
variable pts;
variable i,j,cts;

Silent 1; PauseUpdate
make /o/n=1 temp00
temp00=0;
cts=0;

i=xNum1
do
	j=yNum1
	do	
		temp00[]+=oriwv[i][j]
		cts+=1
		j+=1
	while(j<yNum2)
	i+=1
while(i<xNum2)
temp00/=cts
variable ans = temp00[0][0]
return ans

end




function DropSaturatedPixel(wv,image, threshold)  
//wv = imchi3(raw data, four-dimensional), image = image(the image you wanted to delete pixels, two-dimensional)
// This function delete the pixels of which singnal in raw data is saturated.  
wave wv;
wave image;
variable threshold
variable pts,xNum,yNum,pixnum;
variable i,j,k,cts, count;


Silent 1; PauseUpdate
pts=dimsize(wv,0)
xNum=dimsize(wv,1)
yNum=dimsize(wv,2)
make /o/n=(xNum, yNum) temp00
temp00=0
count = 0
cts=0;

i=0
do
	j=0
	do
		k=0
		do
			if(wv[k][i][j][0]<threshold)
				cts+=1
			else
				count+=1
				cts+=1
			endif
			k+=1
		while(k<pts)
		
		if(count>0)
			temp00[i][j]=0
		else
			temp00[i][j]=image[i][j]
		endif
		count=0
		j+=1
	while(j<yNum)
	i+=1
while(i<xNum)
temp00/=cts


end
