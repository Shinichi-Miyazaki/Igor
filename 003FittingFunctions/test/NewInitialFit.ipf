#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// Initial fitting function
function InitialFitnew(wv, xaxis, wcoef)
	// Author: Shinichi Miyazaki
	
	// arguments
	wave wv, xaxis, wcoef
	// predifined waves
	wave ProcessedWCoef
	variable NumOfGauss, i
	// for display each gauss 
	wave singlegausswv
	wave gauss1, gauss2, gauss3, gauss4, gauss5, gauss6, gauss7
	
	// name fit wave 
	String fitName = "fit_" + nameOfWave(wv)
	
	// Kill waves and remove graph, for repeated use
	RemoveFromGraph/z $fitName
	RemoveFromGraph/z FitGauss0, Fitgauss1, FitGauss2, FitGauss3, FitGauss4, FitGauss5, FitGauss6, FitGauss7
	Killwaves/z fit_tempwv
	Killwaves/z FitGauss0, Fitgauss1, FitGauss2, FitGauss3, FitGauss4, FitGauss5, FitGauss6, FitGauss7
	
	// obtain cursor position from graph
	variable WaveStart = pcsr(A)
	variable WaveEnd = pcsr(B)
	
	// Duplicate wv
	Duplicate/o wv tempwv
	Duplicate/o xaxis Axis
	
	// Initial baseline 
	InitBase(wv,axis,wcoef)
	
	// check the num of coef, and gauss
	variable NumOfCoef = dimsize(wcoef,0)
	variable NumOfGaussCoef =NumOfCoef-2 
	if (mod(NumOfGaussCoef, 3)!=0)
		print "The number of coef is not adequate"
		print "The number of coef should be 2+3*NumOfGauss"
	else
		NumOfGauss = NumOfGaussCoef/3
	endif	
	print NumOfGauss
	make/o/T GasuuNumMessages={\
								"One Gauss fit",\
								"Two Gauss Fit",\
								"Three Gauss Fit",\
								"Four Gauss Fit",\
								"Five Gauss Fit",\
								"Six Gauss Fit",\
								"Seven Gauss Fit"\
                                }

    make/o/T Constraints={"K2>0","k5>0","k8>0","k11>0","k14>0","k17>0", "k20>0"}

	 make/o/T FittingParameters={\
								"00000111111111111111111",\
								"00000000111111111111111",\
								"00000000000111111111111",\
								"00000000000000111111111",\
								"00000000000000000111111",\
								"00000000000000000000111",\
								"00000000000000000000000"\
								}
	// print guass num
	// make initial flag and constraints wave 
	 print GasuuNumMessages[NumOfGauss-1]
	 make/t/o/n = (NumofGauss) tempConstraints = Constraints
	 wave ProcessedWCoef = CoefProcess(WCoef)
	 Funcfit/Q/H=FittingParameters[NumOfGauss-1] gaussfunc ProcessedWCoef wv[wavestart,waveend] /X=axis/D /C=tempConstraints;
    i=0
    do
	    variable CoefStart = i*3 + 2
	    variable CoefEnd = i*3 + 4
	    String FitGaussName="FitGauss"+num2str(i)
	    duplicate/o/R = [CoefStart,CoefEnd] Processedwcoef tempcoef
		 SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], tempcoef[0], tempcoef[1], tempcoef[2])
		 duplicate/o singlegausswv $FitGaussName
		 AppendToGraph $FitGaussName vs axis
		 ModifyGraph lstyle($FitGaussName)=3,rgb($FitGaussName)=(0,0,0)
	    i+=1
	 while (i<NumOfGauss)
	 wcoef = Processedwcoef
	// change fit color 
	 ModifyGraph rgb($fitname)=(1,12815,52428)

end 