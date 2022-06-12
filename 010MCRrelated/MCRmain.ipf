#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function/wave remove_blank_cols(inwave)
	wave inwave
	matrixop/o/free inwaveCopy = inwave^t

	variable numOfRows = dimsize(inwaveCopy,0) 
	variable numOfCOls = dimsize(inwaveCopy,1)
	// redimension to 1D wave
	Redimension /N=(numOfRows*numOfCOls) inwaveCopy
	WaveTransform zapNaNs  inwaveCopy
	variable numOfRowsChanged = numpnts(inwaveCopy)/numOfCOls 
	Redimension /N=(numOfRowsChanged, numOfCOls) inwaveCopy
	matrixop/o destWave = inwaveCopy^t
	return destWave
end

Function/wave extractCols(wv, colMaskwv)
	wave wv, colMaskwv
	matrixop/o/free inwave = wv+1
	matrixop/o/free extractedWave = scalecols(inwave, colMaskwv)
	matrixop/o/free extractedWave = replace(extractedWave, 0, NaN)
	wave destWave = remove_blank_cols(extractedWave)
	matrixop/o destWave = destwave-1
	return destWave
end


Function/wave extractCols2(wv, colMaskwv)
	wave wv, colMaskwv
	matrixop/o/free destwave = scalecols(wv, colMaskwv)
	return destWave
end

Function/wave extractRows1D(wv, rowMaskWv)
	wave wv, rowMaskWv
	
	matrixop/o/free inwave = wv+1
	matrixop/o/free extractedWave = replace(inwave*rowMaskWv, 0, NaN)
	wavetransform zapNaNs extractedWave
	matrixop/o extractedWave=extractedWave-1
	return extractedWave
end

Function/wave colSelectMatGen(colIndices)
	wave colIndices
	variable i
	variable matSize = numpnts(colIndices)
	matrixop/o colSelectMat = identity(matSize)
	i=0
	do 
		colSelectMat[i][i] = colIndices[i]
		i+=1
	while(i<matSize)
	return colSelectMat
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
	make/o/n = (ZColumn) d = 0
	make/o/n = (ZColumn) Swave = 0
	// A4
	matrixop/o w = Z^t x (xVec- Z x d)

	do
		//B1
		wave WnR = extractRows1D(w, RVecExtract)
		//matrixop/o WnR = w * RVecExtract
		if (sum(RVecExtract)!=0 && (wavemax(WnR)>tolerance))
			mainLoopJudge = 1
			//B2
			wavestats/Q WnR
			//B3
			//Remove from Rvec
			RVecExtract[V_maxRowLoc] = 0
			//Include in PVec
			PVecExtract[V_maxRowLoc] = 1
			//B4
			wave Zp = extractCols(Z, PVecExtract)
			// solve least square only using passive values 
			matrixop/o Sp = inv(Zp^t x Zp) x Zp^t x xVec
			do
				//C1
				if (wavemin(Sp)<=0)
					innerLoopJudge = 1
					//C2
					wave dp = extractRows1D(d, PVecExtract)
					matrixop/o/free alphaWave = (dp/(dp-sp))
					variable alpha = -wavemin(alphaWave)
					//C3
					d = d + alpha * (Swave-d)
					//update R and P 
					make/o/n=(Zcolumn) removeVec = (d[p]==0) ? 0 : 1
					matrixop/o PVecExtract = PVecExtract * removeVec
					matrixop/o RVecExtract = -(PVecExtract-1)
					wave Zp = extractCols(Z, PVecExtract)
					matrixop/o sp = inv(Zp^t x Zp) x Zp^t x xVec
					
					make/o/n=(Zcolumn) indexwave = p
					matrixop/o indexWave = (indexWave+1)*PVecExtract
					indexWave = indexWave == 0 ? NaN : indexWave
					WaveTransform zapNaNs indexwave
					indexwave -= 1
					
					Swave[indexWave] = {Sp}
				else
					innerLoopJudge = 0
				endif
			while (innerLoopJudge == 1)
			
			make/o/n=(Zcolumn) indexwave = p
			matrixop/o indexWave = (indexWave+1)*PVecExtract
			indexWave = indexWave == 0 ? NaN : indexWave
			WaveTransform zapNaNs indexwave
			indexwave -= 1
			
			// followin code is incorrect
			Swave[indexWave] = {Sp}
			d = Swave
			matrixop/o w = Z^t x (xVec- Z x d)
		else
			mainLoopJudge = 0
		endif
	while (mainLoopJudge==1)
	matrixop/o residual = (Z x d - XVec)^t x (Z x d - XVec) 
	return d
	//print residual[0]^0.5
end


function MCRALS(indata, initSpec, xNum, yNum, maxIter)
	wave indata, initSpec
	variable xNum, yNum, maxIter
	variable i, j
	
	variable tolerance = 0
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
			do
				matrixop/o Zwave = indata^t
				make/o/n = (wavenum) xVec = 0 
				xVec = initSpec[p][j]
				wave ans = NNLS(Zwave, xvec, tolerance)
				Concentration[][j] = ans[p]
				j+=1
			while (j<specNum)
		elseif (mod(i,2)==1)
			do
				matrixop/o tempConcentration = Concentration
				matrixop/o Zwave = indata
				make/o/n  = (spatialPnts) xVec = 0
				xVec = tempConcentration[p][j]
				wave ans = NNLS(Zwave, xvec, tolerance)
				Spectrum[][j] = ans[p]
				j+=1
			while (j<specNum)
		else 
			do
				matrixop/o Zwave = indata^t
				make/o/n  = (waveNum) xVec = 0
				xVec = Spectrum[p][j]
				wave ans = NNLS(Zwave, xvec, tolerance)
				Concentration[][j] = ans[p]
				j+=1
			while (j<specNum)
		endif 
		i += 1
	while (i<maxIter)
end 