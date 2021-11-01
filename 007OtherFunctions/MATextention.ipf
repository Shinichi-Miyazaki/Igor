#pragma rtGlobals=1		// Use modern global access method.

Function CursorMovedHook(info)
	string info;
	variable /G pointAx,pointAy;
	variable /G DependImgSwitch;
	wave DependImgSpc;
	wave imchi3_data;

	if(DependImgSwitch ==1)
		pointAx = pcsr(A);
		pointAy = qcsr(A);
		DependImgSpc =  imchi3_data[p][pointAx][pointAy][0] ;
	endif
End

function  DependImgGraph()
		Variable /G pointAx,pointAy;
		variable /G DependImgSwitch;
		wave imchi3_data,point_wv,DIStemp,DIStemp_switch;
		
		DependImgSwitch = 1;
		pointAx =1;
		pointAy =1;
		
		make /o/n = (2,4) point_wv;
		point_wv = 0;
		make /o/n=(dimsize(imchi3_data,0),4) DIStemp
		DIStemp = 0;
		make /o/n = 4 DIStemp_switch;
		DIStemp_switch = 0;

		make /O/n=(dimsize(imchi3_data,0)) DependImgSpc
		DependImgSpc =  imchi3_data[p][pointAx][pointAy][0]		
		Display DependImgSpc vs re_ramanshift2
		SetAxis/A/R bottom
		ControlBar 45
		SetVariable setvar_Xpix title="Xpix",value=pointAx, pos={10,5},size={70,15}
		SetVariable setvar_Ypix title="Ypix",value=pointAy, pos={90,5},size={70,15}
		SetVariable setvar_ap1x title="x",value=point_wv[0][0], pos={200,28},size={50,15}
		SetVariable setvar_ap1y title="y",value=point_wv[1][0], pos={260,28},size={50,15}
		SetVariable setvar_ap2x title="x",value=point_wv[0][1], pos={320,28},size={50,15}
		SetVariable setvar_ap2y title="y",value=point_wv[1][1], pos={380,28},size={50,15}
		SetVariable setvar_ap3x title="x",value=point_wv[0][2], pos={440,28},size={50,15}
		SetVariable setvar_ap3y title="y",value=point_wv[1][2], pos={500,28},size={50,15}
		SetVariable setvar_ap4x title="x",value=point_wv[0][3], pos={560,28},size={50,15}
		SetVariable setvar_ap4y title="y",value=point_wv[1][3], pos={620,28},size={50,15}
		
		
		Button button_append1 title="Append1",proc=ButtonProc_append1
		Button button_append1 pos={200,5},size={60,20}
		Button button_append1sw title="on/off",proc=ButtonProc_append1sw
		Button button_append1sw pos={260,5},size={40,20}
		Button button_append2 title="Append2",proc=ButtonProc_append2
		Button button_append2 pos={320,5},size={60,20}
		Button button_append2sw title="on/off",proc=ButtonProc_append2sw
		Button button_append2sw pos={380,5},size={40,20}
		Button button_append3 title="Append3",proc=ButtonProc_append3
		Button button_append3 pos={440,5},size={60,20}
		Button button_append3sw title="on/off",proc=ButtonProc_append3sw
		Button button_append3sw pos={500,5},size={40,20}
		Button button_append4 title="Append4",proc=ButtonProc_append4
		Button button_append4 pos={560,5},size={60,20}
		Button button_append4sw title="on/off",proc=ButtonProc_append4sw
		Button button_append4sw pos={620,5},size={40,20}
		
		AppendToGraph DIStemp[][0] vs re_ramanshift2
		ModifyGraph rgb(DIStemp)=(0,39168,0),hideTrace(DIStemp)=1
		AppendToGraph DIStemp[][1] vs re_ramanshift2
		ModifyGraph rgb(DIStemp#1)=(0,0,52224),hideTrace(DIStemp#1)=1
		AppendToGraph DIStemp[][2] vs re_ramanshift2
		ModifyGraph rgb(DIStemp#2)=(65280,43520,0),hideTrace(DIStemp#2)=1
		AppendToGraph DIStemp[][3] vs re_ramanshift2
		ModifyGraph rgb(DIStemp#3)=(0,52224,52224),hideTrace(DIStemp#3)=1
endmacro


Function ButtonProc_append1(ctrlName) : ButtonControl
	String ctrlName
	variable /G pointAx,pointAy;
	variable p;
	wave DIStemp,DependImgSpc,point_wv;
	p = 0;
	do
		DIStemp[p][0] = DependImgSpc[p];
		p += 1;
	while(p < dimsize(DependImgSpc,0))
	point_wv[0][0] = pointAx;
	point_wv[1][0] = pointAy;
End
Function ButtonProc_append2(ctrlName) : ButtonControl
	String ctrlName
	variable /G pointAx,pointAy;
	variable p;
	wave DIStemp,DependImgSpc,point_wv;
	p = 0;
	do
		DIStemp[p][1] = DependImgSpc[p];
		p += 1;
	while(p < dimsize(DependImgSpc,0))
	point_wv[0][1] = pointAx;
	point_wv[1][1] = pointAy;
End
Function ButtonProc_append3(ctrlName) : ButtonControl
	String ctrlName
	variable /G pointAx,pointAy;
	variable p;
	wave DIStemp,DependImgSpc,point_wv;
	p = 0;
	do
		DIStemp[p][2] = DependImgSpc[p];
		p += 1;
	while(p < dimsize(DependImgSpc,0))
	point_wv[0][2] = pointAx;
	point_wv[1][2] = pointAy;
End
Function ButtonProc_append4(ctrlName) : ButtonControl
	String ctrlName
	variable /G pointAx,pointAy;
	variable p;
	wave DIStemp,DependImgSpc,point_wv;
	p = 0;
	do
		DIStemp[p][3] = DependImgSpc[p];
		p += 1;
	while(p < dimsize(DependImgSpc,0))
	point_wv[0][3] = pointAx;
	point_wv[1][3] = pointAy;
End
Function ButtonProc_append1sw(ctrlName) : ButtonControl
	String ctrlName
	variable /G pointAx,pointAy;
	wave DIStemp_switch
		If(DIStemp_switch[0] == 0)
			ModifyGraph hideTrace(DIStemp)=0
			DIStemp_switch[0] = 1;
		elseif(DIStemp_switch[0] == 1)
			ModifyGraph hideTrace(DIStemp)=1
			DIStemp_switch[0] = 0;
		endif
End
Function ButtonProc_append2sw(ctrlName) : ButtonControl
	String ctrlName
	variable /G pointAx,pointAy;
	wave DIStemp_switch
		If(DIStemp_switch[1] == 0)
			ModifyGraph hideTrace(DIStemp#1)=0
			DIStemp_switch[1] = 1;
		elseif(DIStemp_switch[1] == 1)
			ModifyGraph hideTrace(DIStemp#1)=1
			DIStemp_switch[1] = 0;
		endif
End
Function ButtonProc_append3sw(ctrlName) : ButtonControl
	String ctrlName
	variable /G pointAx,pointAy;
	wave DIStemp_switch
		If(DIStemp_switch[2] == 0)
			ModifyGraph hideTrace(DIStemp#2)=0
			DIStemp_switch[2] = 1;
		elseif(DIStemp_switch[2] == 1)
			ModifyGraph hideTrace(DIStemp#2)=1
			DIStemp_switch[2] = 0;
		endif
End
Function ButtonProc_append4sw(ctrlName) : ButtonControl
	String ctrlName
	variable /G pointAx,pointAy;
	wave DIStemp_switch
		If(DIStemp_switch[3] == 0)
			ModifyGraph hideTrace(DIStemp#3)=0
			DIStemp_switch[3] = 1;
		elseif(DIStemp_switch[3] == 1)
			ModifyGraph hideTrace(DIStemp#3)=1
			DIStemp_switch[3] = 0;
		endif
End

function SumFromImage_Mask(znum)
variable znum
variable cts1,cts2,cts3,cts4,cts5;
variable i,j;
wave MaskImage;
wave temp_Mask1,temp_Mask2,temp_Mask3,temp_Mask4,temp_Mask5;
wave Mask1,Mask2,Mask3,Mask4,Mask5,Mask_switch;
wave imchi3_data,re_ramanshift2;

Duplicate/o MaskImage,Mask1;
Duplicate/o MaskImage,Mask2;
Duplicate/o MaskImage,Mask3;
Duplicate/o MaskImage,Mask4;
Duplicate/o MaskImage,Mask5;
Mask1 = 0;
Mask2 = 0;
Mask3 = 0;
Mask4 = 0;
Mask5 = 0;
make /o/n = 2 Mask_switch;
Mask_switch = 1;

Display;appendimage MaskImage
ControlBar 30;
AppendImage Mask1
ModifyImage Mask1 ctab= {0.5,0.5,Grays,0};DelayUpdate
ModifyImage Mask1 minRGB=NaN,maxRGB=(65280,0,0)
AppendImage Mask2
ModifyImage Mask2 ctab= {0.5,0.5,Grays,0};DelayUpdate
ModifyImage Mask2 minRGB=NaN,maxRGB=(0,52224,0)
AppendImage Mask3
ModifyImage Mask3 ctab= {0.5,0.5,Grays,0};DelayUpdate
ModifyImage Mask3 minRGB=NaN,maxRGB=(0,0,52224)
AppendImage Mask4
ModifyImage Mask4 ctab= {0.5,0.5,Grays,0};DelayUpdate
ModifyImage Mask4 minRGB=NaN,maxRGB=(0,30000,20000)
AppendImage Mask5
ModifyImage Mask5 ctab= {0.5,0.5,Grays,0};DelayUpdate
ModifyImage Mask5 minRGB=NaN,maxRGB=(30000,0,20000)

Button button_MaskAdd1 title="\\Z10Add1",proc=ButtonProc_MaskAdd1
Button button_MaskAdd1 pos={10,5},size={40,14}
Button button_MaskVanish1 title="\\Z10Vanish1",proc=ButtonProc_MaskVanish1
Button button_MaskVanish1 pos={50,5},size={40,14}
Button button_MaskSQ1 title="\\Z10SQ1",proc=ButtonProc_MaskSQ1
Button button_MaskSQ1 pos={90,5},size={40,14}
Button button_MaskReset1 title="\\Z10Reset1",proc=ButtonProc_MaskReset1
Button button_MaskReset1 pos={130,5},size={40,14}
Button button_MaskOnOff1 title="\\Z10on/off1",proc=ButtonProc_MaskOnOff1
Button button_MaskOnOff1 pos={170,5},size={40,14}

Button button_MaskAdd2 title="\\Z10Add2",proc=ButtonProc_MaskAdd2
Button button_MaskAdd2 pos={220,5},size={40,14}
Button button_MaskVanish2 title="\\Z10Vanish2",proc=ButtonProc_MaskVanish2
Button button_MaskVanish2 pos={260,5},size={40,14}
Button button_MaskSQ2 title="\\Z10SQ2",proc=ButtonProc_MaskSQ2
Button button_MaskSQ2 pos={300,5},size={40,14}
Button button_MaskReset2 title="\\Z10Reset2",proc=ButtonProc_MaskReset2
Button button_MaskReset2 pos={340,5},size={40,14}
Button button_MaskOnOff2 title="\\Z10on/off2",proc=ButtonProc_MaskOnOff2
Button button_MaskOnOff2 pos={380,5},size={40,14}

Button button_MaskAdd3 title="\\Z10Add3",proc=ButtonProc_MaskAdd3
Button button_MaskAdd3 pos={10,17},size={40,14}
Button button_MaskVanish3 title="\\Z10Vanish3",proc=ButtonProc_MaskVanish3
Button button_MaskVanish3 pos={50,17},size={40,14}
Button button_MaskSQ3 title="\\Z10SQ3",proc=ButtonProc_MaskSQ3
Button button_MaskSQ3 pos={90,17},size={40,14}
Button button_MaskReset3 title="\\Z10Reset3",proc=ButtonProc_MaskReset3
Button button_MaskReset3 pos={130,17},size={40,14}
Button button_MaskOnOff3 title="\\Z10on/off3",proc=ButtonProc_MaskOnOff3
Button button_MaskOnOff3 pos={170,17},size={40,14}

Button button_MaskAdd4 title="\\Z10Add4",proc=ButtonProc_MaskAdd4
Button button_MaskAdd4 pos={10,30},size={40,14}
Button button_MaskVanish4 title="\\Z10Vanish4",proc=ButtonProc_MaskVanish4
Button button_MaskVanish4 pos={50,30},size={40,14}
Button button_MaskSQ4 title="\\Z10SQ4",proc=ButtonProc_MaskSQ4
Button button_MaskSQ4 pos={90,30},size={40,14}
Button button_MaskReset4 title="\\Z10Reset4",proc=ButtonProc_MaskReset4
Button button_MaskReset4 pos={130,30},size={40,14}
Button button_MaskOnOff4 title="\\Z10on/off4",proc=ButtonProc_MaskOnOff4
Button button_MaskOnOff4 pos={170,30},size={40,14}

Button button_MaskAdd5 title="\\Z10Add5",proc=ButtonProc_MaskAdd5
Button button_MaskAdd5 pos={220,30},size={40,14}
Button button_MaskVanish5 title="\\Z10Vanish5",proc=ButtonProc_MaskVanish5
Button button_MaskVanish5 pos={260,30},size={40,14}
Button button_MaskSQ5 title="\\Z10SQ5",proc=ButtonProc_MaskSQ5
Button button_MaskSQ5 pos={300,30},size={40,14}
Button button_MaskReset5 title="\\Z10Reset5",proc=ButtonProc_MaskReset5
Button button_MaskReset5 pos={340,30},size={40,14}
Button button_MaskOnOff5 title="\\Z10on/off5",proc=ButtonProc_MaskOnOff5
Button button_MaskOnOff5 pos={380,30},size={40,14}

make /o/n=(dimsize(imchi3_data,0)) temp_Mask1,temp_Mask2,temp_Mask3,temp_Mask4,temp_Mask5;
temp_Mask1 = 0;
temp_Mask2 = 0;
temp_Mask3 = 0;
temp_Mask4 = 0;
temp_Mask5 = 0;
cts1 = 0;
cts2 = 0;
cts3 = 0;
cts4 = 0;
cts5 = 0;

i=0;
do
	j=0;
	do
		if(Mask1[i][j] == 1)
			temp_Mask1[]+=imchi3_data[p][i][j][znum]
			cts1+=1
		endif
		if(Mask2[i][j] == 1)
			temp_Mask1[]+=imchi3_data[p][i][j][znum]
			cts2+=1
		endif
		if(Mask3[i][j] == 1)
			temp_Mask1[]+=imchi3_data[p][i][j][znum]
			cts3+=1
		endif
		if(Mask4[i][j] == 1)
			temp_Mask1[]+=imchi3_data[p][i][j][znum]
			cts4+=1
		endif
		if(Mask5[i][j] == 1)
			temp_Mask1[]+=imchi3_data[p][i][j][znum]
			cts5+=1
		endif
		j+=1
	while(j<dimsize(MaskImage,1))
	i+=1
while(i<dimsize(MaskImage,0))
temp_Mask1/=cts1;
temp_Mask2/=cts2;
temp_Mask3/=cts3;
temp_Mask4/=cts4;
temp_Mask5/=cts5;
print cts1,cts2,cts3,cts4,cts5;

display temp_Mask1 vs re_ramanshift2;
ControlBar 30
SetAxis/A/R bottom

AppendToGraph temp_Mask2 vs re_ramanshift2;
ModifyGraph rgb(temp_Mask2)=(0,52224,0)

AppendToGraph temp_Mask3 vs re_ramanshift2;
ModifyGraph rgb(temp_Mask3)=(0,0,52224)

AppendToGraph temp_Mask4 vs re_ramanshift2;
ModifyGraph rgb(temp_Mask4)=(0,30000,20000)

AppendToGraph temp_Mask5 vs re_ramanshift2;
ModifyGraph rgb(temp_Mask5)=(30000,0,20000)

Button button_MakeMaskImage title="Make",proc=ButtonProc_MakeMaskImage
Button button_MakeMaskImage pos={10,5},size={100,20}

end

Function ButtonProc_MakeMaskImage(ctrlName) : ButtonControl
	String ctrlName
	variable cts1,cts2,cts3,cts4,cts5,i,j;;
	wave temp_Mask1, Mask1;
	wave temp_Mask2, Mask2;
	wave temp_Mask3, Mask3;
	wave temp_Mask4, Mask4;
	wave temp_Mask5, Mask5;
	wave imchi3_data;
	temp_Mask1 = 0;
	temp_Mask2 = 0;
	temp_Mask3 = 0;
	temp_Mask4 = 0;
	temp_Mask5 = 0
	cts1 = 0;
	cts2 = 0;
	cts3 = 0;
	cts4 = 0;
	cts5 = 0;
	i=0
	do
		j=0
		do
			if(Mask1[i][j] == 1)
				temp_Mask1[]+=imchi3_data[p][i][j][0]
				cts1+=1
			endif
			if(Mask2[i][j] == 1)
				temp_Mask2[]+=imchi3_data[p][i][j][0]
				cts2+=1
			endif
				if(Mask3[i][j] == 1)
				temp_Mask3[]+=imchi3_data[p][i][j][0]
				cts3+=1
			endif
			if(Mask4[i][j] == 1)
				temp_Mask4[]+=imchi3_data[p][i][j][0]
				cts4+=1
			endif
			if(Mask5[i][j] == 1)
				temp_Mask5[]+=imchi3_data[p][i][j][0]
				cts5+=1
			endif
			j+=1
		while(j<dimsize(MaskImage,1))
		i+=1
	while(i<dimsize(MaskImage,0))
	temp_Mask1/=cts1;
	temp_Mask2/=cts2;
	temp_Mask3/=cts3;
	temp_Mask4/=cts4;
	temp_Mask5/=cts5;
	print cts1,cts2,cts3,cts4,cts5;
End
Function ButtonProc_MaskAdd1(ctrlName) : ButtonControl
	String ctrlName
	wave Mask1
	Mask1[pcsr(A)][qcsr(A)] = 1;
End
Function ButtonProc_MaskVanish1(ctrlName) : ButtonControl
	String ctrlName
	wave Mask1
	Mask1[pcsr(A)][qcsr(A)] = 0;
End
Function ButtonProc_MaskSQ1(ctrlName) : ButtonControl
	String ctrlName
	variable i,j;
	wave Mask1
	i = pcsr(A);
	do
		j = qcsr(A);
		do
			Mask1[i][j] = 1;
		j += 1;
		while(j < qcsr(B)+1)
	i += 1;
	while(i < pcsr(B)+1)
End
Function ButtonProc_MaskReset1(ctrlName) : ButtonControl
	String ctrlName
	wave Mask1
	Mask1 = 0;
End
Function ButtonProc_MaskOnOff1(ctrlName) : ButtonControl
	String ctrlName
	wave Mask1,Mask_switch;
	If(Mask_switch[0] == 0)
		ModifyImage Mask1 minRGB=NaN,maxRGB=(65280,0,0)
		Mask_switch[0] = 1;
	elseif(Mask_switch[0] == 1)
		ModifyImage Mask1 minRGB=NaN,maxRGB=NaN
		Mask_switch[0] = 0;
	endif
End
Function ButtonProc_MaskAdd2(ctrlName) : ButtonControl
	String ctrlName
	wave Mask2
	Mask2[pcsr(A)][qcsr(A)] = 1;
End
Function ButtonProc_MaskVanish2(ctrlName) : ButtonControl
	String ctrlName
	wave Mask2
	Mask2[pcsr(A)][qcsr(A)] = 0;
End
Function ButtonProc_MaskSQ2(ctrlName) : ButtonControl
	String ctrlName
	variable i,j;
	wave Mask2
	i = pcsr(A);
	do
		j = qcsr(A);
		do
			Mask2[i][j] = 1;
		j += 1;
		while(j < qcsr(B)+1)
	i += 1;
	while(i < pcsr(B)+1)
End
Function ButtonProc_MaskReset2(ctrlName) : ButtonControl
	String ctrlName
	wave Mask2
	Mask2 = 0;
End
Function ButtonProc_MaskOnOff2(ctrlName) : ButtonControl
	String ctrlName
	wave Mask2,Mask_switch;
	If(Mask_switch[1] == 0)
		ModifyImage Mask2 minRGB=NaN,maxRGB=(0,52224,0)
		Mask_switch[1] = 1;
	elseif(Mask_switch[1] == 1)
		ModifyImage Mask2 minRGB=NaN,maxRGB=NaN
		Mask_switch[1] = 0;
	endif
End

Function ButtonProc_MaskAdd3(ctrlName) : ButtonControl
	String ctrlName
	wave Mask3
	Mask3[pcsr(A)][qcsr(A)] = 1;
End
Function ButtonProc_MaskVanish3(ctrlName) : ButtonControl
	String ctrlName
	wave Mask3
	Mask3[pcsr(A)][qcsr(A)] = 0;
End
Function ButtonProc_MaskSQ3(ctrlName) : ButtonControl
	String ctrlName
	variable i,j;
	wave Mask3
	i = pcsr(A);
	do
		j = qcsr(A);
		do
			Mask3[i][j] = 1;
		j += 1;
		while(j < qcsr(B)+1)
	i += 1;
	while(i < pcsr(B)+1)
End
Function ButtonProc_MaskReset3(ctrlName) : ButtonControl
	String ctrlName
	wave Mask3
	Mask3 = 0;
End
Function ButtonProc_MaskOnOff3(ctrlName) : ButtonControl
	String ctrlName
	wave Mask3,Mask_switch;
	If(Mask_switch[1] == 0)
		ModifyImage Mask3 minRGB=NaN,maxRGB=(0,0,52224)
		Mask_switch[1] = 1;
	elseif(Mask_switch[1] == 1)
		ModifyImage Mask3 minRGB=NaN,maxRGB=NaN
		Mask_switch[1] = 0;
	endif
End

Function ButtonProc_MaskAdd4(ctrlName) : ButtonControl
	String ctrlName
	wave Mask4
	Mask4[pcsr(A)][qcsr(A)] = 1;
End
Function ButtonProc_MaskVanish4(ctrlName) : ButtonControl
	String ctrlName
	wave Mask4
	Mask4[pcsr(A)][qcsr(A)] = 0;
End
Function ButtonProc_MaskSQ4(ctrlName) : ButtonControl
	String ctrlName
	variable i,j;
	wave Mask4
	i = pcsr(A);
	do
		j = qcsr(A);
		do
			Mask4[i][j] = 1;
		j += 1;
		while(j < qcsr(B)+1)
	i += 1;
	while(i < pcsr(B)+1)
End
Function ButtonProc_MaskReset4(ctrlName) : ButtonControl
	String ctrlName
	wave Mask4
	Mask4 = 0;
End
Function ButtonProc_MaskOnOff4(ctrlName) : ButtonControl
	String ctrlName
	wave Mask4,Mask_switch;
	If(Mask_switch[1] == 0)
		ModifyImage Mask4 minRGB=NaN,maxRGB=(0,30000,20000)
		Mask_switch[1] = 1;
	elseif(Mask_switch[1] == 1)
		ModifyImage Mask4 minRGB=NaN,maxRGB=NaN
		Mask_switch[1] = 0;
	endif
End

Function ButtonProc_MaskAdd5(ctrlName) : ButtonControl
	String ctrlName
	wave Mask5
	Mask5[pcsr(A)][qcsr(A)] = 1;
End
Function ButtonProc_MaskVanish5(ctrlName) : ButtonControl
	String ctrlName
	wave Mask5
	Mask5[pcsr(A)][qcsr(A)] = 0;
End
Function ButtonProc_MaskSQ5(ctrlName) : ButtonControl
	String ctrlName
	variable i,j;
	wave Mask5
	i = pcsr(A);
	do
		j = qcsr(A);
		do
			Mask5[i][j] = 1;
		j += 1;
		while(j < qcsr(B)+1)
	i += 1;
	while(i < pcsr(B)+1)
End
Function ButtonProc_MaskReset5(ctrlName) : ButtonControl
	String ctrlName
	wave Mask5
	Mask5 = 0;
End
Function ButtonProc_MaskOnOff5(ctrlName) : ButtonControl
	String ctrlName
	wave Mask5,Mask_switch;
	If(Mask_switch[1] == 0)
		ModifyImage Mask5 minRGB=NaN,maxRGB=(30000,0,20000)
		Mask_switch[1] = 1;
	elseif(Mask_switch[1] == 1)
		ModifyImage Mask5 minRGB=NaN,maxRGB=NaN
		Mask_switch[1] = 0;
	endif
End