## 領域平均スペクトルの作成  

0. 用意するもの  
imchi3_data  
re_ramanshift2  
rawdata (MEM前のデータ)  


---
#### 撮影した画像内の特定の領域の平均スペクトルを得る  
撮影した画像から特定の領域 (細胞やその中の特定の構造) の平均スペクトルを得る場合です.   

1. Data/Load Data/Load ZigZag SPE File Noshifted and Make Each Z swap AV Quickly LF PIXIS NO zigzagを使って画像を出す.   
(これらはextensionを入れていないとIgorで表示されません. extensionの導入方法は別に示します.)

2. Image/Image ROI からROIマネージャーを起動  

3. ROIというウィンドウがポップアップするので, start ROI Editingをクリック 

4. 画像の左側にツールバーが出現するので, 好きなツールを選択してROIを囲む  

5. roi などの適当な名前で保存  


