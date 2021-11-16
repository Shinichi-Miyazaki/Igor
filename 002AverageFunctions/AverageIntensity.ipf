#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function AverageIntensity(wv,wavenum,roiwv)
	// this function calculate the average intensity among provided roi
	// input wv: 4d wave
	// written by Shinichi Miyazaki
   wave wv, roiwv;
   variable wavenum
   variable pts, xNum, yNum, znum;
   variable i
	//get x and y range
	pts = dimsize(wv,0)
	xNum = dimsize(wv,1)
	yNum = dimsize(wv,2)
	zNum = dimsize(wv,3)
	
	//inverse roiwv
	matrixop/O temproi = -(roiwv-1)
	make/o/n = (zNum) RoiAverage
	
	i=0
	do 
		duplicate/O/R=[wavenum][0,*][0,*][i] wv tempwv
		make/o/n = (1, xNum, yNUM) tempforrearrange 
		tempforrearrange = tempwv[p][q][r][0]
		matrixop/o temptr = transposevol(tempforrearrange, 4)
		make/o/n = (xNum, YnUm) tempwv = temptr[p][q]
		matrixop/o TempSum = sum(tempwv * roiwv)
		matrixop/o TempArea = sum(roiwv)
		RoiAverage[i] = Tempsum[0]/temparea[0]
		i+=1
	while(i<zNum)

end

Function ReduceCols(in)
    wave in
   
    MatrixOP/FREE temp = Sumcols(in)
    MatrixOP/O in = TransposeVol(temp,1)
End