#pragma TextEncoding = "Shift_JIS"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


function GUI()
 //制作者:田中

 //imchi3_dataを解析する際に使えるプログラムです。
 //imchi3_dataとre_ramanshift2という名前のwaveが存在していれば使えます。
 variable zstack
 wave imchi3_data,re_ramanshift2
 variable wvnum,xnum,ynum,znum,knum,i
 variable xpoint,ypoint,flagimchi,flagreraman,switchnum=0
 string strX,strY,Graphname
 
 flagimchi=waveexists(imchi3_data)
 flagreraman=waveexists(re_ramanshift2)
 
 if(flagimchi==1)
  if(flagreraman==1)
   
  prompt wvnum,"イメージを出したい波数の値を入力してください"
 doprompt "",wvnum

 wvnum=ceil((wvnum-re_ramanshift2[0])/((re_ramanshift2[dimsize(re_ramanshift2,0)-1]-re_ramanshift2[0])/dimsize(re_ramanshift2,0)))
 
 xnum=dimsize(imchi3_data,1)
 ynum=dimsize(imchi3_data,2)
 znum=dimsize(imchi3_data,3)
 knum=dimsize(imchi3_data,0)
 
 make/n=(xnum,ynum)/o imGUIwv
 
 imGUIwv[][]=imchi3_data[wvnum][p][q][0]
  
 
 newimage/N=imGUI imGUIwv
 SetAxis/A left
 showinfo
  
 cursor/i/a=1/c=(0,0,60000,65000) a imguiwv round(xnum/2),round(ynum/2)
  
 
 xpoint=pcsr(A)
 ypoint=qcsr(A) 
 
 strX=num2str(xpoint)
 strY=num2str(ypoint)
  
 make/o/n=(knum) imchi3GUI_data
 
 imchi3GUI_data=imchi3_data[p][xpoint][ypoint][0]
 
 display/N=imGUIspe/W=(0,0,500,250) imchi3GUI_data vs re_ramanshift2 
 cursor/w=imGUIspe/a=1/c=(0,0,60000,65000) A imchi3GUI_data wvnum
 SetAxis/A/R bottom
 
 newpanel/FLT=0/N=imGUIspe_controlpanel/W=(0,0,170,150)/HOST=imGUIspe/EXT=0/NA=0 
 //スペクトルの方のコントロールパネル
 Button imGUIreimage title="別の波数で画像を出し直す",size={150,20},pos={10,10},proc=ButtonProcimGUIreimage
 Button imGUIspeimage title="積算した強度での画像",size={150,20},pos={10,50},proc=ButtonProcimGUIspeimage
 
 
 newpanel/FLT=0/N=imGUI_controlpanel/W=(0,0,300,300)/HOST=imgui/EXT=0/NA=0
 //画像の方のコントロールパネル
 
 if(znum>1) 
 Slider slider0,pos={30,110},vert=1,proc=SliderProcimGUIzstack,size={30,znum*10},limits={0,znum-1,1},value=0
 ValDisplay imGUIval title="zstack",value=0,size={65,16},pos={20,80},fstyle=1, ticks=2
 endif
 
 Button imcont1 title="↑" ,proc=ButtonProcimcont1,pos={61,11}

 Button imcont2 title="↓" ,proc=ButtonProcimcont2,pos={61,40}
 
 Button imcont3 title="→" ,proc=ButtonProcimcont3,pos={121,25}

 Button imcont4 title="←" ,proc=ButtonProcimcont4,pos={1,25}
 
 Button imGUI6 title="スペクトル書き出し",proc=ButtonProcimcontspe,size={150,20},pos={140,60}
 
 CheckBox imGUIchick title="グラフに重ねて表示",value=1,proc=CheckProcimGUIcheck,pos={145,150}
 
 Button imGUI7 title="領域平均",size={150,20},pos={140,90},proc=ButtonProcimcontregion_analysis
 
 Button button0 title="delete",proc=ButtonProc_imGUIdelete,size={50,20},pos={230,20}
 
 Button buttonimGUI_highpass title="highpass",proc=ButtonProc_highpass,pos={140,180},size={70,20}
 
 Button buttonimGUI_lowpass title="lowpass",proc=ButtonProc_lowpass,pos={140,200},size={70,20}
 
 //Button buttonimGUI_xy title="X-Y",proc=ButtonProcimGUI_XY,pos={230,180}
 
 Button buttonimGUI_xz title="X-Z",proc=ButtonProcimGUI_XZ,pos={230,200}
 
 Button buttonimGUI_yz title="Y-Z",proc=ButtonProcimGUI_yz,pos={230,220}
 
 Button buttonimGUI_sumfromimage title="sumfromimage" ,proc=ButtonProc_sumfromimage,pos={140,120},size={150,20}
 
 make/o/n=9 imGUIcontrol

 imGUIcontrol[0]=xnum         //imchi3_dataのxのデータの個数
 imGUIcontrol[1]=ynum         //imchi3_dataのyのデータの個数
 imGUIcontrol[2]=znum         //imchi3_dataのzのデータの個数
 imGUIcontrol[3]=xpoint       //現在imGUIwv上にあるcursorAのX位置
 imGUIcontrol[4]=ypoint       //現在imGUIwv上にあるcursorAのY位置
 imGUIcontrol[5]=0            //現在imGUIwv上にあるcursorAのZ位置
 imGUIcontrol[6]=wvnum        //現在imGUIspe上にあるcursorAの位置
 imGUIcontrol[7]=switchnum    //imageの表示形式がどの二方向かを区別
 imGUIcontrol[8]=1            //書き出すスペクトルをimGUIspeに重ねて表示するかを区別
 showinfo/W=imGUI
 
  elseif(flagreraman==0)
  wave m_ramanshift1
  if(waveexists(m_ramanshift1)==1)
   print "m_ramanshift1が見つかりません。"
  endif
  endif
  
 elseif(flagimchi==0)
  print "imchi3_dataが見つかりません。なお、名前が違うと動かないので注意してください。"
 endif
  
end



Function ButtonProcimcont1(ba) : ButtonControl
   ///↑のボタンに対応するfunction
	STRUCT WMButtonAction &ba
   wave imGUIcontrol,imchi3_data,re_ramanshift2,imGUIwv,imchi3GUI_data
   string Graphname
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUI
			//showinfo/w=imGUI
		 if(imGUIcontrol[7]==0)
			imGUIcontrol[3]=pcsr(A)
			imGUIcontrol[4]=qcsr(A)	
			imGUIcontrol[4]+=1
		   
		   if(imGUIcontrol[4]>imGUIcontrol[1]-1)
		    imGUIcontrol[4]-=1
		   else
		    cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[3],imGUIcontrol[4]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
			
		 elseif(imGUIcontrol[7]==2)
		   imGUIcontrol[4]=pcsr(A)
			imGUIcontrol[5]=qcsr(A)	
			imGUIcontrol[4]+=1
		   
		   if(imGUIcontrol[4]>imGUIcontrol[1]-1)
		    imGUIcontrol[4]-=1
		   else
		    cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[4],imGUIcontrol[5]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
		 
		 endif
			break
		case -1: // control being killed
		   
			break
	endswitch

	return 0
End



Function ButtonProcimcont2(ba) : ButtonControl
   ///↓のボタンに対応するfunction
	STRUCT WMButtonAction &ba
   wave imGUIcontrol,imchi3_data,re_ramanshift2,imchi3GUI_data
   string Graphname
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUI
			//showinfo/w=imGUI
		 if(imGUIcontrol[7]==0)
			imGUIcontrol[3]=pcsr(A)
			imGUIcontrol[4]=qcsr(A)
			imGUIcontrol[4]-=1
		   
		   if(imGUIcontrol[4]<0)
		    imGUIcontrol[4]+=1
		   else
   	       cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[3],imGUIcontrol[4]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
		 
		 elseif(imguicontrol[7]==2)
		   imGUIcontrol[4]=pcsr(A)
			imGUIcontrol[5]=qcsr(A)
			imGUIcontrol[4]-=1
		   
		   if(imGUIcontrol[4]<0)
		    imGUIcontrol[4]+=1
		   else
   	       cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[4],imGUIcontrol[5]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
		 
		 endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function ButtonProcimcont3(ba) : ButtonControl
   ///→のボタンに対応するfunction
	STRUCT WMButtonAction &ba
	wave imGUIcontrol,imchi3_data,re_ramanshift2,imchi3GUI_data
	string Graphname
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUI
			//showinfo/w=imGUI
			
			imGUIcontrol[3]=pcsr(A)
			imGUIcontrol[4]=qcsr(A)
			imGUIcontrol[3]+=1
			
			if(imGUIcontrol[3]>imGUIcontrol[0]-1)
			 imGUIcontrol[3]-=1
			else
		    cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[3],imGUIcontrol[4]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function ButtonProcimcont4(ba) : ButtonControl
	///←のボタンに対応するfunction
	STRUCT WMButtonAction &ba
   wave imGUIcontrol,imchi3_data,re_ramanshift2,imchi3GUI_data
   string Graphname
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUI
			//showinfo/w=imGUI
			
			imGUIcontrol[3]=pcsr(A)
			imGUIcontrol[4]=qcsr(A)
			imGUIcontrol[3]-=1
			
			if(imGUIcontrol[3]<0)
			 imGUIcontrol[3]+=1
			else
		    cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[3],imGUIcontrol[4]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcimcont5(ba) : ButtonControl
	///Z方向の↑ボタンに対応するfunction
	STRUCT WMButtonAction &ba
   wave imGUIcontrol,imchi3_data,re_ramanshift2,imchi3GUI_data
   string Graphname
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUI
			//showinfo/w=imGUI
			if(imGUIcontrol[7]==1)
			 imGUIcontrol[3]=pcsr(A)
			 imGUIcontrol[5]=qcsr(A)
			 imGUIcontrol[5]+=1
			
			 if(imGUIcontrol[5]>imGUIcontrol[2]-1)
			  imGUIcontrol[5]-=1
			 else
		     cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[3],imGUIcontrol[5]
		     imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			 endif
			
			elseif(imGUIcontrol[7]==2)
			 imGUIcontrol[4]=pcsr(A)
			 imGUIcontrol[5]=qcsr(A)
			 imGUIcontrol[5]+=1
			 
			 if(imGUIcontrol[5]>imGUIcontrol[2]-1)
			  imGUIcontrol[5]-=1
			 else
		     cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[4],imGUIcontrol[5]
		     imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			 endif
			
			endif
			
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcimcont6(ba) : ButtonControl
	///Z方向の↓ボタンに対応するfunction
	STRUCT WMButtonAction &ba
   wave imGUIcontrol,imchi3_data,re_ramanshift2,imchi3GUI_data
   string Graphname
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUI
			//showinfo/w=imGUI	
			if(imGUIcontrol[7]==1)
			 imGUIcontrol[3]=pcsr(A)
			 imGUIcontrol[5]=qcsr(A)
			 imGUIcontrol[5]-=1
			
			 if(imGUIcontrol[5]<0)
			  imGUIcontrol[5]+=1
			 else
		     cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[3],imGUIcontrol[5]
		     imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			 endif
			
			elseif(imGUIcontrol[7]==2)
			 imGUIcontrol[4]=pcsr(A)
			 imGUIcontrol[5]=qcsr(A)
			 imGUIcontrol[5]-=1
			 
			 if(imGUIcontrol[5]<0)
			  imGUIcontrol[5]+=1
			 else
		     cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[4],imGUIcontrol[5]
		     imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			 endif
			
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function SliderProcimGUIzstack(sa) : SliderControl
	STRUCT WMSliderAction &sa
   wave imGUIcontrol,imGUIwv,imchi3_data
   variable/G zstack
	switch( sa.eventCode )
		case -3: // Control received keyboard focus
		case -2: // Control lost keyboard focus
		case -1: // Control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				
				Variable curval = sa.curval
				
				imGUIcontrol[5]=curval
				ValDisplay imGUIval value=_NUM:curval
				
				hideinfo/w=imGUIspe
		     	showinfo/w=imGUIspe
			
			   
			
		    	imGUIwv[][]=imchi3_data[imGUIcontrol[6]][p][q][curval]
			endif
			break
	endswitch
	return 0
End


Function ButtonProcimcontspe(ba) : ButtonControl
   //スペクトルを書き出すためのfunctionです。
	STRUCT WMButtonAction &ba
	wave imchi3GUI_data,imGUIcontrol,re_ramanshift2
   string xxx,yyy,wvname,wvnamesta
   variable flagspe,flagspesta
   wave aaa
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
		
			hideinfo/w=imGUI
			showinfo/w=imGUI
			
			xxx=num2str(pcsr(a))
			yyy=num2str(qcsr(a))
			wvname="imspe"+xxx+"×"+yyy+"×"+num2str(imGUIcontrol[5])		
			
			
			duplicate/o imchi3GUI_data aaa

			 flagspe=waveexists($wvname)
			
			 if(flagspe==1)
			  print "既にこの位置におけるスペクトルは書き出されています"
					 
		    elseif(flagspe==0)
		     rename aaa $wvname
		     if(imGUIcontrol[8]==1)
			   AppendToGraph/C=(0,65535,65535)/L/W=imGUIspe $wvname vs re_ramanshift2
			  endif
		    endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function CheckProcimGUIcheck(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
   wave imGUIcontrol
	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			imGUIcontrol[8]=checked
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcimcontregion_analysis(ba) : ButtonControl
   //領域平均を出す際のボタンです。
	STRUCT WMButtonAction &ba
   variable largeX,smallX,largeY,smallY,i,j,flagavrgwv,flagstre
   wave imGUIcontrol,avrgwv,re_ramanshift2
   string avrgwvname
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUI
			showinfo/w=imGUI
			
			make/o/n=1 avrgwv
			//ここでavrgwvを作っておかないとregion_analysisforGUIでavrgwvを作っても
			//なぜかrenameに間に合わないため作っています
						
			largeX=max(pcsr(a),pcsr(b))
			smallX=min(pcsr(a),pcsr(b))
			largeY=max(qcsr(a),qcsr(b))
			smallY=min(qcsr(a),qcsr(b))
			
			avrgwvname="region_ave"+num2str(smallX)+"~"+num2str(largeX)+","+num2str(smallY)+"~"+num2str(largeY)+"_"+num2str(imGUIcontrol[5])
			flagavrgwv=waveexists($avrgwvname)

			if(flagavrgwv==0)
			 make/o/n=(imGUIcontrol[0],imGUIcontrol[1]) imGUIregion	
		    imGUIregion=0
								
			 for(i=smallX;i<largeX+1;i+=1)
			  for(j=smallY;j<largeY+1;j+=1)
			  
			   imGUIregion[i][j]=1
			  			  
			  endfor
			 endfor
			
			  region_analysisforimGUI()
			  		  
			  rename avrgwv $avrgwvname
			  
			  if(imGUIcontrol[8]==1)
			   AppendToGraph/C=(0,65535,0)/L/W=imGUIspe $avrgwvname vs re_ramanshift2
			  endif
                       
			elseif(flagavrgwv==1)
			 print "既にこの領域における平均スペクトルは書き出されています"
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function region_analysisforimGUI()
    //一つのファイルにまとまってたら楽かなと思ってstre()からコピーしてきただけです。
    //中身はほとんどstre()のものと同じです。
    //region_analysisとはroiwaveの中身が違うため、互換性はありません。
    wave imchi3_data,imGUIregion,avrewv,imGUIcontrol
    variable pts, xNum, yNum;
    variable i, j;
  
    pts = dimsize(imchi3_data, 0)
    xNum = dimsize(imchi3_data, 1)
    yNum = dimsize(imchi3_data, 2)

 
    make/o/n=(pts,xNum,yNum) extractedwv
    make/o/n=(pts,xNum,yNum) tempwv
    tempwv[][][]=imchi3_data[p][q][r][imGUIcontrol[5]]

    i=0
    do
        j=0
        do
            extractedwv[][i][j] = tempwv[p][i][j] *imGUIregion[i][j]
            j+=1
        while(j<yNUm)
        i+=1
    while(i<xNum)
    
    matrixop/o temp = sumrows(extractedwv)
    matrixop/o roinum = sum(imGUIregion)
    matrixop/o avrgwv = sumbeams(temp)/roinum[0]
    
    killwaves extractedwv,temp,tempwv,roinum
    
end



Function ButtonProcimGUIreimage(ba) : ButtonControl
   //imageを出し直す際のボタンです。
	STRUCT WMButtonAction &ba
	wave imchi3_data,imGUIcontrol,imGUIwv,re_ramanshift2
	variable wvnum
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUIspe
			//showinfo/w=imGUIspe
			
			wvnum=pcsr(a)
			
			imGUIcontrol[6]=wvnum
			
			imGUIwv[][]=imchi3_data[wvnum][p][q][imGUIcontrol[5]]
      
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcimGUIspeimage(ba) : ButtonControl
   //imageをスペクトルの積算強度で出し直す際のボタンです。
	STRUCT WMButtonAction &ba
	wave imchi3_data,imGUIcontrol,imGUIwv,re_ramanshift2
	variable wvnum,wvnum2,pnum,qnum,i,j,k,cons,ave
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUIspe
			//showinfo/w=imGUIspe
						
			wvnum=max(pcsr(a),pcsr(b))
			wvnum2=min(pcsr(a),qcsr(b))
			
			imGUIwv=0
			
			if(imGUIcontrol[7]==0)			
			pnum=imGUIcontrol[0]
			qnum=imGUIcontrol[1]
			for(k=0;k<pnum;k+=1)
			 for(j=0;j<qnum;j+=1)
			 ave=(imchi3_data[pcsr(a)][k][j][imGUIcontrol[5]]-imchi3_data[pcsr(b)][k][j][imGUIcontrol[5]])/(pcsr(a)-pcsr(b))
			 cons=imchi3_data[pcsr(a)][k][j][imGUIcontrol[5]]-ave*pcsr(a)
			  for(i=wvnum2;i<wvnum+1;i+=1)
			   imGUIwv[k][j]+=imchi3_data[i][k][j][imGUIcontrol[5]]+(i*ave+cons)
	        endfor
          endfor
         endfor
         
         elseif(imGUIcontrol[7]==1)
			pnum=imGUIcontrol[0]
			qnum=imGUIcontrol[2]
			for(k=0;k<pnum;k+=1)
			 for(j=0;j<qnum;j+=1)
			  for(i=wvnum2;i<wvnum+1;i+=1)
			   imGUIwv[k][j]+=imchi3_data[i][k][imGUIcontrol[4]][j]-(i*(imchi3_data[pcsr(a)][k][imGUIcontrol[4]][j]-imchi3_data[pcsr(b)][k][imGUIcontrol[4]][j])/(xcsr(a)-xcsr(b)+imchi3_data[pcsr(a)][k][imGUIcontrol[4]][j]-imchi3_data[pcsr(b)][k][imGUIcontrol[4]][j])/(xcsr(a)-xcsr(b))*xcsr(a))
	        endfor
          endfor
         endfor
			
			elseif(imGUIcontrol[7]==2)
			pnum=imGUIcontrol[1]
			qnum=imGUIcontrol[2]
			for(k=0;k<pnum;k+=1)
			 for(j=0;j<qnum;j+=1)
			  for(i=wvnum2;i<wvnum+1;i+=1)
			   imGUIwv[k][j]+=imchi3_data[i][imGUIcontrol[3]][k][j]-(i*(imchi3_data[pcsr(a)][imGUIcontrol[3]][k][j]-imchi3_data[pcsr(b)][imGUIcontrol[3]][k][j])/(xcsr(a)-xcsr(b)+imchi3_data[pcsr(a)][imGUIcontrol[3]][k][j]-imchi3_data[pcsr(b)][imGUIcontrol[3]][k][j])/(xcsr(a)-xcsr(b))*xcsr(a))
	        endfor
          endfor
         endfor
			endif
         
         
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function ButtonProc_imGUIdelete(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			killwindow/Z imGUI
			killwindow/Z imGUIspe
			killwindow/Z imGUI_controlpanel
			
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ButtonProcimGUI_XY(ba) : ButtonControl
	STRUCT WMButtonAction &ba
   wave imGUIcontrol,imchi3_data

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			imGUIcontrol[7]=0
					
			make/o/n=(imGUIcontrol[0],imGUIcontrol[1]) imGUIwv
			
		   imGUIwv[][]=imchi3_data[imGUIcontrol[6]][p][q][0]
			
			killwindow imGUI						
			newimage/N=imGUI imGUIwv
			SetAxis/A left
			cursor/i/a=1/c=(0,0,60000,65000) a imguiwv round(imGUIcontrol[0]/2),round(imGUIcontrol[1]/2)
			newpanel/FLT=0/N=imGUI_controlpanel/W=(0,0,300,300)/HOST=imgui/EXT=0/NA=0
			if(imGUIcontrol[2]>1) 
          Slider slider0,pos={30,110},vert=1,proc=SliderProcimGUIzstack,size={30,imGUIcontrol[2]*10},limits={0,imGUIcontrol[2]-1,1},value=0
          ValDisplay imGUIval title="zstack",value=0,size={65,16},pos={20,80},fstyle=1, ticks=2
         endif
			Button imcont1 title="↑" ,proc=ButtonProcimcont1,pos={61,11}
			Button imcont2 title="↓" ,proc=ButtonProcimcont2,pos={61,40}
			Button imcont3 title="→" ,proc=ButtonProcimcont3,pos={121,25}
			Button imcont4 title="←" ,proc=ButtonProcimcont4,pos={1,25}
			Button imGUI6 title="スペクトル書き出し",proc=ButtonProcimcontspe,size={150,20},pos={140,60}
			CheckBox imGUIchick title="グラフに重ねて表示",value=1,proc=CheckProcimGUIcheck,pos={145,150}
			Button imGUI7 title="領域平均",size={150,20},pos={140,90},proc=ButtonProcimcontregion_analysis
			Button button0 title="delete",proc=ButtonProc_imGUIdelete,size={50,20},pos={230,20}
			Button buttonimGUI_highpass title="highpass",proc=ButtonProc_highpass,pos={140,180},size={70,20}
			Button buttonimGUI_lowpass title="lowpass",proc=ButtonProc_lowpass,pos={140,200},size={70,20}
			//Button buttonimGUI_xy title="X-Y",proc=ButtonProcimGUI_XY,pos={230,180}
			Button buttonimGUI_xz title="X-Z",proc=ButtonProcimGUI_XZ,pos={230,200}
			Button buttonimGUI_yz title="Y-Z",proc=ButtonProcimGUI_yz,pos={230,220}
			Button buttonimGUI_sumfromimage title="sumfromimage" ,proc=ButtonProc_sumfromimage,pos={140,120},size={150,20}
			imGUIcontrol[8]=1  		
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcimGUI_XZ(ba) : ButtonControl
	STRUCT WMButtonAction &ba
   wave imGUIcontrol,imchi3_data

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			imGUIcontrol[7]=1
					
			make/o/n=(imGUIcontrol[0],imGUIcontrol[2]) imGUIwv
			
		   imGUIwv[][]=imchi3_data[imGUIcontrol[6]][p][0][q]
			
			killwindow imGUI			
			newimage/N=imGUI imGUIwv
			SetAxis/A left
			cursor/i/a=1/c=(0,0,60000,65000) a imguiwv round(imGUIcontrol[0]/2),round(imGUIcontrol[2]/2)
			newpanel/FLT=0/N=imGUI_controlpanel/W=(0,0,300,300)/HOST=imgui/EXT=0/NA=0
			if(imGUIcontrol[1]>1) 
          Slider slider0,pos={30,110},vert=1,proc=SliderProcimGUIystack,size={30,imGUIcontrol[1]*10},limits={0,imGUIcontrol[1]-1,1},value=0
			 valDisplay imGUIval title="ystack",value=0,size={65,16},pos={20,80},fstyle=1, ticks=2
         endif
			Button imcont1 title="↑" ,proc=ButtonProcimcont5,pos={61,11}
			Button imcont2 title="↓" ,proc=ButtonProcimcont6,pos={61,40}
			Button imcont3 title="→" ,proc=ButtonProcimcont3,pos={121,25}
			Button imcont4 title="←" ,proc=ButtonProcimcont4,pos={1,25}
			Button imGUI6 title="スペクトル書き出し",proc=ButtonProcimcontspe,size={150,20},pos={140,60}
			CheckBox imGUIchick title="グラフに重ねて表示",value=1,proc=CheckProcimGUIcheck,pos={145,150}
			Button imGUI7 title="領域平均",size={150,20},pos={140,90},proc=ButtonProcimcontregion_analysis
			Button button0 title="delete",proc=ButtonProc_imGUIdelete,size={50,20},pos={230,20}
			Button buttonimGUI_highpass title="highpass",proc=ButtonProc_highpass,pos={140,180},size={70,20}
			Button buttonimGUI_lowpass title="lowpass",proc=ButtonProc_lowpass,pos={140,200},size={70,20}
			Button buttonimGUI_xy title="X-Y",proc=ButtonProcimGUI_XY,pos={230,180}
			//Button buttonimGUI_xz title="X-Z",proc=ButtonProcimGUI_XZ,pos={230,200}
			Button buttonimGUI_yz title="Y-Z",proc=ButtonProcimGUI_yz,pos={230,220}
			Button buttonimGUI_sumfromimage title="sumfromimage" ,proc=ButtonProc_sumfromimage,pos={140,120},size={150,20}
			imGUIcontrol[8]=1  
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProcimGUI_YZ(ba) : ButtonControl
	STRUCT WMButtonAction &ba
   wave imGUIcontrol,imchi3_data

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
				
			imGUIcontrol[7]=2
					
			make/o/n=(imGUIcontrol[1],imGUIcontrol[2]) imGUIwv
			
		   imGUIwv[][]=imchi3_data[imGUIcontrol[6]][0][p][q]
			
			killwindow imGUI			
			newimage/N=imGUI imGUIwv
			SetAxis/A left
			cursor/i/a=1/c=(0,0,60000,65000) a imguiwv round(imGUIcontrol[1]/2),round(imGUIcontrol[2]/2)		
			newpanel/FLT=0/N=imGUI_controlpanel/W=(0,0,300,300)/HOST=imgui/EXT=0/NA=0
			if(imGUIcontrol[0]>1) 
          Slider slider0,pos={30,110},vert=1,proc=SliderProcimGUIxstack,size={30,imGUIcontrol[0]*10},limits={0,imGUIcontrol[0]-1,1},value=0
          ValDisplay imGUIval title="xstack",value=0,size={65,16},pos={20,80},fstyle=1, ticks=2
         endif
			Button imcont1 title="↑" ,proc=ButtonProcimcont5,pos={61,11}
			Button imcont2 title="↓" ,proc=ButtonProcimcont6,pos={61,40}
			Button imcont3 title="→" ,proc=ButtonProcimcont1,pos={121,25}
			Button imcont4 title="←" ,proc=ButtonProcimcont2,pos={1,25}
			Button imGUI6 title="スペクトル書き出し",proc=ButtonProcimcontspe,size={150,20},pos={140,60}
			CheckBox imGUIchick title="グラフに重ねて表示",value=1,proc=CheckProcimGUIcheck,pos={145,150}
			Button imGUI7 title="領域平均",size={150,20},pos={140,90},proc=ButtonProcimcontregion_analysis
			Button button0 title="delete",proc=ButtonProc_imGUIdelete,size={50,20},pos={230,20}
			Button buttonimGUI_highpass title="highpass",proc=ButtonProc_highpass,pos={140,180},size={70,20}
			Button buttonimGUI_lowpass title="lowpass",proc=ButtonProc_lowpass,pos={140,200},size={70,20}
			Button buttonimGUI_xy title="X-Y",proc=ButtonProcimGUI_XY,pos={230,180}
			Button buttonimGUI_xz title="X-Z",proc=ButtonProcimGUI_XZ,pos={230,200}
			//Button buttonimGUI_yz title="Y-Z",proc=ButtonProcimGUI_yz,pos={230,220}
			Button buttonimGUI_sumfromimage title="sumfromimage" ,proc=ButtonProc_sumfromimage,pos={140,120},size={150,20}
			imGUIcontrol[8]=1 
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function SliderProcimGUIystack(sa) : SliderControl
	STRUCT WMSliderAction &sa
   wave imGUIcontrol,imGUIwv,imchi3_data
   variable/G zstack
	switch( sa.eventCode )
		case -3: // Control received keyboard focus
		case -2: // Control lost keyboard focus
		case -1: // Control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				
				Variable curval = sa.curval
				
				imGUIcontrol[4]=curval
				ValDisplay imGUIval value=_NUM:curval
				
				hideinfo/w=imGUIspe
		     	showinfo/w=imGUIspe
			
			
		    	imGUIwv[][]=imchi3_data[imGUIcontrol[6]][p][curval][q]
			endif
			break
	endswitch
	return 0
end


Function SliderProcimGUIxstack(sa) : SliderControl
	STRUCT WMSliderAction &sa
   wave imGUIcontrol,imGUIwv,imchi3_data
   variable/G zstack
	switch( sa.eventCode )
		case -3: // Control received keyboard focus
		case -2: // Control lost keyboard focus
		case -1: // Control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				
				Variable curval = sa.curval
				
				imGUIcontrol[3]=curval
				ValDisplay imGUIval value=_NUM:curval
				
				hideinfo/w=imGUIspe
		     	showinfo/w=imGUIspe
			
			
		    	imGUIwv[][]=imchi3_data[imGUIcontrol[6]][curval][p][q]
			endif
			break
	endswitch
	return 0
end


DemoWindowHook():
Function MyWindowHook(s)
	STRUCT WMWinHookStruct &s
	wave imGUIcontrol,imchi3GUI_data,imchi3_data
	Variable hookResult = 0	// 0 if we do not handle event, 1 if we handle it.
   variable xnum,ynum
	switch(s.eventCode)
		case 11:					// Keyboard event
			switch (s.keycode)
				case 28:
		 hideinfo/w=imGUI
			//showinfo/w=imGUI
			
			imGUIcontrol[3]=pcsr(A)
			imGUIcontrol[4]=qcsr(A)
			imGUIcontrol[3]-=1
			
			if(imGUIcontrol[3]<0)
			 imGUIcontrol[3]+=1
			else
		    cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[3],imGUIcontrol[4]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
					hookResult = 1
					DoWindow/F imGUI				// Does graph exist?
	if (V_flag == 0)
		Display /N=imGUI			// Create graph
		SetWindow imGUI, hook(MyHook) = MyWindowHook	// Install window hook
	endif
					break
				case 29:
			hideinfo/w=imGUI
			//showinfo/w=imGUI
			
			imGUIcontrol[3]=pcsr(A)
			imGUIcontrol[4]=qcsr(A)
			imGUIcontrol[3]+=1
			
			if(imGUIcontrol[3]>imGUIcontrol[0]-1)
			 imGUIcontrol[3]-=1
			else
		    cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[3],imGUIcontrol[4]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
					hookResult = 1
					DoWindow/F imGUI				// Does graph exist?
	if (V_flag == 0)
		Display /N=imGUI			// Create graph
		SetWindow imGUI, hook(MyHook) = MyWindowHook	// Install window hook
	endif
					break
				case 30:
					// click code here
			
			hideinfo/w=imGUI
			//showinfo/w=imGUI
		 if(imGUIcontrol[7]==0)
			imGUIcontrol[3]=pcsr(A)
			imGUIcontrol[4]=qcsr(A)	
			imGUIcontrol[4]+=1
		   
		   if(imGUIcontrol[4]>imGUIcontrol[1]-1)
		    imGUIcontrol[4]-=1
		   else
		    cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[3],imGUIcontrol[4]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
			
		 elseif(imGUIcontrol[7]==2)
		   imGUIcontrol[4]=pcsr(A)
			imGUIcontrol[5]=qcsr(A)	
			imGUIcontrol[4]+=1
		   
		   if(imGUIcontrol[4]>imGUIcontrol[1]-1)
		    imGUIcontrol[4]-=1
		   else
		    cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[4],imGUIcontrol[5]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
		 
		 endif
					hookResult = 1
					DoWindow/F imGUI				// Does graph exist?
	if (V_flag == 0)
		Display /N=imGUI			// Create graph
		SetWindow imGUI, hook(MyHook) = MyWindowHook	// Install window hook
	endif
					break
				case 31:
					hideinfo/w=imGUI
			//showinfo/w=imGUI
		 if(imGUIcontrol[7]==0)
			imGUIcontrol[3]=pcsr(A)
			imGUIcontrol[4]=qcsr(A)
			imGUIcontrol[4]-=1
		   
		   if(imGUIcontrol[4]<0)
		    imGUIcontrol[4]+=1
		   else
   	       cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[3],imGUIcontrol[4]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
		 
		 elseif(imguicontrol[7]==2)
		   imGUIcontrol[4]=pcsr(A)
			imGUIcontrol[5]=qcsr(A)
			imGUIcontrol[4]-=1
		   
		   if(imGUIcontrol[4]<0)
		    imGUIcontrol[4]+=1
		   else
   	       cursor/w=imGUI/I/a=1/c=(0,0,60000,65000) A imGUIwv imGUIcontrol[4],imGUIcontrol[5]
		    imchi3GUI_data=imchi3_data[p][imGUIcontrol[3]][imGUIcontrol[4]][imGUIcontrol[5]] 
			endif
		 
		 endif
					hookResult = 1
					DoWindow/F imGUI				// Does graph exist?
	if (V_flag == 0)
		Display /N=imGUI			// Create graph
		SetWindow imGUI, hook(MyHook) = MyWindowHook	// Install window hook
	endif
					break			
				default:
					// The keyText field requires Igor Pro 7 or later. See Keyboard Events.
					Printf "Key pressed: %s\r", s.keyText
					break			
			endswitch
			break
	endswitch

	return hookResult	// If non-zero, we handled event and Igor will ignore it.
End

Function DemoWindowHook()
	DoWindow/F imGUI				// Does graph exist?
	if (V_flag == 0)
		Display /N=imGUI	// Create graph
	endif
   SetWindow imGUI, hook(MyHook) = MyWindowHook	// Install window hook
End

menu "Analysis"
 "DemoWindowHook()/q"
end


function highFFT(imGUIwv)
wave imGUIwv
variable i,j,k
variable xnum,ynum

xnum=dimsize(imGUIwv,0)
ynum=dimsize(imGUIwv,1)

duplicate/o imGUIwv test

if(mod(xnum,2)==1)
 insertpoints/m=0/v=(wavemin(imGUIwv)) xnum+1,1,test
 insertpoints/m=1/v=(wavemin(imGUIwv)) xnum+1,1,test
endif


fft/dest=abc test

make/n=(dimsize(abc,0),dimsize(abc,1))/o def
duplicate/o def filter
filter=1
for(i=0;i<dimsize(abc,0);i+=1)
 for(j=0;j<dimsize(abc,1);j+=1)
  if((xnum*0.7)>((dimsize(abc,1)/2)-j)^2+(i)^2)
   filter[i][j]=0
  endif
 endfor
endfor

abc[][]*=filter[p][q]

def[][]=(real(abc[p][q]))^2+(imag(abc[p][q]))^2

ifft/dest=xxx abc

if(mod(xnum,2)==1)
 deletepoints/m=0 xnum,1,xxx
 deletepoints/m=1 xnum,1,xxx
endif

imGUIwv[][]=xxx[p][q]

end


Function ButtonProc_highpass(ba) : ButtonControl
	STRUCT WMButtonAction &ba
   wave imGUIwv
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			highfft(imGUIwv)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


function lowFFT(imGUIwv)
wave imGUIwv
variable i,j,k
variable xnum,ynum

xnum=dimsize(imGUIwv,0)
ynum=dimsize(imGUIwv,1)

duplicate/o imGUIwv test

if(mod(xnum,2)==1)
 insertpoints/m=0/v=(wavemin(imGUIwv)) xnum+1,1,test
 insertpoints/m=1/v=(wavemin(imGUIwv)) xnum+1,1,test
endif


fft/dest=abc test

make/n=(dimsize(abc,0),dimsize(abc,1))/o def
duplicate/o def filter
filter=1
for(i=0;i<dimsize(abc,0);i+=1)
 for(j=0;j<dimsize(abc,1);j+=1)
  if((xnum*6)<((dimsize(abc,1)/2)-j)^2+(i)^2)
   filter[i][j]=0
  endif
 endfor
endfor

abc[][]*=filter[p][q]

def[][]=(real(abc[p][q]))^2+(imag(abc[p][q]))^2

ifft/dest=xxx abc

if(mod(xnum,2)==1)
 deletepoints/m=0 xnum,1,xxx
 deletepoints/m=1 xnum,1,xxx
endif

imGUIwv[][]=xxx[p][q]

end


Function ButtonProc_lowpass(ba) : ButtonControl
	STRUCT WMButtonAction &ba
   wave imGUIwv
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
		    lowFFT(imGUIwv)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


function SumFromImageforGUI(wv, discri, oriwv)
wave wv,oriwv;
variable discri;

variable pts,xNum,yNum,pixnum;
variable i,j,cts,judgeX,judgeY;


Silent 1; PauseUpdate
pts=dimsize(oriwv,0)
xnum=dimsize(wv,0)
ynum=dimsize(wv,1)
make /o/n=(pts) temp00
temp00=0;
cts=0;

make/o/n=(xnum+1,ynum+1) TargetFromImage

targetfromimage=0


i=0
do
	j=0
	do
		if(wv[i][j]>discri)
		//if(imchi3_data[pixnum][i][j][0]>discri)
			temp00[]+=oriwv[p][i][j][1]
			cts+=1 
			targetfromimage[i][j]=1
		endif
		j+=1
	while(j<yNum)
	i+=1
while(i<xNum)

i=0
do
	j=0
	do
		if(wv[i][j]>discri)
		//if(imchi3_data[pixnum][i][j][0]>discri)
			temp00[]+=oriwv[p][i][j][0]
			cts+=1 
		endif
		j+=1
	while(j<yNum)
	i+=1
while(i<xNum)
temp00/=cts

killwindow/z sumfromimage

newimage/n=sumfromimage wv

for(j=0;j<ynum;j+=1)
 for(i=0;i<xnum;i+=1)
  
   judgeX=targetfromimage[i+1][j]-targetfromimage[i][j]
   judgeY=targetfromimage[i][j+1]-targetfromimage[i][j]
   
   
   if(judgex==1||judgex==-1)
    setdrawenv/w=sumfromimage linefgc=(65535,0,0) 
    drawline/w=sumfromimage (i+1)/xnum,(j)/ynum,(i+1)/xnum,(j+1)/ynum
   endif
   
   if(judgey==1||judgey==-1)
    setdrawenv/w=sumfromimage linefgc=(655350,0,0) 
    drawline/w=sumfromimage (i)/xnum,(j+1)/ynum,(i+1)/xnum,(j+1)/ynum
   endif
   
   if(targetfromimage[i][0]==1)
    setdrawenv/w=sumfromimage linefgc=(65535,0,0) 
    drawline/w=sumfromimage i/xnum,0,(i+1)/xnum,0

   elseif(targetfromimage[i][ynum]==1)
    setdrawenv/w=sumfromimage linefgc=(65535,0,0) 
    drawline/w=sumfromimage i/xnum,1,(i+1)/xnum,1

   elseif(targetfromimage[0][j]==1)
    setdrawenv/w=sumfromimage linefgc=(65535,0,0) 
    drawline/w=sumfromimage 0,j/ynum,0,(j+1)/ynum

   elseif(targetfromimage[xnum][j]==1)
    setdrawenv/w=sumfromimage linefgc=(65535,0,0) 
    drawline/w=sumfromimage 1,j/ynum,1,(j+1)/ynum

   endif

 endfor
endfor
end


Function ButtonProc_sumfromimage(ba) : ButtonControl
	STRUCT WMButtonAction &ba
   wave imGUIwv,imchi3_data,temp00,re_ramanshift2,imGUIcontrol
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			sumfromimageforGUI(imGUIwv,imGUIwv[pcsr(A)][qcsr(A)],imchi3_data)
			if(imGUIcontrol[8]==1)
			AppendToGraph/C=(0,0,65535)/L/W=imGUIspe temp00 vs re_ramanshift2
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
