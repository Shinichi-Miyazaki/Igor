#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//Author: Minori Masaki
//Procedure to detect objects from images.

//This function is extract particles for fill centers.
//Use ThresholdValues that are clearly part of the object.
//Use the appropriate minimum particle size >=4.
function ParticleExtract(OriginalImage,ThreshVal,minSize)
  wave OriginalImage;
  variable ThreshVal,minSize;

  duplicate/O OriginalImage, ParticleImage
  ImageThreshold/O/M=0/T=(ThreshVal)/i ParticleImage
  duplicate/O ParticleImage, M_particle
  ImageAnalyzeParticles/D=ParticleImage/W/E/A=(minSize)/M=3 stats ParticleImage
  ParticleImage=M_particle

  duplicate/o  ParticleImage, ParticleROI //Make ParticleROI
	ImageThreshold/O/T=20 ParticleROI
	matrixop/o ParticleROI=ParticleROI/255
	matrixop/O ParticleROI=uint8(ParticleROI)
	newImage/K=0 root:ParticleROI
  
  Killwaves/Z W_BoundaryX,W_BoundaryY,W_circularity,W_ImageObjArea,W_ImageObjPerimeter,W_IntAvg,W_IntMax,W_IntMin,W_rectangularity,W_xmax,W_xmin,W_ymax,W_ymin,W_BoundaryIndex,M_Moments,M_RawMoments
end



//This function creates edges that acts as banks when filling in.
//Use the same ThreshVal as ParticleExtract by default. 
function EdgeEnhanced(OriginalImage,ThreshVal)
  wave OriginalImage;
  variable ThreshVal;

  duplicate/O OriginalImage, EdgeEnhancedImage
  ImageEdgeDetection/O/S=1/M=1 Canny EdgeEnhancedImage
  ImageThreshold/O/Q/M=1/i EdgeEnhancedImage
  matrixop/o EdgeEnhancedImage=OriginalImage+(EdgeEnhancedImage*ThreshVal/255/2)
  matrixop/o EdgeEnhancedImage=uint8(EdgeEnhancedImage)
  NewImage/K=0 root:EdgeEnhancedImage
end



//This function fills in the edges with particles as a marker.
//If the particle areas were too large, it takes longer due to SeedFill.
//minval should be higher than the background value.
function EdgeFillbyParticle(OriginalImage,ParticleImage,EdgeEnhancedImage,minval)
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
    setdrawenv/w=CircleObjectImage0 linefgc=(30583,55769,43176) 
    drawline/w=CircleObjectImage0 (i+1)/xNum,(j)/yNum,(i+1)/xNum,(j+1)/yNum
    endif
  endfor
  endfor
end


//function to determine the position
function Positioning(BiggerImage,SmallerImage,xTravel,yTravel)
  wave BiggerImage,SmallerImage; //BiggerImage assumes TIFF original image, SmallerImage assumes mCARS image
  variable xTravel,yTravel;
  wave EdgeImage, ObjectROI,ParticleROI;
  variable i,j,bxNum,byNum,sxNum,syNum;

  sxNum = dimsize(SmallerImage,0)
  syNum = dimsize(SmallerImage,1)
  bxNum = dimsize(BiggerImage,0)
  byNum = dimsize(BiggerImage,1)
  duplicate/O SmallerImage, PositionImage //To make the same type as SmallerImage
  redimension/N=(bxNum,byNum) PositionImage
  PositionImage=0
  duplicate/O ObjectROI, CutObjectROI //To make CutObjectROI for mCARS image
  redimension/N=(sxNum,syNum) CutObjectROI
  CutObjectROI=0
  duplicate/O ParticleROI, CutObjectROI1
  redimension/N=(sxNum,syNum) CutObjectROI1
  CutObjectROI1=0

  Silent 1; PauseUpdate
  for(i=0;(i<sxNum && i+xTravel<bxNum);i+=1)
    for(j=0;(j<syNum && j+yTravel<byNum);j+=1)
        PositionImage[i+xTravel][j+yTravel] = SmallerImage[i][j]
        CutObjectROI[i][j]=ObjectROI[i+xTravel][j+yTravel]
        CutObjectROI1[i][j]=ParticleROI[i+xTravel][j+yTravel]
    endfor
  endfor
  killwindow/z PositionImage0
  NewImage/n=PositionImage0 PositionImage

  for(i=0;i<bxNum;i+=1)
    for(j=0;j<byNum;j+=1)
      if(EdgeImage[i][j]==0)
      setdrawenv/w=PositionImage0 linefgc=(30583,55769,43176), linethick=0.25
      drawline/w=PositionImage0 (i+1)/bxNum,(j)/byNum,(i+1)/bxNum,(j+1)/byNum
      endif
    endfor
  endfor
end



//use ParticleImage
function ParticlePositioning(BiggerImage,SmallerImage,xTravel,yTravel)
  wave BiggerImage,SmallerImage; //BiggerImage assumes TIFF original image, SmallerImage assumes mCARS image
  variable xTravel,yTravel;
  wave ParticleImage;
  variable i,j,bxNum,byNum,sxNum,syNum;

  sxNum = dimsize(SmallerImage,0)
  syNum = dimsize(SmallerImage,1)
  bxNum = dimsize(BiggerImage,0)
  byNum = dimsize(BiggerImage,1)
  duplicate/O SmallerImage, PositionImage //To make the same type as SmallerImage
  redimension/N=(bxNum,byNum) PositionImage
  PositionImage=0
  duplicate/O ParticleImage, CutObjectROI //To make CutObjectROI for mCARS image
  redimension/N=(sxNum,syNum) CutObjectROI
  CutObjectROI=0

  Silent 1; PauseUpdate
  for(i=0;(i<sxNum && i+xTravel<bxNum);i+=1)
    for(j=0;(j<syNum && j+yTravel<byNum);j+=1)
	    PositionImage[i+xTravel][j+yTravel] = SmallerImage[i][j]
        if(ParticleImage[i+xTravel][j+yTravel]==64)
			CutObjectROI[i][j]=1
		endif
    endfor
  endfor
  killwindow/z PositionImage0
  NewImage/n=PositionImage0 PositionImage

  for(i=0;i<bxNum;i+=1)
    for(j=0;j<byNum;j+=1)
      if(ParticleImage[i][j]==18)
      setdrawenv/w=PositionImage0 linefgc=(30583,55769,43176), linethick=0.25
      drawline/w=PositionImage0 (i+1)/bxNum,(j)/byNum,(i+1)/bxNum,(j+1)/byNum
      endif
    endfor
  endfor
end


//This function makes reverse ROI.
function MakeRiverseROI(OriginalROI)
	wave OriginalROI;
	duplicate/o  OriginalROI, RiverseROI
	ImageThreshold/O/T=0 RiverseROI
	matrixop/o RiverseROI=-(RiverseROI/255-1)
	matrixop/O RiverseROI=uint8(RiverseROI)
	newImage/K=0 root:RiverseROI
end
