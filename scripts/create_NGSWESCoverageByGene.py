#!/usr/bin/env python3
"""create_NGSWESCoverageByGene.py

Convert data from covtidy.txt into a CSV containing the median coverage above 20X for each gene. This data is used to populate the moka NGSWESCoverageByGene database.

Usage:
    ./ create_NGSWESCoverageByGene.py covtidy.txt
Output:
    covtidy_median.txt:
        A1BG,100.0
        A1BG-AS1,32.53454262672811
        A1CF,100.0
        ...............
"""
import sys
import pandas as pd

covtidy = pd.read_csv(sys.argv[1], delimiter='\t', usecols=['Gene', 'above20X'])
covtidy_median = covtidy.groupby('Gene').median()
covtidy_median.to_csv('covtidy_median.txt', header=False)
