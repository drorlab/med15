# Med15 FlexPepDock 

## Overview

Structural analysis of transcription factor binding to domains of the med15 complex.  

We do so by modeling short segments of the transcription factors (referred to as activation domains [ADs]) as peptides, and dock them to domains of med15 (activator-binding domins [ABDs]).

Adapted and run by Raphael Townshend, in support of Adrian Sanborn's work.

## Installation

Please make sure you have the Rosetta bin directory (i.e., `rosetta/main/source/bin`) in your $PATH.  This was tested with Rosetta 3.12 .

## Usage

For these instructions, please assign a name to your ABD and AD (which we shall refer to as RECEPTOR_NAME and NAME, respectively).  We also assume you will output your results to a root directory, which we shall ROOT_DIR.  Finally, please record the number of amino acids in your ABD, which we refer to as RECEPTOR_LENGTH.

To use for an AD/ABD pair, please create ROOT_DIR with a single subdirectory named `start_files`.  This directory should contain, at a minimum, two files:

1) A fasta file named `${NAME}.fasta` in the standard FASTA format.  Please be sure to include a trailing new line at end of second line (windows does not put that in sometimes).

2) A PDB files named `${RECEPTOR_NAME}_${NAME}_initial.pdb` which includes the ABD as chain A, and the AD peptide in fully extended conformation as chain B, placed approximately near the expected binding location (though with no clashes with ABD).  Make sure the residue numbers are all sequential, with the ABD numbering starting with 1 and counting up, and the AD residue numbering continuing after the last ABD residue number.

Then, from this (the code) directory, run:

```
bash flexpepdock.sh $RECEPTOR_NAME $NAME $ROOT_DIR $RECEPTOR_LENGTH
```

An example input is provided under `example/`.
