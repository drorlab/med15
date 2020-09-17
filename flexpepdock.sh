#!/bin/bash

if [ $# -ne 4 ]
then
    echo "Usage: bash flexpepdock.sh RECEPTOR_NAME NAME ROOT_DIR RECEPTOR_LENGTH"
    exit
fi

RECEPTOR_NAME=$1
NAME=$2
ROOT_DIR=$3
RECEPTOR_LENGTH=$4

echo "Receptor name: $1"
echo "Peptide name: $2"
echo "Root dir: $3"
echo "Receptor length: $4"

if [ ! -f "$ROOT_DIR/prepack/score.sc" ] || [ ! -f "$ROOT_DIR/fragments/frags.9mers.offset" ]
then 
    RES=$(sbatch \
        --job-name=FPD-fp-${NAME} \
        --error=../slurm/FPD-fp-${NAME}.err \
        --output=../slurm/FPD-fp-${NAME}.out \
        frag_and_prepack.sbatch \
        $RECEPTOR_NAME \
        $NAME \
        $ROOT_DIR \
        $RECEPTOR_LENGTH \
    )
    FP_ID=${RES##* }
    echo "Submitted frag_and_prepack under ID $FP_ID"
else
    FP_ID=1
    echo "Frag and prepack already done"
fi

# Docking.  We use singleton dependency to prevent more than one of these from
# running at a time.
RES=$(sbatch \
    --job-name=FPD-dock-${NAME} \
    --error=../slurm/FPD-dock-${NAME}.err \
    --output=../slurm/FPD-dock-${NAME}.out \
    --dependency=afterok:${FP_ID} \
    docking.sbatch \
    $RECEPTOR_NAME \
    $NAME \
    $ROOT_DIR \
)
DOCK_ID=${RES##* }

echo "Submitted docking under ID $DOCK_ID"

RES=$(sbatch \
    --job-name=FPD-cluster-${NAME} \
    --error=../slurm/FPD-cluster-${NAME}.err \
    --output=../slurm/FPD-cluster-${NAME}.out \
    --dependency=afterok:$DOCK_ID \
    cluster.sbatch \
    $RECEPTOR_NAME \
    $NAME \
    $ROOT_DIR \
)
CLUSTER_ID=${RES##* }

echo "Submitted cluster under ID $CLUSTER_ID"
