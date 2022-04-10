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
NewImage/K=0 root:ParticleImage
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
   setdrawenv/w=CircleObjectImage0 linefgc=(32639,65535,54484) 
   drawline/w=CircleObjectImage0 (i+1)/xNum,(j)/yNum,(i+1)/xNum,(j+1)/yNum
   endif
 endfor
endfor
end
