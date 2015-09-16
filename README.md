# bashで変数宣言漏れをなくすためのチェックスクリプト

## 例
### 前提
```
MacBookAir:ruby hoshito$ tree .
.
├── README.md
├── bash_val_check.rb
└── test
    ├── memo.sh
    └── test_child
        └── memo_child.sh

2 directories, 4 files
```
```
MacBookAir:ruby hoshito$ cat test/memo.sh 
A_VAL=222

a ${A_VAL} b
b ${B_VAL} c

${D_VAL} c
D_VAL=22

```
```
MacBookAir:ruby hoshito$ cat test/test_child/memo_child.sh 
B_VAL=222
b $C_VAL c
```
この場合, C_VALはどこにも宣言されていないのでエラー. D_VALは使用箇所と宣言箇所の行が逆転しているが, 必ずしもエラーとはいえないため（関数によって逆転はありえる）???を出力.

### 実行
```
MacBookAir:ruby hoshito$ ruby bash_val_check.rb 
A_VAL: 
  SAFE : {"sengen_file"=>"/Users/hoshito/ruby/test/memo.sh", "sengen_line_num"=>1}, {"use_file"=>"/Users/hoshito/ruby/test/memo.sh", "use_line_num"=>4}
B_VAL: 
  WARN : {"sengen_file"=>"/Users/hoshito/ruby/test/test_child/memo_child.sh", "sengen_line_num"=>1}, {"use_file"=>"/Users/hoshito/ruby/test/memo.sh", "use_line_num"=>5}
D_VAL: 
  ??? : {"sengen_file"=>"/Users/hoshito/ruby/test/memo.sh", "sengen_line_num"=>9}, {"use_file"=>"/Users/hoshito/ruby/test/memo.sh", "use_line_num"=>8}
C_VAL: 
  ERROR : {"use_file"=>"/Users/hoshito/ruby/test/test_child/memo_child.sh", "use_line_num"=>2}
```

## 改良点
- 環境変数に対応したほうが良い
