# Igor8 functions
このレポジトリは, 加納研究室で使うIgor8の関数をまとめたものです.  

## 関数の種類

1. MEM related functions  
MEM (maximum entropy method) 関連の関数です.  

2. Average functions  
MEM後のデータで, 領域平均スペクトルを得るための関数です.  

3. Fitting functions  
MEM後のスペクトルをガウスフィットして, 画像化したりするための関数です.  

4. Other functions  
その他の関数です.  

---
## Igorインストールについて (from Igorインストール虎の巻, modified by Miyazaki)
マイドキュメント→wavemetrics→Igor Pro8 User Filesという名でフォルダ作成(この中にigor8インストール)  
google ドライブ→研究室共用ソフト→igor8をダウンロード→全て展開→setupIgor8開いて進んでいきinstallまで進む(上のフォルダに保存)  
MEMを実行するには以下も必要  
MEM最新→64bit対応コード.zip→ダウンロード  
これマイドキュメントのIgor Pro8 User Filesの該当するところに入れていく  

Igor Extension(64-bit)→そのままコピペ  
User Procedure→そのままコピペ  
IgorProcedure →CARS_GenerateTileImage, CARS_GenerateTileImagePMT, mem_approximate, MM procedures, Other_fitのみ移動  


---
# License
The source code is licensed MIT. The website content is licensed MIT license.
