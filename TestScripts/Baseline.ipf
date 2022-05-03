﻿#pragma TextEncoding = "UTF-8"
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
	variable numofPoints, count
	variable meanOfNegativeDiffWave, SDOfNegativeDiffWave
	Variable start = dateTime
	
	numOfPoints = dimsize(rawWave,0)
	// initialize the weightWave and weightWaveDiag
	make/o/free/n=(numOfPoints) weightWave = 1
	make/o/free/n=(numOfPoints) nextweightWave = 1
	matrixop/o/free weightWaveDiag = diagonal(weightWave)
	// make weightedDiffWave (H)
	MakeWeightedDiffWave(numOfPoints)
	matrixop/o/free weightedDiffWave = lam *  weightedDiffWave^t x weightedDiffWave 
	
	count = 0
	do
		matrixop/o/free weightWaveDiag = diagonal(weightWave)
		// (W+H)^-1Wy
		matrixop/o destWave = inv(weightWaveDiag+weightedDiffWave) x weightWaveDiag x rawWave
		matrixop/o/free diffWave = rawWave - destWave
		// make d- only with di<0
		// set positive val to 0
		Extract/o diffWave, negativeDiffWave, diffWave < 0
		//calc mean and SD of negativeDiffWave
		wavestats/q negativeDiffwave
		nextweightWave = 1/(1+exp(2*(diffwave-(-V_avg+2*V_sdev))/v_sdev))
		matrixop/o tempRatioWv = abs(weightwave-nextweightwave)/abs(weightwave)
		matrixop/o weightwave = nextweightwave
		count +=1
	while(tempRatiowv[0]>ratio)
	matrixop/o destWave = inv(weightWaveDiag+weightedDiffWave) x weightWaveDiag x rawWave
	matrixop/o BLSub = rawwave - destWave
	print count
	Variable timeElapsed = dateTime - start
	print "This procedure took " + num2str(timeElapsed) + " in seconds."
end

Function MakeWeightedDiffWave(numOfPoints)
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
end