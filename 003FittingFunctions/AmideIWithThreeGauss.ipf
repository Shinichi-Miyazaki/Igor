#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later

function AmideIFitWithThreeGauss(wv, xaxis)
	// Author: Shinichi Miyazaki
	
	// arguments
	wave wv, xaxis
	// predifined waves
	wave ProcessedWCoef
	variable NumOfGauss, i, j,k,l, NumOfSearchLoop
	// define the fit wave name 
	String fitName = "fit_" + nameOfWave(wv)
	// obtain cursor position from graph
	variable WaveStart = pcsr(A)
	variable WaveEnd = pcsr(B)
	// For error Catch
	variable errorVal
	//Define the text waves

    make/o/T tempConstraints={"K2>0","K4<15","k5>0","K7<15","k8>0","-15<K10<15"}
	make/o/n=11 wcoef ={0,0,0.1, 1655, 10, 0.1, 1670, 10, 0.1, 1685, 10} 
	// Kill waves and remove graph, for repeated use
	RemoveFromGraph/z $fitName
	RemoveFromGraph/z FitGauss0, Fitgauss1, FitGauss2
	Killwaves/z fit_tempwv
	Killwaves/z FitGauss0, Fitgauss1, FitGauss2
	
	// Duplicate wv
	Duplicate/o wv tempwv
	Duplicate/o xaxis Axis
	
	// Initial baseline 
	InitBase(wv,axis,wcoef)
	wave ProcessedWCoef = CoefProcess(WCoef)
	
	variable searchCOef=1
	if (SearchCoef == 1)
		 k=0
		 make/o/n = 7 WcoefChangePos = {-3, -2,-1, 0, 1, 2, 3}
		 make/o/n = (23, 343) WCoefList = 0
		 make/o/N = 343 ChiSqList = 343
		 make/o/n=23 ewave = 1e-5
		 do
		 	 variable Magni1 = WcoefChangePos[k]
		 	 j=0
			 do
			 	variable Magni2 = WcoefChangePos[j]
			 	l=0
			 	do 
			 		variable Magni3 = WcoefChangePos[l]
			 		make/o/n=23 magniwave = {0,0,0,Magni1,0,0,Magni2,0,0,Magni3,0,0,0,0,0,0,0,0,0,0,0,0,0}
			 		matrixop/o ProcessedWcoef = ProcessedwCoef + Magniwave
			 		Funcfit/q/H="00010010010111111111111" gaussfunc ProcessedWCoef wv[wavestart,waveend] /X=axis/D /C=tempConstraints /E=ewave;
					errorVal = GetRTError(1)
					if (errorVal == 0)
						WCoefList[][l+j*7+k*49] = ProcessedWCoef[p]
						ChiSqList[l+j*7+k*49] = V_Chisq
				  	else
					 	WCoefList[][l+j*7+k*49] = ProcessedWCoef[p]
						ChiSqList[l+j*7+k*49] = 10000
					endif
					wave ProcessedWCoef = CoefProcess(WCoef)
					l+=1
				while(l<7)
				j+=1
			 while(j<7)
			 k+=1
		 while(k<7)
    	 wavestats/q ChisqList
    	 ProcessedWcoef[] = WCoefList[p][V_minloc]
    endif
	
	
    // fit with passed wcoef
    Funcfit/q/H="00010010010111111111111" gaussfunc ProcessedWCoef wv[wavestart,waveend] /X=axis/D /C=tempConstraints;
    i=0
    do
	    variable CoefStart = i*3 + 2
	    variable CoefEnd = i*3 + 4
	    String FitGaussName="FitGauss"+num2str(i)
	    duplicate/o/R = [CoefStart,CoefEnd] Processedwcoef tempcoef
		 wave singlegausswv = SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], tempcoef[0], tempcoef[1], tempcoef[2])
		 duplicate/o singlegausswv $FitGaussName
		 AppendToGraph $FitGaussName vs axis
		 ModifyGraph lstyle($FitGaussName)=3,rgb($FitGaussName)=(0,0,0)
	    i+=1
	 while (i<3)
	 wcoef = Processedwcoef
	// change fit color 
	 ModifyGraph rgb($fitname)=(1,12815,52428)
end 