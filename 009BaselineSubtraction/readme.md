## スペクトルからベースラインを引き算する方法  
一般に (Ramanに限らず) 取得されたスペクトルにはベースラインが乗っています。  
今まで特段気にせずに解析をしていましたが、まがいなりにも定量をしようとするなら必要だと思います。  
また、MCR-ALSで解析する場合には、 ベースラインを引いておかないとベースラインのぐらつきでコンポーネントが別れてしまって、
見たいものが見えなくなる時がありますので、要注意です。

なお、ここで紹介する手法は2015年 Analyst にpublishされた手法をigorで実装したものになります。
https://pubs.rsc.org/en/content/articlehtml/2015/an/c4an01061b  
Baseline correction using asymmetrically reweighted penalized least squares smoothing

0. 用意するもの
   1. BLSubArPLS.ipf
   2. Data (1D or 2D) (imchi3_dataのような4次元waveはそのままでは計算できないのでwave4dto2dを使って2次元にすること)
1. 以下を実行します 
```Igor
BLSubArPLS(wave)
//ここでwaveはベースラインを引きたいデータ
```  
2. しばらく待つと (1点の場合には一瞬、101*101で10分程度 PC依存)
wave_blsubというwaveが作成されるのでそちらを用いてのちの解析を行う。