#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function/wave BaselineArPLS(rawWave)
	/// This function subtract baseline from rawWave
	/// based on Baek et al., 2014 Analyst
	/// Author: Shinichi Miyazaki
	/// @params: rawWave, wave, 1 dimensional wave
	/// @params: lam, variable, parameter for differentiation weight
	wave rawWave
	variable lam = 100000
	variable ratio = 0.1
	wave weightWave
	wave destWave, weightedDiffWave
	variable numofPoints, i, t, count
	variable meanOfNegativeDiffWave, SDOfNegativeDiffWave
	
	numOfPoints = dimsize(rawWave,0)
	// initialize the weightWave and weightWaveDiag
	make/o/free/n=(numOfPoints) weightWave = 1
	make/o/free/n=(numOfPoints) nextweightWave = 1
	matrixop/o/free weightWaveDiag = diagonal(weightWave)
	matrixop/o/free weightedDiffWave = lam *  weightedDiffWave^t x weightedDiffWave 
	count = 0
	do
		matrixop/o/free weightWaveDiag = diagonal(weightWave)
		// (W+H)^-1Wy
		matrixop/o/free invWeight = inv(weightWaveDiag+weightedDiffWave)
		matrixop/o destWave = invWeight x weightWaveDiag x rawWave
		matrixop/o/free diffWave = rawWave - destWave
		
		// make d- only with di<0, set positive val to 0
		Extract/o diffWave, negativeDiffWave, diffWave < 0
		//calc mean and SD of negativeDiffWave
		wavestats/q negativeDiffwave
		meanOfNegativeDiffWave = V_avg
		SDOfNegativeDiffWave = V_sdev	
		make/o/n = (numofPoints) nextweightWave = 1/(1+exp(2*(diffwave[p]-(-meanOfNegativeDiffWave + 2*SDOfNegativeDiffWave))/SDOfNegativeDiffWave))
		matrixop/o tempRatioWv = abs(weightwave-nextweightwave)/abs(weightwave)
		weightwave = nextweightwave
		count +=1
	while(tempRatiowv[0]>ratio)
	//print count
	return diffwave
end

Function/wave MakeWeightedDiffWave(numOfPoints)
	/// This function make the wave for differentiation 
	/// Author: Shinichi Miyazaki
	variable numOfPoints
	variable i, j

	make/o/n = (numOfPoints-2, numOfPoints) weightedDiffWave=0
	i=0
	do
		weightedDiffWave[i][i] =1
		weightedDiffWave[i][i+1] =-2
		weightedDiffWave[i][i+2] =1
		i+=1
	while(i<numOfPoints-2)
	return weightedDiffWave
end


Function BaselineArPLS2D(wave_2d)
	/// This function subtract baseline from rawWave
	/// based on Baek et al., 2014 Analyst
	/// Author: Shinichi Miyazaki
	/// @params: Wave_2d, wave, 2 dimensional wave
	/// @params: lam, variable, parameter for differentiation weight
	wave wave_2d
	variable lam = 10000000
	variable ratio = 0.1
	variable i, spatialpnts, wavenum
	
	Variable start = dateTime
	wavenum = dimsize(wave_2d, 0)
	spatialpnts =dimsize(wave_2d, 1)
	duplicate/o wave_2d wave_blsub
	i=0
	make/o/n = (wavenum) BLSub = 0
	// make weightedDiffWave (H)
	wave weightedDiffWave = MakeWeightedDiffWave(wavenum)
	do 
		make/o/n = (wavenum) tempwave = wave_2d[p][i]
		wave BLSub = BaselineArPLS(tempwave)
		wave_blsub[][i] = BLsub[p]
		i+=1
	while(i<spatialpnts)
	Variable timeElapsed = dateTime - start
	print "This procedure took" + num2str(timeElapsed) + "in seconds."
end