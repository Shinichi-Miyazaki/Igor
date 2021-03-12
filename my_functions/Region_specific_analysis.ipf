#pragma TextEncoding = "Shift_JIS"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
Function region_extract(wv, roi, znum)	//extract data from imchi3_data 
//put 4D imchi3_data, roi wave, and z position you want to analyze
	wave	wv, roi;
	variable znum;
	Silent 1;
	Pauseupdate
	
	//extract a single plane wave from imchi3_data, z position is znum
	duplicate/R=[0,*][0,*][0,*][znum]  imchi3_data tempwv
	//original region's value is zero, following fomula change it to one 
	matrixOp/O/FREE temproi = -(roi-1) 
	matrixop/
	wvNum = dimsize(wv, 0)

	make/O/N=(wvNum,Numx,Numy,Numz)/D CARS;
	k = 0;
	j = 0;


	do
		for(j=0;j<Numy;j=j+1)
			start = k * Numx * Numy
			startnum =  start + j * Numx
			endnum = start + (j+1) * Numx
			Duplicate/Free/R=[0,*][startnum,endnum] wv tempwv
			CARS[][][j][k] = tempwv[p][q];
		endfor
		k += 1
	while(k < Numz)
end