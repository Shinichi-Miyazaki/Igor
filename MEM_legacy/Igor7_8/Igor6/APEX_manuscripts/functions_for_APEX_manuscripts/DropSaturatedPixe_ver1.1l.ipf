#pragma rtGlobals=1		// Use modern global access method.
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
