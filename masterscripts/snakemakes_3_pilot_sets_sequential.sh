#!/bin/bash

snakemake -p -s ~/EukBook/snakefiles/Snakefile_simple_metaeuk_joined -d /mnt/samples/simple -j --use-conda --configfile ~/EukBook/samples_yamls/set_1.yaml --resources mem_mb=120000; 

snakemake -p -s ~/EukBook/snakefiles/Snakefile_simple_metaeuk_joined -d /mnt/samples/simple -j --use-conda --configfile ~/EukBook/samples_yamls/set_2.yaml --resources mem_mb=120000;

snakemake -p -s ~/EukBook/snakefiles/Snakefile_simple_metaeuk_joined -d /mnt/samples/simple -j --use-conda --configfile ~/EukBook/samples_yamls/set_3.yaml --resources mem_mb=120000;

