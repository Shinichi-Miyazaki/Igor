#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function SVDandPlots(rawData, xAxis, componentNum, xNum, yNum, [startWaveNum, endWaveNum])
	/// Author: Shinichi Miyazaki
	/// This function conduct SVD and plot spectrum and make images
	/// @params	rawData:			4D wave 	(waveNum, x, y, z) 
	/// @params	xAxis:			1D wave 	(waveNum)
	/// @params	componentNum:	variable	(how many componets do you want to divide into)
	/// @params	xNum, yNUm:		variable	(spatial points)
	/// @params	startWavenum	variable	(optional, wavenum ROI)
	
	wave rawData, xAxis
	variable componentNum, xNum, yNum, startWaveNum, endWaveNum
	wave M_U, M_V, rawData2D
	variable i
	String imageName
	
	wave rawData2D = wave4dto2dSVD(rawData, xNum, yNum)
	
	// svd 
	matrixSVD/DACA/PART=(componentNum) rawData2d
	
	// make spectrum graphs
	i=1
	display M_U[][0] vs xAxis
	do
		AppendtoGraph M_U[][i] vs xAxis
		i+=1
	while (i<componentNum-1)	
	SetAxis/A/R bottom
	
	// make images
	i=0
	do 
		imageName = "image" + num2str(i)
		make/o/n = (xNum*yNum)/D $imageName = M_V[p][i]
		redimension/n =(xNum, yNum) $imageName 
		display; appendimage $imageName
		ModifyGraph width=200, height = {Aspect, yNum/xNum}
		i+=1
	while (i<componentNum)
end

Function/wave wave4Dto2DSVD(wv,Numx,Numy)
	wave	wv;
	variable	Numx,Numy;
	variable	SampleNum,i,j,k,l, wvNum;
	variable start, startnum, endnum, pixelnum, num

	wvNum = dimsize(wv, 0)
	pixelnum = Numx*Numy

	make/O/N=(wvNum,pixelnum)/D imchi3_2d;
	k = 0;
	num=0

	do
		for(j=0;j<Numx;j=j+1)
			imchi3_2D[][num] = wv[p][j][k][0];
			num+=1
		endfor
		k += 1
	while(k < Numy)
	return imchi3_2d
end