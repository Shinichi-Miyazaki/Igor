#pragma TextEncoding = "Shift_JIS"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


//gauss functions
Function gaussoffset(W,X)
	wave	W;
	variable	X;
	variable	ans;
	ans = W[0] + W[1]*X + W[2]*exp(-((X-W[3])/W[4])^2);
	return	ans;	
end

Function Dualgaussoffset(W,X)
	wave	W;
	variable	X;
	variable	ans;
	ans = W[0] + W[1]*X + W[2]*exp(-((X-W[3])/W[4])^2) + W[5]*exp(-((X-W[6])/W[7])^2);
	return	ans;
end


Function Triplegauss(W,X)
	wave	W;
	variable	X;
	variable	ans;
	ans = W[0]  + W[1]*X + W[2]*exp(-((X-W[3])/W[4])^2) + W[5]*exp(-((X-W[6])/W[7])^2) + W[8]*exp(-((X-W[9])/W[10])^2);
	return	ans;
end

Function Quadruple_gauss(W,X)
	wave	W;
	variable	X;
	variable	ans;
	ans = W[0]  + W[1]*X + W[2]*exp(-((X-W[3])/W[4])^2) + W[5]*exp(-((X-W[6])/W[7])^2) + W[8]*exp(-((X-W[9])/W[10])^2)+ W[11]*exp(-((X-W[12])/W[13])^2);
	return	ans;
end

Function Gauss5(W,X)
	wave	W;
	variable	X;
	variable	ans;
	ans = W[0]  + W[1]*X + W[2]*exp(-((X-W[3])/W[4])^2) + W[5]*exp(-((X-W[6])/W[7])^2) + W[8]*exp(-((X-W[9])/W[10])^2)+ W[11]*exp(-((X-W[12])/W[13])^2)+ W[14]*exp(-((X-W[15])/W[16])^2);
	return	ans;
end


Function Gauss6(W,X)
	wave	W;
	variable	X;
	variable	ans;
	ans = W[0]  + W[1]*X + W[2]*exp(-((X-W[3])/W[4])^2) + W[5]*exp(-((X-W[6])/W[7])^2) + W[8]*exp(-((X-W[9])/W[10])^2)+ W[11]*exp(-((X-W[12])/W[13])^2)+ W[14]*exp(-((X-W[15])/W[16])^2)+ W[17]*exp(-((X-W[18])/W[19])^2);
	return	ans;
end

Function Gauss7(W,X)
	wave	W;
	variable	X;
	variable	ans;
	ans = W[0]  + W[1]*X + W[2]*exp(-((X-W[3])/W[4])^2) + W[5]*exp(-((X-W[6])/W[7])^2) + W[8]*exp(-((X-W[9])/W[10])^2)+ W[11]*exp(-((X-W[12])/W[13])^2)+ W[14]*exp(-((X-W[15])/W[16])^2)+ W[17]*exp(-((X-W[18])/W[19])^2)+W[20]*exp(-((X-W[21])/W[22])^2);
	return	ans;
end



function MakeFitImageMS(frompix, endpix, gausNum, wcoef, zNum)
variable frompix,endpix,gausNum,zNum;
wave wcoef
variable i,j, k,pts;
wave imchi3_data, re_ramanshift2
Variable V_fitOptions=4
variable xNum,yNum
String wavestr,wavestr2,wavestr3,wavestr4,wavestr5,wavestr6,wavestr7
Silent 1; PauseUpdate
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
				Funcfit/Q/H="00011111111111111111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
				wavestr="FitimageZ"+num2str(k)
				make /o/n=(xNum,yNum) $wavestr
				wave tempwv = $wavestr
				SetScale/I x 0,(xNum-1)/2,"", tempwv;
				SetScale/I y 0,(yNum-1)/2,"", tempwv;
				tempwv[j][i]=W_coefQrG[2];
				i+=1;
			while(i<yNum)
			j+=1;
		while(j<xNum)
		display;appendimage $wavestr;
		ModifyGraph width=283.465,height={Aspect,yNum/xNum}
		ModifyImage $wavestr ctab= {0,*,Grays,0}	
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

#pragma rtGlobals=1		// Use modern global access method.
macro makeInitBase()

print (temp00[pcsr(B)]-temp00[pcsr(A)])/(re_ramanshift2[pcsr(B)]-re_ramanshift2[pcsr(A)])*(-re_ramanshift2[pcsr(A)])+temp00[pcsr(A)]
print (temp00[pcsr(B)]-temp00[pcsr(A)])/(re_ramanshift2[pcsr(B)]-re_ramanshift2[pcsr(A)])

endmacro