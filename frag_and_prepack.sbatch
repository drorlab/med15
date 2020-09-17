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
RECEPTOR_LENGTH=$4

module load python/2.7.13

# Fragments
mkdir -p $ROOT_DIR/fragments
cd $ROOT_DIR/fragments
$ROSETTA3/tools/fragment_tools/make_fragments.pl -verbose ../start_files/$NAME.fasta
if [[ $? -ne "0" ]]
then
    exit 1
fi

fragment_picker.linuxgccrelease -in:file:vall $ROSETTA3/tools/fragment_tools/vall.jul19.2011 -in:file:checkpoint t001_.checkpoint  -frags:scoring:config  $ROSETTA3/demos/public/abinitio_fold_and_dock_of_peptides_using_flexpepdock/fragment_picking/psi_L1.cfg -frags:frag_sizes 3 5 9 -frags:n_candidates 2000 -frags:n_frags 50 -frags:ss_pred t001_.psipred_ss2 psipred -frags:bounded_protocol true
if [[ $? -ne "0" ]]
then
    exit 1
fi

$ROSETTA3/demos/public/abinitio_fold_and_dock_of_peptides_using_flexpepdock/fragment_picking/shift.sh frags.50.3mers $RECEPTOR_LENGTH > frags.3mers.offset
if [[ $? -ne "0" ]]
then
    exit 1
fi
$ROSETTA3/demos/public/abinitio_fold_and_dock_of_peptides_using_flexpepdock/fragment_picking/shift.sh frags.50.5mers $RECEPTOR_LENGTH > frags.5mers.offset
if [[ $? -ne "0" ]]
then
    exit 1
fi
$ROSETTA3/demos/public/abinitio_fold_and_dock_of_peptides_using_flexpepdock/fragment_picking/shift.sh frags.50.9mers $RECEPTOR_LENGTH > frags.9mers.offset
if [[ $? -ne "0" ]]
then
    exit 1
fi

# Prepack
mkdir -p $ROOT_DIR/prepack
cd $ROOT_DIR/prepack

FlexPepDocking.linuxgccrelease -s ../start_files/${RECEPTOR_NAME}_${NAME}_initial.pdb -flexpep_prepack -ex1 -ex2aro

if [[ $? -ne "0" ]]
then
    exit 1
fi

mv ${RECEPTOR_NAME}_${NAME}_initial_0001.pdb ${RECEPTOR_NAME}_${NAME}_prepack.pdb

