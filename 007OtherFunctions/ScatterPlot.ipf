#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later

Function ScatterPlot(xWave, yWave)
	wave xWave, yWave
	
	display yWave vs xWave
	String xWvName = nameofwave(xwave)
	String yWvName = nameofwave(ywave)
	print nameofwave(xwave)
	ModifyGraph axThick=1.5, width=283.465,height={Aspect,1}, fsize=16
	ModifyGraph mode=3,marker=8,msize=3,rgb=(0,0,0), mrkThick=1
	ModifyGraph axisEnab(left)={0,0.95},axisEnab(bottom)={0,0.95}
	// Ywave hist
	AppendBoxPlot/B=yWaveAxis yWave
	ModifyGraph axisEnab(yWaveAxis)={0.97,1},freePos(yWaveAxis)=0
	ModifyBoxPlot trace=$yWvName,instance=1,showData=None
	ModifyGraph noLabel(yWaveAxis)=2,axThick(yWaveAxis)=0
	// xwave hist
	AppendBoxPlot/L=VertCrossing/B=HorizCrossing/VERT xWave
	ModifyGraph noLabel(HorizCrossing)=2,noLabel(VertCrossing)=2,axThick(HorizCrossing)=0,axThick(VertCrossing)=0,axisEnab(VertCrossing)={0.97,1},freePos(VertCrossing)=0
	ModifyGraph axisEnab(HorizCrossing)={0,0.95}
	ModifyBoxPlot trace=$xWvName,showData=None
	
	//curvefit
	CurveFit line $yWvName /X=$xWvName /D /F={0.95, 5}
	String fit_yWave = "fit_" + yWvName
	String UC_yWave = "UC_" + yWvName
	String LC_yWave = "LC_" + yWvName
	ModifyGraph rgb($fit_yWave)=(0,0,0),lstyle($UC_yWave)=3,rgb($UC_yWave)=(0,0,0),lstyle($LC_yWave)=3,rgb($LC_yWave)=(0,0,0)
end