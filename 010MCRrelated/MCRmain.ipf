#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


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
			matrixop/o PVecExtractMat = colrepeat(PVecExtract, Zrow)^T
			matrixop/o Zp = bitand(Z, PVecExtractMat)
			//matrixop/o Zp = Z x PVecExtractMat
			// solve least square only using passive values 
			matrixop/o Sp = inv(Zp^t x Zp) x Zp^t x xVec
			do
				//C1
				if (wavemin(Sp)<=0)
					innerLoopJudge = 1
					//C2
					matrixop/o/free dp = d^t x PVecExtract
					matrixop/o/free alphaWave = (dp/(dp-sp))
					variable alpha = -wavemin(sp)
					//C3
					d = d + alpha * (Swave-d)
					//update R and P 
					matrixop/o sp = inv(Zp^t x Zp) x Zp^t x xVec
				else
					innerLoopJudge = 0
				endif
			while (innerLoopJudge == 1)
			Swave = d + Sp[0] * PVecExtract
			d = Swave
			Swave = 0
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
