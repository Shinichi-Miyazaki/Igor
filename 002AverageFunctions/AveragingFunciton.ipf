#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function RegionAveraging(wv, roiwv, znum)
	wave wv, roiwv;
	variable znum
	variable pts, xNum, yNum;
	variable i, j;
	//obtain data dimensions
	pts = dimsize(wv, 0)
	xNum = dimsize(wv, 1)
	yNum = dimsize(wv, 2)
	
	//extract z position = znum 
	duplicate/Free/O/R=[0,*][0,*][0,*][znum] wv tempwv
	
	//inverse roiwv
	matrixop/Free/O temproi = -(roiwv-1)
	
	//make new wave 
	make/Free/o/n=(pts, xNum, yNum) extractedwv
	
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
	
	matrixop/Free/o temp = sumrows(extractedwv)
	matrixop/Free/o roinum = sum(temproi)
	matrixop/o average_wv = sumbeams(temp)/roinum[0]
end


function SumFromImageAndShowROI(wv, discri, oriwv)
	// Author: Tanaka Kyosuke
	// Add the spectra at pixel points inside the image that are greater than or equal to discri. 
	// The added area will be shown
	wave wv,oriwv;
	variable discri;
	
	variable pts,xNum,yNum,pixnum;
	variable i,j,cts,judgeX,judgeY;
	
	pts=dimsize(oriwv,0)
	xnum=dimsize(wv,0)
	ynum=dimsize(wv,1)
	make /o/n=(pts) temp00
	temp00=0;
	cts=0;
	
	make/o/n=(xnum,ynum) TargetFromImage
	
	targetfromimage=0
	// Avearaging the data, if each point exceeded the threshold
	i=0
	do
	j=0
	do
	  if(wv[i][j]>discri)
	    temp00[]+=oriwv[p][i][j][0]
	    cts+=1 
	    targetfromimage[i][j]=1
	  endif
	  j+=1
	while(j<yNum)
	i+=1
	while(i<xNum)
	temp00/=cts
	
	killwindow/z sumfromimage
	newimage/n=sumfromimage wv
	
	for(j=0;j<ynum-1;j+=1)
	for(i=0;i<xnum-1;i+=1)
	  
	  judgeX=targetfromimage[i+1][j]-targetfromimage[i][j]
	  judgeY=targetfromimage[i][j+1]-targetfromimage[i][j]
	  
	  
	  if(judgex==1||judgex==-1)
	    setdrawenv/w=sumfromimage linefgc=(65535,0,0) 
	    drawline/w=sumfromimage (i+1)/xnum,(j)/ynum,(i+1)/xnum,(j+1)/ynum
	  endif
	  
	  if(judgey==1||judgey==-1)
	    setdrawenv/w=sumfromimage linefgc=(65535,0,0) 
	    drawline/w=sumfromimage (i)/xnum,(j+1)/ynum,(i+1)/xnum,(j+1)/ynum
	  endif
	  
	  if(targetfromimage[i][0]==1)
	    setdrawenv/w=sumfromimage linefgc=(65535,0,0) 
	    drawline/w=sumfromimage i/xnum,0,(i+1)/xnum,0
	
	  elseif(targetfromimage[i][ynum-1]==1)
	    setdrawenv/w=sumfromimage linefgc=(65535,0,0) 
	    drawline/w=sumfromimage i/xnum,1,(i+1)/xnum,1
	
	  elseif(targetfromimage[0][j]==1)
	    setdrawenv/w=sumfromimage linefgc=(65535,0,0) 
	    drawline/w=sumfromimage 0,j/ynum,0,(j+1)/ynum
	
	  elseif(targetfromimage[xnum-1][j]==1)
	    setdrawenv/w=sumfromimage linefgc=(65535,0,0) 
	    drawline/w=sumfromimage 1,j/ynum,1,(j+1)/ynum
	  endif
	endfor
	endfor
end


function AveragingWithImageAndThreshold(ImageWv,Threshold,OriginalWv)
	// Author: Shinichi Miyazaki 
	// This script return averaged imchi3 wave (AverageWv) 
	// from region where the pixel value of the image (imagewv) 
	// above threshold
	wave ImageWv,OriginalWv;
	variable Threshold;
	variable Wavenum,xNum,yNum, pixnum;
	variable i,j,cts;
	
	// get wavenum 
	wavenum=dimsize(OriginalWv,0)
	// get xnum, ynUm
	xnum = dimsize(Imagewv, 0)
	ynum = dimsize(Imagewv, 1)
	// make AverageWv
	make /o/n=(wavenum) AverageWv = 0
	cts=0;
	
	i=0
	do
	j=0
	do
	  if(Imagewv[i][j]>Threshold)
	    AverageWv[]+=OriginalWv[p][i][j][0]
	    cts+=1
	  endif
	  j+=1
	while(j<yNum)
	i+=1
	while(i<xNum)
	AverageWv/=cts
end


function DropSaturatedPixel(wv,image, threshold)  	
	//Author: Shinichi Miyazaki
	//wv = imchi3(raw data, four-dimensional), image = image(the image you wanted to delete pixels, two-dimensional)
	// This function delete the pixels of which singnal in raw data is saturated.  
	wave wv, image;
	variable threshold
	variable pts,xNum,yNum,pixnum;
	variable i,j,k,cts, count;
	
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

