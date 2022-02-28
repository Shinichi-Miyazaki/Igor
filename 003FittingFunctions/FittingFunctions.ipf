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
			Funcfit/H="00000000000000000000000" gaussfunc ProcessedWCoef Tempwv[pcsr(A),pcsr(B)] /X=axis/D /C=Constraints;
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
	wcoef = Processedwcoef
	//wave fitResult = $fitname
	// change fit color 
	ModifyGraph rgb($fitname)=(1,12815,52428)

end 


function MakeFitImages(wv,axis,wcoef, zNum, [AnalysisType])
	// arguments
	wave wv,axis, wcoef
	variable zNum, AnalysisType;
	// defined waves and variables
	variable i,j, k,l,pts, frompix,endpix;
	wave ProcessedWCoef, wv_2d
	variable xNum,yNum, SpatialPoints
	string FitImagename
	
	// obtain dimension size
	xNum=dimsize(wv,1);
	yNum=dimsize(wv,2);
	SpatialPoints = xNum*yNUm*zNUm
	pts=dimsize(wv,0);
	
	// check the num of coef, and gauss
	variable NumOfGaussCoef = dimsize(wcoef,0)-2
	if (mod(NumOfGaussCoef, 3)!=0)
		print "The number of coef is not adequate"
		print "The number of coef should be 2+3*NumOfGauss"
	else
		variable NumOfGauss = NumOfGaussCoef/3
	endif	
	
	// get frompix and endpix
	frompix = pcsr(A)
	endpix = pcsr(B)
	
	//make text waves

	make/o/T GasuuNumMessages={\
								"One Gauss fit",\
								"Two Gauss Fit",\
								"Three Gauss Fit",\
								"Four Gauss Fit",\
								"Five Gauss Fit",\
								"Six Gauss Fit",\
								"Seven Gauss Fit"}
	
	make/o/T Constraints={"K2>0","k5>0","k8>0","k11>0","k14>0","k17>0", "k20>0"}
	
	
	make/o/T FittingParametersForAmpAnalysis={\
								"11011111111111111111111",\
								"11011011111111111111111",\
								"11011011011111111111111",\
								"11011011011011111111111",\
								"11011011011011011111111",\
								"11011011011011011011111",\
								"11011011011011011011011"}

	make/o/T FittingParametersForPeakPositionAnalysis={\
								"11000111111111111111111",\
								"11000000111111111111111",\
								"11000000000111111111111",\
								"11000000000000111111111",\
								"11000000000000000111111",\
								"11000000000000000000111",\
								"11000000000000000000000"\
								}
	// print guass num
	print GasuuNumMessages[NumOfGauss-1]

	//switch for analysis type
	Killwaves/z FittingParameters
	Switch (AnalysisType)
		case 1:
			print "Peak Position Analysis"
			duplicate/t FittingParametersForPeakPositionAnalysis FittingParameters
		break
		default:
			print "Peak Amplitude Analysis"
			duplicate/t FittingParametersForAmpAnalysis FittingParameters
	endswitch


	// make 2d wave 
	wave4Dto2DForFit(wv)
	
	make /n=(pts)/o temp

	make/o/n= (xNUm,yNUm,znum,NumofGauss) ResultWv
	make/o/n= (SpatialPoints,7) ResultWv2DAmp
	make/o/n= (SpatialPoints,7) ResultWv2DPeakPos
	
	//Loop for spatial points
	i=0
	do
		temp = wv_2d[p][i]
		make/t/o/n = (NumofGauss) tempConstraints = Constraints
		wave ProcessedWCoef = CoefProcess(WCoef)
		wave processedWcoef = LinearBaseline(frompix, endpix, temp, axis)
		Funcfit/Q/H=FittingParameters[NumOfGauss-1] gaussfunc ProcessedWCoef temp[frompix,endpix] /X=axis/D /C=tempConstraints;
		ResultWv2DAmp[i][0] = processedWcoef[2]
		ResultWv2DAmp[i][1] = processedWcoef[5]
		ResultWv2DAmp[i][2] = processedWcoef[8]
		ResultWv2DAmp[i][3] = processedWcoef[11]
		ResultWv2DAmp[i][4] = processedWcoef[14]
		ResultWv2DAmp[i][5] = processedWcoef[17]
		ResultWv2DAmp[i][6] = processedWcoef[20]
		// Peak Pos Wave
		ResultWv2DPeakPos[i][0] = processedWcoef[3]
		ResultWv2DPeakPos[i][1] = processedWcoef[6]
		ResultWv2DPeakPos[i][2] = processedWcoef[9]
		ResultWv2DPeakPos[i][3] = processedWcoef[12]
		ResultWv2DPeakPos[i][4] = processedWcoef[15]
		ResultWv2DPeakPos[i][5] = processedWcoef[18]
		ResultWv2DPeakPos[i][6] = processedWcoef[21]
		i+=1
	while(i<SpatialPoints)
	wave2Dto4DForFit(ResultWv2DAmp, xNum, ynum, znum)

	// make images 
	//Loop for Gauss
	i=0
	do
		//Loop for z direction 
		j=0
		do
			// define image name 
			FitImagename="FitimageGauss"+num2str(i)+"Z"+num2str(j)
			make/O/N=(xNum,yNum)/D $FitImagename = ResultWv[p][q][j][i]
			wave FitImage = $FitImagename
			display;appendimage $FitImagename;
			ModifyGraph width=300,height={Aspect,yNum/xNum}
			ModifyImage $FitImagename ctab= {0,*,Grays,0}
			j+=1
		while(j<zNUm)
		i+=1
	while(i<NumOfGauss)
	
	// make peak pos image
	if (NumOfGauss == 1 && AnalysisType == 1)
		wave2Dto4DForFit(ResultWv2DPeakPos, xNum, ynum, znum)
		i = 0
		do
			// define image name 
			FitImagename="PeakPosImage"+"Z"+num2str(i)
			make/o/n=(xNum, yNUm) $FitImagename = resultwv[p][q][0][0]
			display;appendimage $FitImagename;
			ModifyGraph width=300,height={Aspect,yNum/xNum}
			ModifyImage $FitImagename ctab= {0,*,Grays,0}
			i+=1
		while(i<zNUm)
	endif

end

Function wave4Dto2DForFit(wv)	//rearrange the 4D wave to 2Dwave
	wave	wv;
	variable Numx,Numy,Numz;
	variable i,j,k,l, wvNum;
	variable start, startnum, endnum, pixelnum, num


	Numx = dimsize(wv, 1)
	Numy = dimsize(wv, 2)
	Numz = dimsize(wv, 3)
	wvNum = dimsize(wv, 0)
	pixelnum = Numx*Numy*Numz

	make/O/N=(wvNum,pixelnum)/D wv_2d;
	// loop for z 
	k = 0;
	num=0
	do
		//loop for y
		j =0 
		do
			// loop for x
			i =0 
			do
				wv_2D[][num] = wv[p][i][j][k];
				num+=1
				i+=1
			while(i<Numx)
			j+=1
		while(j<Numy)
		k += 1
	while(k < Numz)
end

Function wave2Dto4DForFit(wv, nUmx, numy, numz)	//rearrange the 4D wave to 2Dwave
	wave	wv;
	variable Numx,Numy,Numz;
	variable i,j,k,l, wvNum, SpatialPoints;
	variable start, startnum, endnum, pixelnum, num

	wvNum = dimsize(wv, 0)
	SpatialPoints = Numx*Numy*numz

	make/O/N=(Numx, Numy, Numz, 7)/D ResultWv;
	// loop for z 
	k = 0;
	num=0
	do
		//loop for y
		j =0 
		do
			// loop for x
			i =0 
			do
				ResultWv[i][j][k][0] = wv[num][0]
				ResultWv[i][j][k][1] = wv[num][1]
				ResultWv[i][j][k][2] = wv[num][2]
				ResultWv[i][j][k][3] = wv[num][3]
				ResultWv[i][j][k][4] = wv[num][4]
				ResultWv[i][j][k][5] = wv[num][5]
				ResultWv[i][j][k][6] = wv[num][6]
				num+=1
				i+=1
			while(i<Numx)
			j+=1
		while(j<Numy)
		k += 1
	while(k < Numz)
end

//preprocessing the coefs
Function/wave CoefProcess(WCoef)
// WCoef: coef wave
	wave WCoef
	variable CoefNum = dimsize(WCoef,0)
	make/o/d/n=23 ProcessedWCoef = 0 
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


function MakeFitImagePeak(frompix, endpix, gausNum, wcoef, zNum)
// arguments
variable frompix,endpix,gausNum,zNum;
wave wcoef
// defined waves and variables
variable i,j, k,pts;
wave imchi3_data, xaxis
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
				Funcfit/Q/H="00000111111111111111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=xaxis/D/C=T_constraint;
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
				Funcfit/Q/H="00011011111111111111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=xaxis/D/C=T_constraint;
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
				Funcfit/Q/H="00011011011111111111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=xaxis/D/C=T_constraint;
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
				Funcfit/Q/H="00011011011011111111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=xaxis/D/C=T_constraint;
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
				Funcfit/Q/H="00011011011011011111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=xaxis/D/C=T_constraint;
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
				Funcfit/Q/H="00011011011011011011111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=xaxis/D/C=T_constraint;
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
				Funcfit/Q/H="00011011011011011011011"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=xaxis/D/C=T_constraint;
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


//Parabolic
Function Parabolic(W,X)
   wave W;
   	variable X;
	variable ans;
	ans=W[0]+W[1]*X+W[2]*X^2
	return ans;
end

function MakeFitImageMSpeakParabolic(frompix, endpix, gausNum, wcoef, frompix2, endpix2,wcoef2,zNum,thr)
// arguments
variable frompix,endpix,gausNum, frompix2, endpix2,zNum,thr;
wave wcoef,wcoef2
// defined waves and variables
variable i,j, k,pts;
wave imchi3_data, re_ramanshift2
Variable V_fitOptions=4
variable xNum,yNum
String wavestr,wavestr2,wavestr3,wavestr4,wavestr5,wavestr6,wavestr7
print frompix,endpix, gausNum;

make /o/n=23  W_coefQrG
make /o/n=3 wcoefpara

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
				wavestr="FitimageZ"+num2str(k)
				make /o/n=(xNum,yNum) $(wavestr+"Gausspk")
				make /o/n=(xNum,yNum) $(wavestr+"Parabolicpk")
				wave tempwv = $(wavestr+"Gausspk")
				wave tempwvPK = $(wavestr+"Parabolicpk")
				SetScale/I x 0,(xNum-1)/2,"", tempwv;
				SetScale/I y 0,(yNum-1)/2,"", tempwv;
				SetScale/I x 0,(xNum-1)/2,"", tempwvPK;
				SetScale/I y 0,(yNum-1)/2,"", tempwvPK;
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
				Funcfit/Q/H="00001111111111111111111"/NTHR=0 GaussFunc W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
				
				if(W_coefQrG[2]>thr)
					wcoefpara=wcoef2
					Funcfit/Q/NTHR=0 Parabolic wcoefpara temp[frompix2,endpix2]/X=re_ramanshift2/D
					//tempwvPK[j][i]=W_coefQrG[3];
					tempwvPK[j][i]=-wcoefpara[1]/2/wcoefpara[2];
					tempwv[j][i]=W_coefQrG[3];
				else
					tempwvPK[j][i]=nan
					tempwv[j][i]=nan;
				endif
				i+=1;
			while(i<yNum)
			j+=1;
		while(j<xNum)
		display;appendimage $(wavestr+"Gausspk");
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $(wavestr+"Gausspk") ctab= {0,*,Grays,0}	
		display;appendimage $(wavestr+"Parabolicpk");
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $(wavestr+"Parabolicpk") ctab= {0,*,Grays,0}	
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
