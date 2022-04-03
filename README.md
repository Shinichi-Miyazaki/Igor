# Igor8 functions
このレポジトリは, 加納研究室で使うIgor8の関数をまとめたものです.  


---
## Igorインストールについて (from Igorインストール虎の巻, modified by Miyazaki)
1. マイドキュメント→wavemetrics→Igor Pro8 User Filesという名でフォルダ作成(この中にigor8インストール)  
2. google ドライブ→研究室共用ソフト→igor8をダウンロード  
3. 全て展開→setupIgor8開いて進んでいきinstallまで進む(上のフォルダに保存)  
4. MEMを実行するには以下も必要  
5. google drive上のMEM最新→64bit対応コード.zip→ダウンロード  
6. 以下に従って, マイドキュメントのIgor Pro8 User Filesの該当するところに入れていく  

Igor Extension(64-bit)→そのままコピペ  
User Procedure→そのままコピペ  
IgorProcedure →CARS_GenerateTileImage, CARS_GenerateTileImagePMT, mem_approximate, MM procedures, Other_fitのみ移動  

---
## 関数の種類

1. MEM related functions  
MEM (maximum entropy method) 関連の関数です.  

2. Average functions  
MEM後のデータで, 領域平均スペクトルを得るための関数です.  

3. Fitting functions  
MEM後のスペクトルをガウスフィットして, 画像化したりするための関数です.  

4. Ratiometric_analysis  
強度比を用いて解析を行う際に使用する関数です.  

5. IgorTips  
Igorの便利技等を書いていきます.   

6. ImagePlot  
Image plot用の関数を置いてあります. 

7. OtherFunctions  
その他関数, 古い関数などです.

8. GUI  
Imchi3_dataの解析用GUIです. マニュアルはpdf参照

9. BaselineSubtraction
Baseline引き算用の関数です

---
## 関数作成時のルール  
1. 関数名  
関数名は機能を表した名前を付け, 一般的な名前は避ける.  
(良くない例)  
Wave2Dto4D_MS (MSは私の名前だが, 書いてあっても何もわかりやすくない)  
(良い例)  
WaveTransformer2Dto4D  
作成者や作成日時は関数内のコメントに記載し, 可能な限り関数名には入れない (Miyazakiなどと入れても関数名はわかりやすくはならないため)  

2. コメント
関数を定義したら下に, ///で初めるコメントを記載する.  
記載内容としては, 何をする関数であるのか, 誰が記載した (更新した) のか, いつ更新したのか, パラメータは何か. 注意点など  
コメントは基本は英語, 日本語も可能とする. (記載のハードルを下げる, 英語で書きにくいくらいなら日本語でもいいからとにかく書いておく) 

3. 記載方法, 命名規則
命名規則はCamelCase (先頭を大文字, WaveNameSelectみたいな感じ)  
コメントアウトしたコードは極力消す.  
定数はなるべく関数の最初に定義を行う.  
マジックナンバー (42-wavenum　のようにみただけではわからない具体的な数値) には必ずコメントをつける 

## License
The source code is licensed MIT. The website content is licensed MIT license.
