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
	MatrixOp/O image2 = setNaNs(image2,greater(LowerThreshold,image2))
	matrixop/o RatioImage=image1/image2
   NewImage RatioImage
end
	


