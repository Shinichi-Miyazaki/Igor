#pragma rtGlobals=1		// Use modern global access method.
Function Gauss7(W,X)
	wave	W;
	variable	X;
	variable	ans;
	ans = W[0]  + W[1]*X + W[2]*exp(-((X-W[3])/W[4])^2) + W[5]*exp(-((X-W[6])/W[7])^2) + W[8]*exp(-((X-W[9])/W[10])^2)+ W[11]*exp(-((X-W[12])/W[13])^2)+ W[14]*exp(-((X-W[15])/W[16])^2)+ W[17]*exp(-((X-W[18])/W[19])^2)+W[20]*exp(-((X-W[21])/W[22])^2);
	return	ans;
end

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





function MakeFitImageBy7Gauss(frompix,endpix,gausNum,wcoef)
variable frompix,endpix,gausNum;
wave wcoef
variable i,j,pts;
wave imchi3_data
Variable V_fitOptions=4
variable xNum,yNum

Silent 1; PauseUpdate
print frompix,endpix, gausNum;
if (gausNum==1)
	make /O/T/N=1 T_constraint;
	T_constraint = {"K2 > 0"};
elseif (gausNum==2)
	make /O/T/N=2 T_constraint;
	T_constraint = {"K2 > 0", "K5 > 0"};
elseif (gausNum==3)
	make /O/T/N=3 T_constraint;
	T_constraint = {"K2 > 0", "K5 > 0","K8 > 0"};
elseif (gausNum==4)
	make /O/T/N=4 T_constraint;
	T_constraint = {"K2 > 0", "K5 > 0","K8 > 0","K11 > 0"};
elseif (gausNum==5)
	make /O/T/N=5 T_constraint;
	T_constraint = {"K2 > 0", "K5 > 0","K8 > 0","K11 > 0","K14 > 0"};
elseif (gausNum==6)
	make /O/T/N=6 T_constraint;
	T_constraint = {"K2 > 0", "K5 > 0","K8 > 0","K11 > 0","K14 > 0","K17 > 0"};
elseif (gausNum==7)
	make /O/T/N=7 T_constraint;
	T_constraint = {"K2 > 0", "K5 > 0","K8 > 0","K11 > 0","K14 > 0","K17 > 0","K20 > 0"};
endif
		
make /o/n=23  W_coefQrG
xNum=dimsize(imchi3_data,1);
yNum=dimsize(imchi3_data,2);

if (gausNum==1)
	make /o/n=(xNum,yNum) FitImage
	SetScale/I x 0,(xNum-1)/2,"", FitImage;
	SetScale/I y 0,(yNum-1)/2,"", FitImage;
elseif (gausNum==2)
	make /o/n=(xNum,yNum) FitImage
	make /o/n=(xNum,yNum) FitImage2
	SetScale/I x 0,(xNum-1)/2,"", FitImage,FitImage2;
	SetScale/I y 0,(yNum-1)/2,"", FitImage,FitImage2;
elseif (gausNum==3)
	make /o/n=(xNum,yNum) FitImage
	make /o/n=(xNum,yNum) FitImage2
	make /o/n=(xNum,yNum) FitImage3
	SetScale/I x 0,(xNum-1)/2,"", FitImage,FitImage2,FitImage3;
	SetScale/I y 0,(yNum-1)/2,"", FitImage,FitImage2,FitImage3;
elseif (gausNum==4)
	make /o/n=(xNum,yNum) FitImage
	make /o/n=(xNum,yNum) FitImage2
	make /o/n=(xNum,yNum) FitImage3
	make /o/n=(xNum,yNum) FitImage4
	SetScale/I x 0,(xNum-1)/2,"", FitImage,FitImage2,FitImage3,FitImage4;
	SetScale/I y 0,(yNum-1)/2,"", FitImage,FitImage2,FitImage3,FitImage4;
elseif (gausNum==5)
	make /o/n=(xNum,yNum) FitImage
	make /o/n=(xNum,yNum) FitImage2
	make /o/n=(xNum,yNum) FitImage3
	make /o/n=(xNum,yNum) FitImage4
	make /o/n=(xNum,yNum) FitImage5
	SetScale/I x 0,(xNum-1)/2,"", FitImage,FigImage2,FitImage3,FitImage4,FitImage5;
	SetScale/I y 0,(yNum-1)/2,"", FitImage,FigImage2,FitImage3,FitImage4,FitImage5;
elseif (gausNum==6)
	make /o/n=(xNum,yNum) FitImage
	make /o/n=(xNum,yNum) FitImage2
	make /o/n=(xNum,yNum) FitImage3
	make /o/n=(xNum,yNum) FitImage4
	make /o/n=(xNum,yNum) FitImage5
	make /o/n=(xNum,yNum) FitImage6
	SetScale/I x 0,(xNum-1)/2,"", FitImage,FigImage2,FitImage3,FitImage4,FitImage5,FitImage6;
	SetScale/I y 0,(yNum-1)/2,"", FitImage,FigImage2,FitImage3,FitImage4,FitImage5,FitImage6;
elseif (gausNum==7)
	make /o/n=(xNum,yNum) FitImage
	make /o/n=(xNum,yNum) FitImage2
	make /o/n=(xNum,yNum) FitImage3
	make /o/n=(xNum,yNum) FitImage4
	make /o/n=(xNum,yNum) FitImage5
	make /o/n=(xNum,yNum) FitImage6
	make /o/n=(xNum,yNum) FitImage7
	SetScale/I x 0,(xNum-1)/2,"", FitImage,FigImage2,FitImage3,FitImage4,FitImage5,FitImage6,FitImage7;
	SetScale/I y 0,(yNum-1)/2,"", FitImage,FigImage2,FitImage3,FitImage4,FitImage5,FitImage6,FitImage7;
endif

pts=dimsize(imchi3_data,0);
make /n=(pts)/o temp

i=0;
do
	j=0;
	do
		temp= imchi3_data[p][i][j][0];
		W_coefQrG=wcoef
		if (gausNum==1)
			W_coefQrG[5]=0;
			W_coefQrG[8]=0;
			W_coefQrG[11]=0;
			W_coefQrG[14]=0;
			W_coefQrG[17]=0;
			W_coefQrG[20]=0;
			Funcfit/Q/H="00011111111111111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
			FitImage[i][j]=W_coefQrG[2];
		elseif (gausNum==2)
			W_coefQrG[8]=0;
			W_coefQrG[11]=0;
			W_coefQrG[14]=0;
			W_coefQrG[17]=0;
			W_coefQrG[20]=0;
			Funcfit/Q/H="00011011111111111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
			FitImage[i][j]=W_coefQrG[2];
			FitImage2[i][j]=W_coefQrG[5];
		elseif (gausNum==3)
			W_coefQrG[11]=0;
			W_coefQrG[14]=0;
			W_coefQrG[17]=0;
			W_coefQrG[20]=0;
			Funcfit/Q/H="00011011011111111111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
			FitImage[i][j]=W_coefQrG[2];
			FitImage2[i][j]=W_coefQrG[5];
			FitImage3[i][j]=W_coefQrG[8];
		elseif (gausNum==4)
			W_coefQrG[14]=0;
			W_coefQrG[17]=0;
			W_coefQrG[20]=0;
			Funcfit/Q/H="00011011011011111111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
			FitImage[i][j]=W_coefQrG[2];
			FitImage2[i][j]=W_coefQrG[5];
			FitImage3[i][j]=W_coefQrG[8];
			FitImage4[i][j]=W_coefQrG[11];
		elseif (gausNum==5)
			W_coefQrG[17]=0;
			W_coefQrG[20]=0;
			Funcfit/Q/H="00011011011011011111111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
			FitImage[i][j]=W_coefQrG[2];
			FitImage2[i][j]=W_coefQrG[5];
			FitImage3[i][j]=W_coefQrG[8];
			FitImage4[i][j]=W_coefQrG[11];
			FitImage5[i][j]=W_coefQrG[14];
		elseif (gausNum==6)
			W_coefQrG[20]=0;
			Funcfit/Q/H="00011011011011011011111"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
			FitImage[i][j]=W_coefQrG[2];
			FitImage2[i][j]=W_coefQrG[5];
			FitImage3[i][j]=W_coefQrG[8];
			FitImage4[i][j]=W_coefQrG[11];
			FitImage5[i][j]=W_coefQrG[14];
			FitImage6[i][j]=W_coefQrG[17];
		elseif (gausNum==7)
			Funcfit/Q/H="00011011011011011011011"/NTHR=0 Gauss7 W_coefQrG temp[frompix,endpix]/X=re_ramanshift2/D/C=T_constraint;
			FitImage[i][j]=W_coefQrG[2];
			FitImage2[i][j]=W_coefQrG[5];
			FitImage3[i][j]=W_coefQrG[8];
			FitImage4[i][j]=W_coefQrG[11];
			FitImage5[i][j]=W_coefQrG[14];
                    FitImage6[i][j]=W_coefQrG[17];
                    FitImage7[i][j]=W_coefQrG[20];
		endif
		j+=1;
	while(j<yNum)
	i+=1;
while(i<xNum)

if (gausNum==1)
	display;appendimage FitImage;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage ctab= {0,*,Grays,0}
	//SetAxis/A/R left;
elseif (gausNum==2)
	display;appendimage FitImage;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage ctab= {0,*,Grays,0}
	//SetAxis/A/R left;
	
	display;appendimage FitImage2;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage2 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
elseif (gausNum==3)
	display;appendimage FitImage;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage ctab= {0,*,Grays,0}
	//SetAxis/A/R left;
	
	display;appendimage FitImage2;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage2 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
	
	display;appendimage FitImage3;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage3 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
elseif (gausNum==4)
	display;appendimage FitImage;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage ctab= {0,*,Grays,0}
	//SetAxis/A/R left;
	
	display;appendimage FitImage2;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage2 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
	
	display;appendimage FitImage3;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage3 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
	
	display;appendimage FitImage4;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage4 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
elseif (gausNum==5)
	display;appendimage FitImage;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage ctab= {0,*,Grays,0}
	//SetAxis/A/R left;
	
	display;appendimage FitImage2;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage2 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
	
	display;appendimage FitImage3;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage3 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
	
	display;appendimage FitImage4;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage4 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
	
	display;appendimage FitImage5;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage5 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
elseif (gausNum==6)
	display;appendimage FitImage;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage ctab= {0,*,Grays,0}
	//SetAxis/A/R left;
	
	display;appendimage FitImage2;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage2 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
	
	display;appendimage FitImage3;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage3 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
	
	display;appendimage FitImage4;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage4 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
	
	display;appendimage FitImage5;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage5 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
	
	display;appendimage FitImage6;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage6 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
elseif (gausNum==7)
	display;appendimage FitImage;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage ctab= {0,*,Grays,0}
	//SetAxis/A/R left;
	
	display;appendimage FitImage2;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage2 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
	
	display;appendimage FitImage3;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage3 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
	
	display;appendimage FitImage4;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage4 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
	
	display;appendimage FitImage5;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage5 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
	
	display;appendimage FitImage6;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage6 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
	display;appendimage FitImage7;
	ModifyGraph width=283.465,height={Aspect,yNum/xNum}
	ModifyImage FitImage6 ctab= {0,*,Grays,0};
	//SetAxis/A/R left;
endif

end

