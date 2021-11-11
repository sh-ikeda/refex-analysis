# refex-analysis

Usage:
```
$ docker run --rm -v /path/to/data:/data -w /data shikeda/refex-analysis \
    Rscript /work/refex-analysis/script/deg.r --g1 <sample group IDs 1> --g2 <sample group IDs 2> \
    -i <count table file> -m <mapping table file> -o <output table file> --l1 <label1> --l2 <label2>
```
