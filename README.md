# EukBook
Global search for novel Eukaryotic proteins in public metagenomic data using MetaEuk


Sample accessions must be passed to snakamekae via command line option:
snakemake [options] --configfile path/to/samples/yaml

samples.yaml file should look like:

SAMPLESET: set1
SAMPLE:
   - SRR5918406
   - SRR5788362
   - SRR5788367
   - ...

In future, an additional script will be able to create separate sample_setxx.yaml files from a text file with a list of accessions.
