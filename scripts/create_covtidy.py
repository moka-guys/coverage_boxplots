#!/usr/bin/env python3
"""create_covtidy.py

Create data for covearge app from chanjo output files. Requires a file mapping HGNC symbols mapped
to Entrez Gene IDs which is available from genenames.org or from the moka.GenesHGNC_current table.

Example:
./create_covtidy.py -s symbol_entrez_hgnc.txt -f *.chanjo_txt
Outputs:
    covtidy.txt - Percentage coverage above 20X for each gene in each sample. Used in CovApp.
    covtidy_genes.txt - A list of unique genes in all samples. Used in CovApp.
    covtidy_median.txt - The median percentage coverage above 20X for each gene across all samples. Used to update moka table NGSWESCoverageByGene.
""" 

# Read CLI
import argparse
import pandas as pd
import numpy as np
import pathlib

def parsed_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--gene-entrez', '-s',
        help="A file linking HGNC symbols to Entrez Gene IDs. Available from moka.GenesHGNC_current or genenames.org",
        required=True)
    parser.add_argument('--chanjo-files','-f', required=True, nargs='+')
    parsed = parser.parse_args()
    return parsed
    
def chanjo_transformer(cfile):
    """Transform a chanjo text file to data columns: entrez, above20X, Sample
    
    Args:
        cfile(str): Chanjo text file
    Returns:
        df(pandas.DataFrame): A dataframe containing chanjo sample data
    """
    df = pd.read_csv(
        cfile, header=None, names=["entrez", "above20X", "average"],
        usecols=['entrez', "above20X"], delimiter='\t'
    )
    df['Sample'] = pathlib.Path(cfile).name.split('_')[2]
    return df

def main():
    args = parsed_args()
    # Read files from command line
    cfiles = args.chanjo_files
    symbol_gene_entrez = pd.read_csv(
        args.gene_entrez, # Entrez mapping file passed as -s on command-line.
        header=None,
        names=['Gene','entrez', 'hgnc']
    )

    # Build table from processed chanjo outputs. Table contains sample, coverage and
    # genes as entrez ids.
    cfiles_clean = ( chanjo_transformer(cfile) for cfile in cfiles )
    cfiles_concat = pd.concat(cfiles_clean, axis=0, ignore_index=True)

    # Convert entrez ids to gene symbols. This is covtidy.txt, a dataset for CovApp
    gene_entrez = symbol_gene_entrez[['Gene','entrez']]
    covtidy = pd.merge(cfiles_concat, gene_entrez, how='inner', on='entrez')
    # Get unique genes for outputs. This is covtidy_genes.txt, a dataset for CovApp
    covtidy_genes = pd.Series(covtidy.Gene.unique()).sort_values()

    # Get median percentage above20X for each gene.
    # This is covtidy_median.txt, a dataset for moka NGSWESCoveragebyGene table
    covtidy_median_long = covtidy.groupby('Gene').median()
    covtidy_median_rounded = covtidy_median_long.reset_index().round(2)
    covtidy_median = pd.merge(
        covtidy_median_rounded,
        symbol_gene_entrez[['hgnc','entrez']],
        how='left',
        on='entrez'
    )

    # Write output files to current working directory 
    covtidy.to_csv(
        'covtidy.txt',
        sep='\t',
        columns=['Sample','above20X','Gene'],
        header=True,
        index=False
    )
    covtidy_genes.to_csv('covtidy_genes.txt', header=False, index=False)
    covtidy_median[['Gene','above20X','hgnc']].to_csv('covtidy_median.txt', header=False, index=False)

if __name__ == "__main__":
    main()
