#!/bin/bash

# assumes gnuin is present in running dir

# usage: cluster.sh <pdb name> <top x structures> <radius> <score.sc> <native.pdb> <decoys.silent> <stype=column number of score according to which to select the top x structures>
# e.g. cluster.sh 2FMF 100 1 ../score.sc ../native.pdb ../decoys.silent 2 ---> clusters top 100 by total score with 1A peptide bb rms radius.

name=$1
top=$2
radius=$3
score=$4
native=$5
decoys=$6
stype=$7


#calculate actual clustering radius taking intoaccount protein lenght.
len=`grep " CA " $native | wc -l`
plen=`awk '$5=="B"' $native | grep " CA " | wc -l`
actualR=`date | awk '{print sqrt('$plen'/'$len')*'$radius'}'`
cluster_flag=""

# Correction for if excluding first and last peptide residue from analysis
if [ 1 -eq 0 ]
then
    # First and last reisude of peptide.  We assume peptide comes at end of PDB file.
    first_peptide_res=$((len - plen + 1))
    last_peptide_res=$len
    plen=$((plen - 2))
    len=$((len - 2))
    actualR=`date | awk '{print sqrt('$plen'/'$len')*'$radius'}'`
    cluster_flags="-exclude_res $first_peptide_res $last_peptide_res"
fi

score_col=$(awk -F' ' -vfield=reweighted_sc 'NR==1{for(i=1;i<=NF;i++){if($i==field){print i;exit}}}' $score)
desc_col=$(awk -F' ' -vfield=description 'NR==1{for(i=1;i<=NF;i++){if($i==field){print i;exit}}}' $score)

#send clustering run
cluster.linuxgccrelease -in:file:silent $decoys -in:file:silent_struct_type binary -cluster:radius $actualR -in:file:fullatom -tags `cat $score | tail -n +2 | sort -nrk $score_col | tail -n $top | tr -s ' ' | cut -d ' ' -f $desc_col` -silent_read_through_errors $cluster_flags > clog

topW5=$(($top + 5))
  
#join by score.  New code finds last "Clusters:" output in clog, and then extracts clusters after that
tac clog |  sed '/Clusters: /q'  | tac | sed -e '1,3d' | head -n -5 | awk '{print $3, $4, $5 }' | sort -nk2 | sort -k 1b,1 > tmp.listA
# Join by score.  Old code just assumed we have exactly $top entries after last "Clusters:" output in clog, which does not always seem to be the case.
# tail -n $topW5 clog | head -$top | awk '{print $3, $4, $5 }' | sort -nk2 | sort > tmp.listA
cat $score | tail -n +2 | awk -vfield1=$desc_col -vfield2=$score_col '{print $field1, $field2}' | sort -k 1b,1 > tmp.listB
# Keep only best member of each cluster.
echo "description cluster cluster_idx reweighted_sc" > clusters
join -1 1 -2 1 tmp.listA tmp.listB | sort -nk2 -k 4 | awk 'BEGIN{cur=0}{if(cur==$2){print; cur++;}}' | sort -nk 4 >> clusters
# All members of each cluster.
echo "description cluster cluster_idx reweighted_sc" > cluster_members
join -1 1 -2 1 tmp.listA tmp.listB | sort -nk4 >> cluster_members

# rm -rf tmp.list*
