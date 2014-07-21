## 環境

1. JDK1.7/JRE7
2. JRuby 1.7

  インストールは[JRuby](http://jruby.org/getting-started)を参照

3. Gem
* jdbc-postgres

```
gem install jdbc-postgres
```
* jdbc-mysql

```
gem install jdbc-mysql
```

## インストール

```
git clone https://github.com/a1153tm/db_comp.git
```

## Configuration

DB接続情報を設定するだけです。JDBC URL,USER,PWDをdb_comp.rbに記述します。

```ruby:db_comp.conf
redshift.url = "jdbc:postgresql://localhost/test"
redshift.user = "test"
redshift.password = "test"

mysql.url = "jdbc:mysql://localhost/test"
mysql.user = "test"
mysql.password = "test"
```

## Checkfile

チェック事項はCheckfileに記述します。Checkfileに記述する構文は、db_compのDSLに従います。
以下を参考に記述してください。

```ruby:Checkfile
col_date = {name: "col_date", type: :date, nullable: true}
col_timestamp = {name: "col_timestamp", type: :timestamp, nullable: false}

redshift.test1 == mysql.test1
redshift.test1 == redshift.test2
redshift.test1 == mysql.test1 - ["col_date", "col_timestamp"]
redshift.test1 == mysql.test1 - [col_date, col_timestamp]
redshift.test1 + [col_date, col_timestamp] == mysql.test1
redshift.test1 + redshift.test2 == mysql.test1
(redshift.test1 + redshift.test2).sort == mysql.test1.sort
(redshift.test1 + redshift.test2).override({column: "all", nullable: false}) == mysql.test1.override({column: "all", nullable: false})
(redshift.test1 + redshift.test2).override({column: "col_timestamp", nullable: false}) == mysql.test1.override({column: "col_timestamp", nullable: false})
```

### 比較
* '==': レイアウトを完全比較します。カラムの数、名前、型、長さ、Nullable、カラムの順序がすべて一致した場合にtrueと評価されます。

### 計算
* '+': カラムを追加します。LayoutオブジェクトまたはHashの配列を指定できます。
* '-': カラムを削除します。文字列の配列またはHashの配列を指定できます。

### ソート、オーバライド
* sort(): カラムをアルファベット順でソートします。カラムの並びに対処できない場合に使用します。
* override(): カラムの属性(nullable、type、length)を上書きします。

## 実行方法

jruby db_comp

## 結果

以下のような感じです。

```
NG: Redshift.test1 == MySQL.test1
      left: Redshift.test1
         col_char       char      30   true
         col_varchar    varchar   50   true
         col_int        int            true
         col_bool       bool           true
      right: MySQL.test1
         col_char       char      30   true
         col_varchar    varchar   50   true
         col_int        int            true
         col_bool       bool           true
         col_date       date           true
         col_timestamp  timestamp      false
NG: Redshift.test1 == Redshift.test2
      left: Redshift.test1
         col_char       char      30   true
         col_varchar    varchar   50   true
         col_int        int            true
         col_bool       bool           true
      right: Redshift.test2
         col_varchar    varchar   15   true
         col_date       date           true
         col_timestamp  timestamp      false
OK: Redshift.test1 == (calcurated from MySQL.test1)
OK: Redshift.test1 == (calcurated from MySQL.test1)
OK: (calcurated Redshift.test1) == MySQL.test1
OK: (calcurated Redshift.test1) == MySQL.test1
OK: (calcurated Redshift.test1)[sorted] == MySQL.test1[sorted]
OK: (calcurated Redshift.test1)[overridden] == MySQL.test1[overridden]
OK: (calcurated Redshift.test1)[overridden] == MySQL.test1[overridden]
TOTAL:9, OK:7, NG:2
```

