# refex-analysis

Usage:
```
$ docker run --rm -v /path/to/data:/data -w /data shikeda/refex-analysis \
    Rscript /work/refex-analysis/script/deg.r --g1 <sample group IDs 1> --g2 <sample group IDs 2> \
    -i <count table file> -m <mapping table file> -o <output table file> --l1 <label1> --l2 <label2>
```

`--g1 <sample group IDs 1> --g2 <sample group IDs 2>`\
`mapping table file` に記述された RefEx Sample ID。 `--g1 RES00001651,RES00001652 --g2 RES00001662,RES00001663` のようにカンマ区切りでの指定が可能。\
これらのグループ間の発現変動遺伝子を計算することになる。

`-i <count table file>`\
raw read count の tsv ファイル名。\
各行が遺伝子で、1 列目(行名)は遺伝子 ID。\
各列がサンプル名で、1 行目(列名)は `mapping table file` に記述された BioSample ID。

`-m <mapping table file>`\
`RefEx_Sample_ID<TAB>BioSample_ID<TAB>Project_Sample_ID` の形式の tsv ファイル。

`-o <output table file>`\
出力ファイル名。任意の文字列。

`--l1 <label1> --l2 <label2>`\
それぞれ `--g1`, `--g2` で指定したグループに対するラベル名。optional であり、指定しない場合は `--g1`, `--g2` で指定したのと同じ文字列になる。
