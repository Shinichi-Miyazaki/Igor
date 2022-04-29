#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function BaselineArPLS(rawWave, lam)
	/// This function subtract baseline from rawWave
	/// based on Baek et al., 2014 Analyst
	/// Author: Shinichi Miyazaki
	/// @params: rawWave, wave, 2 dimensional wave
	/// @params: lam, variable, parameter for differentiation weight
	wave rawWave
	variable lam
	wave weightWave
	wave destWave, weightedDiffWave
	variable numofPoints, i, t
	variable meanOfNegativeDiffWave, SDOfNegativeDiffWave
	
	numOfPoints = dimsize(rawWave,1)
	
	// initialize the weightWave and weightWaveDiag
	make/o/free/n=(numOfPoints) weightWave = 1
	matrixop/o/free weightWaveDiag = diagonal(weightWave)
	// make weightedDiffWave (H)
	MakeWeightedDiffWave(numOfPoints)
	matrixop/o/free weightedDiffWave = lam * weightedDiffWave * weightedDiffWave^t
	
	t=0
	do
		matrixop/o/free weightWaveDiag = diagonal(weightWave)
		// (W+H)^-1Wy
		matrixop/o/free invWeight = inv(weightWaveDiag+weightedDiffWave)
		//destWave = invWeigth * weightWaveDiag * rawWave
		matrixop/o/free diffWave = rawWave - destWave
		
		// make d- only with di<0
		// set positive val to 0
		matrixop/o/free negativeDiffWave = clip(diffWave, -Inf, 0)
		//calc mean and SD of negativeDiffWave
		wavestats negativeDiffwave
		meanOfNegativeDiffWave = V_avg
		SDOfNegativeDiffWave = V_sdev
		
		
		i=0
		do
			i+=1
		while(i<numOfPoints)
		t+=1
	while(t<i) 
end

Function MakeWeightedDiffWave(numOfPoints)
	/// This function make the wave for differentiation 
	/// This function is too inefficient, cannot work with over 10000
	/// Author: Shinichi Miyazaki
	variable numOfPoints
	variable i, j

	make/o/n = (numOfPoints, numOfPoints) weightedDiffWave=0
	i=0
	do
		j=0
		do	
			if(i==j)
				weightedDiffWave[j][i] = 1
			elseif(i==j+1)
				weightedDiffWave[j][i] = -2
			elseif(i==j+2)
				weightedDiffWave[j][i] = 1
			endif
			j+=1
		while(j<numOfPoints)
		i+=1
	while(i<numOfPoints)
end