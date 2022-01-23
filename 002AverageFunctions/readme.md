## 領域平均スペクトルの作成   

---
#### 撮影した画像内の特定の領域の平均スペクトルを得る  
撮影した画像から特定の領域 (細胞やその中の特定の構造) の平均スペクトルを得る場合です.   

0. 用意するもの  
imchi3_data  
re_ramanshift2  
rawdata (MEM前のデータ)  
region_analysis.ipf  

1. Data/Load Data/Load ZigZag SPE File Noshifted and Make Each Z swap AV Quickly LF PIXIS NO zigzagを使って画像を出す.  
(これらはextensionを入れていないとIgorで表示されません. extensionの導入方法は別に示します.)

2. Image/Image ROI からROIマネージャーを起動  

3. ROIというウィンドウがポップアップするので, start ROI Editingをクリック 

4. 画像の左側にツールバーが出現するので, 好きなツールを選択してROIを囲む  

5. roi などの適当な名前で保存  
![roi_setting](https://user-images.githubusercontent.com/59829168/111895116-afb93000-8a53-11eb-9003-e7ae4fcd92e2.jpg)  

6. 以下のコードで領域平均スペクトルを求める  
```Igor
region_analysis(imchi3_data, roiwave, znum)
	//ここでroiwaveは先ほど作ったもの
	//znumはimchi3_dataがz方向に複数枚の時には, 
	//好きなz平面の解析ができます. 1枚目はznum = 0
	//average_wvという名前で保存されるので, 好きな名前に変更
rename average_wv region_av
```


---
#### 表示している画像内の画素値が一定以上の空間点の平均スペクトルを求める  
例)  
SHが一定値以上の強度の空間点の平均スペクトルを求めたいとき  
すでにフィットしたが, ある波数で強度の強いピクセルを足しこみたいとき  

0. 用意するもの  
imchi3_data  
re_ramanshift2  
rawdata (MEM前のデータ)  
averaging_function

1. 画像の表示  
適当な方法で画像を出します.  
ImageMSでも良いですし, Data/Load Data/Load ZigZag SPE File Noshifted and Make Each Z swap AV Quickly LF PIXIS NO zigzagでもOKです.  
Fit後の画像で実行したいときはFitImageが出ていればOKです.  

2. 閾値を決めるために, 画像内の適当な位置の輝度値の確認  
足し込みする閾値を決めるために, 画像内の適当な点の輝度値を取得します  
![スクリーンショット 2021-03-24 22 00 08](https://user-images.githubusercontent.com/59829168/112314542-7c450280-8cec-11eb-85f6-b1900411a19c.png)  

上の図のように, 画像を出してカーソル (ctrl + i)で見ても良いですし, Windows/New tableから, 画像を数値データとして表示して閾値を見るのも良いです. 

3. 閾値を決めて, それ以上の領域の足し込み  
閾値が決まったら以下のコードで足し込みをおこないます.   
```Igor
AveragingWithImageAndDiscri(ImageWv,Threshold,OriginalWv)
	//imagewvにはimageの名前をいれてください.  
	//thresholdには2. で決めた閾値を入れます.
	//originalwvにはimchi3_dataなどを入れます
rename temp00 discriwv
	//temp00という名前でwaveが作成されるので, 適当に名前をつけてください. 
	
```






