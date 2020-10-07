#pragma rtGlobals=1		// Use modern global access method.
Function wave2Dto4DMS(wv,Numx,Numy,Numz)	//rearrange the 2D wave to 4Dwave
	wave	wv;
	variable	Numx,Numy,Numz;
	variable	SampleNum,i,j,k,l, wvNum;
	variable startnum, endnum

	Silent 1;
	Pauseupdate
	wvNum = dimsize(wv, 0)

	make/O/N=(wvNum,Numx,Numy,Numz)/D CARS;
	k = 0;
	j = 0;


	do
		for(j=0;j<Numy;j=j+1)
			startnum = j * Numx
			endnum = (j+1) * Numx
			Duplicate/Free/R=[0,*][startnum,endnum] wv tempwv
			CARS[][][j][k] = tempwv[p][q];
		endfor
		k += 1
	while(k < Numz)
end
