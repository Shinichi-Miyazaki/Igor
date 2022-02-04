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

Function SingleGauss(axis, coef)
	wave axis
	wave coef
	make/o/n = (dimsize(axis, 0)) singlegausswv = coef[0]*exp(-((axis-coef[1])/coef[2])^2)
end

Function SingleGaussWithLinearBaseline(axis, coef0, coef1, coef2, coef3, coef4)
	wave axis
	variable coef0, coef1, coef2, coef3, coef4
	make/o/n = (dimsize(axis, 0)) singlegausswv = coef0+coef1*axis+coef2*exp(-((axis-coef3)/coef4)^2)
end

function InitBase(wv,axis, wcoef)
	wave wv, axis, wcoef
	wcoef[0] = (wv[pcsr(B)]-wv[pcsr(A)])/(axis[pcsr(B)]-axis[pcsr(A)])*(-axis[pcsr(A)])+wv[pcsr(A)]
	wcoef[1] = (wv[pcsr(B)]-wv[pcsr(A)])/(axis[pcsr(B)]-axis[pcsr(A)])
end


// Initial fitting function
function InitialFit(wv, xaxis, wcoef)
	// Author: Shinichi Miyazaki
	
	// arguments
	wave wv, xaxis, wcoef
	// predifined waves
	wave ProcessedWCoef
	variable NumOfGauss 
	// for display each gauss 
	wave singlegausswv
	wave gauss1, gauss2, gauss3, gauss4, gauss5, gauss6, gauss7
	
	// name fit wave 
	String fitName = "fit_" + nameOfWave(wv)
	
	// Kill waves and remove graph, for repeated use
	RemoveFromGraph/z $fitName
	RemoveFromGraph/z gauss1,gauss2,gauss3, gauss4, gauss5, gauss6, gauss7
	Killwaves/z fit_tempwv
	Killwaves/z gauss1, gauss2, gauss3, gauss4, gauss5, gauss6, gauss7
	
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
	
	
	// make initial flag and constraints wave 
	switch (NumOfGauss)
		case 1:
			print "Single gauss fit"
			wave ProcessedWCoef = CoefProcess(WCoef)
			Make/O/T/N=1 Constraints={"K2>0"}
			Funcfit/H="00000111111111111111111" gaussfunc ProcessedWCoef wv[wavestart,waveend] /X=axis/D /C=Constraints;
			// show gauss
			duplicate/o/R = [2,4] Processedwcoef coef1
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef1[0], coef1[1], coef1[2])
			duplicate/o singlegausswv gauss1
			AppendToGraph gauss1 vs axis
			ModifyGraph lstyle(gauss1)=3,rgb(gauss1)=(0,0,0)
		break
		
		case 2:
			print "Double gauss fit"
			wave ProcessedWCoef = CoefProcess(WCoef)
			Make/O/T/N=2 Constraints={"K2>0","k5>0"}
			Funcfit/H="00000000111111111111111" gaussfunc ProcessedWCoef wv[wavestart,waveend] /X=xaxis/D /C=Constraints;
			// show gauss
			duplicate/o/R = [2,4] Processedwcoef coef1
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef1[0], coef1[1], coef1[2])
			duplicate/o singlegausswv gauss1
			AppendToGraph gauss1 vs axis
			ModifyGraph lstyle(gauss1)=3,rgb(gauss1)=(0,0,0)
			
			duplicate/o/R = [5,7] Processedwcoef coef2
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef2[0], coef2[1], coef2[2])
			duplicate/o singlegausswv gauss2
			AppendToGraph gauss2 vs axis
			ModifyGraph lstyle(gauss2)=3,rgb(gauss2)=(0,0,0)
		break
		
		case 3:
			print "Triple gauss fit"
			wave ProcessedWCoef = CoefProcess(WCoef)
			Make/O/T/N=3 Constraints={"K2>0","k5>0","k8>0"}
			Funcfit/H="00000000000111111111111" gaussfunc ProcessedWCoef wv[wavestart,waveend] /X=axis/D /C=Constraints;
			// display each gauss
			duplicate/o/R = [2,4] Processedwcoef coef1
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef1[0], coef1[1], coef1[2])
			duplicate/o singlegausswv gauss1
			AppendToGraph gauss1 vs axis
			ModifyGraph lstyle(gauss1)=3,rgb(gauss1)=(0,0,0)
			
			duplicate/o/R = [5,7] Processedwcoef coef2
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef2[0], coef2[1], coef2[2])
			duplicate/o singlegausswv gauss2
			AppendToGraph gauss2 vs axis
			ModifyGraph lstyle(gauss2)=3,rgb(gauss2)=(0,0,0)
			
			duplicate/o/R = [8,10] Processedwcoef coef3
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef3[0], coef3[1], coef3[2])
			duplicate/o singlegausswv gauss3
			AppendToGraph gauss3 vs axis
			ModifyGraph lstyle(gauss3)=3,rgb(gauss3)=(0,0,0)
		break
		
		case 4:
			print "Four gauss fit"
			wave ProcessedWCoef = CoefProcess(WCoef)
			Make/O/T/N=4 Constraints={"K2>0","k5>0","k8>0","k11>0"}
			Funcfit/H="00000000000000111111111" gaussfunc ProcessedWCoef wv[wavestart,waveend] /X=axis/D /C=Constraints;
			// display each gauss
			duplicate/o/R = [2,4] Processedwcoef coef1
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef1[0], coef1[1], coef1[2])
			duplicate/o singlegausswv gauss1
			AppendToGraph gauss1 vs axis
			ModifyGraph lstyle(gauss1)=3,rgb(gauss1)=(0,0,0)
			
			duplicate/o/R = [5,7] Processedwcoef coef2
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef2[0], coef2[1], coef2[2])
			duplicate/o singlegausswv gauss2
			AppendToGraph gauss2 vs axis
			ModifyGraph lstyle(gauss2)=3,rgb(gauss2)=(0,0,0)
			
			duplicate/o/R = [8,10] Processedwcoef coef3
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef3[0], coef3[1], coef3[2])
			duplicate/o singlegausswv gauss3
			AppendToGraph gauss3 vs axis
			ModifyGraph lstyle(gauss3)=3,rgb(gauss3)=(0,0,0)
			
			duplicate/o/R = [11,13] Processedwcoef coef4
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef4[0], coef4[1], coef4[2])
			duplicate/o singlegausswv gauss4
			AppendToGraph gauss4 vs axis
			ModifyGraph lstyle(gauss4)=3,rgb(gauss4)=(0,0,0)
		break
		
		case 5:
			print "Five gauss fit"
			wave ProcessedWCoef = CoefProcess(WCoef)
			Make/O/T/N=5 Constraints={"K2>0","k5>0","k8>0","k11>0","k14>0"}
			Funcfit/H="00000000000000000111111" gaussfunc ProcessedWCoef wv[wavestart,waveend] /X=axis/D /C=Constraints;
			// display each gauss
			duplicate/o/R = [2,4] Processedwcoef coef1
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef1[0], coef1[1], coef1[2])
			duplicate/o singlegausswv gauss1
			AppendToGraph gauss1 vs axis
			ModifyGraph lstyle(gauss1)=3,rgb(gauss1)=(0,0,0)
			
			duplicate/o/R = [5,7] Processedwcoef coef2
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef2[0], coef2[1], coef2[2])
			duplicate/o singlegausswv gauss2
			AppendToGraph gauss2 vs axis
			ModifyGraph lstyle(gauss2)=3,rgb(gauss2)=(0,0,0)
			
			duplicate/o/R = [8,10] Processedwcoef coef3
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef3[0], coef3[1], coef3[2])
			duplicate/o singlegausswv gauss3
			AppendToGraph gauss3 vs axis
			ModifyGraph lstyle(gauss3)=3,rgb(gauss3)=(0,0,0)
			
			duplicate/o/R = [11,13] Processedwcoef coef4
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef4[0], coef4[1], coef4[2])
			duplicate/o singlegausswv gauss4
			AppendToGraph gauss4 vs axis
			ModifyGraph lstyle(gauss4)=3,rgb(gauss4)=(0,0,0)
			
			duplicate/o/R = [14,16] Processedwcoef coef5
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef5[0], coef5[1], coef5[2])
			duplicate/o singlegausswv gauss5
			AppendToGraph gauss5 vs axis
			ModifyGraph lstyle(gauss5)=3,rgb(gauss5)=(0,0,0)
		break
		
		case 6:
			print "Six gauss fit"
			wave ProcessedWCoef = CoefProcess(WCoef)
			Make/O/T/N=6 Constraints={"K2>0","k5>0","k8>0","k11>0","k14>0","k17>0"}
			Funcfit/H="00000000000000000000111" gaussfunc ProcessedWCoef wv[wavestart,waveend] /X=axis/D /C=Constraints;
			// display each gauss
			duplicate/o/R = [2,4] Processedwcoef coef1
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef1[0], coef1[1], coef1[2])
			duplicate/o singlegausswv gauss1
			AppendToGraph gauss1 vs axis
			ModifyGraph lstyle(gauss1)=3,rgb(gauss1)=(0,0,0)
			
			duplicate/o/R = [5,7] Processedwcoef coef2
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef2[0], coef2[1], coef2[2])
			duplicate/o singlegausswv gauss2
			AppendToGraph gauss2 vs axis
			ModifyGraph lstyle(gauss2)=3,rgb(gauss2)=(0,0,0)
			
			duplicate/o/R = [8,10] Processedwcoef coef3
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef3[0], coef3[1], coef3[2])
			duplicate/o singlegausswv gauss3
			AppendToGraph gauss3 vs axis
			ModifyGraph lstyle(gauss3)=3,rgb(gauss3)=(0,0,0)
			
			duplicate/o/R = [11,13] Processedwcoef coef4
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef4[0], coef4[1], coef4[2])
			duplicate/o singlegausswv gauss4
			AppendToGraph gauss4 vs axis
			ModifyGraph lstyle(gauss4)=3,rgb(gauss4)=(0,0,0)
			
			duplicate/o/R = [14,16] Processedwcoef coef5
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef5[0], coef5[1], coef5[2])
			duplicate/o singlegausswv gauss5
			AppendToGraph gauss5 vs axis
			ModifyGraph lstyle(gauss5)=3,rgb(gauss5)=(0,0,0)
			
			duplicate/o/R = [17,19] Processedwcoef coef6
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef6[0], coef6[1], coef6[2])
			duplicate singlegausswv gauss6
			AppendToGraph gauss6 vs axis
			ModifyGraph lstyle(gauss6)=3,rgb(gauss6)=(0,0,0)
		break
		
		case 7:
			print "Seven gauss fit"
			wave ProcessedWCoef = CoefProcess(WCoef)
			Make/O/T/N=7 Constraints={"K2>0","k5>0","k8>0","k11>0","k14>0","k17>0", "k20>0"}
			Funcfit/H="00000000000000000000000" gaussfunc ProcessedWCoef Tempwv[wavestart,waveend] /X=axis/D /C=Constraints;
			// display each gauss
			duplicate/o/R = [2,4] Processedwcoef coef1
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef1[0], coef1[1], coef1[2])
			duplicate/o singlegausswv gauss1
			AppendToGraph gauss1 vs axis
			ModifyGraph lstyle(gauss1)=3,rgb(gauss1)=(0,0,0)
			
			duplicate/o/R = [5,7] Processedwcoef coef2
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef2[0], coef2[1], coef2[2])
			duplicate/o singlegausswv gauss2
			AppendToGraph gauss2 vs axis
			ModifyGraph lstyle(gauss2)=3,rgb(gauss2)=(0,0,0)
			
			duplicate/o/R = [8,10] Processedwcoef coef3
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef3[0], coef3[1], coef3[2])
			duplicate/o singlegausswv gauss3
			AppendToGraph gauss3 vs axis
			ModifyGraph lstyle(gauss3)=3,rgb(gauss3)=(0,0,0)
			
			duplicate/o/R = [11,13] Processedwcoef coef4
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef4[0], coef4[1], coef4[2])
			duplicate/o singlegausswv gauss4
			AppendToGraph gauss4 vs axis
			ModifyGraph lstyle(gauss4)=3,rgb(gauss4)=(0,0,0)
			
			duplicate/o/R = [14,16] Processedwcoef coef5
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef5[0], coef5[1], coef5[2])
			duplicate/o singlegausswv gauss5
			AppendToGraph gauss5 vs axis
			ModifyGraph lstyle(gauss5)=3,rgb(gauss5)=(0,0,0)
			
			duplicate/o/R = [17,19] Processedwcoef coef6
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef6[0], coef6[1], coef6[2])
			duplicate singlegausswv gauss6
			AppendToGraph gauss6 vs axis
			ModifyGraph lstyle(gauss6)=3,rgb(gauss6)=(0,0,0)
			
			duplicate/o/R = [20,22] Processedwcoef coef7
			SingleGaussWithLinearBaseline(axis, Processedwcoef[0], Processedwcoef[1], coef7[0], coef7[1], coef7[2])
			duplicate/o singlegausswv gauss7
			AppendToGraph gauss7 vs axis
			ModifyGraph lstyle(gauss7)=3,rgb(gauss7)=(0,0,0)
		break
	endswitch 
	
	//wave fitResult = $fitname
	// change fit color 
	ModifyGraph rgb($fitname)=(1,12815,52428)

end 


function MakeFitImages(wv,wcoef, zNum)
	// arguments
	wave wv, wcoef
	variable zNum;
	// defined waves and variables
	variable i,j, k,pts, frompix,endpix;
	wave imchi3_data, re_ramanshift2, ProcessedWCoef, W
	variable xNum,yNum
	string FitImage1name, FitImage2name, FitImage3name, FitImage4name
	string FitImage5name, FitImage6name, FitImage7name
	
	xNum=dimsize(wv,1);
	yNum=dimsize(wv,2);
	pts=dimsize(wv,0);
	
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
	
	// get frompix and endpix
	frompix = pcsr(A)
	endpix = pcsr(B)
	
	make /n=(pts)/o temp
	switch (NumOfGauss)
		case 1:
			print "Single gauss fit"
			Make/O/T/N=1 Constraints={"K2>0"}
			
			k=0
			do
				// define image name 
				FitImage1name="FitimageZ"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage1name
				wave FitImage = $FitImage1name
				j=0
				do
					i=0
					do
						// define image name 
						FitImage1name="FitimageZ"+num2str(k)
						make/O/N=(xNum,yNum)/D $FitImage1name
						wave FitImage = $FitImage1name
						
						temp = wv[p][i][j][k]
						wave ProcessedWCoef = CoefProcess(WCoef)
						wave processedWcoef = LinearBaseline(frompix, endpix, temp, re_ramanshift2)
						Funcfit/Q/H="11011111111111111111111"/NTHR=0 gaussfunc ProcessedWCoef temp[frompix,endpix] /X=re_ramanshift2/D /C=Constraints;
						Fitimage[i][j] = processedWcoef[2]
						i+=1
					while(i<xNum)
					j+=1
				while(j<yNum)
				display;appendimage $FitImage1name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage1name ctab= {0,*,Grays,0}
				k+=1
			while(k<zNUm)
		break
		
		case 2:
			print "Double gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=2 Constraints={"K2>0","k5>0"}
			k=0;
			do
				// define image name 
				FitImage1Name="Fitimage1Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage1Name = 0
				wave FitImage1 = $FitImage1name
				FitImage2Name="Fitimage2Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage2Name = 0
				wave FitImage2 = $FitImage2Name	
				j=0;
				do
					i=0;
					do
						temp= wv[p][i][j][k];
						wave ProcessedWCoef = CoefProcess(WCoef)
						wave processedWcoef = LinearBaseline(frompix, endpix, temp, re_ramanshift2)
						Funcfit/Q/H="11011011111111111111111" gaussfunc ProcessedWCoef temp[frompix,endpix] /X=re_ramanshift2/D /C=Constraints;
						Fitimage1[i][j] = processedWcoef[2]
						Fitimage2[i][j] = processedWcoef[5]
						i+=1;
					while(i<xNum)
					j+=1;
				while(j<yNum)
				display;appendimage $FitImage1name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage1name ctab= {0,*,Grays,0}	
				display;appendimage $FitImage2name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage2name ctab= {0,*,Grays,0}	
				k+=1;
			while(k<zNum)
			
		break
		
		case 3:
			print "Triple gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=3 Constraints={"K2>0","k5>0","k8>0"}
			
			//loop 
			k=0;
			do
				// define image names
				FitImage1Name="Fitimage1Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage1Name
				wave FitImage1 = $FitImage1name
				FitImage2Name="Fitimage2Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage2Name
				wave FitImage2 = $FitImage2Name
				FitImage3Name="Fitimage3Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage3Name
				wave FitImage3 = $FitImage3Name

				j=0;
				do
					i=0;
					do 
						// define image names
						FitImage1Name="Fitimage1Z"+num2str(k)
						make/O/N=(xNum,yNum)/D $FitImage1Name = 0
						wave FitImage1 = $FitImage1name
						FitImage2Name="Fitimage2Z"+num2str(k)
						make/O/N=(xNum,yNum)/D $FitImage2Name = 0
						wave FitImage2 = $FitImage2Name
						FitImage3Name="Fitimage3Z"+num2str(k)
						make/O/N=(xNum,yNum)/D $FitImage3Name = 0
						wave FitImage3 = $FitImage3Name
						
						temp= wv[p][i][j][k];
						wave ProcessedWCoef = CoefProcess(WCoef)
						wave processedWcoef = LinearBaseline(frompix, endpix, temp, re_ramanshift2)
						Funcfit/Q/H="11011011011111111111111" gaussfunc ProcessedWCoef temp[frompix,endpix] /X=re_ramanshift2/D /C=Constraints;					
						Fitimage1[i][j] = processedWcoef[2]
						Fitimage2[i][j] = processedWcoef[5]
						Fitimage3[i][j] = processedWcoef[8]
						i+=1;
					while(i<xNum)
					j+=1;
				while(j<yNum)
				k+=1;
			while(k<zNum)
			display;appendimage $FitImage1name;
			ModifyGraph width=113.386,height={Aspect,yNum/xNum}
			ModifyImage $FitImage1name ctab= {0,*,Grays,0}	
			display;appendimage $FitImage2name;
			ModifyGraph width=113.386,height={Aspect,yNum/xNum}
			ModifyImage $FitImage2name ctab= {0,*,Grays,0}	
			display;appendimage $FitImage3name;
			ModifyGraph width=113.386,height={Aspect,yNum/xNum}
			ModifyImage $FitImage3name ctab= {0,*,Grays,0}	
				
		break
		
		case 4:
			print "Four gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=4 Constraints={"K2>0","k5>0","k8>0","k11>0"}
			
			k=0
			do
				// define image names 
				FitImage1Name="Fitimage1Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage1Name = 0
				wave FitImage1 = $FitImage1name
				FitImage2Name="Fitimage2Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage2Name = 0
				wave FitImage2 = $FitImage2Name
				FitImage3Name="Fitimage3Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage3Name = 0
				wave FitImage3 = $FitImage3Name
				FitImage4Name="Fitimage4Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage4Name = 0
				wave FitImage4 = $FitImage4Name
				j=0;
				do
					i=0;
					do 
						// define image names 
						FitImage1Name="Fitimage1Z"+num2str(k)
						make/O/N=(xNum,yNum)/D $FitImage1Name = 0
						wave FitImage1 = $FitImage1name
						FitImage2Name="Fitimage2Z"+num2str(k)
						make/O/N=(xNum,yNum)/D $FitImage2Name = 0
						wave FitImage2 = $FitImage2Name
						FitImage3Name="Fitimage3Z"+num2str(k)
						make/O/N=(xNum,yNum)/D $FitImage3Name = 0
						wave FitImage3 = $FitImage3Name
						FitImage4Name="Fitimage4Z"+num2str(k)
						make/O/N=(xNum,yNum)/D $FitImage4Name = 0
						wave FitImage4 = $FitImage4Name
						
						
						temp= wv[p][i][j][k];
						wave ProcessedWCoef = CoefProcess(WCoef)
						wave processedWcoef = LinearBaseline(frompix, endpix, temp, re_ramanshift2)
						Funcfit/Q/H="11011011011011111111111" gaussfunc ProcessedWCoef temp[frompix,endpix] /X=re_ramanshift2/D /C=Constraints;
						Fitimage1[i][j] = processedWcoef[2]
						Fitimage2[i][j] = processedWcoef[5]
						Fitimage3[i][j] = processedWcoef[8]
						Fitimage4[i][j] = processedWcoef[11]
						i+=1;
					while(i<xNum)
					j+=1;
				while(j<yNum)
				display;appendimage $FitImage1name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage1name ctab= {0,*,Grays,0}	
				display;appendimage $FitImage2name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage2name ctab= {0,*,Grays,0}	
				display;appendimage $FitImage3name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage3name ctab= {0,*,Grays,0}	
				display;appendimage $FitImage4name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage4name ctab= {0,*,Grays,0}	
				k+=1;
			while(k<zNum)
		break
		
		case 5:
			print "Five gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=5 Constraints={"K2>0","k5>0","k8>0","k11>0","k14>0"}
			
			k=0
			do
				// define image names 
				FitImage1Name="Fitimage1Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage1Name = 0
				wave FitImage1 = $FitImage1name
				FitImage2Name="Fitimage2Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage2Name = 0
				wave FitImage2 = $FitImage2Name
				FitImage3Name="Fitimage3Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage3Name = 0
				wave FitImage3 = $FitImage3Name
				FitImage4Name="Fitimage4Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage4Name = 0
				wave FitImage4 = $FitImage4Name
				FitImage5Name="Fitimage5Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage5Name = 0
				wave FitImage5 = $FitImage5Name
				j=0;
				do
					i=0;
					do 
						// define image names 
						FitImage1Name="Fitimage1Z"+num2str(k)
						make/O/N=(xNum,yNum)/D $FitImage1Name = 0
						wave FitImage1 = $FitImage1name
						FitImage2Name="Fitimage2Z"+num2str(k)
						make/O/N=(xNum,yNum)/D $FitImage2Name = 0
						wave FitImage2 = $FitImage2Name
						FitImage3Name="Fitimage3Z"+num2str(k)
						make/O/N=(xNum,yNum)/D $FitImage3Name = 0
						wave FitImage3 = $FitImage3Name
						FitImage4Name="Fitimage4Z"+num2str(k)
						make/O/N=(xNum,yNum)/D $FitImage4Name = 0
						wave FitImage4 = $FitImage4Name
						FitImage5Name="Fitimage5Z"+num2str(k)
						make/O/N=(xNum,yNum)/D $FitImage5Name = 0
						wave FitImage5 = $FitImage5Name
						
						temp= wv[p][i][j][k];
						wave ProcessedWCoef = CoefProcess(WCoef)
						wave processedWcoef = LinearBaseline(frompix, endpix, temp, re_ramanshift2)
						Funcfit/Q/H="11011011011011011111111" gaussfunc ProcessedWCoef temp[frompix,endpix] /X=re_ramanshift2/D /C=Constraints;
						Fitimage1[i][j] = processedWcoef[2]
						Fitimage2[i][j] = processedWcoef[5]
						Fitimage3[i][j] = processedWcoef[8]
						Fitimage4[i][j] = processedWcoef[11]
						Fitimage5[i][j] = processedWcoef[14]
						i+=1;
					while(i<xNum)
					j+=1;
				while(j<yNum)
				display;appendimage $FitImage1name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage1name ctab= {0,*,Grays,0}	
				display;appendimage $FitImage2name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage2name ctab= {0,*,Grays,0}	
				display;appendimage $FitImage3name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage3name ctab= {0,*,Grays,0}	
				display;appendimage $FitImage4name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage4name ctab= {0,*,Grays,0}	
				display;appendimage $FitImage5name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage5name ctab= {0,*,Grays,0}	
				k+=1;
			while(k<zNum)
		break
		
		case 6:
			print "Six gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=6 Constraints={"K2>0","k5>0","k8>0","k11>0","k14>0","k17>0"}
			
			k=0
			do
				// define image names
				FitImage1Name="Fitimage1Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage1Name = 0
				wave FitImage1 = $FitImage1name
				FitImage2Name="Fitimage2Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage2Name = 0
				wave FitImage2 = $FitImage2Name
				FitImage3Name="Fitimage3Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage3Name = 0
				wave FitImage3 = $FitImage3Name
				FitImage4Name="Fitimage4Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage4Name = 0
				wave FitImage4 = $FitImage4Name
				FitImage5Name="Fitimage5Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage5Name = 0
				wave FitImage5 = $FitImage5Name
				FitImage6Name="Fitimage6Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage6Name = 0
				wave FitImage6 = $FitImage6Name
				j=0;
				do
					i=0;
					do
						temp= wv[p][i][j][k];
						wave ProcessedWCoef = CoefProcess(WCoef)
						wave processedWcoef = LinearBaseline(frompix, endpix, temp, re_ramanshift2)
						Funcfit/Q/H="11011011011011011011111" gaussfunc ProcessedWCoef temp[frompix,endpix] /X=re_ramanshift2/D /C=Constraints;
						Fitimage1[i][j] = processedWcoef[2]
						Fitimage2[i][j] = processedWcoef[5]
						Fitimage3[i][j] = processedWcoef[8]
						Fitimage4[i][j] = processedWcoef[11]
						Fitimage5[i][j] = processedWcoef[14]
						Fitimage6[i][j] = processedWcoef[17]
						i+=1;
					while(i<xNum)
					j+=1;
				while(j<yNum)
				display;appendimage $FitImage1name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage1name ctab= {0,*,Grays,0}	
				display;appendimage $FitImage2name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage2name ctab= {0,*,Grays,0}	
				display;appendimage $FitImage3name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage3name ctab= {0,*,Grays,0}	
				display;appendimage $FitImage4name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage4name ctab= {0,*,Grays,0}	
				display;appendimage $FitImage5name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage5name ctab= {0,*,Grays,0}	
				display;appendimage $FitImage6name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage6name ctab= {0,*,Grays,0}	
				k+=1;
			while(k<zNum)
		break
		
		case 7:
			print "Seven gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=7 Constraints={"K2>0","k5>0","k8>0","k11>0","k14>0","k17>0", "k20>0"}
			
			k=0
			do
				//define image names 
				FitImage1Name="Fitimage1Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage1Name = 0
				wave FitImage1 = $FitImage1name
				FitImage2Name="Fitimage2Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage2Name = 0
				wave FitImage2 = $FitImage2Name
				FitImage3Name="Fitimage3Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage3Name = 0
				wave FitImage3 = $FitImage3Name
				FitImage4Name="Fitimage4Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage4Name = 0
				wave FitImage4 = $FitImage4Name
				FitImage5Name="Fitimage5Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage5Name = 0
				wave FitImage5 = $FitImage5Name
				FitImage6Name="Fitimage6Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage6Name = 0
				wave FitImage6 = $FitImage6Name
				FitImage7Name="Fitimage7Z"+num2str(k)
				make/O/N=(xNum,yNum)/D $FitImage7Name = 0
				wave FitImage7 = $FitImage7Name
				j=0;
				do
					i=0;
					do 
						//define image names 
						FitImage1Name="Fitimage1Z"+num2str(k)
						make/O/N=(xNum,yNum)/D $FitImage1Name = 0
						wave FitImage1 = $FitImage1name
						FitImage2Name="Fitimage2Z"+num2str(k)
						make/O/N=(xNum,yNum)/D $FitImage2Name = 0
						wave FitImage2 = $FitImage2Name
						FitImage3Name="Fitimage3Z"+num2str(k)
						make/O/N=(xNum,yNum)/D $FitImage3Name = 0
						wave FitImage3 = $FitImage3Name
						FitImage4Name="Fitimage4Z"+num2str(k)
						make/O/N=(xNum,yNum)/D $FitImage4Name = 0
						wave FitImage4 = $FitImage4Name
						FitImage5Name="Fitimage5Z"+num2str(k)
						make/O/N=(xNum,yNum)/D $FitImage5Name = 0
						wave FitImage5 = $FitImage5Name
						FitImage6Name="Fitimage6Z"+num2str(k)
						make/O/N=(xNum,yNum)/D $FitImage6Name = 0
						wave FitImage6 = $FitImage6Name
						FitImage7Name="Fitimage7Z"+num2str(k)
						make/O/N=(xNum,yNum)/D $FitImage7Name = 0
						wave FitImage7 = $FitImage7Name
						
						temp= wv[p][i][j][k];
						wave ProcessedWCoef = CoefProcess(WCoef)
						wave processedWcoef = LinearBaseline(frompix, endpix, temp, re_ramanshift2)
						Funcfit/Q/H="11011011011011011011011" gaussfunc ProcessedWCoef temp[frompix,endpix] /X=re_ramanshift2/D /C=Constraints;
						Fitimage1[i][j] = processedWcoef[2]
						Fitimage2[i][j] = processedWcoef[5]
						Fitimage3[i][j] = processedWcoef[8]
						Fitimage4[i][j] = processedWcoef[11]
						Fitimage5[i][j] = processedWcoef[14]
						Fitimage6[i][j] = processedWcoef[17]
						Fitimage7[i][j] = processedWcoef[20]
						i+=1;
					while(i<xNum)
					j+=1;
				while(j<yNum)
				display;appendimage $FitImage1name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage1name ctab= {0,*,Grays,0}	
				display;appendimage $FitImage2name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage2name ctab= {0,*,Grays,0}	
				display;appendimage $FitImage3name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage3name ctab= {0,*,Grays,0}	
				display;appendimage $FitImage4name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage4name ctab= {0,*,Grays,0}	
				display;appendimage $FitImage5name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage5name ctab= {0,*,Grays,0}	
				display;appendimage $FitImage6name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage6name ctab= {0,*,Grays,0}	
				display;appendimage $FitImage7name;
				ModifyGraph width=113.386,height={Aspect,yNum/xNum}
				ModifyImage $FitImage7name ctab= {0,*,Grays,0}	
				k+=1;
			while(k<zNum)
		break
	endswitch 
end

//preprocessing the coefs
Function/wave CoefProcess(WCoef)
// WCoef: coef wave
	wave WCoef
	variable CoefNum = dimsize(WCoef,0)
	make/o/n=23 ProcessedWCoef = 0 
	ProcessedWCoef[0,CoefNum-1]= WCoef[p]
	return processedWcoef
end


function/wave LinearBaseline(FromPx, EndPx, wv, axis)
	wave wv, axis
	variable FromPx, EndPx
	wave ProcessedWCoef
	ProcessedWcoef[0] = (wv[EndPx]-wv[FromPx])/(axis[EndPx]-axis[FromPx])*(-axis[FromPx])+wv[FromPx]
	ProcessedWCoef[1] = (wv[EndPx]-wv[FromPx])/(axis[EndPx]-axis[FromPx])
	return ProcessedWCoef
end

function MakeFitImageChunk(wv,wcoef, zNum)
	// arguments
	wave wv, wcoef
	variable zNum;
	// defined waves and variables
	variable i,j, k,pts, frompix,endpix;
	wave imchi3_data, re_ramanshift2, ProcessedWCoef, W
	variable xNum,yNum
	
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
	
	// get frompix and endpix
	frompix = pcsr(A)
	endpix = pcsr(B)
	
	// make result wave
	make/o/n = (xNum, yNum, zNum+1, NumOfGauss) FitImageChunk = 0
	
	make /n=(pts)/o temp
	switch (NumOfGauss)
		case 1:
			print "Single gauss fit"
			Make/O/T/N=1 Constraints={"K2>0"}
			k=0
			do
				j=0
				do
					i=0
					do
						temp = wv[p][i][j][k]
						wave ProcessedWCoef = CoefProcess(WCoef)
						wave processedWcoef = LinearBaseline(frompix, endpix, temp, re_ramanshift2)
						Funcfit/Q/H="11011111111111111111111"/NTHR=0 gaussfunc ProcessedWCoef temp[frompix,endpix] /X=re_ramanshift2/D /C=Constraints;
						FitImageChunk[i][j][k][0] = processedWcoef[2]
						i+=1
					while(i<xNum)
					j+=1
				while(j<yNum)
				k+=1
			while(k<zNUm)
		break
		
		case 2:
			print "Double gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=2 Constraints={"K2>0","k5>0"}
			k=0;
			do
				j=0;
				do
					i=0;
					do 
						temp= wv[p][i][j][k];
						wave ProcessedWCoef = CoefProcess(WCoef)
						wave processedWcoef = LinearBaseline(frompix, endpix, temp, re_ramanshift2)
						Funcfit/Q/H="11011011111111111111111" gaussfunc ProcessedWCoef temp[pcsr(A),pcsr(B)] /X=re_ramanshift2/D /C=Constraints;
						FitImageChunk[i][j][k][0] = processedWcoef[2]
						FitImageChunk[i][j][k][1] = processedWcoef[5]
						i+=1;
					while(i<xNum)
					j+=1;
				while(j<yNum)	
				k+=1;
			while(k<zNum)
		break
		
		case 3:
			print "Triple gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=3 Constraints={"K2>0","k5>0","k8>0"}
			k=0;
			do
				j=0;
				do
					i=0;
					do 
						temp= wv[p][i][j][k];
						wave ProcessedWCoef = CoefProcess(WCoef)
						wave processedWcoef = LinearBaseline(frompix, endpix, temp, re_ramanshift2)
						Funcfit/Q/H="11011011011111111111111" gaussfunc ProcessedWCoef temp[pcsr(A),pcsr(B)] /X=re_ramanshift2/D /C=Constraints;
						FitImageChunk[i][j][k][0] = processedWcoef[2]
						FitImageChunk[i][j][k][1] = processedWcoef[5]
						FitImageChunk[i][j][k][2] = processedWcoef[8]
						i+=1;
					while(i<xNum)
					j+=1;
				while(j<yNum)
				k+=1;
			while(k<zNum)
		break
		
		case 4:
			print "Four gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=4 Constraints={"K2>0","k5>0","k8>0","k11>0"}
			k=0
			do
				j=0;
				do
					i=0;
					do 
						temp= wv[p][i][j][k];
						wave ProcessedWCoef = CoefProcess(WCoef)
						wave processedWcoef = LinearBaseline(frompix, endpix, temp, re_ramanshift2)
						Funcfit/Q/H="11011011011011111111111" gaussfunc ProcessedWCoef temp[frompix,endpix] /X=re_ramanshift2/D /C=Constraints;
						FitImageChunk[i][j][k][0] = processedWcoef[2]
						FitImageChunk[i][j][k][1] = processedWcoef[5]
						FitImageChunk[i][j][k][2] = processedWcoef[8]
						FitImageChunk[i][j][k][3] = processedWcoef[11]
						i+=1;
					while(i<xNum)
					j+=1;
				while(j<yNum)
				k+=1;
			while(k<zNum)
		break
		
		case 5:
			print "Five gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=5 Constraints={"K2>0","k5>0","k8>0","k11>0","k14>0"}
			k=0
			do
				j=0;
				do
					i=0;
					do 
						temp= wv[p][i][j][k];
						wave ProcessedWCoef = CoefProcess(WCoef)
						wave processedWcoef = LinearBaseline(frompix, endpix, temp, re_ramanshift2)
						Funcfit/Q/H="11011011011011011111111" gaussfunc ProcessedWCoef temp[frompix,endpix] /X=re_ramanshift2/D /C=Constraints;
						FitImageChunk[i][j][k][0] = processedWcoef[2]
						FitImageChunk[i][j][k][1] = processedWcoef[5]
						FitImageChunk[i][j][k][2] = processedWcoef[8]
						FitImageChunk[i][j][k][3] = processedWcoef[11]
						FitImageChunk[i][j][k][4] = processedWcoef[14]
						i+=1;
					while(i<xNum)
					j+=1;
				while(j<yNum)
				k+=1;
			while(k<zNum)
		break
		
		case 6:
			print "Six gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=6 Constraints={"K2>0","k5>0","k8>0","k11>0","k14>0","k17>0"}
			k=0
			do
				j=0;
				do
					i=0;
					do 
						temp= wv[p][i][j][k];
						wave ProcessedWCoef = CoefProcess(WCoef)
						wave processedWcoef = LinearBaseline(frompix, endpix, temp, re_ramanshift2)
						Funcfit/Q/H="11011011011011011011111" gaussfunc ProcessedWCoef temp[frompix,endpix] /X=re_ramanshift2/D /C=Constraints;
						FitImageChunk[i][j][k][0] = processedWcoef[2]
						FitImageChunk[i][j][k][1] = processedWcoef[5]
						FitImageChunk[i][j][k][2] = processedWcoef[8]
						FitImageChunk[i][j][k][3] = processedWcoef[11]
						FitImageChunk[i][j][k][4] = processedWcoef[14]
						FitImageChunk[i][j][k][5] = processedWcoef[17]
						i+=1;
					while(i<xNum)
					j+=1;
				while(j<yNum)
				k+=1;
			while(k<zNum)
		break
		
		case 7:
			print "Seven gauss fit"
			CoefProcess(WCoef)
			Make/O/T/N=7 Constraints={"K2>0","k5>0","k8>0","k11>0","k14>0","k17>0", "k20>0"}
			k=0
			do
				j=0;
				do
					i=0;
					do 
						temp= wv[p][i][j][k];
						wave ProcessedWCoef = CoefProcess(WCoef)
						wave processedWcoef = LinearBaseline(frompix, endpix, temp, re_ramanshift2)
						Funcfit/Q/H="11011011011011011011011" gaussfunc ProcessedWCoef temp[frompix,endpix] /X=re_ramanshift2/D /C=Constraints;
						FitImageChunk[i][j][k][0] = processedWcoef[2]
						FitImageChunk[i][j][k][1] = processedWcoef[5]
						FitImageChunk[i][j][k][2] = processedWcoef[8]
						FitImageChunk[i][j][k][3] = processedWcoef[11]
						FitImageChunk[i][j][k][4] = processedWcoef[14]
						FitImageChunk[i][j][k][5] = processedWcoef[17]
						FitImageChunk[i][j][k][6] = processedWcoef[20]
						i+=1;
					while(i<xNum)
					j+=1;
				while(j<yNum)
				k+=1;
			while(k<zNum)
		break
	endswitch 
end

function MakeFitImagePeak(frompix, endpix, gausNum, wcoef, zNum)
// arguments
variable frompix,endpix,gausNum,zNum;
wave wcoef
// defined waves and variables
variable i,j, k,pts;
wave imchi3_data, re_ramanshift2
Variable V_fitOptions=4
variable xNum,yNum
String wavestr,wavestr2,wavestr3,wavestr4,wavestr5,wavestr6,wavestr7
print frompix,endpix, gausNum;

make /o/n=23  W_coefQrG

xNum=dimsize(imchi3_data,1);
yNum=dimsize(imchi3_data,2);
pts=dimsize(imchi3_data,0);

make /n=(pts)/o temp

//Single gauss
if (gausNum==1)
	make /O/T/N=1 T_constraint;
	T_constraint = {"K2 > 0"};
	k=0;
	do
		j=0;
		do
			i=0;
			do 
				temp= imchi3_data[p][j][i][k];
				W_coefQrG[0,4]=wcoef[p]
				W_coefQrG[5]=0;
				W_coefQrG[8]=0;
				W_coefQrG[11]=0;
				W_coefQrG[14]=0;
				W_coefQrG[17]=0;
				W_coefQrG[20]=0;
				Funcfit/Q/H="00000111111111111111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
				wavestr="FitimageZ"+num2str(k)
				make /o/n=(xNum,yNum) $wavestr
				make /o/n=(xNum,yNum) $(wavestr+"pk")
				wave tempwv = $wavestr
				wave tempwvPK = $(wavestr+"pk")
				SetScale/I x 0,(xNum-1)/2,"", tempwv;
				SetScale/I y 0,(yNum-1)/2,"", tempwv;
				SetScale/I x 0,(xNum-1)/2,"", tempwvPK;
				SetScale/I y 0,(yNum-1)/2,"", tempwvPK;
				tempwv[j][i]=W_coefQrG[2];
				tempwv[j][i]=W_coefQrG[3];
				i+=1;
			while(i<yNum)
			j+=1;
		while(j<xNum)
		display;appendimage $wavestr;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr ctab= {0,*,Grays,0}	
		display;appendimage $(wavestr+"pk");
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $(wavestr+"pk") ctab= {0,*,Grays,0}	
		k+=1;
	while(k<zNum)
	
	//SetAxis/A/R left;
endif



//Double gauss
if (gausNum==2)
	make /O/T/N=2 T_constraint;
	T_constraint = {"K2 > 0", "K5 > 0"};
	k=0;
	do
		j=0;
		do
			i=0;
			do 
				temp= imchi3_data[p][j][i][k];
				W_coefQrG[0,7]=wcoef[p]
				W_coefQrG[8]=0;
				W_coefQrG[11]=0;
				W_coefQrG[14]=0;
				W_coefQrG[17]=0;
				W_coefQrG[20]=0;
				Funcfit/Q/H="00011011111111111111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
				wavestr="FitimageZ"+num2str(k)
				wavestr2="Fitimage2Z"+num2str(k)
				make /o/n=(xNum,yNum) $wavestr
				make /o/n=(xNum,yNum) $wavestr2
				wave tempwv = $wavestr
				wave tempwv2 = $wavestr2
				SetScale/I x 0,(xNum-1)/2,"", tempwv,tempwv2;
				SetScale/I y 0,(yNum-1)/2,"", tempwv,tempwv2;
				tempwv[j][i]=W_coefQrG[2];
				tempwv2[j][i]=W_coefQrG[5];
				i+=1;
			while(i<yNum)
			j+=1;
		while(j<xNum)
		display;appendimage $wavestr;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr ctab= {0,*,Grays,0}	
		display;appendimage $wavestr2;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr2 ctab= {0,*,Grays,0}	
		k+=1;
	while(k<zNum)
endif


//Triple gauss
if (gausNum==3)
	make /O/T/N=3 T_constraint;
	T_constraint = {"K2 > 0", "K5 > 0","K8 > 0"};
	k=0;
	do
		j=0;
		do
			i=0;
			do 
				temp= imchi3_data[p][j][i][k];
				W_coefQrG[0,10]=wcoef[p]
				W_coefQrG[11]=0;
				W_coefQrG[14]=0;
				W_coefQrG[17]=0;
				W_coefQrG[20]=0;
				Funcfit/Q/H="00011011011111111111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
				wavestr="FitimageZ"+num2str(k)
				wavestr2="Fitimage2Z"+num2str(k)
				wavestr3="Fitimage3Z"+num2str(k)
				make /o/n=(xNum,yNum) $wavestr
				make /o/n=(xNum,yNum) $wavestr2
				make /o/n=(xNum,yNum) $wavestr3
				wave tempwv = $wavestr
				wave tempwv2 = $wavestr2
				wave tempwv3 = $wavestr3
				SetScale/I x 0,(xNum-1)/2,"", tempwv,tempwv2,tempwv3;
				SetScale/I y 0,(yNum-1)/2,"", tempwv,tempwv2,tempwv3;
				tempwv[j][i]=W_coefQrG[2];
				tempwv2[j][i]=W_coefQrG[5];
				tempwv3[j][i]=W_coefQrG[8];
				i+=1;
			while(i<yNum)
			j+=1;
		while(j<xNum)
		display;appendimage $wavestr;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr ctab= {0,*,Grays,0}	
		display;appendimage $wavestr2;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr2 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr3;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr3 ctab= {0,*,Grays,0}	
		k+=1;
	while(k<zNum)
endif


//quadruple gauss
if (gausNum==4)
	make /O/T/N=4 T_constraint;
	T_constraint = {"K2 > 0", "K5 > 0","K8 > 0","K11 > 0"};
	k=0;
	do
		j=0;
		do
			i=0;
			do 
				temp= imchi3_data[p][j][i][k];
				W_coefQrG[0,13]=wcoef[p]
				W_coefQrG[14]=0;
				W_coefQrG[17]=0;
				W_coefQrG[20]=0;
				Funcfit/Q/H="00011011011011111111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
				wavestr="FitimageZ"+num2str(k)
				wavestr2="Fitimage2Z"+num2str(k)
				wavestr3="Fitimage3Z"+num2str(k)
				wavestr4="Fitimage4Z"+num2str(k)
				make /o/n=(xNum,yNum) $wavestr
				make /o/n=(xNum,yNum) $wavestr2
				make /o/n=(xNum,yNum) $wavestr3
				make /o/n=(xNum,yNum) $wavestr4
				wave tempwv = $wavestr
				wave tempwv2 = $wavestr2
				wave tempwv3 = $wavestr3
				wave tempwv4 = $wavestr4
				SetScale/I x 0,(xNum-1)/2,"", tempwv,tempwv2,tempwv3,tempwv4;
				SetScale/I y 0,(yNum-1)/2,"", tempwv,tempwv2,tempwv3,tempwv4;
				tempwv[j][i]=W_coefQrG[2];
				tempwv2[j][i]=W_coefQrG[5];
				tempwv3[j][i]=W_coefQrG[8];
				tempwv4[j][i]=W_coefQrG[11];
				i+=1;
			while(i<yNum)
			j+=1;
		while(j<xNum)
		display;appendimage $wavestr;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr ctab= {0,*,Grays,0}	
		display;appendimage $wavestr2;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr2 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr3;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr3 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr4;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr4 ctab= {0,*,Grays,0}	
		k+=1;
	while(k<zNum)
endif

//five gauss
if (gausNum==5)
	make /O/T/N=5 T_constraint;
	T_constraint = {"K2 > 0", "K5 > 0","K8 > 0","K11 > 0","K14 > 0"};
	k=0;
	do
		j=0;
		do
			i=0;
			do 
				temp= imchi3_data[p][j][i][k];
				W_coefQrG[0,16]=wcoef[p]
				W_coefQrG[17]=0;
				W_coefQrG[20]=0;
				Funcfit/Q/H="00011011011011011111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
				wavestr="FitimageZ"+num2str(k)
				wavestr2="Fitimage2Z"+num2str(k)
				wavestr3="Fitimage3Z"+num2str(k)
				wavestr4="Fitimage4Z"+num2str(k)
				wavestr5="Fitimage5Z"+num2str(k)
				make /o/n=(xNum,yNum) $wavestr
				make /o/n=(xNum,yNum) $wavestr2
				make /o/n=(xNum,yNum) $wavestr3
				make /o/n=(xNum,yNum) $wavestr4
				make /o/n=(xNum,yNum) $wavestr5
				wave tempwv = $wavestr
				wave tempwv2 = $wavestr2
				wave tempwv3 = $wavestr3
				wave tempwv4 = $wavestr4
				wave tempwv5 = $wavestr5
				SetScale/I x 0,(xNum-1)/2,"", tempwv,tempwv2,tempwv3,tempwv4,tempwv5;
				SetScale/I y 0,(yNum-1)/2,"", tempwv,tempwv2,tempwv3,tempwv4,tempwv5;
				tempwv[j][i]=W_coefQrG[2];
				tempwv2[j][i]=W_coefQrG[5];
				tempwv3[j][i]=W_coefQrG[8];
				tempwv4[j][i]=W_coefQrG[11];
				tempwv5[j][i]=W_coefQrG[14];
				i+=1;
			while(i<yNum)
			j+=1;
		while(j<xNum)
		display;appendimage $wavestr;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr ctab= {0,*,Grays,0}	
		display;appendimage $wavestr2;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr2 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr3;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr3 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr4;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr4 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr5;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr5 ctab= {0,*,Grays,0}	
		k+=1;
	while(k<zNum)
endif


//six gauss
if (gausNum==6)
	make /O/T/N=6 T_constraint;
	T_constraint = {"K2 > 0", "K5 > 0","K8 > 0","K11 > 0","K14 > 0","K17 > 0"};
	k=0;
	do
		j=0;
		do
			i=0;
			do 
				temp= imchi3_data[p][j][i][k];
				W_coefQrG[0,19]=wcoef[p]
				W_coefQrG[20]=0;
				Funcfit/Q/H="00011011011011011011111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
				wavestr="FitimageZ"+num2str(k)
				wavestr2="Fitimage2Z"+num2str(k)
				wavestr3="Fitimage3Z"+num2str(k)
				wavestr4="Fitimage4Z"+num2str(k)
				wavestr5="Fitimage5Z"+num2str(k)
				wavestr6="Fitimage6Z"+num2str(k)
				make /o/n=(xNum,yNum) $wavestr
				make /o/n=(xNum,yNum) $wavestr2
				make /o/n=(xNum,yNum) $wavestr3
				make /o/n=(xNum,yNum) $wavestr4
				make /o/n=(xNum,yNum) $wavestr5
				make /o/n=(xNum,yNum) $wavestr6
				wave tempwv = $wavestr
				wave tempwv2 = $wavestr2
				wave tempwv3 = $wavestr3
				wave tempwv4 = $wavestr4
				wave tempwv5 = $wavestr5
				wave tempwv6 = $wavestr6
				SetScale/I x 0,(xNum-1)/2,"", tempwv,tempwv2,tempwv3,tempwv4,tempwv5,tempwv6;
				SetScale/I y 0,(yNum-1)/2,"", tempwv,tempwv2,tempwv3,tempwv4,tempwv5,tempwv6;
				tempwv[j][i]=W_coefQrG[2];
				tempwv2[j][i]=W_coefQrG[5];
				tempwv3[j][i]=W_coefQrG[8];
				tempwv4[j][i]=W_coefQrG[11];
				tempwv5[j][i]=W_coefQrG[14];
				tempwv6[j][i]=W_coefQrG[17];
				i+=1;
			while(i<yNum)
			j+=1;
		while(j<xNum)
		display;appendimage $wavestr;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr ctab= {0,*,Grays,0}	
		display;appendimage $wavestr2;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr2 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr3;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr3 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr4;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr4 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr5;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr5 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr6;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr6 ctab= {0,*,Grays,0}	
		k+=1;
	while(k<zNum)
endif

//seven gauss
if (gausNum==7)
	make /O/T/N=7 T_constraint;
	T_constraint = {"K2 > 0", "K5 > 0","K8 > 0","K11 > 0","K14 > 0","K17 > 0","K20 > 0"};
	k=0;
	do
		j=0;
		do
			i=0;
			do 
				temp= imchi3_data[p][j][i][k];
				W_coefQrG[0,22]=wcoef[p]
				Funcfit/Q/H="00011011011011011011011"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
				wavestr="FitimageZ"+num2str(k)
				wavestr2="Fitimage2Z"+num2str(k)
				wavestr3="Fitimage3Z"+num2str(k)
				wavestr4="Fitimage4Z"+num2str(k)
				wavestr5="Fitimage5Z"+num2str(k)
				wavestr6="Fitimage6Z"+num2str(k)
				wavestr7="Fitimage7Z"+num2str(k)
				make /o/n=(xNum,yNum) $wavestr
				make /o/n=(xNum,yNum) $wavestr2
				make /o/n=(xNum,yNum) $wavestr3
				make /o/n=(xNum,yNum) $wavestr4
				make /o/n=(xNum,yNum) $wavestr5
				make /o/n=(xNum,yNum) $wavestr6
				make /o/n=(xNum,yNum) $wavestr7
				wave tempwv = $wavestr
				wave tempwv2 = $wavestr2
				wave tempwv3 = $wavestr3
				wave tempwv4 = $wavestr4
				wave tempwv5 = $wavestr5
				wave tempwv6 = $wavestr6
				wave tempwv7 = $wavestr7
				SetScale/I x 0,(xNum-1)/2,"", tempwv,tempwv2,tempwv3,tempwv4,tempwv5,tempwv6,tempwv7;
				SetScale/I y 0,(yNum-1)/2,"", tempwv,tempwv2,tempwv3,tempwv4,tempwv5,tempwv6,tempwv7;
				tempwv[j][i]=W_coefQrG[2];
				tempwv2[j][i]=W_coefQrG[5];
				tempwv3[j][i]=W_coefQrG[8];
				tempwv4[j][i]=W_coefQrG[11];
				tempwv5[j][i]=W_coefQrG[14];
				tempwv6[j][i]=W_coefQrG[17];
				tempwv7[j][i]=W_coefQrG[20];
				i+=1;
			while(i<yNum)
			j+=1;
		while(j<xNum)
		display;appendimage $wavestr;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr ctab= {0,*,Grays,0}	
		display;appendimage $wavestr2;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr2 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr3;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr3 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr4;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr4 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr5;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr5 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr6;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr6 ctab= {0,*,Grays,0}	
		display;appendimage $wavestr7;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr7 ctab= {0,*,Grays,0}	
		k+=1;
	while(k<zNum)
endif
end