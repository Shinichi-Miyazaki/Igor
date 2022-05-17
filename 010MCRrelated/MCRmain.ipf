#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


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
	variable mainLoopJudge
	
	//obtain matrix size
	variable ZRow = dimsize(Z, 0) 
	variable ZColumn = dimsize(Z, 1) 
	
	// A1 
	// P_vec is indices which already changed
	make/o/n = (ZColumn) PVec = 0
	// A2
	// R_vec is indices which is not updated
	make/o/n = (ZColumn) RVec = p
	// A3
	make/o/n = (ZColumn) d = 0
	// A4
	matrixop/o w = Z^t x (xVec- Z x d)
	//todo if A is not 2dim array, alert
	
	//B1 
	do
		if (dimsize(RVec,0)!=1 && (wavemax(w)>tolerance))
			mainLoopJudge = 1
			wavestats/Q w
			// there is no empty wave
			// dimsize(RVec, 0) == 0 is impossible
			Extract/O RVec, RVec, RVec!=RVec[V_maxRowLoc+1]
			PVec[V_maxRowLoc+1] = 1
			matrixop/o Zp = Z x PVec
			matrixop/o sp = inv(Zp^t x Zp) x Zp^t x xVec
			do
				matrixop/o/free dp = d^t x PVec
				matrixop/o/free alphaWave = (dp/(dp-sp))
				wavestats/q alphawave
				variable alpha = -V_min
				d = d + alpha * (s-d)
				//update R and P 
				
				matrixop/o sp = inv(Zp^t x Zp) x Zp^t x xVec
				matrixop/o sr = 0
				wavestats/Q sp
			while (V_min <= 0)
			d = s
			matrixop/o w = Z^t x (xVec- Z x d)
			
		else
			mainLoopJudge = 0
		endif
	while (mainLoopJudge==1)
	
	return d
end
