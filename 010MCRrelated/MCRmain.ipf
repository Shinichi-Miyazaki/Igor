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

Function/wave extractRows1D(wv, rowMaskWv)
	wave wv, rowMaskWv
	
	matrixop/o/free inwave = wv+1
	matrixop/o/free extractedWave = replace(inwave*rowMaskWv, 0, NaN)
	wavetransform zapNaNs extractedWave
	matrixop/o extractedWave=extractedWave-1
	return extractedWave
end

function NNLS(Z, xvec, tolerance)
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
	// P_vec is indices which already changed
	make/o/n = 0 PVec
	make/o/n = (Zcolumn) PVecExtract=0
	// A2
	// R_vec is indices which is not updated
	//make/o/n = (ZColumn) RVec = p
	make/o/n = (Zcolumn) RVecExtract=1
	// A3
	make/o/n = (ZColumn) d = 0
	make/o/n = (ZColumn) Swave = 0
	// A4
	matrixop/o w = Z^t x (xVec- Z x d)

	do
		//B1
		matrixop/o WnR = w * RVecExtract
		//wave WnR = extractCols(w, RvecExtract)
		if (sum(RVecExtract)!=0 && (wavemax(WnR)>tolerance))
			mainLoopJudge = 1
			//B2
			wavestats/Q WnR
			//B3
			//Remove from Rvec
			//Extract/O RVec, RVec, RVec!=RVec[V_maxRowLoc]
			RVecExtract[V_maxRowLoc] = 0
			//Include in PVec
			PVec[V_maxRowLoc] = {1}
			PVecExtract[V_maxRowLoc] = 1
			//B4
			// following code make Zp = 1 d 
			// change PVexExtract to matrix which can extract p colomns from Z or d
			wave Zp = extractCols(Z, PVecExtract)
			//matrixop/o Zp = Z x PVecExtractMat
			// solve least square only using passive values 
			matrixop/o Sp = inv(Zp^t x Zp) x Zp^t x xVec
			do
				//C1
				if (wavemin(Sp)<=0)
					innerLoopJudge = 1
					//C2
					wave dp = extractRows1D(d, PVecExtract)
					matrixop/o/free alphaWave = (dp/(dp-sp))
					variable alpha = -wavemin(sp)
					//C3
					d = d + alpha * (Swave-d)
					//update R and P 
					removeVec = (d[p]==0) ? 0 : 1
					matrixop/o PVecExtract = PVecExtract * removeVec
					matrixop/o RVecExtract = -(PVecExtract-1)
					matrixop/o sp = inv(Zp^t x Zp) x Zp^t x xVec
				else
					innerLoopJudge = 0
				endif
			while (innerLoopJudge == 1)
			// followin code is incorrect
			Swave = d + Sp[0] * PVecExtract
			d = Swave
			//Swave = 0
			// maybe following row is not needed
			//PVecExtract=0
			matrixop/o w = Z^t x (xVec- Z x d)
		else
			mainLoopJudge = 0
		endif
	while (mainLoopJudge==1)
	matrixop/o residual = (Z x d - XVec)^t x (Z x d - XVec) 
	print residual[0]^0.5
end


