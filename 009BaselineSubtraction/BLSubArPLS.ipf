#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function BaselineArPLS(rawWave, lam, ratio)
	/// This function subtract baseline from rawWave
	/// based on Baek et al., 2014 Analyst
	/// Author: Shinichi Miyazaki
	/// @params: rawWave, wave, 2 dimensional wave
	/// @params: lam, variable, parameter for differentiation weight
	wave rawWave
	variable lam, ratio
	wave weightWave
	wave destWave, weightedDiffWave
	variable numofPoints, i, t, count
	variable meanOfNegativeDiffWave, SDOfNegativeDiffWave
	
	numOfPoints = dimsize(rawWave,0)
	// initialize the weightWave and weightWaveDiag
	make/o/free/n=(numOfPoints) weightWave = 1
	make/o/free/n=(numOfPoints) nextweightWave = 1
	matrixop/o/free weightWaveDiag = diagonal(weightWave)
	// make weightedDiffWave (H)
	wave weightedDiffWave = MakeWeightedDiffWave(numOfPoints)
	matrixop/o/free weightedDiffWave = lam *  weightedDiffWave^t x weightedDiffWave 
	
	t=0
	count = 0
	do
		matrixop/o/free weightWaveDiag = diagonal(weightWave)
		// (W+H)^-1Wy
		matrixop/o/free invWeight = inv(weightWaveDiag+weightedDiffWave)
		matrixop/o destWave = invWeight x weightWaveDiag x rawWave
		matrixop/o/free diffWave = rawWave - destWave
		
		// make d- only with di<0
		// set positive val to 0
		Extract/o diffWave, negativeDiffWave, diffWave < 0
		//matrixop/o/free negativeDiffWave = clip(diffWave, -Inf, 0)
		// or this?
		// Extract diffwave negativeDiffWave diffwave<0
		//calc mean and SD of negativeDiffWave
		wavestats/q negativeDiffwave
		meanOfNegativeDiffWave = V_avg
		SDOfNegativeDiffWave = V_sdev
		i=0
		do
			nextweightWave[i] = 1/(1+exp(2*(diffwave[i]-(-meanOfNegativeDiffWave + 2*SDOfNegativeDiffWave))/SDOfNegativeDiffWave))
			i+=1
		while(i<numOfPoints)
		t+=1
		matrixop/o tempRatioWv = abs(weightwave-nextweightwave)/abs(weightwave)
		variable tempRatio = tempRatiowv[0]
		weightwave = nextweightwave
		count +=1
	while(tempRatio>ratio)
	matrixop/o BLSub = rawwave - destWave
	print count
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