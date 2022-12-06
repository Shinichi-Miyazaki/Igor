#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//Author: Minori Masaki
//Select an appropriate ROIs and find the mean

Function MakeROIperCell(ROIwv)
	wave ROIwv;
	wave ObjectROI;

	duplicate/O ROIwv, ObjectROI

	duplicate/O ObjectROI, ROIperCell
	duplicate/O ObjectROI, M_ROIMask
	M_ROIMask=0;

	//make riverseROI of ObjectROI
	duplicate/o  ObjectROI, RiverseObjectROI
	ImageThreshold/O/T=0 RiverseObjectROI
	matrixop/o RiverseObjectROI=-(RiverseObjectROI/255-1)
	matrixop/O RiverseObjectROI=uint8(RiverseObjectROI)

	//set button & draw line
	NewImage/K=0 root:ObjectROI
	ModifyGraph margin(left)=80;
	Button button0 title="Add",pos={10,10},proc=ButtonProc_addROI;
	Showtools
	SetDrawLayer ProgFront
	SetDrawEnv linefgc=(0,0,65535),fillpat=0,save
End

Function ButtonProc_addROI(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 2: // mouse up
			wave ObjectROI,M_ROIMask,RiverseObjectROI;
			ImageGenerateROIMask ObjectROI
			M_ROIMask=M_ROIMask * RiverseObjectROI
			ObjectROI=ObjectROI+M_ROIMask
			drawaction delete
			ImageThreshold/O/T=0 M_ROIMask
			matrixop/o M_ROIMask=-(M_ROIMask/255-1)
			matrixop/O M_ROIMask=uint8(M_ROIMask)
			Concatenate/NP=3 {M_ROIMask},ROIperCell
			SetDrawLayer ProgFront
			SetDrawEnv linefgc=(0,0,65535),fillpat=0,save
			break

		case -1: // control being killed
			break

	endswitch	
	return 0
End	



Function CellMean(Fitimage)
	wave Fitimage;
	wave ROIperCell;
	variable i,j,k;
	make/o/n=(dimsize(ROIperCell,2)-1) Cell_Sum
	make/o/n=(dimsize(ROIperCell,2)-1) Cell_Points
	make/o/n=(dimsize(ROIperCell,2)-1) Cell_Average
	Cell_Sum=0;Cell_Points=0;Cell_Average=0;

	for(k=1;k<dimsize(ROIperCell,2);k+=1)
		for(i=0;i<dimsize(ROIperCell,0);i+=1)
			for(j=0;j<dimsize(ROIperCell,1);j+=1)
				if(ROIperCell[i][j][k]==0)
				Cell_Sum[k-1]+=Fitimage[i][j]
				Cell_Points[k-1]+=1
				endif
			endfor
		endfor
		Cell_Average[k-1]=Cell_Sum[k-1]/Cell_Points[k-1]
	endfor

	Edit Cell_Sum,Cell_Points,Cell_Average;
	Make/o/n=3/T labelW={"exp 1","exp 2","exp 3"}
	display;appendboxplot Cell_Average vs labelW
end




Function CheckROIPerCell()
	wave ROIperCell;
	variable Imagenum;
	NewImage/K=0 root:ROIperCell
	ModifyGraph width=0,height={Aspect,dimsize(ROIperCell,1)/dimsize(ROIperCell,0)};
	ModifyGraph margin(left)=80;
	AutoPositionWindow/E
	Imagenum=0
	Button button0 title="UP",pos={10,10},proc=ButtonProc_UPlayer;
	Button button1 title="DOWN",pos={10,30},proc=ButtonProc_DOWNlayer;
	Valdisplay var0 value=_NUM:Imagenum, pos={25,60}, size={20,10}
End

Function ButtonProc_UPlayer(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 2: // mouse up
			wave ROIperCell;
			variable/G Imagenum;
			ImageNum+=1;
			ModifyImage ROIperCell, plane=Imagenum;
			Valdisplay var0 value=_NUM:Imagenum;
			break

		case -1: // control being killed
			break
	endswitch
	return 0
End

Function ButtonProc_DOWNlayer(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	switch(ba.eventCode)
		case 2: // mouse up
			wave ROIperCell;
			variable/G Imagenum;
			ImageNum-=1;
			ModifyImage ROIperCell, plane=Imagenum;
			Valdisplay var0 value=_NUM:Imagenum;
			break

		case -1: // control being killed
			break
	endswitch
	return 0
End
