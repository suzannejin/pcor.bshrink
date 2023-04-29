# Compositional Covariance Shrinkage and Regularised Partial Correlations
This is the code repository for the paper "Suzanne Jin, Cedric Notredame, & Ionas Erb. (2022) Compositional Covariance Shrinkage and Regularised Partial Correlations".

In this repository you can find:
- The data we used for the benchmark. It is a single-cell gene expression dataset generated from a poupulation of asynchronized mouse stem cells (Riba et al., 2022).
   - Inside the folder `data/genes244` you can find the subset of 244 nonzero genes across all cells. This was used to simulate synthetic logistic normal data.
   - Inside the folder `data/genes770` you can find the subset of 770 genes for which 3986 cells out of the total of 5637 cells have no zeros. 
   - Both folders contain the corresponding count matrix `count.csv.gz`, the gene names `features.csv` and the cell barcodes `barcodes.csv`. The count matrix is organized in such a way so that rows are cells and columns are genes.
- The results produced from the synthetic data in `results/genes244`
   
- A R script `bin/benchmark-simulation.R` that we used to produce the results from the synthetic data.
- A Nextflow pipeline that we used to produce the main results with and without imputation. This pipeline has many components:
   - `bShrink.nf`. This is the main script. 
   - `modules` folder contains the Nextflow modules that calls the R scripts stored in `bin`.
   - `nextflow.config`. This is the main config file for Nextflow.
   - `conf` folder contains the rest of config files.
   
To run the Nextflow pipeline, you should:
1) Install Nextflow. Please check https://www.nextflow.io/
2) Install Singularity. This will allow you to run the scripts inside a container with all the preinstalled packages.
3) Run Nextflow pipeline: 
```
nextflow run -profile singularity bShrink.nf
```
Then, you can find the results in `results/genes770`. You can also reproduce the figures from the paper with the `jupyter` notebooks.


# References
Riba, A., Oravecz, A., Durik, M. et al. Cell cycle gene regulationdynamics revealed by RNA velocity and deep-learning. Nat Commun 13, 2865 (2022)