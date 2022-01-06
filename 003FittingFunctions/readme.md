## フィットと画像の作成  

### 最終更新 2022/1/7

0. 用意するもの  
領域平均スペクトル (.ibw)  
imchi3_data  
re_ramanshift2  
FittingFunctions.ipf   

1. フィット領域の定義のため, グラフを表示  
  まずは, 領域平均スペクトルを表示して, どの波数をフィットするかを考えます.  
  平均スペクトルを読み込んだら, 以下のコードで適当に図を出します.  
```Igor
display waveav vs re_ramanshift2
```
以下のような図が出るはずなので, フィットしたい領域を拡大しましょう.  
<img width="852" alt="im1" src="https://user-images.githubusercontent.com/59829168/112760635-ba1a9180-9032-11eb-9599-b76f88b09e4c.png">  
拡大は適当なところを四角で囲って, 右クリック expandです.   
<img width="852" alt="im2" src="https://user-images.githubusercontent.com/59829168/112760652-c30b6300-9032-11eb-910d-7e5827c970c6.png">


2. wcoefの用意  
加納研で行っているガウスフィットは, あらかじめ与えたbaselineと大まかなガウス関数の形 (振幅, 位置, 幅) でフィットをします. そのため, まずはフィットのための初期値を与える必要があります.  
初期値はグラフの形を見ながら定義します. 解析虎の巻などで, 便利な定数が書いてあったりします.  
例えば, CH regionを6つのガウスでフィットする場合の定数の数は, 2 (baseline) + 3 (gauss) * 6 = 20個となります.
```Igor
make/O/N = 20 wcoef
	//適当にwcoefという名前にしています. 
wcoef = {0, 0 ,0.5, 2850, 10, 0.9, 2870, 10, 0.5,2930, 10, 0.3, 2950, 10, 0.5, 2910, 10, 0.2, 3000, 10}  
	//適当に, ピークを見ながら値を代入します
	//最初の2つは0で良くなりました (次のinitial fit中にベースラインも変更してくれます)  
```

3. Initial fit  
次に, fitする範囲を決めて, initial fitをします.  
この時に, ガウスの位置や幅, ベースラインを決めています
カーソル (ctrl + i) でfitしたい領域の高波数側と低波数側に置きます.  
<img width="852" alt="im3" src="https://user-images.githubusercontent.com/59829168/112760653-c3a3f980-9032-11eb-88be-84798bdabd93.png">  
この状態で, コマンド (ctrl + j)から initialfitを実行します.  
```Igor
InitialFit(wv, wcoef)
	//wvは平均スペクトル (グラフ化したもの) の名前です. 
	//temp00という名前以外でも大丈夫です
``` 
fitがうまくいくと, このようになります.  
(わかりやすいように, fitした曲線を青色に変えています. やり方はグラフをダブルクリックして色変更です. )
<img width="852" alt="im4" src="https://user-images.githubusercontent.com/59829168/112760654-c3a3f980-9032-11eb-8fe6-4fd138678481.png">  

4. Fit Imageの作成
Fitがある程度うまくいったら, Fit imageを作成します.  
```Igor
MakeFitImages(wv,wcoef, zNum)
	//最初の引数はfit したい4次元waveの名前 (例 imchi3_data)
	//2つめはパラメータを入れたwaveの名前 (ここでは wcoef)
	//3つめはz方向の枚数-1 (z stackしていないなら0)
```
----

## z stack時のfitと画像表示について  
z stackで何枚かとった場合, そのままmemをかけることができます.  
そのままfitも3次元でかけることができます.  
やり方は上記と同じですが, 最後のMakeFitImagesで5つ目の引数をz stackの枚数-1とします (5枚撮った時は4としてください.)  
出力される画像はFitImage1Z0のような名前になります.  
最初の数字はいくつ目のガウスでフィットしたかを示し, Zの後の数字はz stack何枚目かを示します. 　


----
## Image Chunkの作り方  
上記のMakeFitImagesはfitの都度, 画像を生成します. 連続していくつかfitしているとよくわからなくなることがあったので, 
fit結果をchunkにして返す関数を作りました.  
```Igor
MakeFitImageChunk(wv,wcoef, zNum)
	//最初の引数はfit したい4次元waveの名前 (例 imchi3_data)
	//2つめはパラメータを入れたwaveの名前 (ここでは wcoef)
	//3つめはz方向の枚数-1 (z stackしていないなら0)
```  
上記を実行すると画像は作成されずFitImageChunkというwaveのみが作成されます. 
このFitImageChunkは4次元waveで (x,y,z,GaussNum)です. 
GaussNumは何番目のガウスフィットかという意味です.  
例えば1660, 1680で4枚のz stack, X=101, y=301のデータをフィットした場合には(101, 301, 4, 2)
となります. 1チャンク目を取り出せば1660fitのZ stack imageとなっています. 

----
## ピーク位置フィット
ガウスの振幅ではなく, 中心位置で画像作成  
以前のmakefitimagemsからの派生なので, 最新版と統合はしていない.
(baseline fit等が必要になっている)
近日修正
```Igor
MakeFitImagePeak(frompix, endpix, gausNum, wcoef, zNum)
```  