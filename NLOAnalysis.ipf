#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3	
#pragma IgorVersion=8
#pragma version = 0.00

// NLOAnalysis.ipf
// Copyright (c) 2022 Hideaki Kano
// Released under the MIT license
// https://opensource.org/licenses/mit-license.php

// ************************************************************************
// This is a free software for analyzing nonlinear optical (NLO) signal with Igor pro 8 or later. 
// Please use this software at your own risk. 
// The developer does not correspond to any errors in scientific resuls by this script.
// ************************************************************************

///// 001MEMRelatedFunctions ///// 
// Following sctipts are for preprocessing before maximum entropy method (MEM) for CARS signal.
// Usage is described in readme.

Function Wave2Dto4D(wv,Numx,Numy,Numz,[DataType,SlidePxNum])	
	/// Author: Shinichi Miyazaki
	/// This function rearrange the 2D wave to 4D wave
	/// @params	wv: 2D wave (wavenum, xyz)
	/// @params	Numx, Numy, Numz: variable (Number of spatial points)
	/// @params	DataType: variable (default	: no z direction zigzag, axis order is xyZ
	///								1		: z direction zigzag, axis order is xZy
	///								2		: z direction zigzag, axis order is xyZ
	///								3		: one way capturing, xy scan (for IIIS))
	/// Outputs
	/// CARS: 4D wave (wavenum, x, y, z)
	wave	wv;
	variable	Numx,Numy,Numz,DataType, SlidePxNum;
	variable	i,j,k,wvNum;
	variable start,startnum,endnum, ZCenter, nextstartnum,nextendnum
	// make destination wave. the name is CARS
	wvNum = dimsize(wv, 0)
	make/O/N=(wvNum,Numx,Numy,Numz)/D CARS;
	// Switch depend on data type
	Switch (DataType)
		case 1:
			print "z direction zigzag, axis order is xZy"
			//judgement for even or odd
			if(mod(Numy,2)==0)
				ZCenter=(Numy)/2
			else
				ZCenter=(Numy-1)/2
			endif
			i=0;
			j=0;
			k=0;
			do
				do
					start = i * Numx * Numy
					startnum =  start + k * Numx
					endnum = start + (k+1) * Numx
					Duplicate/Free/R=[0,*][startnum,endnum] wv tempwv
					nextstartnum =  start + (k+1) * Numx
					nextendnum = start + (k+2) * Numx
					Duplicate/Free/R=[0,*][nextstartnum,nextendnum] wv nexttempwv
					if(j==0)
						CARS[][][ZCenter][i]=tempwv[p][q]
						j+=1
						k+=1
					else
						CARS[][][ZCEnter+j][i]=tempwv[p][q]
						CARS[][][ZCenter-j][i]=nexttempwv[p][q]
						j+=1
						k+=2
					endif
				while(j<=ZCenter)
				i+=1
			while(i<Numz)
		break
			
		case 2:
			print "z direction zigzag, axis order is xyZ"
			//judgement for even or odd
			if(mod(Numz,2)==0)
				ZCenter=(Numz)/2
			else
				ZCenter=(Numz-1)/2
			endif
			//i for z num 
			i=0;
			j=0;
			// count for mod
			k=0;
			do
				j=0
				do
					if(i==0)
						start = i * Numx * Numy
						startnum = start + j * Numx
						endnum = start + (j+1) * Numx
						Duplicate/Free/R=[0,*][startnum,endnum] wv tempwv
						CARS[][][j][Zcenter] =tempwv[p][q]
						j+=1
					elseif(mod(i,2)==1)
						start = i * Numx * Numy
						startnum = start + j * Numx
						endnum = start + (j+1) * Numx
						Duplicate/Free/R=[0,*][startnum,endnum] wv tempwv
						CARS[][][j][Zcenter+k] =tempwv[p][q]
						j+=1
					elseif(mod(i,2)==0)
						start = i * Numx * Numy
						startnum = start + j * Numx
						endnum = start + (j+1) * Numx
						Duplicate/Free/R=[0,*][startnum,endnum] wv tempwv
						CARS[][][j][Zcenter-k] =tempwv[p][q]
						j+=1
					endif
				while(j<Numy)
				i+=1
				if(mod(i,2)==1)
					k=(i+1)/2
				else
					k=i/2
				endif
			while(i<Numz)
		break

		case 3: 
			print "one way capturing, xy scan"
			for(j=0; j<Numy; j=j+1)
				if (j==0)
					startnum = j * Numx
					endnum = (j+1) * Numx
					Duplicate/Free/R=[0,*][startnum,endnum] wv tempwv
					CARS[][][j][0] = tempwv[p][q];
				elseif (mod(j,2) == 0)	
					startnum = j * Numx
					endnum = (j+1) * Numx
					Duplicate/Free/R=[0,*][startnum,endnum] wv tempwv
					CARS[][][j][0] = tempwv[p][q];
				elseif (mod(j,2) == 1)
					startnum = j * Numx
					endnum = (j+1) * Numx
					Duplicate/Free/R=[0,*][startnum+SlidePxNum,endnum+SlidePxNum] wv tempwv
					imagetransform flipcols tempwv 
					CARS[][][j][0] = tempwv[p][q];
				endif
			endfor
		break

			
		default:
			print "no z direction zigzag, axis order is xyZ"
			i=0;
			j=0;
			do
				for(j=0;j<Numy;j=j+1)
					start = i * Numx * Numy
					startnum =  start + j * Numx
					endnum = start + (j+1) * Numx
					Duplicate/Free/R=[0,*][startnum,endnum] wv tempwv
					CARS[][][j][i] = tempwv[p][q];
				endfor
				i+=1
			while(i<Numz)
		Endswitch
end

Function darkNonres(rawwv, bgwv, nrwv)
	/// Author: Shinichi Miyazaki
	/// This function subtracts bg from rawwv and nrwv
	/// After it divides rawwv with nrwv
	/// @params rawwv	: 2D wave		(wavenum, xyz)
	/// @params	bgwv	: 1D or 2D wave	(wavenum, spatial)
	/// @params	nrwv	: 1D or 2D wave	(wavenum, spatial)
	/// Output
	/// None, rawwv will be overwritten
	wave rawwv, bgwv, nrwv
	variable numofwv, bgnum, nrnum

	numofwv = dimsize(rawwv, 1)
	bgnum = dimsize(bgwv, 1)
	// for 1D bg wave
	if(bgnum==0)
		bgnum=1
	endif
	nrnum = dimsize(nrwv, 1)
	// for 1D nr wave
	if(nrnum==0)
		nrnum=1
	endif
	// averaging the bg wave
	matrixOP/free/O sumbgwv = sumRows(bgwv)
	matrixOP/free/O bgwv = sumbgwv / bgnum
	// avearging the nr wave
	matrixOP/free/O sumnrwv = sumRows(nrwv)
	matrixOP/free/O nrwv = sumnrwv / nrnum
	// Subtract bg wave from nr wave and raw wave
	matrixOP/free/o nrwv = nrwv-bgwv
	matrixop/free/o tempbg = colRepeat(bgwv, numofwv)
	matrixop/o rawwv = rawwv - tempbg
	// Devide raw wave with nr wave
	matrixop/free/o tempnr = colRepeat(nrwv, numofwv)
	matrixOP/O rawwv = rawwv / tempnr
end

Function/wave makeramanshift4(wv)		
	/// Author: Unknown
	/// making new Ramanshift wave after MEM
	/// @params wv: m_ramanshift1
	/// Output
	/// re_ramanshift2
	wave	wv;
	variable	pixNum;
	variable	i;
	pixNum=DimSize(wv,0);
	print pixNum
	make/O/N=(pixNum) /D re_ramanshift2;
	for(i=0;i<pixNum;i=i+1)
		re_ramanshift2[i] = -wv[pixNum-1-i];
	endfor
	return	re_ramanshift2;
end

Function ImageCreate(wv,pixel,Numx,Numy,Numz)    
	/// Author: Shinichi Miyazaki
	/// make 2d image at particular pixel point
   	/// @params wv					: 	wave
	/// @params pixel				:	variable, pixel value for wavenumber that you want to visualize
	/// @params Numx, Numy, Numz	:	variable, number of spatial points
	/// Output
	/// None, Image create
	
	wave wv;
	variable pixel,Numx,Numy,Numz;
	variable ImageSize,i, WaveDimSize
	String ImageName
	ImageSize = Numx*Numy
	WaveDimSize = dimsize(wv, 2)
	switch (WaveDimSize)
		case 0:
			make/O/N=(Numx,Numy)/D im;
			duplicate/O/R=[pixel][0, imagesize] wv im
			redimension/n=(imagesize) im
			redimension/n = (Numx, Numy) im
			newimage im
			break
		default:
			i=0
			do
				ImageName="ImageZ="+num2str(i)
				make/O/N=(Numx,Numy) $ImageName;
				duplicate/O/R=[pixel][0,Numx][0,Numy][i] wv $ImageName
				redimension/n=(imagesize) $ImageName
				redimension/n=(Numx, Numy) $ImageName
				newimage $ImageName
				ModifyGraph width=283.465,height={Aspect,1}
				i+=1
			while(i<=Numz)
		endswitch
end

Function wave4Dto2D(wv,Numx,Numy)	
	// Author: Shinichi Miyazaki
	// rearrange the 4D wave to 2Dwave
	// @params wv	: 4D wave (wavenum, x, y, z)
	// @params Numx	: variavle (x spatial points)
	// @params Numy : variable (y spatial points)
	// Output imchi3_2d : 2D wave (wavenum, xy spatial points) 
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
end

Function TransposeLayersAndChunks(w4DIn, nameOut)
	// Author: Shinichi Miyazaki
	// Transpose Layer (3rd axis) and Chunk (4th axis), (wavenum, x, y, z) -> (wavenum, x, Z, Y) 
	// @params w4DIn	: 4D wave (wavenum, x, y, z)
	// @params nameOut	: string (wave name)
	// Output nameOut	: 4D wave
    Wave w4DIn
    String nameOut          // Desired name for new wave
    // Get information about input wave
    Variable rows = DimSize(w4DIn, 0)
    Variable columns = DimSize(w4DIn, 1)
    Variable layers = DimSize(w4DIn, 2)
    Variable chunks = DimSize(w4DIn, 3)
    Variable type = WaveType(w4DIn)
    // Make output wave. Note that numLayers and numChunks are swapped
    Make/O/N=(rows,columns,chunks,layers)/Y=(type) $nameOut
    Wave w4DOut = $nameOut
    // Copy scaling and units
    CopyScales w4DIn, w4DOut
    // Swap layer and chunk scaling
    Variable v0, dv
    String units
    v0 = DimOffset(w4DIn, 2)
    dv = DimDelta(w4DIn, 2)
    units = WaveUnits(w4DIn, 2)
    SetScale t, v0, dv, units,  w4DOut  // Copy layer dimensions and units to chunk dimension
    v0 = DimOffset(w4DIn, 3)
    dv = DimDelta(w4DIn, 3)
    units = WaveUnits(w4DIn, 3)
    SetScale z, v0, dv, units,  w4DOut  // Copy chunk dimensions and units to layer dimension
    // Transfer data
    w4DOut = w4DIn[p][q][s][r]          // s and r are reversed from normal
End

Function extractWaveFromStack(inwave, repeattime, numX, numY, offset)
	// Author: Shinichi Miyazaki
	// extract data from 4D wave
	// Useful for multiple stack data 
	// for example, when you take 2 data / 1 spatial point for 40 * 40, you get 3200 data points (16x16x2)
	// to extract 1st data (40x40) you should use this script
	// @params inwave		:2D wave 
	// @params repeattime	:variable (how many data you get each spatial point)
	// @params NumX			:variable (x spatial points)
	// @params NumY			:variable (y spatial points)
	// @params offset		:variable (which data you want to get, if you want to get 1st image, please put 0)
	// Output extractedWave :2D wave
	wave inwave
	variable repeattime, numX, numY, offset
	variable i, waveNum, num
	// i for spatial point
	// num for loop count
	waveNum  = dimsize(inwave, 0)
	make/o/n=(waveNum,numx*numy)/D extractedWave = 0
	i=offset
	num=0
	do
		extractedWave[][num] = inwave[p][i]
		i += repeattime
		num += 1 
	while(i<NumX*NumY*repeatTime)
end

///// 002AvearagingFunction ///// 
// Following sctipts are for averaging signal. 
// Usage is described in readme.

Function RegionAveraging(wv, roiwv, znum)
	// Author: Shincihi Miyazaki
	// averaging data from ROI (determined by Igor function)
	// @params wv	:4D wave (Imchi3_data)
	// @params roiwv:2D wave (made using Igor function)
	// @params znum	:variable (which slice do you want to averaging, 0 means 1st slice)
	// Output	average_wv: 1D wave
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

Function PixelValueExtract(Imagewv, roi)
	// Author: Shinichi Miyazaki?
	// Make image mask
	// @params Imagewv	:2D wave 
	// @params roi		:2D wave (made using Igor function)
	// Output MaskedImage
	wave ImageWv, roi;
	variable pts, xNum, yNum;
	variable i, j;
	//obtain data dimensions
	xNum = dimsize(imagewv, 0)
	yNum = dimsize(imagewv, 1)
	//inverse roiwv
	matrixop/O temproi = -(roi-1)
	//Redimension ROI
	matrixop/o  maskedImage = imagewv * tempRoi
	//make new wave 
	redimension/n = (xNUm*yNum) maskedImage
	matrixop/o maskedImage = replace(maskedImage, 0, NaN)
	WaveTransform zapNaNs  maskedImage
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
	//Drop satudated pixel value to 0
	// @params wv		:4D wave
	// @params image	:2D wave 
	// @params threshold:variable (saturated threshold)
	// Output temp00 
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


function ParticleExtract(OriginalImage,ThreshVal,minSize)
//Author: Minori Masaki
//Procedure to detect objects from images.

//This function is extract particles for fill centers.
//Use ThresholdValues that are clearly part of the object.
//Use the appropriate minimum particle size >=4.
wave OriginalImage;
variable ThreshVal,minSize;

duplicate/O OriginalImage, ParticleImage
ImageThreshold/O/M=0/T=(ThreshVal)/i ParticleImage
duplicate/O ParticleImage, M_particle
ImageAnalyzeParticles/D=ParticleImage/W/E/A=(minSize)/M=3 stats ParticleImage
ParticleImage=M_particle
NewImage/K=0 root:ParticleImage
Killwaves/Z W_BoundaryX,W_BoundaryY,W_circularity,W_ImageObjArea,W_ImageObjPerimeter,W_IntAvg,W_IntMax,W_IntMin,W_rectangularity,W_xmax,W_xmin,W_ymax,W_ymin,W_BoundaryIndex,M_Moments,M_RawMoments
end


function EdgeEnhanced(OriginalImage,ThreshVal)
//This function creates edges that acts as banks when filling in.
//Use the same ThreshVal as ParticleExtract by default. 
wave OriginalImage;
variable ThreshVal;

duplicate/O OriginalImage, EdgeEnhancedImage
ImageEdgeDetection/O/S=1/M=1 Canny EdgeEnhancedImage
ImageThreshold/O/Q/M=1/i EdgeEnhancedImage
matrixop/o EdgeEnhancedImage=OriginalImage+(EdgeEnhancedImage*ThreshVal/255/2)
matrixop/o EdgeEnhancedImage=uint8(EdgeEnhancedImage)
NewImage/K=0 root:EdgeEnhancedImage
end



function EdgeFillbyParticle(OriginalImage,ParticleImage,EdgeEnhancedImage,minval)
//This function fills in the edges with particles as a marker.
//If the particle areas were too large, it takes longer due to SeedFill.
//minval should be higher than the background value.
wave OriginalImage,ParticleImage,EdgeEnhancedImage;
variable minval;
variable xNum,yNum,i,j;

Silent 1; PauseUpdate
xNum=dimsize(ParticleImage,0)
yNum=dimsize(ParticleImage,1)
duplicate/o EdgeEnhancedImage, ObjectROI,M_SeedFill
ObjectROI=0

for(i=0;i<xNum;i+=1)
 for(j=0;j<yNum;j+=1)
   if((ParticleImage[i][j]==16)&&(ObjectROI[i][j]==0))
     ImageSeedFill/B=0 min=minval,adaptive=10, seedX=i, seedY=j, target=1, srcWave=EdgeEnhancedImage
     ObjectROI+=M_SeedFill
   endif
 endfor
endfor

ImageThreshold/O/T=0 ObjectROI
MatrixFilter /N=3 max ObjectROI
matrixop/O ObjectROI=-(ObjectROI/255-1) //To be used as ROIwave.
matrixop/O ObjectROI=uint8(ObjectROI)
NewImage/K=0 root:ObjectROI

//This function check ROI on Image.
duplicate/O ObjectROI, EdgeImage
ImageEdgeDetection/O/S=1/M=1 Canny EdgeImage
duplicate/O OriginalImage, CircleObjectImage
killwindow/z CircleObjectImage0
NewImage/n=CircleObjectImage0 CircleObjectImage

for(i=0;i<xNum;i+=1)
 for(j=0;j<yNum;j+=1)
  if(EdgeImage[i][j]==0)
   setdrawenv/w=CircleObjectImage0 linefgc=(32639,65535,54484) 
   drawline/w=CircleObjectImage0 (i+1)/xNum,(j)/yNum,(i+1)/xNum,(j+1)/yNum
   endif
 endfor
endfor
end


///// 003FittingFunctions /////
// these scripts for Gaussian function fitting
// Details in readme

Function GaussFunc(W,X)
	// CoefW: coef wave, the parameters for gauss fit
	// CoefW does not have to possess 23 values
	// X: X axis
	// Amp: variable return
	// W: coef wave padded with 0, if the coefw had 14 values (4 gauss), value15~23 is 0. 
	wave w;		
	variable	X;
	variable Amp;
	Amp=W[0]+W[1]*X+W[2]*exp(-((X-W[3])/W[4])^2)+W[5]*exp(-((X-W[6])/W[7])^2)+W[8]*exp(-((X-W[9])/W[10])^2)+W[11]*exp(-((X-W[12])/W[13])^2)+ W[14]*exp(-((X-W[15])/W[16])^2)+W[17]*exp(-((X-W[18])/W[19])^2)+W[20]*exp(-((X-W[21])/W[22])^2);
	return	Amp;
end

Function SingleGauss(axis, coef)
	wave axis
	wave coef
	make/o/n = (dimsize(axis, 0)) singlegausswv = coef[0]*exp(-((axis-coef[1])/coef[2])^2)
end

Function/wave SingleGaussWithLinearBaseline(axis, coef0, coef1, coef2, coef3, coef4)
	wave axis
	variable coef0, coef1, coef2, coef3, coef4
	make/o/n = (dimsize(axis, 0)) singlegausswv = coef0+coef1*axis+coef2*exp(-((axis-coef3)/coef4)^2)
	return singlegausswv
end

function InitBase(wv,axis, wcoef)
	wave wv, axis, wcoef
	wcoef[0] = (wv[pcsr(B)]-wv[pcsr(A)])/(axis[pcsr(B)]-axis[pcsr(A)])*(-axis[pcsr(A)])+wv[pcsr(A)]
	wcoef[1] = (wv[pcsr(B)]-wv[pcsr(A)])/(axis[pcsr(B)]-axis[pcsr(A)])
end


// Initial fitting function
function InitialFit(wv, xaxis, wcoef, [SearchCoef])
	// Author: Shinichi Miyazaki
	
	// arguments
	wave wv, xaxis, wcoef
	variable SearchCoef
	// predifined waves
	wave ProcessedWCoef
	variable NumOfGauss, i, j,k, NumOfSearchLoop
	// define the fit wave name 
	String fitName = "fit_" + nameOfWave(wv)
	// obtain cursor position from graph
	variable WaveStart = pcsr(A)
	variable WaveEnd = pcsr(B)
	// For error Catch
	variable errorVal
	//Define the text waves
	make/o/T GasuuNumMessages={\
								"One Gauss fit",\
								"Two Gauss Fit",\
								"Three Gauss Fit",\
								"Four Gauss Fit",\
								"Five Gauss Fit",\
								"Six Gauss Fit",\
								"Seven Gauss Fit"\
                                }

    make/o/T Constraints={"K2>0","k5>0","k8>0","k11>0","k14>0","k17>0", "k20>0"}
	 make/o/T FittingParameters={\
								"00000111111111111111111",\
								"00000000111111111111111",\
								"00000000000111111111111",\
								"00000000000000111111111",\
								"00000000000000000111111",\
								"00000000000000000000111",\
								"00000000000000000000000"\
								}
	
	// Kill waves and remove graph, for repeated use
	RemoveFromGraph/z $fitName
	RemoveFromGraph/z FitGauss0, Fitgauss1, FitGauss2, FitGauss3, FitGauss4, FitGauss5, FitGauss6, FitGauss7
	Killwaves/z fit_tempwv
	Killwaves/z FitGauss0, Fitgauss1, FitGauss2, FitGauss3, FitGauss4, FitGauss5, FitGauss6, FitGauss7
	
	// Duplicate wv
	Duplicate/o wv tempwv
	Duplicate/o xaxis Axis
	
	// Initial baseline 
	InitBase(wv,axis,wcoef)
	
	// check the num of coef, and gauss
	variable NumOfCoef = dimsize(wcoef,0)
	variable NumOfGaussCoef =NumOfCoef-2 
	if (mod(NumOfGaussCoef, 3)!=0)
		print "The number of coef is not adequate"
		print "The number of coef should be 2+3*NumOfGauss"
	else
		NumOfGauss = NumOfGaussCoef/3
	endif	
	
	// print guass num
	// make initial flag and constraints wave 
	 print GasuuNumMessages[NumOfGauss-1]
	 make/t/o/n = (NumofGauss) tempConstraints = Constraints
	 wave ProcessedWCoef = CoefProcess(WCoef)
	 
	 // loop for searching good coef
	 if (SearchCoef == 1)
		 k=0
		 NumOfSearchLoop = 2*NumOfGauss
		 make/o/n = 14 WcoefChangePos = {2,4,5,7,8,10,11,13,14,16,17,19,20,22}
		 make/o/n = 10 Wcoefmagni = {0.01,0.1,0.125,0.25,0.5,2, 4, 8, 10, 100} 
		 make/o/n = (23, 150) WCoefList = 0
		 make/o/N = 150 ChiSqList = 100
		 make/o/n=23 ewave = 1e-5
		 do
		 	 variable Magni = WcoefMagni[k]
		 	 j=0
			 do 
				 Funcfit/q/H=FittingParameters[NumOfGauss-1] gaussfunc ProcessedWCoef wv[wavestart,waveend] /X=axis/D /C=tempConstraints /E=ewave;
				 errorVal = GetRTError(1)
				 if (errorVal == 0)
					 WCoefList[][k*10+j] = ProcessedWCoef[p]
					 ChiSqList[k*10+j] = V_Chisq
			  	 else
				 	 WCoefList[][k*10+j] = ProcessedWCoef[p]
					 ChiSqList[k*10+j] = 10000
				 endif
				 wave ProcessedWCoef = CoefProcess(WCoef)
				 ProcessedWcoef[WcoefChangePos[j]]*=Magni
				 j+=1
			 while (j<14)
			 k+=1
		 while(k<10)
    	 wavestats/q ChisqList
    	 ProcessedWcoef[] = WCoefList[p][V_minloc]
    endif
    
    // fit with passed wcoef
    Funcfit/q/H=FittingParameters[NumOfGauss-1] gaussfunc ProcessedWCoef wv[wavestart,waveend] /X=axis/D /C=tempConstraints;
    i=0
    do
	    variable CoefStart = i*3 + 2
	    variable CoefEnd = i*3 + 4
	    String FitGaussName="FitGauss"+num2str(i)
	    duplicate/o/R = [CoefStart,CoefEnd] Processedwcoef tempcoef
		 wave singlegausswv = SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], tempcoef[0], tempcoef[1], tempcoef[2])
		 duplicate/o singlegausswv $FitGaussName
		 AppendToGraph $FitGaussName vs axis
		 ModifyGraph lstyle($FitGaussName)=3,rgb($FitGaussName)=(0,0,0)
	    i+=1
	 while (i<NumOfGauss)
	 wcoef = Processedwcoef
	// change fit color 
	 ModifyGraph rgb($fitname)=(1,12815,52428)
end 

function MakeFitImages(wv,axis,wcoef, zNum, [AnalysisType])
	// arguments
	wave wv,axis, wcoef
	variable zNum, AnalysisType;
	// defined waves and variables
	variable i,j, k,l,pts, frompix,endpix;
	wave ProcessedWCoef, wv_2d
	variable xNum,yNum, SpatialPoints
	string FitImagename
	
	// obtain dimension size
	xNum=dimsize(wv,1);
	yNum=dimsize(wv,2);
	SpatialPoints = xNum*yNUm*zNUm
	pts=dimsize(wv,0);
	
	// check the num of coef, and gauss
	variable NumOfGaussCoef = dimsize(wcoef,0)-2
	if (mod(NumOfGaussCoef, 3)!=0)
		print "The number of coef is not adequate"
		print "The number of coef should be 2+3*NumOfGauss"
	else
		variable NumOfGauss = NumOfGaussCoef/3
	endif	
	
	// get frompix and endpix
	frompix = pcsr(A)
	endpix = pcsr(B)
	
	//make text waves

	make/o/T GasuuNumMessages={\
								"One Gauss fit",\
								"Two Gauss Fit",\
								"Three Gauss Fit",\
								"Four Gauss Fit",\
								"Five Gauss Fit",\
								"Six Gauss Fit",\
								"Seven Gauss Fit"}
	
	make/o/T Constraints={"K2>0","k5>0","k8>0","k11>0","k14>0","k17>0", "k20>0"}
	
	
	make/o/T FittingParametersForAmpAnalysis={\
								"11011111111111111111111",\
								"11011011111111111111111",\
								"11011011011111111111111",\
								"11011011011011111111111",\
								"11011011011011011111111",\
								"11011011011011011011111",\
								"11011011011011011011011"\
								}

	make/o/T FittingParametersForPeakPositionAnalysis={\
								"11000111111111111111111",\
								"11000000111111111111111",\
								"11000000000111111111111",\
								"11000000000000111111111",\
								"11000000000000000111111",\
								"11000000000000000000111",\
								"11000000000000000000000"\
								}
	// print guass num
	print GasuuNumMessages[NumOfGauss-1]

	//switch for analysis type
	Killwaves/z FittingParameters
	Switch (AnalysisType)
		case 1:
			print "Amplitude and Peak Position Analysis"
			duplicate/t FittingParametersForPeakPositionAnalysis FittingParameters
		break
		case 2:
			print "Amplitude and Area Analysis"
			duplicate/t FittingParametersForAmpAnalysis FittingParameters
		break
		default:
			print "Amplitude Analysis"
			duplicate/t FittingParametersForAmpAnalysis FittingParameters
	endswitch

	// make 2d wave 
	wave wv_2d = wave4Dto2DForFit(wv)
	
	make /n=(pts)/o temp
	make/o/n= (xNUm,yNUm,znum,NumofGauss) ResultWv
	make/o/n= (SpatialPoints,7) ResultWv2DAmp=0
	make/o/n= (SpatialPoints,7) ResultWv2DPeakPos=0
	make/o/n= (SpatialPoints,7) ResultWv2DArea=0
	
	//Loop for spatial points
	i=0
	do
		temp = wv_2d[p][i]
		make/t/o/n = (NumofGauss) tempConstraints = Constraints
		wave ProcessedWCoef = CoefProcess(WCoef)
		wave processedWcoef = LinearBaseline(frompix, endpix, temp, axis)
		Funcfit/Q/H=FittingParameters[NumOfGauss-1] gaussfunc ProcessedWCoef temp[frompix,endpix] /X=axis/D /C=tempConstraints;
		// Amplitude image
		ResultWv2DAmp[i][0] = processedWcoef[2]
		ResultWv2DAmp[i][1] = processedWcoef[5]
		ResultWv2DAmp[i][2] = processedWcoef[8]
		ResultWv2DAmp[i][3] = processedWcoef[11]
		ResultWv2DAmp[i][4] = processedWcoef[14]
		ResultWv2DAmp[i][5] = processedWcoef[17]
		ResultWv2DAmp[i][6] = processedWcoef[20]
		// Area (Amplitude * Width)
		ResultWv2DArea[i][0] = processedWcoef[2] * processedWcoef[4]
		ResultWv2DArea[i][1] = processedWcoef[5] * processedWcoef[7]
		ResultWv2DArea[i][2] = processedWcoef[8] * processedWcoef[10]
		ResultWv2DArea[i][3] = processedWcoef[11] * processedWcoef[13]
		ResultWv2DArea[i][4] = processedWcoef[14] * processedWcoef[16]
		ResultWv2DArea[i][5] = processedWcoef[17] * processedWcoef[19]
		ResultWv2DArea[i][6] = processedWcoef[20] * processedWcoef[22]
		// Peak Pos Wave
		ResultWv2DPeakPos[i][0] = processedWcoef[3]
		ResultWv2DPeakPos[i][1] = processedWcoef[6]
		ResultWv2DPeakPos[i][2] = processedWcoef[9]
		ResultWv2DPeakPos[i][3] = processedWcoef[12]
		ResultWv2DPeakPos[i][4] = processedWcoef[15]
		ResultWv2DPeakPos[i][5] = processedWcoef[18]
		ResultWv2DPeakPos[i][6] = processedWcoef[21]
		i+=1
	while(i<SpatialPoints)
	
	// make Amplitude images 
	//Loop for Gauss
	wave2Dto4DForFit(ResultWv2DAmp, xNum, ynum, znum)
	i=0
	do
		//Loop for z direction 
		j=0
		do
			// define image name 
			FitImagename="AmplitudeImage"+num2str(i)+"Z"+num2str(j)
			make/O/N=(xNum,yNum)/D $FitImagename = ResultWv[p][q][j][i]
			wave FitImage = $FitImagename
			display;appendimage $FitImagename;
			ModifyGraph width=300,height={Aspect,yNum/xNum}
			ModifyImage $FitImagename ctab= {0,*,Grays,0}
			j+=1
		while(j<zNUm)
		i+=1
	while(i<NumOfGauss)
	
	// make Area images 
	//Loop for Gauss
	if (AnalysisType == 2)
		wave2Dto4DForFit(ResultWv2DArea, xNum, ynum, znum)
		i=0
		do
			//Loop for z direction 
			j=0
			do
				// define image name 
				FitImagename="AreaImage"+num2str(i)+"Z"+num2str(j)
				make/O/N=(xNum,yNum)/D $FitImagename = ResultWv[p][q][j][i]
				wave FitImage = $FitImagename
				display;appendimage $FitImagename;
				ModifyGraph width=300,height={Aspect,yNum/xNum}
				ModifyImage $FitImagename ctab= {0,*,Grays,0}
				j+=1
			while(j<zNUm)
			i+=1
		while(i<NumOfGauss)
	endif
	
	// make peak pos image
	if (NumOfGauss == 1 && AnalysisType == 1)
		wave2Dto4DForFit(ResultWv2DPeakPos, xNum, ynum, znum)
		i = 0
		do
			// define image name 
			FitImagename="PeakPosImage"+"Z"+num2str(i)
			make/o/n=(xNum, yNUm) $FitImagename = resultwv[p][q][0][0]
			display;appendimage $FitImagename;
			ModifyGraph width=300,height={Aspect,yNum/xNum}
			ModifyImage $FitImagename ctab= {0,*,Grays,0}
			i+=1
		while(i<zNUm)
	endif

end

Function/wave wave4Dto2DForFit(wv)	//rearrange the 4D wave to 2Dwave
	wave	wv;
	variable Numx,Numy,Numz;
	variable i,j,k,l, wvNum;
	variable start, startnum, endnum, pixelnum, num


	Numx = dimsize(wv, 1)
	Numy = dimsize(wv, 2)
	Numz = dimsize(wv, 3)
	wvNum = dimsize(wv, 0)
	pixelnum = Numx*Numy*Numz

	make/O/N=(wvNum,pixelnum)/D wv_2d;
	// loop for z 
	k = 0;
	num=0
	do
		//loop for y
		j =0 
		do
			// loop for x
			i =0 
			do
				wv_2D[][num] = wv[p][i][j][k];
				num+=1
				i+=1
			while(i<Numx)
			j+=1
		while(j<Numy)
		k += 1
	while(k < Numz)
	return wv_2d
end

Function wave2Dto4DForFit(wv, nUmx, numy, numz)	
	wave	wv;
	variable Numx,Numy,Numz;
	variable i,j,k,l, wvNum, SpatialPoints;
	variable start, startnum, endnum, pixelnum, num

	wvNum = dimsize(wv, 0)
	SpatialPoints = Numx*Numy*numz

	make/O/N=(Numx, Numy, Numz, 7)/D ResultWv;
	// loop for z 
	k = 0;
	num=0
	do
		//loop for y
		j =0 
		do
			// loop for x
			i =0 
			do
				ResultWv[i][j][k][0] = wv[num][0]
				ResultWv[i][j][k][1] = wv[num][1]
				ResultWv[i][j][k][2] = wv[num][2]
				ResultWv[i][j][k][3] = wv[num][3]
				ResultWv[i][j][k][4] = wv[num][4]
				ResultWv[i][j][k][5] = wv[num][5]
				ResultWv[i][j][k][6] = wv[num][6]
				num+=1
				i+=1
			while(i<Numx)
			j+=1
		while(j<Numy)
		k += 1
	while(k < Numz)
end

//preprocessing the coefs
Function/wave CoefProcess(WCoef)
// WCoef: coef wave
	wave WCoef
	variable CoefNum = dimsize(WCoef,0)
	make/o/d/n=23 ProcessedWCoef = 0 
	ProcessedWCoef[0,CoefNum-1]= WCoef[p]
	return processedWcoef
end


function/wave LinearBaseline(FromPx, EndPx, wv, axis)
	wave wv, axis
	variable FromPx, EndPx
	wave ProcessedWCoef
	ProcessedWcoef[0] = (wv[EndPx]-wv[FromPx])/(axis[EndPx]-axis[FromPx])*(-axis[FromPx])+wv[FromPx]
	ProcessedWCoef[1] = (wv[EndPx]-wv[FromPx])/(axis[EndPx]-axis[FromPx])
	return ProcessedWCoef
end



// Initial fitting function
function InitialFitFixAmpWidth(wv, xaxis, wcoef)
	// Author: Shinichi Miyazaki
	
	// arguments
	wave wv, xaxis, wcoef
	// predifined waves
	wave ProcessedWCoef
	variable NumOfGauss, i, j,k, NumOfSearchLoop
	// define the fit wave name 
	String fitName = "fit_" + nameOfWave(wv)
	// obtain cursor position from graph
	variable WaveStart = pcsr(A)
	variable WaveEnd = pcsr(B)
	// For error Catch
	variable errorVal
	//Define the text waves
	make/o/T GasuuNumMessages={\
								"One Gauss fit",\
								"Two Gauss Fit",\
								"Three Gauss Fit",\
								"Four Gauss Fit",\
								"Five Gauss Fit",\
								"Six Gauss Fit",\
								"Seven Gauss Fit"\
                                }

    make/o/T Constraints={"K2>0","k5>0","k8>0","k11>0","k14>0","k17>0", "k20>0"}
	 make/o/T FittingParameters={\
								"00011111111111111111111",\
								"00011011111111111111111",\
								"00011011011111111111111",\
								"00011011011011111111111",\
								"00011011011011011111111",\
								"00011011011011011011111",\
								"00011011011011011011011"\
								}
	
	// Kill waves and remove graph, for repeated use
	RemoveFromGraph/z $fitName
	RemoveFromGraph/z FitGauss0, Fitgauss1, FitGauss2, FitGauss3, FitGauss4, FitGauss5, FitGauss6, FitGauss7
	Killwaves/z fit_tempwv
	Killwaves/z FitGauss0, Fitgauss1, FitGauss2, FitGauss3, FitGauss4, FitGauss5, FitGauss6, FitGauss7
	
	// Duplicate wv
	Duplicate/o wv tempwv
	Duplicate/o xaxis Axis
	
	// Initial baseline 
	InitBase(wv,axis,wcoef)
	
	// check the num of coef, and gauss
	variable NumOfCoef = dimsize(wcoef,0)
	variable NumOfGaussCoef =NumOfCoef-2 
	if (mod(NumOfGaussCoef, 3)!=0)
		print "The number of coef is not adequate"
		print "The number of coef should be 2+3*NumOfGauss"
	else
		NumOfGauss = NumOfGaussCoef/3
	endif	
	
	// print guass num
	// make initial flag and constraints wave 
	 print GasuuNumMessages[NumOfGauss-1]
	 make/t/o/n = (NumofGauss) tempConstraints = Constraints
	 wave ProcessedWCoef = CoefProcess(WCoef)
    
    // fit with passed wcoef
    Funcfit/q/H=FittingParameters[NumOfGauss-1] gaussfunc ProcessedWCoef wv[wavestart,waveend] /X=axis/D /C=tempConstraints;
    i=0
    do
	    variable CoefStart = i*3 + 2
	    variable CoefEnd = i*3 + 4
	    String FitGaussName="FitGauss"+num2str(i)
	    duplicate/o/R = [CoefStart,CoefEnd] Processedwcoef tempcoef
		 wave singlegausswv = SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], tempcoef[0], tempcoef[1], tempcoef[2])
		 duplicate/o singlegausswv $FitGaussName
		 AppendToGraph $FitGaussName vs axis
		 ModifyGraph lstyle($FitGaussName)=3,rgb($FitGaussName)=(0,0,0)
	    i+=1
	 while (i<NumOfGauss)
	 wcoef = Processedwcoef
	// change fit color 
	 ModifyGraph rgb($fitname)=(1,12815,52428)
end 

function FitAndNormalize(wv,axis,wcoef, zNum)
	// Use initial fit for setting wcoef before running this script
	// Only One gauss
	// Author Shinichi Miyazaki
	// 20220826
	
	// arguments
	wave wv,axis, wcoef
	variable zNum
	// defined waves and variables
	variable i,j, k,l,pts, frompix,endpix;
	wave ProcessedWCoef, wv_2d
	variable xNum,yNum, SpatialPoints
	string FitImagename
	
	//Threshold 
	variable threshold = 0.01
	
	// obtain dimension size
	xNum=dimsize(wv,1);
	yNum=dimsize(wv,2);
	SpatialPoints = xNum*yNUm*zNUm
	pts=dimsize(wv,0);
	
	// get frompix and endpix
	frompix = pcsr(A)
	endpix = pcsr(B)

	make/o/T Constraints={"K2>0"}

	// make 2d wave 
	wave wv_2d = wave4Dto2DForFit(wv)
	
	make /n=(pts)/o temp
	make/o/n= (xNUm,yNUm,znum,7) ResultWv
	make/o/n= (SpatialPoints,7) ResultWv2DAmp=0
	make/o/n= (SpatialPoints,7) ResultWv2DPeakPos=0
	make/o/n= (SpatialPoints,7) ResultWv2DArea=0
	
	Duplicate/o wv_2d AnsWave_2d
	//Loop for spatial points
	i=0
	do
		temp = wv_2d[p][i]
		wave ProcessedWCoef = CoefProcess(WCoef)
		wave processedWcoef = LinearBaseline(frompix, endpix, temp, axis)
		Funcfit/Q/H="11011111111111111111111" gaussfunc ProcessedWCoef temp[frompix,endpix] /X=axis/D /C=Constraints;
		
		if (processedWcoef[2]<Threshold)
			AnsWave_2d[][i] = 0
		else
			AnsWave_2d[][i] = wv_2d[p][i]/processedWcoef[2]
		endif
		i+=1
	while (i<spatialPoints)
	wave2dto4DForNorm(AnsWave_2d, xNum, yNum, zNum)
end

Function Wave2Dto4DforNorm(wv,Numx,Numy,Numz,[DataType,SlidePxNum])	
	/// Author: Shinichi Miyazaki
	/// This function rearrange the 2D wave to 4D wave
	/// @params	wv: 2D wave (wavenum, xyz)
	/// @params	Numx, Numy, Numz: variable (Number of spatial points)
	/// @params	DataType: variable (default	: no z direction zigzag, axis order is xyZ
	///										1		: z direction zigzag, axis order is xZy
	///										2		: z direction zigzag, axis order is xyZ
	///										3		: one way capturing, xy scan (for IIIS))
	/// Outputs
	/// CARS: 4D wave (wavenum, x, y, z)
	wave	wv;
	variable	Numx,Numy,Numz,DataType, SlidePxNum;
	variable	i,j,k,wvNum;
	variable start,startnum,endnum, ZCenter, nextstartnum,nextendnum
	// make destination wave. the name is CARS
	wvNum = dimsize(wv, 0)
	make/O/N=(wvNum,Numx,Numy,Numz)/D CARS;
	// Switch depend on data type
	Switch (DataType)
		case 1:
			print "z direction zigzag, axis order is xZy"
			//judgement for even or odd
			if(mod(Numy,2)==0)
				ZCenter=(Numy)/2
			else
				ZCenter=(Numy-1)/2
			endif
			i=0;
			j=0;
			k=0;
			do
				do
					start = i * Numx * Numy
					startnum =  start + k * Numx
					endnum = start + (k+1) * Numx
					Duplicate/Free/R=[0,*][startnum,endnum] wv tempwv
					nextstartnum =  start + (k+1) * Numx
					nextendnum = start + (k+2) * Numx
					Duplicate/Free/R=[0,*][nextstartnum,nextendnum] wv nexttempwv
					if(j==0)
						CARS[][][ZCenter][i]=tempwv[p][q]
						j+=1
						k+=1
					else
						CARS[][][ZCEnter+j][i]=tempwv[p][q]
						CARS[][][ZCenter-j][i]=nexttempwv[p][q]
						j+=1
						k+=2
					endif
				while(j<=ZCenter)
				i+=1
			while(i<Numz)
		break
			
		case 2:
			print "z direction zigzag, axis order is xyZ"
			//judgement for even or odd
			if(mod(Numz,2)==0)
				ZCenter=(Numz)/2
			else
				ZCenter=(Numz-1)/2
			endif
			//i for z num 
			i=0;
			j=0;
			// count for mod
			k=0;
			do
				j=0
				do
					if(i==0)
						start = i * Numx * Numy
						startnum = start + j * Numx
						endnum = start + (j+1) * Numx
						Duplicate/Free/R=[0,*][startnum,endnum] wv tempwv
						CARS[][][j][Zcenter] =tempwv[p][q]
						j+=1
					elseif(mod(i,2)==1)
						start = i * Numx * Numy
						startnum = start + j * Numx
						endnum = start + (j+1) * Numx
						Duplicate/Free/R=[0,*][startnum,endnum] wv tempwv
						CARS[][][j][Zcenter+k] =tempwv[p][q]
						j+=1
					elseif(mod(i,2)==0)
						start = i * Numx * Numy
						startnum = start + j * Numx
						endnum = start + (j+1) * Numx
						Duplicate/Free/R=[0,*][startnum,endnum] wv tempwv
						CARS[][][j][Zcenter-k] =tempwv[p][q]
						j+=1
					endif
				while(j<Numy)
				i+=1
				if(mod(i,2)==1)
					k=(i+1)/2
				else
					k=i/2
				endif
			while(i<Numz)
		break

		case 3: 
			print "one way capturing, xy scan"
			for(j=0; j<Numy; j=j+1)
				if (j==0)
					startnum = j * Numx
					endnum = (j+1) * Numx
					Duplicate/Free/R=[0,*][startnum,endnum] wv tempwv
					CARS[][][j][0] = tempwv[p][q];
				elseif (mod(j,2) == 0)	
					startnum = j * Numx
					endnum = (j+1) * Numx
					Duplicate/Free/R=[0,*][startnum,endnum] wv tempwv
					CARS[][][j][0] = tempwv[p][q];
				elseif (mod(j,2) == 1)
					startnum = j * Numx
					endnum = (j+1) * Numx
					Duplicate/Free/R=[0,*][startnum+SlidePxNum,endnum+SlidePxNum] wv tempwv
					imagetransform flipcols tempwv 
					CARS[][][j][0] = tempwv[p][q];
				endif
			endfor
		break

			
		default:
			print "no z direction zigzag, axis order is xyZ"
			i=0;
			j=0;
			do
				for(j=0;j<Numy;j=j+1)
					start = i * Numx * Numy
					startnum =  start + j * Numx
					endnum = start + (j+1) * Numx
					Duplicate/Free/R=[0,*][startnum,endnum] wv tempwv
					CARS[][][j][i] = tempwv[p][q];
				endfor
				i+=1
			while(i<Numz)
		Endswitch
end


///// 004RatiometricAnalysis

function MakeRatiometricImage(image1, image2, LowerThreshold)
	wave image1, image2
	variable LowerThreshold
	variable xNum, yNum
	variable i, j

	// get x, y range
	xNum = dimsize(image1,0)
	yNum = dimsize(image1,1)
	MatrixOp/O tempimage = setNaNs(image2,greater(LowerThreshold,image2))
	matrixop/o RatioImage=image1/tempimage
	matrixop/o ratioimage = replacenans(ratioimage, 0)
   NewImage RatioImage
   ModifyGraph noLabel=2,axThick=0
   ModifyGraph margin(right)=141,width=425.197,height={Aspect,1}
   ColorScale/C/N=text0/F=0/A=MC/X=-15.00/Y=0.00 image=RatioImage
end


///// 006Imageplot /////
Function MakeEdgesWave(centers, edgesWave)
	Wave centers // Input
	Wave edgesWave // Receives output
	Variable N=numpnts(centers)
	Redimension/N=(N+1) edgesWave
	edgesWave[0]=centers[0]-0.5*(centers[1]-centers[0])
	edgesWave[N]=centers[N-1]+0.5*(centers[N-1]-centers[N-2])
	edgesWave[1,N-1]=centers[p]-0.5*(centers[p]-centers[p-1])
End

///// 008GUI /////
function GUI()
 //Author: Kyosuke Tanaka

 //This script is for analyzing imchi3_data with GUI
 //Please import imchi3_data and re_ramanshift2 before using
 variable zstack
 wave imchi3_data,re_ramanshift2
 variable wvnum,xnum,ynum,znum,knum,i
 variable xpoint,ypoint,flagimchi,flagreraman,switchnum=0
 string strX,strY,Graphname
 
 flagimchi=waveexists(imchi3_data)
 flagreraman=waveexists(re_ramanshift2)
 
 if(flagimchi==1)
  if(flagreraman==1)
   
  prompt wvnum,"please put wavenumber that you want to show image"
 doprompt "",wvnum

 wvnum=ceil((wvnum-re_ramanshift2[0])/((re_ramanshift2[dimsize(re_ramanshift2,0)-1]-re_ramanshift2[0])/dimsize(re_ramanshift2,0)))
 
 xnum=dimsize(imchi3_data,1)
 ynum=dimsize(imchi3_data,2)
 znum=dimsize(imchi3_data,3)
 knum=dimsize(imchi3_data,0)
 
 make/n=(xnum,ynum)/o imGUIwv
 
 imGUIwv[][]=imchi3_data[wvnum][p][q][0]
  
 
 newimage/N=imGUI imGUIwv
 SetAxis/A left
 showinfo
  
 cursor/i/a=1/c=(0,0,60000,65000) a imguiwv round(xnum/2),round(ynum/2)
  
 
 xpoint=pcsr(A)
 ypoint=qcsr(A) 
 
 strX=num2str(xpoint)
 strY=num2str(ypoint)
  
 make/o/n=(knum) imchi3GUI_data
 
 imchi3GUI_data=imchi3_data[p][xpoint][ypoint][0]
 
 display/N=imGUIspe/W=(0,0,500,250) imchi3GUI_data vs re_ramanshift2 
 cursor/w=imGUIspe/a=1/c=(0,0,60000,65000) A imchi3GUI_data wvnum
 SetAxis/A/R bottom
 
 newpanel/FLT=0/N=imGUIspe_controlpanel/W=(0,0,170,150)/HOST=imGUIspe/EXT=0/NA=0 
 //Control panel for spectrum
 Button imGUIreimage title="reload image with another wavenumber",size={150,20},pos={10,10},proc=ButtonProcimGUIreimage
 Button imGUIspeimage title="image using cumurative signal intensity",size={150,20},pos={10,50},proc=ButtonProcimGUIspeimage
 
 
 newpanel/FLT=0/N=imGUI_controlpanel/W=(0,0,300,300)/HOST=imgui/EXT=0/NA=0
 //Control panel for image 
 
 if(znum>1) 
 Slider slider0,pos={30,110},vert=1,proc=SliderProcimGUIzstack,size={30,znum*10},limits={0,znum-1,1},value=0
 ValDisplay imGUIval title="zstack",value=0,size={65,16},pos={20,80},fstyle=1, ticks=2
 endif
 
 Button imcont1 title="upper" ,proc=ButtonProcimcont1,pos={61,11}

 Button imcont2 title="lower" ,proc=ButtonProcimcont2,pos={61,40}
 
 Button imcont3 title="right" ,proc=ButtonProcimcont3,pos={121,25}

 Button imcont4 title="left" ,proc=ButtonProcimcont4,pos={1,25}
 
 Button imGUI6 title="write spectrum",proc=ButtonProcimcontspe,size={150,20},pos={140,60}
 
 CheckBox imGUIchick title="overwrite",value=1,proc=CheckProcimGUIcheck,pos={145,150}
 
 Button imGUI7 title="average in roi",size={150,20},pos={140,90},proc=ButtonProcimcontregion_analysis
 
 Button button0 title="delete",proc=ButtonProc_imGUIdelete,size={50,20},pos={230,20}
 
 Button buttonimGUI_highpass title="highpass",proc=ButtonProc_highpass,pos={140,180},size={70,20}
 
 Button buttonimGUI_lowpass title="lowpass",proc=ButtonProc_lowpass,pos={140,200},size={70,20}
 
 //Button buttonimGUI_xy title="X-Y",proc=ButtonProcimGUI_XY,pos={230,180}
 
 Button buttonimGUI_xz title="X-Z",proc=ButtonProcimGUI_XZ,pos={230,200}
 
 Button buttonimGUI_yz title="Y-Z",proc=ButtonProcimGUI_yz,pos={230,220}
 
 Button buttonimGUI_sumfromimage title="sumfromimage" ,proc=ButtonProc_sumfromimage,pos={140,120},size={150,20}
 
 make/o/n=9 imGUIcontrol

 imGUIcontrol[0]=xnum         //imchi3_data xnum
 imGUIcontrol[1]=ynum         //imchi3_data ynum
 imGUIcontrol[2]=znum         //imchi3_data znum
 imGUIcontrol[3]=xpoint       //Current X position in imGUIwv
 imGUIcontrol[4]=ypoint       //Current Y position in imGUIwv
 imGUIcontrol[5]=0            //Current Z position in imGUIwv
 imGUIcontrol[6]=wvnum        //Current position in imGUIspe
 imGUIcontrol[7]=switchnum    //image direction
 imGUIcontrol[8]=1            //overwrite or not
 showinfo/W=imGUI
 
  elseif(flagreraman==0)
  wave m_ramanshift1
  if(waveexists(m_ramanshift1)==1)
   print "there is no m_ramanshift1"
  endif
  endif
  
 elseif(flagimchi==0)
  print "there is no imchi3_data, if you changed name, it does not work."
 endif
  
end



Function ButtonProcimcont1(ba) : ButtonControl
   ///upprt button
	STRUCT WMButtonAction &ba
   wave imGUIcontrol,imchi3_data,re_ramanshift2,imGUIwv,imchi3GUI_data
   string Graphname
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUI
			//showinfo/w=imGUI
		 if(imGUIcontrol[7]==0)
			imGUIcontrol[3]=pcsr(A)
			imGUIcontrol[4]=qcsr(A)	
			imGUIcontrol[4]+=1
		   
		   if(imGUIcontrol[4]>imGUIcontrol[1]-1)
		    imGUIcontrol[4]-=1
		   else
		    cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[3],imGUIcontrol[4]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
			
		 elseif(imGUIcontrol[7]==2)
		   imGUIcontrol[4]=pcsr(A)
			imGUIcontrol[5]=qcsr(A)	
			imGUIcontrol[4]+=1
		   
		   if(imGUIcontrol[4]>imGUIcontrol[1]-1)
		    imGUIcontrol[4]-=1
		   else
		    cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[4],imGUIcontrol[5]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
		 
		 endif
			break
		case -1: // control being killed
		   
			break
	endswitch

	return 0
End



Function ButtonProcimcont2(ba) : ButtonControl
   ///lower button function
	STRUCT WMButtonAction &ba
   wave imGUIcontrol,imchi3_data,re_ramanshift2,imchi3GUI_data
   string Graphname
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUI
			//showinfo/w=imGUI
		 if(imGUIcontrol[7]==0)
			imGUIcontrol[3]=pcsr(A)
			imGUIcontrol[4]=qcsr(A)
			imGUIcontrol[4]-=1
		   
		   if(imGUIcontrol[4]<0)
		    imGUIcontrol[4]+=1
		   else
   	       cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[3],imGUIcontrol[4]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
		 
		 elseif(imguicontrol[7]==2)
		   imGUIcontrol[4]=pcsr(A)
			imGUIcontrol[5]=qcsr(A)
			imGUIcontrol[4]-=1
		   
		   if(imGUIcontrol[4]<0)
		    imGUIcontrol[4]+=1
		   else
   	       cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[4],imGUIcontrol[5]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
		 
		 endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function ButtonProcimcont3(ba) : ButtonControl
   ///right button function
	STRUCT WMButtonAction &ba
	wave imGUIcontrol,imchi3_data,re_ramanshift2,imchi3GUI_data
	string Graphname
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUI
			//showinfo/w=imGUI
			
			imGUIcontrol[3]=pcsr(A)
			imGUIcontrol[4]=qcsr(A)
			imGUIcontrol[3]+=1
			
			if(imGUIcontrol[3]>imGUIcontrol[0]-1)
			 imGUIcontrol[3]-=1
			else
		    cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[3],imGUIcontrol[4]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function ButtonProcimcont4(ba) : ButtonControl
	///left button function
	STRUCT WMButtonAction &ba
   wave imGUIcontrol,imchi3_data,re_ramanshift2,imchi3GUI_data
   string Graphname
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUI
			//showinfo/w=imGUI
			
			imGUIcontrol[3]=pcsr(A)
			imGUIcontrol[4]=qcsr(A)
			imGUIcontrol[3]-=1
			
			if(imGUIcontrol[3]<0)
			 imGUIcontrol[3]+=1
			else
		    cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[3],imGUIcontrol[4]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcimcont5(ba) : ButtonControl
	///upper button function for z direction
	STRUCT WMButtonAction &ba
   wave imGUIcontrol,imchi3_data,re_ramanshift2,imchi3GUI_data
   string Graphname
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUI
			//showinfo/w=imGUI
			if(imGUIcontrol[7]==1)
			 imGUIcontrol[3]=pcsr(A)
			 imGUIcontrol[5]=qcsr(A)
			 imGUIcontrol[5]+=1
			
			 if(imGUIcontrol[5]>imGUIcontrol[2]-1)
			  imGUIcontrol[5]-=1
			 else
		     cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[3],imGUIcontrol[5]
		     imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			 endif
			
			elseif(imGUIcontrol[7]==2)
			 imGUIcontrol[4]=pcsr(A)
			 imGUIcontrol[5]=qcsr(A)
			 imGUIcontrol[5]+=1
			 
			 if(imGUIcontrol[5]>imGUIcontrol[2]-1)
			  imGUIcontrol[5]-=1
			 else
		     cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[4],imGUIcontrol[5]
		     imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			 endif
			
			endif
			
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcimcont6(ba) : ButtonControl
	///lower button function for z direction
	STRUCT WMButtonAction &ba
   wave imGUIcontrol,imchi3_data,re_ramanshift2,imchi3GUI_data
   string Graphname
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUI
			//showinfo/w=imGUI	
			if(imGUIcontrol[7]==1)
			 imGUIcontrol[3]=pcsr(A)
			 imGUIcontrol[5]=qcsr(A)
			 imGUIcontrol[5]-=1
			
			 if(imGUIcontrol[5]<0)
			  imGUIcontrol[5]+=1
			 else
		     cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[3],imGUIcontrol[5]
		     imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			 endif
			
			elseif(imGUIcontrol[7]==2)
			 imGUIcontrol[4]=pcsr(A)
			 imGUIcontrol[5]=qcsr(A)
			 imGUIcontrol[5]-=1
			 
			 if(imGUIcontrol[5]<0)
			  imGUIcontrol[5]+=1
			 else
		     cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[4],imGUIcontrol[5]
		     imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			 endif
			
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function SliderProcimGUIzstack(sa) : SliderControl
	STRUCT WMSliderAction &sa
   wave imGUIcontrol,imGUIwv,imchi3_data
   variable/G zstack
	switch( sa.eventCode )
		case -3: // Control received keyboard focus
		case -2: // Control lost keyboard focus
		case -1: // Control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				
				Variable curval = sa.curval
				
				imGUIcontrol[5]=curval
				ValDisplay imGUIval value=_NUM:curval
				
				hideinfo/w=imGUIspe
		     	showinfo/w=imGUIspe
			
			   
			
		    	imGUIwv[][]=imchi3_data[imGUIcontrol[6]][p][q][curval]
			endif
			break
	endswitch
	return 0
End


Function ButtonProcimcontspe(ba) : ButtonControl
   //button for write spectrum
	STRUCT WMButtonAction &ba
	wave imchi3GUI_data,imGUIcontrol,re_ramanshift2
   string xxx,yyy,wvname,wvnamesta
   variable flagspe,flagspesta
   wave aaa
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
		
			hideinfo/w=imGUI
			showinfo/w=imGUI
			
			xxx=num2str(pcsr(a))
			yyy=num2str(qcsr(a))
			wvname="imspe"+xxx+"x"+yyy+"x"+num2str(imGUIcontrol[5])		
			
			
			duplicate/o imchi3GUI_data aaa

			 flagspe=waveexists($wvname)
			
			 if(flagspe==1)
			  print "spectrum at this position was already drawn"
					 
		    elseif(flagspe==0)
		     rename aaa $wvname
		     if(imGUIcontrol[8]==1)
			   AppendToGraph/C=(0,65535,65535)/L/W=imGUIspe $wvname vs re_ramanshift2
			  endif
		    endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function CheckProcimGUIcheck(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
   wave imGUIcontrol
	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			imGUIcontrol[8]=checked
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcimcontregion_analysis(ba) : ButtonControl
   //button for spatial average
	STRUCT WMButtonAction &ba
   variable largeX,smallX,largeY,smallY,i,j,flagavrgwv,flagstre
   wave imGUIcontrol,avrgwv,re_ramanshift2
   string avrgwvname
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUI
			showinfo/w=imGUI
			
			make/o/n=1 avrgwv
			//for unknown reason, avrgwv must be made here 
						
			largeX=max(pcsr(a),pcsr(b))
			smallX=min(pcsr(a),pcsr(b))
			largeY=max(qcsr(a),qcsr(b))
			smallY=min(qcsr(a),qcsr(b))
			
			avrgwvname="region_ave"+num2str(smallX)+"~"+num2str(largeX)+","+num2str(smallY)+"~"+num2str(largeY)+"_"+num2str(imGUIcontrol[5])
			flagavrgwv=waveexists($avrgwvname)

			if(flagavrgwv==0)
			 make/o/n=(imGUIcontrol[0],imGUIcontrol[1]) imGUIregion	
		    imGUIregion=0
								
			 for(i=smallX;i<largeX+1;i+=1)
			  for(j=smallY;j<largeY+1;j+=1)
			  
			   imGUIregion[i][j]=1
			  			  
			  endfor
			 endfor
			
			  region_analysisforimGUI()
			  		  
			  rename avrgwv $avrgwvname
			  
			  if(imGUIcontrol[8]==1)
			   AppendToGraph/C=(0,65535,0)/L/W=imGUIspe $avrgwvname vs re_ramanshift2
			  endif
                       
			elseif(flagavrgwv==1)
			 print "spectrum at this position was already drawn"
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function region_analysisforimGUI()
    //almost same as stre()
	//this script is not compativle for region_analysis, because Roiwave differs
    wave imchi3_data,imGUIregion,avrewv,imGUIcontrol
    variable pts, xNum, yNum;
    variable i, j;
  
    pts = dimsize(imchi3_data, 0)
    xNum = dimsize(imchi3_data, 1)
    yNum = dimsize(imchi3_data, 2)

 
    make/o/n=(pts,xNum,yNum) extractedwv
    make/o/n=(pts,xNum,yNum) tempwv
    tempwv[][][]=imchi3_data[p][q][r][imGUIcontrol[5]]

    i=0
    do
        j=0
        do
            extractedwv[][i][j] = tempwv[p][i][j] *imGUIregion[i][j]
            j+=1
        while(j<yNUm)
        i+=1
    while(i<xNum)
    
    matrixop/o temp = sumrows(extractedwv)
    matrixop/o roinum = sum(imGUIregion)
    matrixop/o avrgwv = sumbeams(temp)/roinum[0]
    
    killwaves extractedwv,temp,tempwv,roinum
    
end



Function ButtonProcimGUIreimage(ba) : ButtonControl
   //button for redraw
	STRUCT WMButtonAction &ba
	wave imchi3_data,imGUIcontrol,imGUIwv,re_ramanshift2
	variable wvnum
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUIspe
			//showinfo/w=imGUIspe
			
			wvnum=pcsr(a)
			
			imGUIcontrol[6]=wvnum
			
			imGUIwv[][]=imchi3_data[wvnum][p][q][imGUIcontrol[5]]
      
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcimGUIspeimage(ba) : ButtonControl
   //button for redraw an image with cumurative intensity of spectrum
	STRUCT WMButtonAction &ba
	wave imchi3_data,imGUIcontrol,imGUIwv,re_ramanshift2
	variable wvnum,wvnum2,pnum,qnum,i,j,k,cons,ave
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUIspe
			//showinfo/w=imGUIspe
						
			wvnum=max(pcsr(a),pcsr(b))
			wvnum2=min(pcsr(a),qcsr(b))
			
			imGUIwv=0
			
			if(imGUIcontrol[7]==0)			
			pnum=imGUIcontrol[0]
			qnum=imGUIcontrol[1]
			for(k=0;k<pnum;k+=1)
			 for(j=0;j<qnum;j+=1)
			 ave=(imchi3_data[pcsr(a)][k][j][imGUIcontrol[5]]-imchi3_data[pcsr(b)][k][j][imGUIcontrol[5]])/(pcsr(a)-pcsr(b))
			 cons=imchi3_data[pcsr(a)][k][j][imGUIcontrol[5]]-ave*pcsr(a)
			  for(i=wvnum2;i<wvnum+1;i+=1)
			   imGUIwv[k][j]+=imchi3_data[i][k][j][imGUIcontrol[5]]+(i*ave+cons)
	        endfor
          endfor
         endfor
         
         elseif(imGUIcontrol[7]==1)
			pnum=imGUIcontrol[0]
			qnum=imGUIcontrol[2]
			for(k=0;k<pnum;k+=1)
			 for(j=0;j<qnum;j+=1)
			  for(i=wvnum2;i<wvnum+1;i+=1)
			   imGUIwv[k][j]+=imchi3_data[i][k][imGUIcontrol[4]][j]-(i*(imchi3_data[pcsr(a)][k][imGUIcontrol[4]][j]-imchi3_data[pcsr(b)][k][imGUIcontrol[4]][j])/(xcsr(a)-xcsr(b)+imchi3_data[pcsr(a)][k][imGUIcontrol[4]][j]-imchi3_data[pcsr(b)][k][imGUIcontrol[4]][j])/(xcsr(a)-xcsr(b))*xcsr(a))
	        endfor
          endfor
         endfor
			
			elseif(imGUIcontrol[7]==2)
			pnum=imGUIcontrol[1]
			qnum=imGUIcontrol[2]
			for(k=0;k<pnum;k+=1)
			 for(j=0;j<qnum;j+=1)
			  for(i=wvnum2;i<wvnum+1;i+=1)
			   imGUIwv[k][j]+=imchi3_data[i][imGUIcontrol[3]][k][j]-(i*(imchi3_data[pcsr(a)][imGUIcontrol[3]][k][j]-imchi3_data[pcsr(b)][imGUIcontrol[3]][k][j])/(xcsr(a)-xcsr(b)+imchi3_data[pcsr(a)][imGUIcontrol[3]][k][j]-imchi3_data[pcsr(b)][imGUIcontrol[3]][k][j])/(xcsr(a)-xcsr(b))*xcsr(a))
	        endfor
          endfor
         endfor
			endif
         
         
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function ButtonProc_imGUIdelete(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			killwindow/Z imGUI
			killwindow/Z imGUIspe
			killwindow/Z imGUI_controlpanel
			
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ButtonProcimGUI_XY(ba) : ButtonControl
	STRUCT WMButtonAction &ba
   wave imGUIcontrol,imchi3_data

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			imGUIcontrol[7]=0
					
			make/o/n=(imGUIcontrol[0],imGUIcontrol[1]) imGUIwv
			
		   imGUIwv[][]=imchi3_data[imGUIcontrol[6]][p][q][0]
			
			killwindow imGUI						
			newimage/N=imGUI imGUIwv
			SetAxis/A left
			cursor/i/a=1/c=(0,0,60000,65000) a imguiwv round(imGUIcontrol[0]/2),round(imGUIcontrol[1]/2)
			newpanel/FLT=0/N=imGUI_controlpanel/W=(0,0,300,300)/HOST=imgui/EXT=0/NA=0
			if(imGUIcontrol[2]>1) 
          Slider slider0,pos={30,110},vert=1,proc=SliderProcimGUIzstack,size={30,imGUIcontrol[2]*10},limits={0,imGUIcontrol[2]-1,1},value=0
          ValDisplay imGUIval title="zstack",value=0,size={65,16},pos={20,80},fstyle=1, ticks=2
         endif
			Button imcont1 title="upper" ,proc=ButtonProcimcont1,pos={61,11}
			Button imcont2 title="lower" ,proc=ButtonProcimcont2,pos={61,40}
			Button imcont3 title="right" ,proc=ButtonProcimcont3,pos={121,25}
			Button imcont4 title="left" ,proc=ButtonProcimcont4,pos={1,25}
			Button imGUI6 title="draw spectrum",proc=ButtonProcimcontspe,size={150,20},pos={140,60}
			CheckBox imGUIchick title="overlap on graph",value=1,proc=CheckProcimGUIcheck,pos={145,150}
			Button imGUI7 title="spatial average",size={150,20},pos={140,90},proc=ButtonProcimcontregion_analysis
			Button button0 title="delete",proc=ButtonProc_imGUIdelete,size={50,20},pos={230,20}
			Button buttonimGUI_highpass title="highpass",proc=ButtonProc_highpass,pos={140,180},size={70,20}
			Button buttonimGUI_lowpass title="lowpass",proc=ButtonProc_lowpass,pos={140,200},size={70,20}
			//Button buttonimGUI_xy title="X-Y",proc=ButtonProcimGUI_XY,pos={230,180}
			Button buttonimGUI_xz title="X-Z",proc=ButtonProcimGUI_XZ,pos={230,200}
			Button buttonimGUI_yz title="Y-Z",proc=ButtonProcimGUI_yz,pos={230,220}
			Button buttonimGUI_sumfromimage title="sumfromimage" ,proc=ButtonProc_sumfromimage,pos={140,120},size={150,20}
			imGUIcontrol[8]=1  		
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcimGUI_XZ(ba) : ButtonControl
	STRUCT WMButtonAction &ba
   wave imGUIcontrol,imchi3_data

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			imGUIcontrol[7]=1
					
			make/o/n=(imGUIcontrol[0],imGUIcontrol[2]) imGUIwv
			
		   imGUIwv[][]=imchi3_data[imGUIcontrol[6]][p][0][q]
			
			killwindow imGUI			
			newimage/N=imGUI imGUIwv
			SetAxis/A left
			cursor/i/a=1/c=(0,0,60000,65000) a imguiwv round(imGUIcontrol[0]/2),round(imGUIcontrol[2]/2)
			newpanel/FLT=0/N=imGUI_controlpanel/W=(0,0,300,300)/HOST=imgui/EXT=0/NA=0
			if(imGUIcontrol[1]>1) 
          Slider slider0,pos={30,110},vert=1,proc=SliderProcimGUIystack,size={30,imGUIcontrol[1]*10},limits={0,imGUIcontrol[1]-1,1},value=0
			 valDisplay imGUIval title="ystack",value=0,size={65,16},pos={20,80},fstyle=1, ticks=2
         endif
			Button imcont1 title="upper" ,proc=ButtonProcimcont5,pos={61,11}
			Button imcont2 title="lower" ,proc=ButtonProcimcont6,pos={61,40}
			Button imcont3 title="right" ,proc=ButtonProcimcont3,pos={121,25}
			Button imcont4 title="left" ,proc=ButtonProcimcont4,pos={1,25}
			Button imGUI6 title="draw spectrum",proc=ButtonProcimcontspe,size={150,20},pos={140,60}
			CheckBox imGUIchick title="overlap on graph",value=1,proc=CheckProcimGUIcheck,pos={145,150}
			Button imGUI7 title="spatial average",size={150,20},pos={140,90},proc=ButtonProcimcontregion_analysis
			Button button0 title="delete",proc=ButtonProc_imGUIdelete,size={50,20},pos={230,20}
			Button buttonimGUI_highpass title="highpass",proc=ButtonProc_highpass,pos={140,180},size={70,20}
			Button buttonimGUI_lowpass title="lowpass",proc=ButtonProc_lowpass,pos={140,200},size={70,20}
			Button buttonimGUI_xy title="X-Y",proc=ButtonProcimGUI_XY,pos={230,180}
			//Button buttonimGUI_xz title="X-Z",proc=ButtonProcimGUI_XZ,pos={230,200}
			Button buttonimGUI_yz title="Y-Z",proc=ButtonProcimGUI_yz,pos={230,220}
			Button buttonimGUI_sumfromimage title="sumfromimage" ,proc=ButtonProc_sumfromimage,pos={140,120},size={150,20}
			imGUIcontrol[8]=1  
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcimGUI_YZ(ba) : ButtonControl
	STRUCT WMButtonAction &ba
   wave imGUIcontrol,imchi3_data

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
				
			imGUIcontrol[7]=2
					
			make/o/n=(imGUIcontrol[1],imGUIcontrol[2]) imGUIwv
			
		   imGUIwv[][]=imchi3_data[imGUIcontrol[6]][0][p][q]
			
			killwindow imGUI			
			newimage/N=imGUI imGUIwv
			SetAxis/A left
			cursor/i/a=1/c=(0,0,60000,65000) a imguiwv round(imGUIcontrol[1]/2),round(imGUIcontrol[2]/2)		
			newpanel/FLT=0/N=imGUI_controlpanel/W=(0,0,300,300)/HOST=imgui/EXT=0/NA=0
			if(imGUIcontrol[0]>1) 
          Slider slider0,pos={30,110},vert=1,proc=SliderProcimGUIxstack,size={30,imGUIcontrol[0]*10},limits={0,imGUIcontrol[0]-1,1},value=0
          ValDisplay imGUIval title="xstack",value=0,size={65,16},pos={20,80},fstyle=1, ticks=2
         endif
			Button imcont1 title="upper" ,proc=ButtonProcimcont5,pos={61,11}
			Button imcont2 title="lower" ,proc=ButtonProcimcont6,pos={61,40}
			Button imcont3 title="right" ,proc=ButtonProcimcont1,pos={121,25}
			Button imcont4 title="left" ,proc=ButtonProcimcont2,pos={1,25}
			Button imGUI6 title="draw spectrum",proc=ButtonProcimcontspe,size={150,20},pos={140,60}
			CheckBox imGUIchick title="overlap on graph",value=1,proc=CheckProcimGUIcheck,pos={145,150}
			Button imGUI7 title="spatial average",size={150,20},pos={140,90},proc=ButtonProcimcontregion_analysis
			Button button0 title="delete",proc=ButtonProc_imGUIdelete,size={50,20},pos={230,20}
			Button buttonimGUI_highpass title="highpass",proc=ButtonProc_highpass,pos={140,180},size={70,20}
			Button buttonimGUI_lowpass title="lowpass",proc=ButtonProc_lowpass,pos={140,200},size={70,20}
			Button buttonimGUI_xy title="X-Y",proc=ButtonProcimGUI_XY,pos={230,180}
			Button buttonimGUI_xz title="X-Z",proc=ButtonProcimGUI_XZ,pos={230,200}
			//Button buttonimGUI_yz title="Y-Z",proc=ButtonProcimGUI_yz,pos={230,220}
			Button buttonimGUI_sumfromimage title="sumfromimage" ,proc=ButtonProc_sumfromimage,pos={140,120},size={150,20}
			imGUIcontrol[8]=1 
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function SliderProcimGUIystack(sa) : SliderControl
	STRUCT WMSliderAction &sa
   wave imGUIcontrol,imGUIwv,imchi3_data
   variable/G zstack
	switch( sa.eventCode )
		case -3: // Control received keyboard focus
		case -2: // Control lost keyboard focus
		case -1: // Control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				
				Variable curval = sa.curval
				
				imGUIcontrol[4]=curval
				ValDisplay imGUIval value=_NUM:curval
				
				hideinfo/w=imGUIspe
		     	showinfo/w=imGUIspe
			
			
		    	imGUIwv[][]=imchi3_data[imGUIcontrol[6]][p][curval][q]
			endif
			break
	endswitch
	return 0
end


Function SliderProcimGUIxstack(sa) : SliderControl
	STRUCT WMSliderAction &sa
   wave imGUIcontrol,imGUIwv,imchi3_data
   variable/G zstack
	switch( sa.eventCode )
		case -3: // Control received keyboard focus
		case -2: // Control lost keyboard focus
		case -1: // Control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				
				Variable curval = sa.curval
				
				imGUIcontrol[3]=curval
				ValDisplay imGUIval value=_NUM:curval
				
				hideinfo/w=imGUIspe
		     	showinfo/w=imGUIspe
			
			
		    	imGUIwv[][]=imchi3_data[imGUIcontrol[6]][curval][p][q]
			endif
			break
	endswitch
	return 0
end


DemoWindowHook():
Function MyWindowHook(s)
	STRUCT WMWinHookStruct &s
	wave imGUIcontrol,imchi3GUI_data,imchi3_data
	Variable hookResult = 0	// 0 if we do not handle event, 1 if we handle it.
   variable xnum,ynum
	switch(s.eventCode)
		case 11:					// Keyboard event
			switch (s.keycode)
				case 28:
		 hideinfo/w=imGUI
			//showinfo/w=imGUI
			
			imGUIcontrol[3]=pcsr(A)
			imGUIcontrol[4]=qcsr(A)
			imGUIcontrol[3]-=1
			
			if(imGUIcontrol[3]<0)
			 imGUIcontrol[3]+=1
			else
		    cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[3],imGUIcontrol[4]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
					hookResult = 1
					DoWindow/F imGUI				// Does graph exist?
	if (V_flag == 0)
		Display /N=imGUI			// Create graph
		SetWindow imGUI, hook(MyHook) = MyWindowHook	// Install window hook
	endif
					break
				case 29:
			hideinfo/w=imGUI
			//showinfo/w=imGUI
			
			imGUIcontrol[3]=pcsr(A)
			imGUIcontrol[4]=qcsr(A)
			imGUIcontrol[3]+=1
			
			if(imGUIcontrol[3]>imGUIcontrol[0]-1)
			 imGUIcontrol[3]-=1
			else
		    cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[3],imGUIcontrol[4]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
					hookResult = 1
					DoWindow/F imGUI				// Does graph exist?
	if (V_flag == 0)
		Display /N=imGUI			// Create graph
		SetWindow imGUI, hook(MyHook) = MyWindowHook	// Install window hook
	endif
					break
				case 30:
					// click code here
			
			hideinfo/w=imGUI
			//showinfo/w=imGUI
		 if(imGUIcontrol[7]==0)
			imGUIcontrol[3]=pcsr(A)
			imGUIcontrol[4]=qcsr(A)	
			imGUIcontrol[4]+=1
		   
		   if(imGUIcontrol[4]>imGUIcontrol[1]-1)
		    imGUIcontrol[4]-=1
		   else
		    cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[3],imGUIcontrol[4]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
			
		 elseif(imGUIcontrol[7]==2)
		   imGUIcontrol[4]=pcsr(A)
			imGUIcontrol[5]=qcsr(A)	
			imGUIcontrol[4]+=1
		   
		   if(imGUIcontrol[4]>imGUIcontrol[1]-1)
		    imGUIcontrol[4]-=1
		   else
		    cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[4],imGUIcontrol[5]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
		 
		 endif
					hookResult = 1
					DoWindow/F imGUI				// Does graph exist?
	if (V_flag == 0)
		Display /N=imGUI			// Create graph
		SetWindow imGUI, hook(MyHook) = MyWindowHook	// Install window hook
	endif
					break
				case 31:
					hideinfo/w=imGUI
			//showinfo/w=imGUI
		 if(imGUIcontrol[7]==0)
			imGUIcontrol[3]=pcsr(A)
			imGUIcontrol[4]=qcsr(A)
			imGUIcontrol[4]-=1
		   
		   if(imGUIcontrol[4]<0)
		    imGUIcontrol[4]+=1
		   else
   	       cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[3],imGUIcontrol[4]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
		 
		 elseif(imguicontrol[7]==2)
		   imGUIcontrol[4]=pcsr(A)
			imGUIcontrol[5]=qcsr(A)
			imGUIcontrol[4]-=1
		   
		   if(imGUIcontrol[4]<0)
		    imGUIcontrol[4]+=1
		   else
   	       cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[4],imGUIcontrol[5]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
		 
		 endif
					hookResult = 1
					DoWindow/F imGUI				// Does graph exist?
	if (V_flag == 0)
		Display /N=imGUI			// Create graph
		SetWindow imGUI, hook(MyHook) = MyWindowHook	// Install window hook
	endif
					break			
				default:
					// The keyText field requires Igor Pro 7 or later. See Keyboard Events.
					Printf "Key pressed: %s\r", s.keyText
					break			
			endswitch
			break
	endswitch

	return hookResult	// If non-zero, we handled event and Igor will ignore it.
End

Function DemoWindowHook()
	DoWindow/F imGUI				// Does graph exist?
	if (V_flag == 0)
		Display /N=imGUI	// Create graph
	endif
   SetWindow imGUI, hook(MyHook) = MyWindowHook	// Install window hook
End

menu "Analysis"
 "DemoWindowHook()/q"
end


function highFFT(imGUIwv)
wave imGUIwv
variable i,j,k
variable xnum,ynum

xnum=dimsize(imGUIwv,0)
ynum=dimsize(imGUIwv,1)

duplicate/o imGUIwv test

if(mod(xnum,2)==1)
 insertpoints/m=0/v=(wavemin(imGUIwv)) xnum+1,1,test
 insertpoints/m=1/v=(wavemin(imGUIwv)) xnum+1,1,test
endif


fft/dest=abc test

make/n=(dimsize(abc,0),dimsize(abc,1))/o def
duplicate/o def filter
filter=1
for(i=0;i<dimsize(abc,0);i+=1)
 for(j=0;j<dimsize(abc,1);j+=1)
  if((xnum*0.7)>((dimsize(abc,1)/2)-j)^2+(i)^2)
   filter[i][j]=0
  endif
 endfor
endfor

abc[][]*=filter[p][q]

def[][]=(real(abc[p][q]))^2+(imag(abc[p][q]))^2

ifft/dest=xxx abc

if(mod(xnum,2)==1)
 deletepoints/m=0 xnum,1,xxx
 deletepoints/m=1 xnum,1,xxx
endif

imGUIwv[][]=xxx[p][q]

end


Function ButtonProc_highpass(ba) : ButtonControl
	STRUCT WMButtonAction &ba
   wave imGUIwv
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			highfft(imGUIwv)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


function lowFFT(imGUIwv)
wave imGUIwv
variable i,j,k
variable xnum,ynum

xnum=dimsize(imGUIwv,0)
ynum=dimsize(imGUIwv,1)

duplicate/o imGUIwv test

if(mod(xnum,2)==1)
 insertpoints/m=0/v=(wavemin(imGUIwv)) xnum+1,1,test
 insertpoints/m=1/v=(wavemin(imGUIwv)) xnum+1,1,test
endif


fft/dest=abc test

make/n=(dimsize(abc,0),dimsize(abc,1))/o def
duplicate/o def filter
filter=1
for(i=0;i<dimsize(abc,0);i+=1)
 for(j=0;j<dimsize(abc,1);j+=1)
  if((xnum*6)<((dimsize(abc,1)/2)-j)^2+(i)^2)
   filter[i][j]=0
  endif
 endfor
endfor

abc[][]*=filter[p][q]

def[][]=(real(abc[p][q]))^2+(imag(abc[p][q]))^2

ifft/dest=xxx abc

if(mod(xnum,2)==1)
 deletepoints/m=0 xnum,1,xxx
 deletepoints/m=1 xnum,1,xxx
endif

imGUIwv[][]=xxx[p][q]

end


Function ButtonProc_lowpass(ba) : ButtonControl
	STRUCT WMButtonAction &ba
   wave imGUIwv
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
		    lowFFT(imGUIwv)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


function SumFromImageforGUI(wv, discri, oriwv)
wave wv,oriwv;
variable discri;

variable pts,xNum,yNum,pixnum;
variable i,j,cts,judgeX,judgeY;


Silent 1; PauseUpdate
pts=dimsize(oriwv,0)
xnum=dimsize(wv,0)
ynum=dimsize(wv,1)
make /o/n=(pts) temp00
temp00=0;
cts=0;

make/o/n=(xnum+1,ynum+1) TargetFromImage

targetfromimage=0


i=0
do
	j=0
	do
		if(wv[i][j]>discri)
		//if(imchi3_data[pixnum][i][j][0]>discri)
			temp00[]+=oriwv[p][i][j][1]
			cts+=1 
			targetfromimage[i][j]=1
		endif
		j+=1
	while(j<yNum)
	i+=1
while(i<xNum)

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
	while(j<yNum)
	i+=1
while(i<xNum)
temp00/=cts

killwindow/z sumfromimage

newimage/n=sumfromimage wv

for(j=0;j<ynum;j+=1)
 for(i=0;i<xnum;i+=1)
  
   judgeX=targetfromimage[i+1][j]-targetfromimage[i][j]
   judgeY=targetfromimage[i][j+1]-targetfromimage[i][j]
   
   
   if(judgex==1||judgex==-1)
    setdrawenv/w=sumfromimage linefgc=(65535,0,0) 
    drawline/w=sumfromimage (i+1)/xnum,(j)/ynum,(i+1)/xnum,(j+1)/ynum
   endif
   
   if(judgey==1||judgey==-1)
    setdrawenv/w=sumfromimage linefgc=(655350,0,0) 
    drawline/w=sumfromimage (i)/xnum,(j+1)/ynum,(i+1)/xnum,(j+1)/ynum
   endif
   
   if(targetfromimage[i][0]==1)
    setdrawenv/w=sumfromimage linefgc=(65535,0,0) 
    drawline/w=sumfromimage i/xnum,0,(i+1)/xnum,0

   elseif(targetfromimage[i][ynum]==1)
    setdrawenv/w=sumfromimage linefgc=(65535,0,0) 
    drawline/w=sumfromimage i/xnum,1,(i+1)/xnum,1

   elseif(targetfromimage[0][j]==1)
    setdrawenv/w=sumfromimage linefgc=(65535,0,0) 
    drawline/w=sumfromimage 0,j/ynum,0,(j+1)/ynum

   elseif(targetfromimage[xnum][j]==1)
    setdrawenv/w=sumfromimage linefgc=(65535,0,0) 
    drawline/w=sumfromimage 1,j/ynum,1,(j+1)/ynum

   endif

 endfor
endfor
end


Function ButtonProc_sumfromimage(ba) : ButtonControl
	STRUCT WMButtonAction &ba
   wave imGUIwv,imchi3_data,temp00,re_ramanshift2,imGUIcontrol
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			sumfromimageforGUI(imGUIwv,imGUIwv[pcsr(A)][qcsr(A)],imchi3_data)
			if(imGUIcontrol[8]==1)
			AppendToGraph/C=(0,0,65535)/L/W=imGUIspe temp00 vs re_ramanshift2
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


///// 009BaselineSubtraction /////
Function/wave BaselineArPLS(rawWave)
	/// This function subtract baseline from rawWave
	/// based on Baek et al., 2014 Analyst
	/// Author: Shinichi Miyazaki
	/// @params: rawWave, wave, 1 dimensional wave
	/// @params: lam, variable, parameter for differentiation weight
	
	/// recomended parameters 
	
	/// for representative spectrum Lam = 2500000, ratio = 0.0001
	/// for baseline subtraction from all of spatial points,  lam = 1000000, ratio = 0.01 (or 1 for short calc time) 
	wave rawWave
	variable lam = 1000000
	variable ratio = 1
	wave weightWave
	wave destWave, weightedDiffWave
	variable numofPoints, i, t, count
	variable meanOfNegativeDiffWave, SDOfNegativeDiffWave
	
	numOfPoints = dimsize(rawWave,0)
	// initialize the weightWave and weightWaveDiag
	make/o/free/n=(numOfPoints) weightWave = 1
	make/o/free/n=(numOfPoints) nextweightWave = 1
	matrixop/o/free weightWaveDiag = diagonal(weightWave)
	matrixop/o/free weightedDiffWave = lam *  weightedDiffWave^t x weightedDiffWave 
	count = 0
	do
		matrixop/o/free weightWaveDiag = diagonal(weightWave)
		// (W+H)^-1Wy
		matrixop/o/free invWeight = inv(weightWaveDiag+weightedDiffWave)
		matrixop/o destWave = invWeight x weightWaveDiag x rawWave
		matrixop/o/free diffWave = rawWave - destWave
		
		// make d- only with di<0, set positive val to 0
		Extract/o diffWave, negativeDiffWave, diffWave < 0
		//calc mean and SD of negativeDiffWave
		wavestats/q negativeDiffwave
		meanOfNegativeDiffWave = V_avg
		SDOfNegativeDiffWave = V_sdev	
		make/o/n = (numofPoints) nextweightWave = 1/(1+exp(2*(diffwave[p]-(-meanOfNegativeDiffWave + 2*SDOfNegativeDiffWave))/SDOfNegativeDiffWave))
		matrixop/o tempRatioWv = abs(weightwave-nextweightwave)/abs(weightwave)
		weightwave = nextweightwave
		count +=1
	while(tempRatiowv[0]>ratio)
	//print count
	return diffwave
end

Function/wave MakeWeightedDiffWave(numOfPoints)
	/// This function make the wave for differentiation 
	/// Author: Shinichi Miyazaki
	variable numOfPoints
	variable i, j

	make/o/n = (numOfPoints-2, numOfPoints) weightedDiffWave=0
	i=0
	do
		weightedDiffWave[i][i] =1
		weightedDiffWave[i][i+1] =-2
		weightedDiffWave[i][i+2] =1
		i+=1
	while(i<numOfPoints-2)
	return weightedDiffWave
end


Function BLSubArPLS(wave_2d)
	/// This function subtract baseline from rawWave
	/// based on Baek et al., 2014 Analyst
	/// Author: Shinichi Miyazaki
	/// @params: Wave_2d, wave, 2 dimensional wave
	/// @params: lam, variable, parameter for differentiation weight
	wave wave_2d
	variable i, spatialpnts, wavenum
	
	Variable start = dateTime
	wavenum = dimsize(wave_2d, 0)
	spatialpnts =dimsize(wave_2d, 1)
	duplicate/o wave_2d wave_blsub
	i=0
	make/o/n = (wavenum) BLSub = 0
	// make weightedDiffWave (H)
	wave weightedDiffWave = MakeWeightedDiffWave(wavenum)
	do 
		make/o/n = (wavenum) tempwave = wave_2d[p][i]
		wave BLSub = BaselineArPLS(tempwave)
		wave_blsub[][i] = BLsub[p]
		i+=1
	while(i<spatialpnts)
	Variable timeElapsed = dateTime - start
	print "This procedure took" + num2str(timeElapsed) + "in seconds."
end



///// 010MCRrelated /////

Function/wave extractCols(wv, colMaskwv)
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


Function/wave extractRows1D(wv, rowMaskWv)
	wave wv, rowMaskWv
	string outWvName = "extracted" + nameofWave(wv)
	duplicate/o wv $outWvName
	wave outwave = $outWvName
	
	matrixop/o outwave = replace((outwave+1) * rowMaskWv, 0, NaN)
	wavetransform zapNaNs outwave
	if (dimsize(outwave, 0) == 0)
		matrixop/o outwave=0
	else 
		matrixop/o outwave=outwave-1
	endif
	return outwave
end

function/wave NNLS(Z, xvec, tolerance)
	//Author: Shinichi Miyazaki
	//ref "A FAST NON-NEGATIVITY-CONSTRAINED LEAST SQUARES ALGORITHM" 1997
	//this function solve Ax = b about x 
	//under constraints all x >= 0
	//This is a wrapper for a FORTRAN NNLS
	//@ params Z: wave (L x M)
	//@ params x: wave right-hand side vector (L x 1)
	//@ params tolerance: variable 
	//@ return d: wave solution vector (M x 1)
	
	wave Z, xVec
	variable tolerance
	wave removeVec
	variable mainLoopJudge, innerLoopJudge
	
	variable alphaTol = 1e-15
	variable/G residual = 0
	
	//obtain matrix size
	variable ZRow = dimsize(Z, 0) 
	variable ZColumn = dimsize(Z, 1) 
	
	// A1 
	// P_vec is indices which are not fixed
	make/o/n = (Zcolumn) PVecExtract=0
	// A2
	// R_vec is indices which is fixed to zero
	make/o/n = (Zcolumn) RVecExtract=1
	// A3
	make/o/d/n = (ZColumn) d = 0
	make/o/d/n = (ZColumn) Swave = 0
	// A4
	matrixop/o w = Z^t x (xVec- Z x d)
	make/o/n=(Zcolumn) WIdwave = p

	do
		//B1
		wave WnR = extractRows1D(w, RVecExtract)
		wave WIdWaveR = extractRows1D(WIdWave, RVecExtract)
		variable WnRmax = wavemax(WnR)
		if (sum(RVecExtract)!=0 && (WnRmax>tolerance))
			mainLoopJudge = 1
			//B2
			wavestats/Q WnR
			variable m = WIdWaveR[V_maxRowLoc]
			
			//B3
			//Remove from Rvec
			RVecExtract[m] = 0
			//Include in PVec
			PVecExtract[m] = 1
			//B4
			wave Zp = extractCols(Z, PVecExtract)
			// solve least square only using passive values 
			matrixop/o Sp = inv(Zp^t x Zp) x Zp^t x xVec
			
			make/o/n=(Zcolumn) indexwave = p
			matrixop/o indexWave = (indexWave+1)*PVecExtract
			indexWave = indexWave == 0 ? NaN : indexWave
			WaveTransform zapNaNs indexwave
			indexwave -= 1
			
			Swave[indexWave] = {Sp}
			
			do
				//C1
				if (wavemin(Sp)<=0)
					innerLoopJudge = 1
					//C2
					wave dp = extractRows1D(d, PVecExtract)
					
					// get negative index
					make/o/n=(numpnts(Sp)) negativeIndex = (Sp[p]<=0) ? p+1 : 0
					negativeIndex = negativeIndex == 0 ? NaN : negativeIndex
					WaveTransform zapNaNs negativeIndex
					negativeIndex -= 1
					make/o/n=(numPnts(negativeIndex)) Snegative = Sp[negativeIndex]
					make/o/n=(numPnts(negativeIndex)) Dnegative = dp[negativeIndex]
										
					matrixop/o alphaWave = (Dnegative/(Dnegative-Snegative))
					variable alpha = wavemin(alphaWave)
					if (alpha < alphaTol)
						Sp = Dp
						make/o/n=(Zcolumn) indexwave = p
						matrixop/o indexWave = (indexWave+1)*PVecExtract
						indexWave = indexWave == 0 ? NaN : indexWave
						WaveTransform zapNaNs indexwave
						indexwave -= 1
						make/o/d/n = (ZColumn) Swave = 0
						Swave[indexWave] = {Sp}
						
						innerLoopJudge = 0
					else
						//C3
						d = d + alpha * (Swave-d)
						//update R and P 
						make/o/n=(Zcolumn) removeVec = (d[p]<=0) ? 0 : 1
						matrixop/o PVecExtract = PVecExtract * removeVec
						matrixop/o RVecExtract = -(PVecExtract-1)
						
						wave Zp = extractCols(Z, PVecExtract)
						matrixop/o sp = inv(Zp^t x Zp) x Zp^t x xVec
						
						make/o/n=(Zcolumn) indexwave = p
						matrixop/o indexWave = (indexWave+1)*PVecExtract
						indexWave = indexWave == 0 ? NaN : indexWave
						WaveTransform zapNaNs indexwave
						indexwave -= 1
						
						make/o/d/n = (ZColumn) Swave = 0
						Swave[indexWave] = {Sp}
					endif
				else
					innerLoopJudge = 0
				endif
			while (innerLoopJudge == 1)
			d = Swave
			matrixop/o w = Z^t x (xVec- Z x d)
		else
			mainLoopJudge = 0
		endif
	while (mainLoopJudge==1)
	matrixop/o tempresidual = (Z x d - XVec)^t x (Z x d - XVec) 
	residual = residual + tempresidual[0]
	return d
end

function [wave concentration, wave spectrum] MCRALS(wave indata, wave initSpec,variable xNum,variable yNum,variable maxIter)
	variable i, j
	variable/G residual
	
	variable tolerance = 1e-15
	variable spatialNum = dimsize(indata, 0)
	variable specNum = dimsize(initSpec, 1)
	variable wavenum = dimsize(initSpec, 0)
	variable spatialPnts = xNum*yNum
	
	//make empty waves 
	make/o/n = (spatialPnts, specNum) Concentration = 0
	make/o/n = (waveNum, specNum) Spectrum = 0
	
	i = 0
	do 
		j=0
		if (i == 0)
			matrixop/o Zwave = indata^t
			variable meanresidual = 0
			do
				make/o/n = (waveNum) tempZ = Zwave[p][j]
				wave ans = NNLS(InitSpec, tempZ, tolerance)
				Concentration[j][] = ans[q]
				meanresidual += residual
				j+=1
			while (j<spatialNum)
			meanresidual /= spatialNum
			print "Iter: " + num2str(i) + " (C), mse = " + num2Str(meanresidual)
		elseif (mod(i,2)==1)
			matrixop/o Zwave = indata
			meanresidual = 0
			do
				make/o/n = (spatialNum) tempZ = Zwave[p][j]
				wave ans = NNLS(Concentration, tempZ, tolerance)
				Spectrum[j][] = ans[q]
				meanresidual += residual
				j+=1
			while (j<waveNum)
			meanresidual /= waveNum
			print "Iter: " + num2str(i) + " (ST), mse = " + num2Str(meanresidual)
		else 
			matrixop/o Zwave = indata^t
			meanresidual = 0
			do
				make/o/n = (waveNum) tempZ = Zwave[p][j]
				wave ans = NNLS(Spectrum, tempZ, tolerance)
				Concentration[j][] = ans[q]
				meanresidual += residual
				j+=1
			while (j<SPatialnum)
			meanresidual /= spatialNum
			print "Iter: " + num2str(i) + " (C), mse = " + num2Str(meanresidual)
		endif 
		i += 1
	while (i<maxIter)
	return [Concentration, spectrum]
end 



Function [wave rawdata2d,wave subxaxis, wave M_U] SVDandPlots(wave rawData, wave xAxis,variable componentNum, variable startWvNum, variable endWvNum)
	/// Author: Shinichi Miyazaki
	/// This function conduct SVD and plot spectrum and make images
	/// @params	rawData:			4D wave 	(waveNum, x, y, z) 
	/// @params	xAxis:			1D wave 	(waveNum)
	/// @params	componentNum:	variable	(how many componets do you want to divide into)
	/// @params	xNum, yNUm:		variable	(spatial points)
	/// @params	startWavenum	variable	(optional, wavenum ROI)
	
	wave M_U, M_V
	variable i, xnum, ynum
	String imageName
	
	xNum = dimsize(rawdata,1)
	yNUm = dimsize(rawdata,2)
	
	// subrange waves
	make/o/n=(dimsize(xaxis,0)) maskwave = 1
	maskwave = xaxis <= startwvnum ? 0 : maskwave
	maskwave = xaxis >= endwvnUm ? 0 : maskwave
	wave subxaxis = extractRows1D(xaxis, maskwave)
	wave rawData2D = wave4dto2dSVD(rawData, xNum, yNum)
	matrixop/o rawdata2d = rawdata2d^t
	wave subrawdata = extractCols(rawdata2d, maskwave)
	matrixop/o subrawdata = subrawdata^t
	
	
	// svd 
	matrixSVD/DACA/PART=(componentNum) subrawdata
	
	// make spectrum graphs
	wave M_U = M_U
	wave M_V = M_V
	i=1
	display M_U[][0] vs xAxis
	do
		AppendtoGraph M_U[][i] vs xAxis
		i+=1
	while (i<componentNum-1)	
	SetAxis/A/R bottom
	
	// make images
	i=0
	do 
		imageName = "image" + num2str(i)
		make/o/n = (xNum*yNum)/D $imageName = M_V[p][i]
		redimension/n =(xNum, yNum) $imageName 
		display; appendimage $imageName
		ModifyGraph width=200, height = {Aspect, yNum/xNum}
		i+=1
	while (i<componentNum)
	return [subrawdata,subxaxis, M_U]
end

Function/wave wave4Dto2DSVD(wv,Numx,Numy)
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


function SVD_MCRALS(indata, xaxis, componentNum, startwvNum, endwvNum, maxiter)
	wave indata, xaxis
	variable componentNum, startwvNum, endwvNum, maxiter
	variable i, xnum, ynum
	wave rawdata2d, M_U, concentration, spectrum, subaxis
	string imagename
	
	xnum = dimsize(indata, 1)
	ynUm = dimsize(indata,2)
	[rawdata2d,subaxis, M_U] = SVDandPlots(indata, xAxis, componentNum, startwvNum, endwvNum)
	matrixop/o rawdata2d = rawdata2d^t
	[concentration, SPectrum] = MCRALS(rawdata2d, M_U, xNum, yNum, maxIter)
	//show concentration
	i=0
	do
		imagename = "component" + num2str(i)
		make/o/n=(xNUm*yNUm) $imagename = concentration[p][i]
		redimension/N= (xnUm, yNum) $imagename
		display;appendimage $Imagename;
		ModifyGraph width=200,height={Aspect,yNum/xNum}
		ModifyImage $Imagename ctab= {*,3,ColdWarm,0}
		i+=1
	while (i<componentNum)
	
	// show spectrum
	i=0
	do 
		if (i==0)
			display spectrum[][i] vs subaxis
		else
			AppendToGraph Spectrum[][i] vs subaxis
		endif
		i+=1
		SetAxis/A/R bottom
	while (i<componentNum)
end


function weightedAverageWithComponent(indata, componentwave)
	wave indata 
	wave componentwave
	variable wavenum, xnum, ynum, i, j
	
	// obtain dimsizes
	wavenum = dimsize(indata, 0)
	xnum = dimsize(indata, 1)
	yNum = dimsize(indata, 2)
	
	make/o/n = (wavenum) weightedAv=0
	
	// loop 
	i = 0
	do
		j = 0
		do
			weightedAv += indata[p][i][j][0] * componentwave[i][j]
			j+=1
		while (j<ynum)
		i+=1
	while (i<xNum)
end


// WinSpec file (*.spe) loader v 1.0
// Author: Unkown
Menu "Data"
	SubMenu "Import"
		"WinSpec SPE", SpeLoader()
	End
End

// SpeloaderM 
// Author: Unkonw
// Load .spe file (Princeton, Lightfield)
 
Static Constant DATEMAX = 10
Static Constant TIMEMAX = 7
Static Constant COMMENTMAX = 80
Static Constant LABELMAX = 16
Static Constant FILEVERMAX = 16
Static Constant HDRNAMEMAX1 = 100 // splitted 120 to 100, 20 to deal with igor < 6.1
Static Constant HDRNAMEMAX2 = 20
Static Constant ROIMAX = 10

Static Structure ROI // region of interest
	uint16 startx
	uint16 endx
	uint16 groupx
	uint16 starty
	uint16 endy
	uint16 groupy
EndStructure

Static Structure comment
	char body[5]
EndStructure

// Igor does not accept non-2byte-aligned multi-byte menbers in a structure.
// so using "char" instead of "double" here. should re-interpret bit patterns.
Static Structure calib
//	double offset // +0
//	double factor // +8
	char offset[8] // +0
	char factor[8] // +8
	char current_unit // +16 selected scaling unit
	char reserved1    // +17
	char scaling_string[40] // +18
	char reserved2[40]  // +58
	char calib_valid // +98 flag if calib. is vaid
	char input_unit // +99
	char polynom_unit //+100
	char polynom_order //+101
	char calib_count //+102

//	double pixel_position[10] // +103
//	double calib_value[10] // +183
//	double polynom_coeff[6] // +263
//	double laser_position // +311
	char pixel_position[10*8] // +103
	char calib_value[10*8] // +183
	char polynom_coeff[6*8] // +263
	char laser_position[1*8] // +311

	char reserved3 // +319
	char new_calib_flag  // +320 (when ==200, "calib_label" field is valid)
	char calib_label[81] // +321
	char expansion[87] // +402
EndStructure

Structure SPE_Header // WinSpec SPE format ver 2.5
	int16	ControllerVersion		//	0	Hardware Version
	int16	LogicOutput		//	2	Definition of Output BNC
	uint16	AmpHiCapLowNoise		//	4	Amp Switching Mode
	uint16	xDimDet		//	6	Detector x dimension of chip.
	int16	mode		//	8	timing mode
	float	exp_sec		//	10	alternative exposure, in sec.
	int16	VChipXdim		//	14	Virtual Chip X dim
	int16	VChipYdim		//	16	Virtual Chip Y dim
	uint16	yDimDet		//	18	y dimension of CCD or detector.
	char	datestr[DATEMAX]		//	20	date
	int16	VirtualChipFlag		//	30	On/Off
	char	Spare_1[2]		//	32
	int16	noscan		//	34	Old number of scans - should always be -1
	float	DetTemperature		//	36	Detector Temperature Set
	int16	DetType		//	40	CCD/DiodeArray type
	uint16	xdim		//	42	actual # of pixels on x axis
	int16	stdiode		//	44	trigger diode
	float	DelayTime		//	46	Used with Async Mode
	uint16	ShutterControl		//	50	Normal, Disabled Open, Disabled Closed
	int16	AbsorbLive		//	52	On/Off
	uint16	AbsorbMode		//	54	Reference Strip or File
	int16	CanDoVirtualChipFlag		//	56	T/F Cont/Chip able to do Virtual Chip
	int16	ThresholdMinLive		//	58	On/Off
	float	ThresholdMinVal		//	60	Threshold Minimum Value
	int16	ThresholdMaxLive		//	64	On/Off
	float	ThresholdMaxVal		//	66	Threshold Maximum Value
	int16	SpecAutoSpectroMode		//	70	T/F Spectrograph Used
	float	SpecCenterWlNm		//	72	Center Wavelength in Nm
	int16	SpecGlueFlag		//	76	T/F File is Glued
	float	SpecGlueStartWlNm		//	78	Starting Wavelength in Nm
	float	SpecGlueEndWlNm		//	82	Starting Wavelength in Nm
	float	SpecGlueMinOvrlpNm		//	86	Minimum Overlap in Nm
	float	SpecGlueFinalResNm		//	90	Final Resolution in Nm
	int16	PulserType		//	94	0=None, PG200=1, PTG=2, DG535=3
	int16	CustomChipFlag		//	96	T/F Custom Chip Used
	int16	XPrePixels		//	98	Pre Pixels in X direction
	int16	XPostPixels		//	100	Post Pixels in X direction
	int16	YPrePixels		//	102	Pre Pixels in Y direction
	int16	YPostPixels		//	104	Post Pixels in Y direction
	int16	asynen		//	106	asynchronous enable flag 0 = off
	int16	datatype		//	108	experiment datatype 0:float, 1:int32, 2:int16, 3:uint16
	int16	PulserMode		//	110	Repetitive/Sequential
	uint16	PulserOnChipAccums		//	112	Num PTG On-Chip Accums
	uint32	PulserRepeatExp		//	114	Num Exp Repeats (Pulser SW Accum)
	float	PulseRepWidth		//	118	Width Value for Repetitive pulse (usec)
	float	PulseRepDelay		//	122	Width Value for Repetitive pulse (usec)
	float	PulseSeqStartWidth		//	126	Start Width for Sequential pulse (usec)
	float	PulseSeqEndWidth		//	130	End Width for Sequential pulse (usec)
	float	PulseSeqStartDelay		//	134	Start Delay for Sequential pulse (usec)
	float	PulseSeqEndDelay		//	138	End Delay for Sequential pulse (usec)
	int16	PulseSeqIncMode		//	142	Increments: 1=Fixed, 2=Exponential
	int16	PImaxUsed		//	144	PI-Max type controller flag
	int16	PImaxMode		//	146	PI-Max mode
	int16	PImaxGain		//	148	PI-Max Gain
	int16	BackGrndApplied		//	150	1 if background subtraction done
	int16	PImax2nsBrdUsed		//	152	T/F PI-Max 2ns Board Used
	uint16	minblk		//	154	min. # of strips per skips
	uint16	numminblk		//	156	# of min-blocks before geo skps
	int16	SpecMirrorLocation[2]		//	158	Spectro Mirror Location, 0=Not Present
	int16	SpecSlitLocation[4]		//	162	Spectro Slit Location, 0=Not Present
	int16	CustomTimingFlag		//	170	T/F Custom Timing Used
	char	ExperimentTime[TIMEMAX*2]		//	172	Experiment Local Time as hhmmss\0  (UTC follows)
	int16	ExposUnits		//	186	User Units for Exposure
	uint16	ADCoffset		//	188	ADC offset
	uint16	ADCrate		//	190	ADC rate
	uint16	ADCtype		//	192	ADC type
	uint16	ADCresolution		//	194	ADC resolution
	uint16	ADCbitAdjust		//	196	ADC bit adjust
	uint16	gain		//	198	gain
	STRUCT comment	Comments[COMMENTMAX]		//	200	File Comments
	uint16	geometric		//	600	geometric ops: rotate 0x01,reverse 0x02, flip 0x04
	char	xlabel[LABELMAX]		//	602	intensity display string
	uint16	cleans		//	618	cleans
	uint16	NumSkpPerCln		//	620	number of skips per clean.
	uint16	SpecMirrorPos[2]		//	622	Spectrograph Mirror Positions
	float	SpecSlitPos[4]		//	626	Spectrograph Slit Positions
	int16	AutoCleansActive		//	642	T/F
	int16	UseContCleansInst		//	644	T/F
	int16	AbsorbStripNum		//	646	Absorbance Strip Number
	int16	SpecSlitPosUnits		//	648	Spectrograph Slit Position Units
	float	SpecGrooves		//	650	Spectrograph Grating Grooves
	int16	srccmp		//	654	number of source comp. diodes
	uint16	ydim		//	656	y dimension of raw data.
	int16	scramble		//	658	0=scrambled, 1=unscrambled
	int16	ContinuousCleansFlag		//	660	T/F Continuous Cleans Timing Option
	int16	ExternalTriggerFlag		//	662	T/F External Trigger Timing Option
	uint32	lnoscan		//	664	Number of scans (Early WinX)
	uint32	lavgexp		//	668	Number of Accumulations
	float	ReadoutTime		//	672	Experiment readout time
	int16	TriggeredModeFlag		//	676	T/F Triggered Timing Option
	char	Spare_2[10]		//	678
	char	sw_version[FILEVERMAX]		//	688	Version of SW creating this file
	int16	type		//	704	1 = new120 (Type II) 2 = old120 (Type I ) 3 = ST130 4 = ST121 5 = ST138 6 = DC131 (PentaMax) 7 = ST133 (MicroMax/SpectroMax) 8 = ST135 (GPIB) 9 = VICCD 10 = ST116 (GPIB) 11 = OMA3 (GPIB) 12 = OMA4
	int16	flatFieldApplied		//	706	1 if flat field was applied.
	char	Spare_3[16]		//	708
	int16	kin_trig_mode		//	724	Kinetics Trigger Mode
	char	dlabel[LABELMAX]		//	726	Data label.
	char	Spare_41[100]		//	742
	char	Spare_42[100]		//
	char	Spare_43[100]		//
	char	Spare_44[100]		//
	char	Spare_45[36]		//
	char	PulseFileName1[HDRNAMEMAX1]		//	1178	Name of Pulser File with Pulse Widths/Delays (for Z-Slice)
	char	PulseFileName2[HDRNAMEMAX2]		//	1178	Name of Pulser File with Pulse Widths/Delays (for Z-Slice)
	char	AbsorbFileName1[HDRNAMEMAX1]		//	1298	Name of Absorbance File (if File Mode)
	char	AbsorbFileName2[HDRNAMEMAX2]		//	1298	Name of Absorbance File (if File Mode)
	uint32	NumExpRepeats		//	1418	Number of Times experiment repeated
	uint32	NumExpAccums		//	1422	Number of Time experiment accumulated
	int16	YT_Flag		//	1426	Set to 1 if this file contains YT data
	float	clkspd_us		//	1428	Vert Clock Speed in micro-sec
	int16	HwaccumFlag		//	1432	set to 1 if accum done by Hardware.
	int16	StoreSync		//	1434	set to 1 if store sync used
	int16	BlemishApplied		//	1436	set to 1 if blemish removal applied
	int16	CosmicApplied		//	1438	set to 1 if cosmic ray removal applied
	int16	CosmicType		//	1440	if cosmic ray applied, this is type
	float	CosmicThreshold		//	1442	Threshold of cosmic ray removal.
	uint32	NumFrames		//	1446	number of frames in file.
	float	MaxIntensity		//	1450	max intensity of data (future)
	float	MinIntensity		//	1454	min intensity of data (future)
	char	ylabel[LABELMAX]		//	1458	y axis label.
	uint16	ShutterType		//	1474	shutter type.
	float	shutterComp		//	1476	shutter compensation time.
	uint16	readoutMode		//	1480	readout mode, full, kinetics, etc.
	uint16	WindowSize		//	1482	window size for kinetics only.
	uint16	clkspd		//	1484	clock speed for kinetics & frame transfer
	uint16	interface_type		//	1486	computer interface(isa, taxi, pci, eisa, etc.)
	int16	NumROIsInExperiment		//	1488	May be more than the 10 allowed in this header (if 0, assume 1)
	char	Spare_5[16]		//	1490
	uint16	controllerNum		//	1506	if multiple controller system will have controller number data came from. This is a future item.
	uint16	SWmade		//	1508	Which software package created this file
	int16	NumROI		//	1510	number of ROIs used. if 0 assume 1.
	STRUCT ROI	ROIinfoblk[ROIMAX]		//	1512 - 1630	ROI information
	char	FlatField1[HDRNAMEMAX1]		//	1632	Flat field file name.
	char	FlatField2[HDRNAMEMAX2]		//	1632	Flat field file name.
	char	background1[HDRNAMEMAX1]		//	1752	background sub. file name.
	char	background2[HDRNAMEMAX2]		//	1752	background sub. file name.
	char	blemish1[HDRNAMEMAX1]		//	1872	blemish file name.
	char	blemish2[HDRNAMEMAX2]		//	1872	blemish file name.
	float	file_header_ver		//	1992	version of this file header
	char	YT_Info0[100]		//	1996-2996	Reserved for YT information
	char	YT_Info1[100]		//
	char	YT_Info2[100]		//
	char	YT_Info3[100]		//
	char	YT_Info4[100]		//
	char	YT_Info5[100]		//
	char	YT_Info6[100]		//
	char	YT_Info7[100]		//
	char	YT_Info8[100]		//
	char	YT_Info9[100]		//
	uint32	WinView_id		//	2996	0x01234567L if file created by WinX

	STRUCT calib	calib_X		//	3000-3488
	STRUCT calib	calib_Y		//	3489-3977

	char	Istring[40]		//	3978	special Intensity scaling string
	char	Spare_6[76]		//	4018	empty block to reach 4100 bytes
	int16	AvGainUsed		//	4094	avalanche gain was used
	int16	AvGain		//	4096	avalanche gain value
	int16	lastvalue	//	4098	Always the LAST value in the header
EndStructure

Static Constant SPE_HEADER_SIZE = 4100

Static function read_SPE_header(fd, header)
	variable fd;
    	STRUCT SPE_Header &header;
	// expect little-endian
	fSetPos fd, 0
	fBinRead /B=3 fd, header;

	// post-process
	if(header.NumROI == 0)
		header.NumROI = 1
	endif
    	return 0;
end

Static function dump_header(h)
    	STRUCT SPE_Header &h;
    	String hhmmss_local = h.ExperimentTime
    	print "datetime", h.datestr, hhmmss_local[0,1]+":"+ hhmmss_local[2,3]+":"+ hhmmss_local[4,5]
	print "detector element size (x,y)", h.xDimDet, h.yDimDet
	print "image pixels (x,y)", h.xdim, h.ydim
	print "number of frames", h.NumFrames
	print "exposure", h.exp_sec, "[s]"
	print "accum", h.lavgexp

	switch(h.datatype)
		case 0:
			print "datatype: float"
			break
		case 1:
			print "datatype: int32"
			break
		case 2:
			print "datatype: int16"
			break
		case 3:
			print "datatype: uint16"
			break
	endswitch

	Variable i;
	print "number of ROI", h.NumROI
	for(i=0;i<h.NumROI;i+=1)
		print "  ROI#", i+1, "start(x,y)", h.ROIinfoblk[i].startx ,h.ROIinfoblk[i].starty
		print "    end(x,y)", h.ROIinfoblk[i].endx, h.ROIinfoblk[i].endy
		print "    group(x,y)", h.ROIinfoblk[i].groupx, h.ROIinfoblk[i].groupy
	endfor
end



function SpeLoaderM([skip, frames, verbose, compact, fullpath])
	Variable skip; // number of frames to skip
	Variable frames; // number of frames to read. 0 will beinterpreted as Inf.
	Variable verbose; // when non-zero, output debug informations
	Variable compact; // when non-zero, multiple frames will be aggregated into single wave
	String fullpath;

	Variable suppress = 1;

	variable fd = -1;
	String path;
	if(ParamIsdefault(fullpath))
		open/R/T=".SPE" fd;
	else
		open/R fd as fullpath;
		//path = "bdbg.spe"
	endif
	path = S_fileName;

	if(fd < 0)
		return -1;
	endif

	Variable t = ticks // start profiling

    	STRUCT SPE_Header h;
	if(read_SPE_header(fd, h) < 0)
		close fd;
		return -1;
	endif
	close fd;

	if(skip >= h.NumFrames)
		return -1; // no more frame to read
	endif

	if(frames == 0)
		frames = h.NumFrames
	endif
	if(frames + skip > h.NumFrames) // allow to use Inf as "frames"
		frames = h.NumFrames - skip
	endif

	Variable fType;
	Variable frameSize;
	switch(h.datatype)
		case 0:
			fType = 2 // fingle-precision IEEE float
			frameSize = 4*h.xdim*h.ydim
			break
		case 1:
			fType = 32 // signed 32 bit int
			frameSize = 4*h.xdim*h.ydim
			break
		case 2:
			fType = 16 // signed 16 bit int
			frameSize = 2*h.xdim*h.ydim
			break
		case 3:
			fType = 16 + 64 // unsigned 16 bit int
			frameSize = 2*h.xdim*h.ydim
			break
	endswitch

	// ensure unique wave names
	Variable i = 0;
	String basename = StringFromList(0, path[strsearch(path, ":", Inf, 1) +1, Inf], ".");
	String wavbase;
	do
		if(skip > 0)
			wavbase = CleanUpName(basename + num2str(i)+"_from"+ num2str(skip)+ "_", 1)
		else
			wavbase = CleanUpName(basename + "_"+ num2str(i)+"_", 1)
		endif
		i += 1
	while(CheckName(wavbase + "0", 1))

	if(ParamIsdefault(fullpath))
		Prompt wavbase, "prefix for waves: "
		DoPrompt "set name prefix", wavbase
	endif
	if(V_flag == 1)
		return -1;
	endif
	if(verbose)
		print "src SPE:", path;
		print "wave base name will be:", wavbase;
		dump_header(h);
		suppress = 0; // to be used with /Q
	endif

	if(compact)
		GBLoadWave /T={(fType),2} /S=(SPE_HEADER_SIZE + (skip*frameSize)) /U=(h.xdim*h.ydim*frames) /W=1 /B /A=$wavbase /Q=(suppress) path;
	else
		// load values from file as arrays of single-float
		GBLoadWave /T={(fType),2} /S=(SPE_HEADER_SIZE + (skip*frameSize)) /U=(h.xdim*h.ydim) /W=(frames) /B /A=$wavbase /Q=(suppress) path;
	endif

	Variable num = V_flag;
	String loaded_waves = S_waveNames

	if(verbose)
		print " * Loaded", num, "frames as ", wavbase + "*"
		print " * Elapsed", (ticks-t)/60
	endif

	String wn;
	if(compact)
		wn = StringFromList(0, loaded_waves)
		if(h.ydim > 1)
			if(verbose)
				print " * redimension to a 3D wave:", h.xdim, h.ydim, frames;
			endif
			Redimension /N=( (h.xdim), (h.ydim), frames), $(wn)
		else
			if(verbose)
				print " * redimension to a 2D wave:", h.xdim, frames;
			endif
			Redimension /N=( (h.xdim), frames), $(wn)
		endif
	else
		if(h.ydim > 1)
			if(verbose)
				print " * redimension to 2D waves:", h.xdim, h.ydim;
			endif
			for(i=0;i<num;i+=1)
				// dynamically truncate loaded_waves to handle many-wave case
				wn = StringFromList(0, loaded_waves)
				loaded_waves = RemoveListItem(0, loaded_waves)
				Redimension /N=( (h.xdim), (h.ydim) ), $(wn)
			endfor
		endif
	endif
	return num;
end

