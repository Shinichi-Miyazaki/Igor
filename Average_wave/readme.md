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


