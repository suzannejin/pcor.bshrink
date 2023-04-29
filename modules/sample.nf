process SAMPLE {

    tag "${dataset}_${ncell}_${ngene}_${nsamp}"
    
    input:
    tuple val(dataset),
          path(count),
          val(ncell),
          val(ngene),
          val(nsamp)

    output:
    tuple val(dataset),
          val(ncell),
          val(ngene),
          val(nsamp),
          path("count_truth_${ncell}_${ngene}_${nsamp}.csv.gz"),
          path("count_bench-nozero_${ncell}_${ngene}_${nsamp}.csv.gz"),
          path("count_bench-withzero_${ncell}_${ngene}_${nsamp}.csv.gz")

    script:
    """
    sample.R \
        -i ${count} \
        -o1 count_truth_${ncell}_${ngene}_${nsamp}.csv.gz \
        -o2 count_bench-nozero_${ncell}_${ngene}_${nsamp}.csv.gz \
        -o3 count_bench-withzero_${ncell}_${ngene}_${nsamp}.csv.gz \
        --ncell ${ncell} \
        --ngene ${ngene}
    """

    stub:
    """
    echo sample.R \
        -i ${count} \
        -o1 count_truth_${ncell}_${ngene}_${nsamp}.csv.gz \
        -o2 count_bench-nozero_${ncell}_${ngene}_${nsamp}.csv.gz \
        -o3 count_bench-withzero_${ncell}_${ngene}_${nsamp}.csv.gz \
        --ncell ${ncell} \
        --ngene ${ngene}
    touch count_truth_${ncell}_${ngene}_${nsamp}.csv.gz
    touch count_bench-nozero_${ncell}_${ngene}_${nsamp}.csv.gz
    touch count_bench-withzero_${ncell}_${ngene}_${nsamp}.csv.gz
    """
}