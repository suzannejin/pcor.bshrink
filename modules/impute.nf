process IMPUTE {

    tag "${dataset}_${ncell}_${ngene}_${nsamp}_${method}"

    input:
    tuple val(dataset),
          val(ncell),
          val(ngene),
          val(nsamp),
          path(count_truth), 
          path(count_bench_nozero),
          path(count_bench_withzero)
    each method

    output:
    tuple val(dataset),
          val(ncell),
          val(ngene),
          val(nsamp),
          val(method),
          path(count_truth), 
          path(count_bench_nozero),
          path("count_bench-withzero_${ncell}_${ngene}_${nsamp}_${method}.csv.gz")

    script:
    """
    impute.R \
        -i ${count_bench_withzero} \
        -o count_bench-withzero_${ncell}_${ngene}_${nsamp}_${method}.csv.gz \
        --method ${method}
    """

    stub:
    """
    echo impute.R \
        -i ${count_bench_withzero} \
        -o count_bench-withzero_${ncell}_${ngene}_${nsamp}_${method}.csv.gz \
        --method ${method}
    touch count_bench-withzero_${ncell}_${ngene}_${nsamp}_${method}.csv.gz
    """
}
