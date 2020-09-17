#!/bin/bash
#SBATCH --partition rondror
#SBATCH --mail-type=FAIL
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=1
#SBATCH --ntasks=1
#SBATCH --time=12:00:00

RECEPTOR_NAME=$1
NAME=$2
ROOT_DIR=$3

module load python/2.7.13

# Extract scores
cd $ROOT_DIR/docking
cat decoys.silent | grep SCORE > decoys.sc

# Cluster
mkdir -p $ROOT_DIR/cluster
cd $ROOT_DIR/cluster
bash ../../../src/cluster.sh ${RECEPTOR_NAME}_${NAME}_prepack 500 2 ../docking/decoys.sc ../prepack/${RECEPTOR_NAME}_${NAME}_prepack.pdb ../docking/decoys.silent reweighted_sc

# Extract representative PDBs
mkdir -p $ROOT_DIR/selected
cd $ROOT_DIR/selected
extract_pdbs.linuxgccrelease -in::file::silent $ROOT_DIR/docking/decoys.silent -tags `cat ../cluster/clusters  | tail -n+2 | head -n 10 | tr -s ' ' | cut -d ' ' -f 1` -out::prefix ./

# RMSD
mkdir -p $ROOT_DIR/rmsd
cd $ROOT_DIR/rmsd
BEST=`cat ../cluster/clusters | sort -r -n -k 4 | tail -n 1 | cut -d ' ' -f 1`
score_jd2.linuxgccrelease -in:file:native ../selected/${BEST}.pdb -in:file:silent ../docking/decoys.silent
tail -n +2 score.sc | tr -s ' '  |  awk '{print $58, $4 }' | sed 's/_0001 / /g' > rmsds

# Analysis
mkdir -p $ROOT_DIR/analysis
cd $ROOT_DIR/analysis
join -1 1 -2 1 --header ../rmsd/rmsds <(head -n 1 ../cluster/cluster_members && tail -n +2 ../cluster/cluster_members | sort -k 1) > top500
echo "description rms reweighted_sc" > all
join -1 1 -2 1 <(tail -n +2 ../rmsd/rmsds) ../cluster/tmp.listB >> all

source ~/.med15

# ASA
cd $ROOT_DIR/../../src
for file in $ROOT_DIR/selected/*.pdb
do
     python asa.py /share/PI/rondror/software/freesasa/bin/freesasa $file
done
