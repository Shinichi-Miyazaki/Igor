## MCR-ALS by Igorの開発

### 5/17までのまとめ
MCR-ALSを実装するために、pyMCRを読んだところ、まずはNNLSを実装する必要がありそうであった。   
そのため"A FAST NON-NEGATIVITY-CONSTRAINED LEAST SQUARES ALGORITHM" (Bro and Jong, 1997)
を参考に実装中  
テストデータで実行までは可能となった。  
現状は論文中に存在するfast algorithmではなく、1995の論文に出てくる手法のまま

**解が一致していないので改善が必要**

NNLSを実装した後に必要な手順として、スペクトルデータをこれに導入できるように変更
加えて、解の形式を指定

検証としては、IgorとPythonでNNLSして、答えが一致するかどうかを検証予定

PvecとRvecの扱い方が異なっているので、こちらを合わせたい。  
Z_waveはL x M  
Pvecは"未固定の"変数たち  
Rvecは0に固定されている変数  
初期値はPは空集合、Rは1, 2, 3, ・・・M  
となっているが、Igor proでは空集合を定義できないので、代わりに0番目に0を入れておく  
対応をとるためにRvecも0番目に0

dはMx1のベクタ
初期値はすべて0

wもMx1のベクタ