process BENCHMARK {

    tag "${dataset}_${ncell}_${ngene}_${nsamp}_${imp_method}_${transf}"

    input:
    tuple val(dataset),
          val(ncell),
          val(ngene),
          val(nsamp),
          val(imp_method),
          path(count_truth), 
          path(count_bench)
    each transf

    output:
    tuple val(dataset),
          val(ncell),
          val(ngene),
          val(nsamp),
          val(imp_method),
          val(transf),
          path("mse_${ncell}_${ngene}_${nsamp}_${imp_method}_${transf}.csv")

    script:
    """
    benchmark.R \
        -i1 ${count_truth} \
        -i2 ${count_bench} \
        -o mse_${ncell}_${ngene}_${nsamp}_${imp_method}_${transf}.csv \
        --transf ${transf} \
        --rlib ${params.rlib}
    """

    stub:
    """
    echo benchmark.R \
        -i1 ${count_truth} \
        -i2 ${count_bench} \
        -o mse_${ncell}_${ngene}_${nsamp}_${imp_method}_${transf}.csv \
        --transf ${transf} \
        --rlib ${params.rlib}
    touch mse_${ncell}_${ngene}_${nsamp}_${imp_method}_${transf}.csv
    """
}
