#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later

Function AmideINormalize(inwave)
	wave inwave
	variable signalAmp, noiseAmp, SNR
	
	make/o/n=5 wcoef={0,0,0.1, 1660, 30}
	wave ProcessedWCoef = CoefProcess(WCoef)
	Funcfit/q/H="00000111111111111111111" gaussfunc processedwcoef inwave[X2Pnt(inwave,1600),X2Pnt(inwave,1700)]
	SignalAmp = processedwcoef[2]
	
	matrixop/o inwave = inwave / signalAmp
End