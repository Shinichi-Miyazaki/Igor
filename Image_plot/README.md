## Image plotで横軸を設定する方法  
Image plotを普通に作成すると, 下の図のように横軸, 縦軸はともにwave pointとなります.   
![Graph0](https://user-images.githubusercontent.com/59829168/128812831-16161ac8-1630-4fa8-838b-b1f881b248e9.png)

この縦, 横軸を単位ありの軸にする方法の解説です (ここでは距離で試してみます)  
ちなみに私は線虫の神経活動を測定して, ヒートマップにする際にこの手法を使いました.  
以下の手法はIgor 8 manual (help/manual) Ⅱ-320 あたりに記載があります.  

0. 用意するもの  
	1. 出したいイメージ (2次元waveとして読み込んでください. 誤って1次元wave の集まりとして読み込んだ場合にはData/Concatenate wavesでくっつけてください)   
	2. 縦の軸 (1次元wave), 横の軸 (1次元wave)  
	3. Make_edge_wave.ipf  

1. 以下の命令を実行します  
```Igor
Make/O edgesx; MakeEdgesWave(xaxis, edgesx)
```  
この関数がやっているのは, ただの1次元waveからImage plotの軸として使用可能なwaveへの変換です.  

2. この状態でWindows/New/Image plotを実行すると以下の画面が出現します.  

![Image_plot](https://user-images.githubusercontent.com/59829168/128812875-a1fec004-56aa-4026-b6e2-a39c3b6ee3b5.png)

ここで, x wave, y waveをedges x, edges yにすると, 以下の画像が出現します.  
![Image_plot2](https://user-images.githubusercontent.com/59829168/128812882-632ca9de-e6e4-4fec-8b97-ae1f825afeb5.png)
![graph1](https://user-images.githubusercontent.com/59829168/128812913-970ce67e-c575-4d9f-ac77-f69ed9f0371b.PNG)

横軸, 縦軸が不均一になっています. このように任意の軸を用いることが可能です  

