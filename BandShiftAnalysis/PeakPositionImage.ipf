#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
function PeakPositionImage(rawwv, axis,  StartWvNum, EndWvNum)
	///This function enable the analysis about band shift (i.e. 1650)
	///wv: the 4D wave you want to analyze
	///axis: the x axis you want to use for analysis
	///StartWvNum: The lowest wave number of the interested band
	///EndWvNum: The higest wave number
	///Author: Shinichi Miyazaki
	
	wave rawwv, axis
	variable StartWvNum, EndWvNum
	variable wvnum = dimsize(rawwv,0)
	variable xnum = dimsize(rawwv,1)
	variable yNum = dimsize(rawwv,2)
	variable pnts = xNum*yNUm
	variable i, j, k, num
	
	
	// wave 4d to 2d
	make/O/N=(wvNum,pnts)/D wv
	k = 0;
	num=0

	do
		for(j=0;j<xNum;j=j+1)
			wv[][num] = rawwv[p][j][k][0];
			num+=1
		endfor
		k += 1
	while(k < yNum)
	
	// Get which subrange should be extracted within x axis
	matrixop/o AxisMask = setNans(axis, greater(axis, EndwvNum))
	AxisMask = -AxisMask
	matrixop/o AxisMask = setNans(AxisMask, greater(AxisMask, -StartwvNUm))
	AxisMask = -AxisMask
	//Numtype return 2 if the value is NaN and 0 for normal value. 
	//To convert 0 for Nan and 1 for nomal value, following eq is needed
	matrixop/o Axismask = -((numtype(axismask)-2)/2)
	matrixop/o RepeatedAxisMask = colrepeat(AxisMask,Pnts)
	matrixop/o Maskedwv = RepeatedAxisMask * wv 

	
	// calculate the wave number, where the intensity was maximum 
	// obtain maximum values
	matrixop/o MaximumVals = maxcols(maskedwv)
	
	make/o/n=(pnts) ShiftImage
	i = 0;
	do 
		duplicate/o/r=[0,*][i] maskedwv tempwv
		redimension/n=(wvnum) tempwv
		variable tempmax = maximumvals[0][i]
		findvalue/v=(tempmax) tempwv
		ShiftImage[i] = axis[V_value]
		
	// Make new 2D wave, each pixel has the shift number
		i+=1
	while(i<Pnts)
	
	redimension/n=(xNum, yNum) ShiftImage
end
