#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function/wave extractCols(wv, colMaskwv)
	wave wv, colMaskwv
	string outWvName = "extractedCols" + nameofWave(wv)
	duplicate/o wv $outWvName
	wave outwave = $outWvName
	
	matrixop/o/free outwave = scalecols((outwave+1), colMaskwv)
	matrixop/o/free outwave = replace(outwave, 0, NaN)
	matrixop/o/free outwave = outwave^t
	variable numOfRows = dimsize(outwave,0) 
	variable numOfCOls = dimsize(outwave,1)
	Redimension /N=(numOfRows*numOfCOls) outwave
	WaveTransform zapNaNs  outwave
	variable numOfRowsChanged = numpnts(outwave)/numOfCOls 
	Redimension /N=(numOfRowsChanged, numOfCOls) outwave
	matrixop/o outwave = outwave^t
	matrixop/o/free outwave = outwave-1
	return outwave
end


Function/wave extractRows1D(wv, rowMaskWv)
	wave wv, rowMaskWv
	string outWvName = "extracted" + nameofWave(wv)
	duplicate/o wv $outWvName
	wave outwave = $outWvName
	
	matrixop/o outwave = replace((outwave+1) * rowMaskWv, 0, NaN)
	wavetransform zapNaNs outwave
	if (dimsize(outwave, 0) == 0)
		matrixop/o outwave=0
	else 
		matrixop/o outwave=outwave-1
	endif
	return outwave
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
	
	variable alphaTol = 1e-15
	variable/G residual = 0
	
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
	make/o/d/n = (ZColumn) d = 0
	make/o/d/n = (ZColumn) Swave = 0
	// A4
	matrixop/o w = Z^t x (xVec- Z x d)
	make/o/n=(Zcolumn) WIdwave = p

	do
		//B1
		wave WnR = extractRows1D(w, RVecExtract)
		wave WIdWaveR = extractRows1D(WIdWave, RVecExtract)
		variable WnRmax = wavemax(WnR)
		if (sum(RVecExtract)!=0 && (WnRmax>tolerance))
			mainLoopJudge = 1
			//B2
			wavestats/Q WnR
			variable m = WIdWaveR[V_maxRowLoc]
			
			//B3
			//Remove from Rvec
			RVecExtract[m] = 0
			//Include in PVec
			PVecExtract[m] = 1
			//B4
			wave Zp = extractCols(Z, PVecExtract)
			// solve least square only using passive values 
			matrixop/o Sp = inv(Zp^t x Zp) x Zp^t x xVec
			
			make/o/n=(Zcolumn) indexwave = p
			matrixop/o indexWave = (indexWave+1)*PVecExtract
			indexWave = indexWave == 0 ? NaN : indexWave
			WaveTransform zapNaNs indexwave
			indexwave -= 1
			
			Swave[indexWave] = {Sp}
			
			do
				//C1
				if (wavemin(Sp)<=0)
					innerLoopJudge = 1
					//C2
					wave dp = extractRows1D(d, PVecExtract)
					
					// get negative index
					make/o/n=(numpnts(Sp)) negativeIndex = (Sp[p]<=0) ? p+1 : 0
					negativeIndex = negativeIndex == 0 ? NaN : negativeIndex
					WaveTransform zapNaNs negativeIndex
					negativeIndex -= 1
					make/o/n=(numPnts(negativeIndex)) Snegative = Sp[negativeIndex]
					make/o/n=(numPnts(negativeIndex)) Dnegative = dp[negativeIndex]
										
					matrixop/o alphaWave = (Dnegative/(Dnegative-Snegative))
					variable alpha = wavemin(alphaWave)
					if (alpha < alphaTol)
						Sp = Dp
						make/o/n=(Zcolumn) indexwave = p
						matrixop/o indexWave = (indexWave+1)*PVecExtract
						indexWave = indexWave == 0 ? NaN : indexWave
						WaveTransform zapNaNs indexwave
						indexwave -= 1
						make/o/d/n = (ZColumn) Swave = 0
						Swave[indexWave] = {Sp}
						
						innerLoopJudge = 0
					else
						//C3
						d = d + alpha * (Swave-d)
						//update R and P 
						make/o/n=(Zcolumn) removeVec = (d[p]<=0) ? 0 : 1
						matrixop/o PVecExtract = PVecExtract * removeVec
						matrixop/o RVecExtract = -(PVecExtract-1)
						
						wave Zp = extractCols(Z, PVecExtract)
						matrixop/o sp = inv(Zp^t x Zp) x Zp^t x xVec
						
						make/o/n=(Zcolumn) indexwave = p
						matrixop/o indexWave = (indexWave+1)*PVecExtract
						indexWave = indexWave == 0 ? NaN : indexWave
						WaveTransform zapNaNs indexwave
						indexwave -= 1
						
						make/o/d/n = (ZColumn) Swave = 0
						Swave[indexWave] = {Sp}
					endif
				else
					innerLoopJudge = 0
				endif
			while (innerLoopJudge == 1)
			d = Swave
			matrixop/o w = Z^t x (xVec- Z x d)
		else
			mainLoopJudge = 0
		endif
	while (mainLoopJudge==1)
	matrixop/o tempresidual = (Z x d - XVec)^t x (Z x d - XVec) 
	residual = residual + tempresidual[0]
	return d
end

function [wave concentration, wave spectrum] MCRALS(wave indata, wave initSpec,variable xNum,variable yNum,variable maxIter)
	variable i, j
	variable/G residual
	
	variable tolerance = 1e-15
	variable spatialNum = dimsize(indata, 0)
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
			matrixop/o Zwave = indata^t
			variable meanresidual = 0
			do
				make/o/n = (waveNum) tempZ = Zwave[p][j]
				wave ans = NNLS(InitSpec, tempZ, tolerance)
				Concentration[j][] = ans[q]
				meanresidual += residual
				j+=1
			while (j<spatialNum)
			meanresidual /= spatialNum
			print "Iter: " + num2str(i) + " (C), mse = " + num2Str(meanresidual)
		elseif (mod(i,2)==1)
			matrixop/o Zwave = indata
			meanresidual = 0
			do
				make/o/n = (spatialNum) tempZ = Zwave[p][j]
				wave ans = NNLS(Concentration, tempZ, tolerance)
				Spectrum[j][] = ans[q]
				meanresidual += residual
				j+=1
			while (j<waveNum)
			meanresidual /= waveNum
			print "Iter: " + num2str(i) + " (ST), mse = " + num2Str(meanresidual)
		else 
			matrixop/o Zwave = indata^t
			meanresidual = 0
			do
				make/o/n = (waveNum) tempZ = Zwave[p][j]
				wave ans = NNLS(Spectrum, tempZ, tolerance)
				Concentration[j][] = ans[q]
				meanresidual += residual
				j+=1
			while (j<SPatialnum)
			meanresidual /= spatialNum
			print "Iter: " + num2str(i) + " (C), mse = " + num2Str(meanresidual)
		endif 
		i += 1
	while (i<maxIter)
	return [Concentration, spectrum]
end 



Function [wave rawdata2d,wave subxaxis, wave M_U] SVDandPlots(wave rawData, wave xAxis,variable componentNum, variable startWvNum, variable endWvNum)
	/// Author: Shinichi Miyazaki
	/// This function conduct SVD and plot spectrum and make images
	/// @params	rawData:			4D wave 	(waveNum, x, y, z) 
	/// @params	xAxis:			1D wave 	(waveNum)
	/// @params	componentNum:	variable	(how many componets do you want to divide into)
	/// @params	xNum, yNUm:		variable	(spatial points)
	/// @params	startWavenum	variable	(optional, wavenum ROI)
	
	wave M_U, M_V
	variable i, xnum, ynum
	String imageName
	
	xNum = dimsize(rawdata,1)
	yNUm = dimsize(rawdata,2)
	
	// subrange waves
	make/o/n=(dimsize(xaxis,0)) maskwave = 1
	maskwave = xaxis <= startwvnum ? 0 : maskwave
	maskwave = xaxis >= endwvnUm ? 0 : maskwave
	wave subxaxis = extractRows1D(xaxis, maskwave)
	wave rawData2D = wave4dto2dSVD(rawData, xNum, yNum)
	matrixop/o rawdata2d = rawdata2d^t
	wave subrawdata = extractCols(rawdata2d, maskwave)
	matrixop/o subrawdata = subrawdata^t
	
	
	// svd 
	matrixSVD/DACA/PART=(componentNum) subrawdata
	
	// make spectrum graphs
	wave M_U = M_U
	wave M_V = M_V
	i=1
	display M_U[][0] vs xAxis
	do
		AppendtoGraph M_U[][i] vs xAxis
		i+=1
	while (i<componentNum-1)	
	SetAxis/A/R bottom
	
	// make images
	i=0
	do 
		imageName = "image" + num2str(i)
		make/o/n = (xNum*yNum)/D $imageName = M_V[p][i]
		redimension/n =(xNum, yNum) $imageName 
		display; appendimage $imageName
		ModifyGraph width=200, height = {Aspect, yNum/xNum}
		i+=1
	while (i<componentNum)
	return [subrawdata,subxaxis, M_U]
end

Function/wave wave4Dto2DSVD(wv,Numx,Numy)
	wave	wv;
	variable	Numx,Numy;
	variable	SampleNum,i,j,k,l, wvNum;
	variable start, startnum, endnum, pixelnum, num

	wvNum = dimsize(wv, 0)
	pixelnum = Numx*Numy

	make/O/N=(wvNum,pixelnum)/D imchi3_2d;
	k = 0;
	num=0

	do
		for(j=0;j<Numx;j=j+1)
			imchi3_2D[][num] = wv[p][j][k][0];
			num+=1
		endfor
		k += 1
	while(k < Numy)
	return imchi3_2d
end


function SVD_MCRALS(indata, xaxis, componentNum, startwvNum, endwvNum, maxiter)
	wave indata, xaxis
	variable componentNum, startwvNum, endwvNum, maxiter
	variable i, xnum, ynum
	wave rawdata2d, M_U, concentration, spectrum, subaxis
	string imagename
	
	xnum = dimsize(indata, 1)
	ynUm = dimsize(indata,2)
	[rawdata2d,subaxis, M_U] = SVDandPlots(indata, xAxis, componentNum, startwvNum, endwvNum)
	matrixop/o rawdata2d = rawdata2d^t
	[concentration, SPectrum] = MCRALS(rawdata2d, M_U, xNum, yNum, maxIter)
	//show concentration
	i=0
	do
		imagename = "component" + num2str(i)
		make/o/n=(xNUm*yNUm) $imagename = concentration[p][i]
		redimension/N= (xnUm, yNum) $imagename
		display;appendimage $Imagename;
		ModifyGraph width=200,height={Aspect,yNum/xNum}
		ModifyImage $Imagename ctab= {*,3,ColdWarm,0}
		i+=1
	while (i<componentNum)
	
	// show spectrum
	i=0
	do 
		if (i==0)
			display spectrum[][i] vs subaxis
		else
			AppendToGraph Spectrum[][i] vs subaxis
		endif
		i+=1
		SetAxis/A/R bottom
	while (i<componentNum)
end