#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// Following function fit the data with gauss function
// CUrrently, upper limit for the number of funciton is 7 (=coef23)
// Written by Shinichi Miyazaki, 2021/11/03


//Define Gauss Function
Function GaussFunc(W,X)
	// CoefW: coef wave, the parameters for gauss fit
	// CoefW does not have to possess 23 values
	// X: X axis
	// Amp: variable return
	// W: coef wave padded with 0, if the coefw had 14 values (4 gauss), value15~23 is 0. 
	wave w;
	variable	X;
	variable Amp;
	Amp=W[0]+W[1]*X+W[2]*exp(-((X-W[3])/W[4])^2)+W[5]*exp(-((X-W[6])/W[7])^2)+W[8]*exp(-((X-W[9])/W[10])^2)+W[11]*exp(-((X-W[12])/W[13])^2)+ W[14]*exp(-((X-W[15])/W[16])^2)+W[17]*exp(-((X-W[18])/W[19])^2)+W[20]*exp(-((X-W[21])/W[22])^2);
	return	Amp;
end


// Initial fitting function
function InitialFit(wv, wcoef)
	// arguments
	wave wv, wcoef
	// predifined waves
	wave temp00, re_ramanshift2, ProcessedWCoef
	variable NumOfGauss 
	
	
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
	
	// make initial flag and constraints wave 
	switch (NumOfGauss)
		case 1:
			print "Single gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=1 Constraints={"K2>0"}
			Funcfit/H="00000111111111111111111" gaussfunc ProcessedWCoef wv[pcsr(A),pcsr(B)] /X=re_ramanshift2/D /C=Constraints;
		break
		
		case 2:
			print "Double gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=2 Constraints={"K2>0","k5>0"}
			Funcfit/H="00000000111111111111111" gaussfunc ProcessedWCoef wv[pcsr(A),pcsr(B)] /X=re_ramanshift2/D /C=Constraints;
		break
		
		case 3:
			print "Triple gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=3 Constraints={"K2>0","k5>0","k8>0"}
			Funcfit/H="00000000000111111111111" gaussfunc ProcessedWCoef wv[pcsr(A),pcsr(B)] /X=re_ramanshift2/D /C=Constraints;
		break
		
		case 4:
			print "Four gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=4 Constraints={"K2>0","k5>0","k8>0","k11>0"}
			Funcfit/H="00000000000000111111111" gaussfunc ProcessedWCoef wv[pcsr(A),pcsr(B)] /X=re_ramanshift2/D /C=Constraints;
		break
		
		case 5:
			print "Five gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=5 Constraints={"K2>0","k5>0","k8>0","k11>0","k14>0"}
			Funcfit/H="00000000000000000111111" gaussfunc ProcessedWCoef wv[pcsr(A),pcsr(B)] /X=re_ramanshift2/D /C=Constraints;
		break
		
		case 6:
			print "Six gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=6 Constraints={"K2>0","k5>0","k8>0","k11>0","k14>0","k17>0"}
			Funcfit/H="00000000000000000000111" gaussfunc ProcessedWCoef wv[pcsr(A),pcsr(B)] /X=re_ramanshift2/D /C=Constraints;
		break
		
		case 7:
			print "Seven gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=7 Constraints={"K2>0","k5>0","k8>0","k11>0","k14>0","k17>0", "k20>0"}
			Funcfit/H="00000000000000000000000" gaussfunc ProcessedWCoef wv[pcsr(A),pcsr(B)] /X=re_ramanshift2/D /C=Constraints;
		break
	endswitch 
end 


function MakeFitImages(frompix, endpix, wv,wcoef, zNum)
	// arguments
	wave wv, wcoef
	variable frompix,endpix,zNum;
	// defined waves and variables
	variable i,j, k,pts;
	wave imchi3_data, re_ramanshift2, ProcessedWCoef, W
	variable xNum,yNum
	String wavestr,wavestr2,wavestr3,wavestr4,wavestr5,wavestr6,wavestr7
	
	xNum=dimsize(imchi3_data,1);
	yNum=dimsize(imchi3_data,2);
	pts=dimsize(imchi3_data,0);
	
	// check the num of coef, and gauss
	variable NumOfCoef = dimsize(wcoef,0)
	variable NumOfGaussCoef =NumOfCoef-2 
	if (mod(NumOfGaussCoef, 3)!=0)
		print "The number of coef is not adequate"
		print "The number of coef should be 2+3*NumOfGauss"
	else
		variable NumOfGauss = NumOfGaussCoef/3
	endif	
	print NumOfGauss
	
	make /n=(pts)/o temp
	switch (NumOfGauss)
		case 1:
			print "Single gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=1 Constraints={"K2>0"}
			
			String FitImagename="FitimageZ"+num2str(k)
			make/O/N=(xNum,yNum)/D $FitImagename
			wave FitImage = $FitImagename
			k=0
			do
				j=0
				do
					i=0
					do
						temp = wv[p][i][j][k]
						Funcfit/H="00000111111111111111111" gaussfunc ProcessedWCoef wv[frompix,endpix] /X=re_ramanshift2/D /C=Constraints;
						Fitimage[i][j] = processedWcoef[2]
					while(i<xNum)
				while(j<yNum)
			while(k<zNUm)
		break
		
		case 2:
			print "Double gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=2 Constraints={"K2>0","k5>0"}
			Funcfit/H="00000000111111111111111" gaussfunc ProcessedWCoef wv[pcsr(A),pcsr(B)] /X=re_ramanshift2/D /C=Constraints;
		break
		
		case 3:
			print "Triple gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=3 Constraints={"K2>0","k5>0","k8>0"}
			Funcfit/H="00000000000111111111111" gaussfunc ProcessedWCoef wv[pcsr(A),pcsr(B)] /X=re_ramanshift2/D /C=Constraints;
		break
		
		case 4:
			print "Four gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=4 Constraints={"K2>0","k5>0","k8>0","k11>0"}
			Funcfit/H="00000000000000111111111" gaussfunc ProcessedWCoef wv[pcsr(A),pcsr(B)] /X=re_ramanshift2/D /C=Constraints;
		break
		
		case 5:
			print "Five gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=5 Constraints={"K2>0","k5>0","k8>0","k11>0","k14>0"}
			Funcfit/H="00000000000000000111111" gaussfunc ProcessedWCoef wv[pcsr(A),pcsr(B)] /X=re_ramanshift2/D /C=Constraints;
		break
		
		case 6:
			print "Six gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=6 Constraints={"K2>0","k5>0","k8>0","k11>0","k14>0","k17>0"}
			Funcfit/H="00000000000000000000111" gaussfunc ProcessedWCoef wv[pcsr(A),pcsr(B)] /X=re_ramanshift2/D /C=Constraints;
		break
		
		case 7:
			print "Seven gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=7 Constraints={"K2>0","k5>0","k8>0","k11>0","k14>0","k17>0", "k20>0"}
			Funcfit/H="00000000000000000000000" gaussfunc ProcessedWCoef wv[pcsr(A),pcsr(B)] /X=re_ramanshift2/D /C=Constraints;
		break
	endswitch 
		
	
	
	//GaussFit
	// the amplitude constraints, the amplitude must be greater than 0
	//Make/O/T/N=7 T_Constraints={"K2 > 0", "K5 > 0","K8 > 0","K11 > 0","K14 > 0","K17 > 0","K20 > 0"}
	// Q: silent, just for speedup
	// H: which cofficient should be static, 1 = static (can not change)
	// (old) NTHR: it is no longer necessary (from Igor pro7)
	
	//Funcfit/Q/H="00011011011011011011111" Gaussfunc W temp00 /X=re_ramanshift2/D /C=T_constraints;
	

end

//preprocessing the coefs
Function CoefProcess(WCoef)
// WCoef: coef wave
	wave WCoef
	variable CoefNum = dimsize(WCoef,0)
	make/o/n=23 ProcessedWCoef = 0 
	ProcessedWCoef[0,CoefNum-1]= WCoef[p]
end


