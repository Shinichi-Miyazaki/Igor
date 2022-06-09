#pragma TextEncoding = "Shift_JIS"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
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