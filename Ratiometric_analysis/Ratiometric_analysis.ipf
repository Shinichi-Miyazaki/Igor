#pragma TextEncoding = "Shift_JIS"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
function ratiometric_image(image1, image2)
	wave image1, image2
	variable xNum, yNum
	variable i, j

	// get x, y range
	xNum = dimsize(image1,0)
	yNum = dimsize(image1,1)
	make/o/n=(xNum, yNum) ratioimage
	
	i=0
    do
        j=0
        do
            ratioimage[i][j] = image1[i][j] / image2[i][j]
            j+=1
        while(j<yNUm)
        i+=1
    while(i<xNum)
    NewImage ratioimage

end
	


