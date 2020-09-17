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

CLUSTER_DIR=$ROOT_DIR/cluster
RMSD_DIR=$ROOT_DIR/rmsd
ANALYSIS_DIR=$ROOT_DIR/analysis
SELECTED_DIR=$ROOT_DIR/selected

module load python/2.7.13

# Extract scores
cd $ROOT_DIR/docking
cat decoys.silent | grep SCORE > decoys.sc

# Cluster
mkdir -p $CLUSTER_DIR
cd $CLUSTER_DIR
bash ../../../src/cluster.sh ${RECEPTOR_NAME}_${NAME}_prepack 500 2 ../docking/decoys.sc ../prepack/${RECEPTOR_NAME}_${NAME}_prepack.pdb ../docking/decoys.silent reweighted_sc

# Extract representative PDBs
mkdir -p $SELECTED_DIR
cd $SELECTED_DIR
extract_pdbs.linuxgccrelease -in::file::silent $ROOT_DIR/docking/decoys.silent -tags `cat $CLUSTER_DIR/clusters  | tail -n+2 | head -n 10 | tr -s ' ' | cut -d ' ' -f 1` -out::prefix ./

# RMSD
mkdir -p $RMSD_DIR
cd $RMSD_DIR
BEST=`cat $CLUSTER_DIR/clusters | sort -r -n -k 4 | tail -n 1 | cut -d ' ' -f 1`
score_jd2.linuxgccrelease -in:file:native $SELECTED_DIR/${BEST}.pdb -in:file:silent ../docking/decoys.silent
tail -n +2 score.sc | tr -s ' '  |  awk '{print $58, $4 }' | sed 's/_0001 / /g' > rmsds

# Analysis
mkdir -p $ANALYSIS_DIR
cd $ANALYSIS_DIR
join -1 1 -2 1 --header $RMSD_DIR/rmsds <(head -n 1 $CLUSTER_DIR/cluster_members && tail -n +2 $CLUSTER_DIR/cluster_members | sort -k 1) > top500
echo "description rms reweighted_sc" > all
join -1 1 -2 1 <(tail -n +2 $RMSD_DIR/rmsds) $CLUSTER_DIR/tmp.listB >> all

source ~/.med15

# ASA
cd $ROOT_DIR/../../src
for file in $SELECTED_DIR/*.pdb
do
     python asa.py /share/PI/rondror/software/freesasa/bin/freesasa $file
done
