# foodrad

厚生労働省発表の「食品中の放射性物質の検査結果について」を
[三重大の奥村晴彦教授が CSV 化したもの](http://oku.edu.mie-u.ac.jp/~okumura/stat/data/mhlw/)
を MySQL に取り込み、iPhone/Android での利用に適した検索画面を提供します。

このバージョンは 4 月 1 日以前の形式にも対応します。


## 用意するもの

基本的に Debian squeeze のパッケージで揃います。

- Ruby 1.9.2 くらい
  - MySQL/Ruby http://www.tmtm.org/mysql/ruby/
- MySQL 5.1 くらい
- PHP 5.3 くらい
  - mysqli 拡張
- PHP が動く Web サーバ


## インストール

### ソースの入手

ソース一式を入手します。

    $ git clone git://github.com/autch/foodrad.git foodrad

中身はこうなっています。

    foodrad/		チェックアウトしたディレクトリ
    |
    +-- data/		CSV ファイルをダウンロードするディレクトリ
    +-- www/		Web サーバで公開するディレクトリ

data ディレクトリがないときは作っておきます。


### DB の準備

foodrad.sql ファイルを MySQL で実行します。ユーザや DB 名は適当に決めます。

    $ mysql -ufoodrad -p foodrad < foodrad.sql


### 設定ファイルの修正

ユーザのホームディレクトリのような安全なところに、foodrad.json とかい
う名前のファイルを作り、その中に foodrad.sql を実行した時の MySQL ユー
ザや DB 名を書き込みます。

    $ cat /home/autch/.foodrad.json
    {
      "host": "localhost",
      "db": "foodrad",
      "username": "foodrad",
      "password": "XXXXXXXXXXXXXXXXXX"
    }

チェックアウトしたディレクトリにある csv2db.rb を開き、
DBCONFIG_FILENAME という行を検索します。この値をさっき作った
foodrad.json へのフルパスにします。update_db.rb にも同じ行があるので修
正します。

    DBCONFIG_FILENAME = "/path/to/foodrad.json"

同様に www/db.inc.php を開き、DBCONFIG_FILENAME の定数定義を修正します。

    define('DBCONFIG_FILENAME', '/path/to/foodrad.json');


### ディレクトリの公開

www/ ディレクトリを Web サーバで公開します。このディレクトリの中の php
ファイルが実行できるようにしてください。


### データの導入

[http://oku.edu.mie-u.ac.jp/~okumura/stat/data/mhlw/](http://oku.edu.mie-u.ac.jp/~okumura/stat/data/mhlw/) にアクセスし、<b>数字.csv</b> と <b>a数字.csv</b> ファイルをダウンロードしてきます。
これらをたとえば foodrad/data/ ディレクトリに置いたとしましょう。


CSV ファイルをまとめて DB へ入れます。

    $ ./csv2db.rb data/*.csv

例外が出なければ大丈夫なはずです。index.html へアクセスしてみましょう。


## 日頃のデータ更新

csv2db.rb を、新しい CSV ファイルを引数にして実行します。

    $ ./csv2db.rb data/a360.csv

例外が出ないのに複数回実行するとデータがダブります。DB に csv_filename
という列があるのでこれを使って整理することができます。

同様のことを自動的に行う update_db.rb というスクリプトがあります。この
スクリプトと同じディレクトリに data というディレクトリを作り、cron ジョ
ブとして登録すれば自動的に CSV ファイルをダウンロードして DB に変換でき
ます。


## ソースについて

index.html がすべての画面を持ち、都道府県リストや食品カテゴリのリストは
JSON を返すだけの PHP ファイルを呼ぶことで動的に取得します。

PHP ファイルの JSON の返し方を修正することで異なる DB へも対応できるはずです。

各種測定値の ND に対するポリシーは csv2db_inserters.rb の
CSVInserter#set_values に実装しています。

yasaikensa.csv に対応するコードは書いてありますが未確認です。

BSD ライセンスとします。
