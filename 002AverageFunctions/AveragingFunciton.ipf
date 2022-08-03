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
	duplicate/O/R=[0,*][0,*][0,*][znum] wv tempwv
	//redimension
	wave tempwv_2d = wave4dto2dAveraging(tempwv, xnum, ynum)

	//inverse roiwv
	matrixop/O temproi = -(roiwv-1)
	//Redimension ROI
	Redimension/n = (xNum*yNUM) temproi
	
	//make new wave 
	wave extractedwv = extractColsForAveraging(tempwv_2d, tempROI)
	
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

Function/wave extractColsForAveraging(wv, colMaskwv)
	wave wv, colMaskwv
	string outWvName = "extractedCols" + nameofWave(wv)
	duplicate/o wv $outWvName
	wave outwave = $outWvName
	
	matrixop/o outwave = scalecols((outwave+1), colMaskwv)
	matrixop/o outwave = replace(outwave, 0, NaN)
	matrixop/o  outwave = outwave^t
	variable numOfRows = dimsize(outwave,0) 
	variable numOfCOls = dimsize(outwave,1)
	Redimension /N=(numOfRows*numOfCOls) outwave
	WaveTransform zapNaNs  outwave
	variable numOfRowsChanged = numpnts(outwave)/numOfCOls 
	Redimension /N=(numOfRowsChanged, numOfCOls) outwave
	matrixop/o outwave = outwave^t
	matrixop/o  outwave = outwave-1
	return outwave
end

Function/wave wave4Dto2DAveraging(wv,Numx,Numy)
	wave	wv;
	variable	Numx,Numy;
	variable	SampleNum,i,j,k,l, wvNum;
	variable start, startnum, endnum, pixelnum, num

	wvNum = dimsize(wv, 0)
	pixelnum = Numx*Numy

	make/O/N=(wvNum,pixelnum)/D imchi3_2d;
	k = 0;
	num=0

	do
		for(j=0;j<Numx;j=j+1)
			imchi3_2D[][num] = wv[p][j][k][0];
			num+=1
		endfor
		k += 1
	while(k < Numy)
	return imchi3_2d
end