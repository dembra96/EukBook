# This is script to update metaeuk to a certain GitHub version.
# Script is designed to be called directly once(!) on each node, not with a sbatch command.
# On the master node run:
#    for i in {1..25}; do ssh $(node $i) ' source ~/.profile; metaeuk; cd;
#       mv metaeuk metaeuk_alpha;
#       wget https://mmseqs.com/archive/d49cd731e4241abfae11004b0d6da5cf3c515297/metaeuk-linux-avx2.tar.gz;
#       tar xzvf metaeuk-linux-avx2.tar.gz;
#	rm metaeuk-linux-avx2.tar.gz;
#       source ~/.profile; metaeuk;' ;
#    done



