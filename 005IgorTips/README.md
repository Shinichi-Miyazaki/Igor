## Igor便利技  
ここでは, Igorで便利な技を紹介します.  

### グラフスタイルマクロ  
Igorにはグラフスタイルマクロという, 複数の似たグラフを作る際に便利な機能があります.  
これは, 一つ作ったグラフから, そのスタイル (軸やラベル, 色などの情報) のマクロを作成して, ほかのグラフに適応できるという機能です.  
例えば, 以下の左のグラフのようなスタイルを, 右のグラフに適応したいとします.  
<img width="960" alt="im6" src="https://user-images.githubusercontent.com/59829168/112761243-65c4e100-9035-11eb-8d53-e4f30c0d86f1.png"> 
windowからcontrolを選択すると, 以下のような画面が出てきます.  
style macroにチェックして, OKを押します.  
<img width="960" alt="im7" src="https://user-images.githubusercontent.com/59829168/112761244-665d7780-9035-11eb-81dc-bea1ae2ece7a.png">
<img width="960" alt="im8" src="https://user-images.githubusercontent.com/59829168/112761245-665d7780-9035-11eb-89bb-83c5e331d9bb.png">

次にwindow/graph macroを押すと先ほどの作成したmacroが使用できます.  
(ここで, styleを適応したいグラフをアクティブにしている必要があります.　一回クリックしてから上記操作をすると安心です.)
<img width="960" alt="im9" src="https://user-images.githubusercontent.com/59829168/112761242-6493b400-9035-11eb-88d8-ca9fedb8b8df.png">  


---

### 複数のプロットに別の色を付ける  
ここでは, 一つのグラフに複数のプロットをした際の便利な機能を紹介します.  
まずは適当にwaveを作ります.  
<img width="960" alt="image0" src="https://user-images.githubusercontent.com/59829168/115130596-e15df080-a02b-11eb-885d-f3c5b35efc99.png">
例として5つのグラフに色を付けてみます. このようにWindow/new graphで出てくるウィンドウから, y waveを複数選択してdo itで複数プロットを一つにまとめることができます.  
<img width="960" alt="image1" src="https://user-images.githubusercontent.com/59829168/115130597-e1f68700-a02b-11eb-9d0d-aa4699740eb9.png">
最初に出てくるグラフはこのように, 全て同じ色になっています.  
<img width="960" alt="image2" src="https://user-images.githubusercontent.com/59829168/115130599-e28f1d80-a02b-11eb-871e-fb7ade50be08.png">
この状態で, Graph/Packages/make traces differentを選択します.  
<img width="960" alt="image2 5" src="https://user-images.githubusercontent.com/59829168/115130598-e1f68700-a02b-11eb-98b9-5cf38b4990b9.png">
ポップアップするウィンドウの中の, Colors Quick Setで好きなカラーセットをSet Traces To のコンボボックスから選びます. (ここではRainbowにしています)  
その後, commonly used colorsをクリックするとこのようにプロットに色がつきます.  
<img width="960" alt="image4" src="https://user-images.githubusercontent.com/59829168/115130601-e327b400-a02b-11eb-97d4-f87cdd7830c6.png">
ちなみに, 上のLine styles quick setをクリックするとこのように実線や点線などを変えることができます.  
<img width="960" alt="image5" src="https://user-images.githubusercontent.com/59829168/115130602-e327b400-a02b-11eb-9c75-d13e1dc852ff.png">


---
### 複数プロットの平均値とsd (or se, 95% CI)をプロットする  
こちらはあまり使わないかもしれませんが, 念のために  
上記で紹介したような, 複数プロットが表示されている状態で, (正確にはプロットしておく必要はないですが) Analysis/Pakages/Average Wavesを選択します.  
<img width="960" alt="image6" src="https://user-images.githubusercontent.com/59829168/115130603-e3c04a80-a02b-11eb-812a-65ce1e36b3ad.png">
出現するウィンドウでOutput Wavesの中で, デフォルトではConfidence Intervalとなっている部分を変更すると, エラーバーを変更できます.  
<img width="960" alt="image7" src="https://user-images.githubusercontent.com/59829168/115130604-e3c04a80-a02b-11eb-946f-47c75e99d613.png">
この状態で, Do itをクリックすると平均とエラーバーのwaveが生成されます.  
次にNew graphをクリックすると先に得たwaveでグラフが生成されます.  
<img width="960" alt="image8" src="https://user-images.githubusercontent.com/59829168/115130595-e0c55a00-a02b-11eb-85b7-d6f2cef3ffba.png">

### 箱ひげ図, バイオリンプロットで一つ一つの系列を塗分ける
実はこれはマニュアルにも記載ありません.  
(Igorがカテゴリプロットを苦手としているのは, 作り手があまりカテゴリプロットを使ったことがなかったかららしいです. )
-> Igor pro9で実装とのこと, 需要があれば記載予定

---

## Igor redimensionの挙動について  
Igor のredimensionは便利そうだが, 挙動がよくわからなかったのでメモ  

```igor
•make/o/n=6 test = p
•redimension/n = (1,2,3) test
```

これは, 0,1,2・・・と続くtestという名前の1次元waveを3次元に変換している.  
![image](https://user-images.githubusercontent.com/59829168/139604611-9f889f68-07bc-4fbf-ab37-a5d582083e31.png)  
から  
![image](https://user-images.githubusercontent.com/59829168/139604620-af9a07f0-a15d-469e-b585-4c0656a72e68.png)
![image](https://user-images.githubusercontent.com/59829168/139604625-c2ed892e-36db-4ce0-9d28-19a5daad1d35.png)  
へ  
変換後は1行2列3レイヤの行列で, 数値はきちんと保持されている. 望ましいredimensionの挙動  
しかし次元の総数があっていても以下はうまくいかない  
```igor
•redimension/n = (1,2,3) test 
•redimension/n = (1,3,2) test
```  
![image](https://user-images.githubusercontent.com/59829168/139604678-e8dea93f-c24a-4dbd-9576-b4754e0dec91.png)  
見ての通り, 3列目が0で埋められている.  
このように, redimensionを成功させるには, 次元総数があっているだけではなく, 移動先の次元が元の次元と同じデータ点数か多くないとデータが0で埋められてしまう.  

---
## Baseline fitの導入方法

1. 以下よりUpdaterというファイルをダウンロード  
https://www.wavemetrics.com/project/Updater  
Updaterは有志が作ってくれたファイルで、Igor Exchangeにアップされたプロジェクトを直接手元のIgorに入れられるようになります
アップデートがIgor上でできるようになるのでとても便利


3. ダウンロードしたファイルを以下の場所に移動  
Documents/Wavemetrics/Igor Pro 8 User Files/Igor Procedures


5. Igor を開くと、以下の画像のようにMisc内にIgorExchange Projectsという項目ができているので、こちらをクリック
![image2](https://user-images.githubusercontent.com/59829168/177090909-48a1043a-23d7-4d6d-9503-11b5c0c1aac5.png)

6. 開くウィンドウの中のFilterというところに"baseline"と打つと以下が出るので、Baseline fittingを選んでインストール
![image1](https://user-images.githubusercontent.com/59829168/177090945-342592f6-edf7-4bab-8846-b9792b59427e.png)

7. あとは、ベースラインフィットをしたいグラフを開いて、Analysis/Baseline

8. GUIに従って解析して、Subtractを押すと元のwaveの名前に_subがついたwaveが引き算後のwaveとして保存される。
![image3](https://user-images.githubusercontent.com/59829168/177090865-cad436bb-91c5-46d8-951a-5e39b90bb78f.PNG)

9. parameter は spline, arc hull, 1~2程度がおすすめ
![image4](https://user-images.githubusercontent.com/59829168/177090831-e6c30205-460e-4681-a24a-554e46094571.PNG)

---
## 解析虎の巻よりフィット時の初期値まとめ  
ここでは, fit時に有用な数字を紹介します.  
元は解析虎の巻というファイルです (どなたが作ったかはわかりません)  
fit時に, wcoefという名前のwaveを作って, 以下の数字を代入するとfitがうまくいきやすいです (必ずうまくいくとは限りません)

#### OH region  
3つのガウス
```Igor
wcoef = {0.5,-0.0001, 0.5 ,3670,100,1.7, 3400,150, 1,3200,100}
	//baselineの値は適当です
```

#### aromatic CH   
1つのガウス
```Igor
wcoef={ -0.277265,0.00012024,0.1,3065,5}
	//baselineの値は適当です
```

#### 1755と1650  
2つのガウス
```Igor
wcoef={0.0075,0.00001,0.01,1742,13.1,0.1,1656,14}
	//baselineの値は適当です
```

#### CH region  
2614~2872
```Igor
wcoef={-2.71478,0.00102714,0.04,2850,8.45146,0.12,2868.28,10,0.09,2770,10,0.372906,2713,10,0.152805,2661.95,10.3172,0.35006,2690.4,13.694}
	//baselineの値は適当です
```


#### 1450  
2つのガウス
```Igor
wcoef={-0.31,0.0001,0.1,1455,13,0.1,1435,12}
	//baselineの値は適当です
```
#### 1400-1200のフィット  
3つのガウス
```Igor
wcoef={0.0036,0.000005,0.008,1303,6.8,0.02,1281,74,0.01,1264,10}
	//baselineの値は適当です
```


