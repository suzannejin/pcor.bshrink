#!/usr/bin/env nextflow

nextflow.enable.dsl = 2


////////////////////////////////////////////////////
/* --          VALIDATE INPUTS                 -- */
////////////////////////////////////////////////////


Channel
    .fromPath(params.count, checkIfExists:true)
    .map{ it -> [it.getParent().getName(), it] }
    .set{ ch_count }
Channel
    .fromList(params.ncell)
    .set{ ch_ncell }
Channel
    .fromList(params.ngene)
    .set{ ch_ngene }
Channel
    .of(1..params.nsamp)
    .set{ ch_nsamp }
ch_count
    .combine(ch_ncell)
    .combine(ch_ngene)
    .combine(ch_nsamp)
    .set{ ch_input }


///////////////////////////////////////////////////////////////
/* --          IMPORT LOCAL MODULES/SUBWORKFLOWS          -- */
///////////////////////////////////////////////////////////////

include { SAMPLE    } from './modules/sample.nf'
include { IMPUTE    } from './modules/impute.nf'
include { BENCHMARK } from './modules/benchmark.nf'



workflow {

    // sample genes and cells
    SAMPLE(ch_input)

    // impute zeros
    IMPUTE(SAMPLE.out, params.imputation)

    // benchmark
    SAMPLE.out
        .map{ it -> [ it[0], it[1], it[2], it[3], 'None', it[4], it[5] ] }
        .set{ch_bench_nozero}
    IMPUTE.out
        .map{ it -> [ it[0], it[1], it[2], it[3], it[4], it[5], it[7] ] }
        .set{ch_bench_withzero}
    ch_bench_nozero
        .mix(ch_bench_withzero)
        .set{ch_bench}
    BENCHMARK(ch_bench, params.transformation)
    
}