#pragma TextEncoding = "Shift_JIS"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


function GUI()
 //制作者:田中

 //imchi3_dataを解析する際に使えるプログラムです。
 //imchi3_dataとre_ramanshift2という名前のwaveが存在していれば使えます。

 wave imchi3_data,re_ramanshift2
 variable wvnum,xnum,ynum,znum,knum
 variable xpoint,ypoint,flagimchi,flagreraman
 variable/G zstack
 string strX,strY,Graphname,panelname
 
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
 
 display/N=imGUIspe imchi3GUI_data vs re_ramanshift2 


 panelname="imGUI_controlpanel"

 newpanel/n=$panelname
 
 if(znum>1) 
 Slider slider0,pos={30,110},vert=1,proc=SliderProcimGUIzstack,size={30,znum*10},limits={0,znum-1,1},value=0
 ValDisplay imGUIval title="zstack",value=0,size={65,16},pos={20,80},fstyle=1, ticks=2
 endif
 
 Button imcont1 title="↑" ,proc=ButtonProcimcont1,pos={61,11}

 Button imcont2 title="↓" ,proc=ButtonProcimcont2,pos={61,40}
 
 Button imcont3 title="→" ,proc=ButtonProcimcont3,pos={121,25}

 Button imcont4 title="←" ,proc=ButtonProcimcont4,pos={1,25}
 
 Button imGUI6 title="スペクトル書き出し",proc=ButtonProcimcontspe,size={150,20},pos={140,70}
 
 CheckBox imGUIchick title="書き出す際に規格化しますか？",proc=CheckProcimGUIcheck,pos={135,95}
 
 Button imGUI7 title="領域平均",size={150,20},pos={140,120},proc=ButtonProcimcontregion_analysis

 Button imGUIreimage title="別の波数で画像を出し直す",size={150,20},pos={140,155},proc=ButtonProcimGUIreimage
 
 make/o/n=9 imGUIcontrol

 imGUIcontrol[0]=xnum
 imGUIcontrol[1]=ynum
 imGUIcontrol[2]=znum
 imGUIcontrol[3]=xpoint
 imGUIcontrol[4]=ypoint
 imGUIcontrol[5]=0
 imGUIcontrol[6]=wvnum
 showinfo/W=imGUI
 
  elseif(flagreraman==0)
                                                                                                                                                          print "re_ramanshift2がありません。makeramanshift4(m_ramanshift1)をし忘れていませんか？"
  
  endif
  
 elseif(flagimchi==0)
  
                                                                                                                                                                    print "imchi3_dataが見つかりません。なお、名前が違うと動かないので注意してください。"
 
 endif
  
end



Function ButtonProcimcont1(ba) : ButtonControl
   ///↑のボタンに対応するfunction
	STRUCT WMButtonAction &ba
   wave imGUIcontrol,imchi3_data,re_ramanshift2,imGUIwv,imchi3GUI_data
   variable ynum
   string Graphname
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUI
			showinfo/w=imGUI
			
			imGUIcontrol[3]=pcsr(A)
			imGUIcontrol[4]=qcsr(A)	
			imGUIcontrol[4]+=1
			ynum=imGUIcontrol[0]
		   
		   if(imGUIcontrol[4]>ynum-1)
		    imGUIcontrol[4]-=1
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



Function ButtonProcimcont2(ba) : ButtonControl
   ///↓のボタンに対応するfunction
	STRUCT WMButtonAction &ba
   wave imGUIcontrol,imchi3_data,re_ramanshift2,imchi3GUI_data
   string Graphname
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUI
			showinfo/w=imGUI
			
			imGUIcontrol[3]=pcsr(A)
			imGUIcontrol[4]=qcsr(A)
			imGUIcontrol[4]-=1
		   
		   if(imGUIcontrol[4]<0)
		    imGUIcontrol[4]+=1
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



Function ButtonProcimcont3(ba) : ButtonControl
   ///→のボタンに対応するfunction
	STRUCT WMButtonAction &ba
	wave imGUIcontrol,imchi3_data,re_ramanshift2,imchi3GUI_data
	variable xnum
	string Graphname
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			hideinfo/w=imGUI
			showinfo/w=imGUI
			
			imGUIcontrol[3]=pcsr(A)
			imGUIcontrol[4]=qcsr(A)
			imGUIcontrol[3]+=1
			xnum=imGUIcontrol[0]
			
			if(imGUIcontrol[3]>xnum-1)
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
			showinfo/w=imGUI
			
			imGUIcontrol[3]=pcsr(A)
			imGUIcontrol[4]=qcsr(A)
			imGUIcontrol[3]-=1
			
			if(imGUIcontrol[3]<0)
			 imGUIcontrol+=1
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
			
			
			duplicate imchi3GUI_data aaa
			
			
	       if(imGUIcontrol[7]==0)
	       
			 flagspe=waveexists($wvname)
			
			 if(flagspe==1)
			  print "既にこの位置におけるスペクトルは書き出されています"
					 
		    elseif(flagspe==0)
		     rename aaa $wvname
		     display $wvname vs re_ramanshift2
		    endif
		    
		    elseif(imGUIcontrol[7]==1)
 
			  wvnamesta=wvname+"sta"
			  flagspesta=waveexists($wvnamesta)
			  
			  
			  if(flagspesta==0)
			   aaa/=wavemax(imchi3GUI_data)
			   rename aaa $wvnamesta
			   display $wvnamesta vs re_ramanshift2
			  elseif(flagspesta==1)
			   print "既にこの位置における規格化されたスペクトルは書き出されています"
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
			imGUIcontrol[7]=checked
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
			  
			  display $avrgwvname vs re_ramanshift2
                       
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
			showinfo/w=imGUIspe
			
			wvnum=pcsr(a)
			
			imGUIcontrol[6]=wvnum
			
			imGUIwv[][]=imchi3_data[wvnum][p][q][imGUIcontrol[5]]
      
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End