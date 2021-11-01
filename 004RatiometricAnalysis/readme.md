## フィッティング後の画像でのratiometric imageの作成  

0. 用意するもの  
フィット後の画像 (2つ)  
Ratiometric_analysis.ipf  

1. ガウスフィットの実行  
詳しくはフィットのreadmeで書いてあります. うまくいっていれば"Fitimage" みたいな名前のwaveがすでに手に入っているはずです. (ctrl+Bでwave ブラウザを見てみましょう)  

2. ratiometric imageの作成  
Ratiometric_analysis.ipfをコンパイルして以下です  
```Igor
ratiometric_image(image1, image2)
	//image1とimage2には比をとりたいフィット画像を入れましょう. 
	//image1が分子, image2が分母になります. 
```

3. ratioimageという名前のwaveが作成されて, 画像が出ていると思います. 