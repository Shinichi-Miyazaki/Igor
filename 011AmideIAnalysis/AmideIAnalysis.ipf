#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later



function/wave AmideIFitWithFourGauss(wv)
	// Author: Shinichi Miyazaki
	
	// arguments
	wave wv
	// predifined waves
	wave ProcessedWCoef
	variable NumOfGauss, i, j,k,l, NumOfSearchLoop
	// define the fit wave name 
	String fitName = "fit_" + nameOfWave(wv)
	// obtain cursor position from graph
	// For error Catch
	variable errorVal
	//Define the text waves
	
	variable wavenum = dimsize(wv,0)
	variable lower = 1620
	variable upper = 1700

    make/o/T/N=6 tempConstraints={"K2>0","10>K4>0","k5>0","10>K7>0","k8>0","10>K10>0", "K11>0","1680>K12", "K13>30"}
	make/o/n=14 wcoef ={0,0,0.1, 1656, 9, 0.1, 1668, 9, 0.1, 1685, 9, 0.1, 1650, 40} 
	// Kill waves and remove graph, for repeated use
	RemoveFromGraph/z $fitName
	RemoveFromGraph/z FitGauss0, Fitgauss1, FitGauss2
	Killwaves/z fit_tempwv
	Killwaves/z FitGauss0, Fitgauss1, FitGauss2
	
	// Duplicate wv
	Duplicate/o wv tempwv
	
	// Initial baseline 
	wave ProcessedWCoef = CoefProcess(WCoef)
	
	variable searchCOef=1
	if (SearchCoef == 1)
		 k=0
		 make/o/n = 7 WcoefChangePos = {-3, -2,-1, 0, 1, 2,3}
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
			 		Funcfit/q/H="00010010010000111111111" gaussfunc ProcessedWCoef wv[X2Pnt(wv,lower),X2Pnt(wv,upper)]/D /C=tempConstraints;
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
    Funcfit/q/H="11111111111111111111111" gaussfunc ProcessedWCoef wv[X2Pnt(wv,lower),X2Pnt(wv,upper)] /D /E=ewave;
    i=0
    do
	    variable CoefStart = i*3 + 2
	    variable CoefEnd = i*3 + 4
	    String FitGaussName="FitGauss"+num2str(i)
	    duplicate/o/R = [CoefStart,CoefEnd] Processedwcoef tempcoef
		wave singlegausswv = SingleGaussWithLinearBaselineScaled(wv, wavenum, Processedwcoef[0], Processedwcoef[1], tempcoef[0], tempcoef[1], tempcoef[2])
		duplicate/o singlegausswv $FitGaussName
		AppendToGraph $FitGaussName
		ModifyGraph lstyle($FitGaussName)=3,rgb($FitGaussName)=(0,0,0)
	    i+=1
	while (i<4)
	wcoef = Processedwcoef
	// change fit color 
	ModifyGraph rgb($fitname)=(1,12815,52428)
	return ProcessedWcoef
end 

Function/wave BaselineArPLS_mod(rawWave)
	/// This function subtract baseline from rawWave
	/// based on Baek et al., 2014 Analyst
	/// Author: Shinichi Miyazaki
	/// @params: rawWave, wave, 1 dimensional wave
	/// @params: lam, variable, parameter for differentiation weight
	
	/// recomended parameters 
	
	/// for representative spectrum Lam = 2500000, ratio = 0.0001
	/// for baseline subtraction from all of spatial points,  lam = 1000000, ratio = 0.01 (or 1 for short calc time) 
	wave rawWave
	variable lam = 1000000
	variable ratio = 0.001
	wave weightWave
	wave destWave, weightedDiffWave
	variable numofPoints, i, t, count
	variable meanOfNegativeDiffWave, SDOfNegativeDiffWave
	
	numOfPoints = dimsize(rawWave,0)
	// initialize the weightWave and weightWaveDiag
	make/o/free/n=(numOfPoints) weightWave = 1
	make/o/free/n=(numOfPoints) nextweightWave = 1
	matrixop/o/free weightedDiffWave = lam *  weightedDiffWave^t x weightedDiffWave 
	do
		// (W+H)^-1Wy
		matrixop/o/free diffWave = rawWave - inv(diagonal(weightWave)+weightedDiffWave) x diagonal(weightWave) x rawWave
		// make d- only with di<0, set positive val to 0
		Extract/o diffWave, negativeDiffWave, diffWave < 0
		//calc mean and SD of negativeDiffWave
		wavestats/q negativeDiffwave
		nextweightWave = 1/(1+exp(2*(diffwave[p]-(-V_avg+2*V_sdev))/V_sdev))
		matrixop/o tempRatioWv = abs(weightwave-nextweightwave)/abs(weightwave)
		weightwave = nextweightwave
	while(tempRatiowv[0]>ratio)
	return diffwave
end


Function/wave BLSubArPLS_mod(wave_2d)
	/// This function subtract baseline from rawWave
	/// based on Baek et al., 2014 Analyst
	/// Author: Shinichi Miyazaki
	/// @params: Wave_2d, wave, 2 dimensional wave
	/// @params: lam, variable, parameter for differentiation weight
	wave wave_2d
	variable i, spatialpnts, wavenum
	wavenum = dimsize(wave_2d, 0)
	spatialpnts =dimsize(wave_2d, 1)
	duplicate/o wave_2d wave_blsub
	i=0
	make/o/n = (wavenum) BLSub = 0
	wave weightedDiffWave = MakeWeightedDiffWave(wavenum)
	do 
		make/o/n = (wavenum) tempwave = wave_2d[p][i]
		wave BLSub = BaselineArPLS_mod(tempwave)
		wave_blsub[][i] = BLsub[p]
		i+=1
	while(i<spatialpnts)
	return wave_blsub
end

Function AmideINormalize(inwave)
	wave inwave
	variable signalAmp, noiseAmp, SNR
	
	make/o/n=5 wcoef={0,0,0.1, 1660, 30}
	wave ProcessedWCoef = CoefProcess(WCoef)
	Funcfit/q/H="00000111111111111111111" gaussfunc processedwcoef inwave[X2Pnt(inwave,1600),X2Pnt(inwave,1700)]
	SignalAmp = processedwcoef[2]
	
	matrixop/o inwave = inwave / signalAmp
End

Function AmideIIINormalize(inwave)
	wave inwave
	variable signalAmp, noiseAmp, SNR
	make/o/T/N=2 tempConstraints={"K2>0","30>K4>0"}
	make/o/n=5 wcoef={0,0,0.1, 1250, 20}
	wave ProcessedWCoef = CoefProcess(WCoef)
	Funcfit/q/H="00000111111111111111111" gaussfunc processedwcoef inwave[X2Pnt(inwave,1220),X2Pnt(inwave,1280)] /C=tempConstraints;
	SignalAmp = processedwcoef[2]
	
	matrixop/o inwave = inwave / signalAmp
End

Function/wave SingleGaussWithLinearBaselineScaled(wv,wavenum, coef0, coef1, coef2, coef3, coef4)
	wave wv
	variable wavenum, coef0, coef1, coef2, coef3, coef4
	make/o/n = (wavenum) singlegausswv
	copyscales wv singlegausswv
	singlegausswv = coef2*exp(-((x-coef3)/coef4)^2)
	return singlegausswv
end


Function AmideIANalysisForFiles(dataRootPath, [preprocess])
	String dataRootPath
	variable preprocess
	wave processedWCoef
	wave/T filepaths=GetFilePathNames(dataRootPath)
	variable NumOfFiles = dimsize(filepaths,0)
	variable i = 0
	
	// make result wave 
	Make/o/n=(23, NumofFiles) resultWave= 0
	do 
		String CurrentFilePath = Filepaths[i]
		wave currentwave = $currentFilepath
		display/n =CurrentFilepath currentWave
		switch(preprocess)
			case 1:
				wave wave_blsub = AmideIProcess(currentWave)
				currentWave = wave_blsub
				NewDataFolder/o root:Preprocessed
				String DestPath = "root:Preprocessd:"
				// 20230113
				// Obtain path and make same path in preprocessed folder
				//MoveWave wave_blsub, [destDataFolderPath:] [newName ]
				break
			default:
				break
		endswitch
		wave ProcessedWcoef = AmideIFitWithFourGauss(Currentwave)
		ResultWave[][i] = ProcessedWcoef[p]
		i+=1
		
	while(i<NumOfFiles)
	resultwave = abs(resultwave)
end

Function/WAVE GetSubfolderNames(dataRootPath)
	String dataRootPath
	String objName
	Variable index = 0
	Variable NumOfSubFolders = countobjects(dataRootPath, 4)
	make/T/o/n=(NumOfSubFolders) foldernames
	do
		objName = GetIndexedObjName(dataRootPath, 4, index)
		folderNames[index] = objName
		if (strlen(objName) == 0)
			break
		endif
		index += 1
	while(index<NumOfSubFOlders)
	return foldernames
End

Function/wave GetFilePaths(dataRootPath)
	String dataRootPath
	wave/t foldernames
	String objName
	Variable index = 0
	variable i=0
	variable j=0
	variable cnt=0
	make/T/o tempFilePaths = ""
	wave/T foldernames = GetSubfolderNames(dataRootPath)
	variable NumOfFolders = dimsize(foldernames, 0)
	do
		String currentFolder = dataRootPath+"'"+folderNames[j]+"'" 
		i=0
		do
			Variable NumOfFiles = countobjects(currentFolder, 1)
			objName = GetIndexedObjName(CurrentFolder, 1, i)
			if (strlen(objName) == 0)
				break
			endif
			tempFilepaths[cnt] = CurrentFolder  +":"+  objName
			cnt+=1
			i+=1
		while(i<NumOfFiles)
		j+=1
	while(j<NumofFolders)
	duplicate/t/o/R=[0,cnt-1] tempfilePaths Filepaths
	return filepaths
End

Function/wave AmideIProcess(inwave)
	wave inwave
	//Setscale/p x, axis[0], axis[1]-axis[0], inwave
	wave wave_blsub = BlsubarPLS_mod(inwave)
	AmideINormalize(wave_blsub)
	return wave_blsub
end

Function/wave GetFilePathNames(dataRootPath)
	String dataRootPath
	wave/t foldernames
	String objName
	Variable index = 0
	variable i=0
	variable j=0
	variable cnt=0
	make/T/o FilePaths = ""
	SearchFiles(dataRootPath, cnt)
	return Filepaths
end

function SearchFiles(dataRootPath, cnt)
	String dataRootPath
	variable cnt
	wave/t foldernames
	wave/t filepaths
	String objName
	Variable index = 0
	variable i=0
	variable j=0
	
	// get folder num and names
	variable foldernums = countobjects(dataRootPath, 4)
	// get file num and names
	variable filenums = countobjects(dataRootPath, 1)
	
	if (filenums == 0)
	else
		i=0
		do
			objName = GetIndexedObjName(dataRootPath, 1, i)
			Filepaths[cnt] = dataRootPath +  objName
			cnt+=1
			i+=1
		while(i<filenums)
	endif
	
	do
		if (foldernums == 0)
			j+=1
		else
			wave/T foldernames = GetSubfolderNames(dataRootPath)
			string tempfolder = dataRootPath  + "'"+ foldernames[j]+"'" + ":"
			cnt = SearchFiles(tempfolder, cnt)
			j+=1
		endif
	while(j<folderNums)
	return cnt
End
