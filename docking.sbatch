#!/bin/bash
#SBATCH --job-name=FlexPepDock
#SBATCH --time=24:00:00
#SBATCH --mail-type=ALL
#SBATCH --partition=owners
#SBATCH --cpus-per-task=1
##SBATCH --ntasks-per-node=10
#SBATCH --ntasks=200
#SBATCH --output=flexpepdock.out
#SBATCH --error=flexpepdock.err

RECEPTOR_NAME=$1
NAME=$2
ROOT_DIR=$3

module load openmpi/4.0.3

mkdir -p $ROOT_DIR/docking
cd $ROOT_DIR/docking

mpirun FlexPepDocking.mpi.linuxgccrelease \
    -s ../prepack/${RECEPTOR_NAME}_${NAME}_prepack.pdb \
    -out:file:silent decoys.silent \
    -out:file:silent_struct_type binary \
    -lowres_abinitio \
    -pep_refine \
    -ex1 \
    -ex2aro \
    -use_input_sc \
    -frag3 ../fragments/frags.3mers.offset \
    -flexPepDocking:frag5 ../fragments/frags.5mers.offset \
    -frag9 ../fragments/frags.9mers.offset \
    -nstruct 500000 \
    -unboundrot ../start_files/${RECEPTOR_NAME}.pdb
