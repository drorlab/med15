import collections as col
import glob
import os
import sys

import pandas as pd
import pyrosetta as pr
import pyrosetta.rosetta.core.scoring as scoring
import pyrosetta.teaching as pt

if len(sys.argv) < 2:
    print('Usage: python per_aa.py pdb_dir')
    sys.exit(1)
filedir = sys.argv[1]
output_csv = filedir + '/per_aa.csv'
print(f'Writing {filedir:} to {output_csv:}')

pr.init("-mute basic.random basic.io core.chemical core.scoring core.pack "
        "core.init core.import_pose",
        silent=True)

ref15 = pt.get_fa_scorefxn()

scorefxn = scoring.get_score_function()

sf = pr.ScoreFunction()

results = col.defaultdict(list)

for filepath in glob.glob(filedir + '*.pdb'):
    print(f'Doing {filepath:}')
    pose = pr.pose_from_pdb(filepath)

    # scorefxn.show(pose)
    scorefxn.score(pose)

    # Copying from
    # main/source/src/protocols/flexpep_docking/FlexPepDockingPoseMetrics.cc

    recseq = pose.chain_sequence(1)
    pepseq = pose.chain_sequence(2)

    pepscore = 0
    pepscore_noref = 0
    filename_len = len(os.path.basename(filepath))
    file_column_name = 'file'
    results[f'{file_column_name:<{filename_len}}'].append(os.path.basename(filepath))

    for idx, i in enumerate(range(len(recseq) + 1, len(recseq) + 1 + len(pepseq))):
        ienergy = pose.energies().residue_total_energy(i)
        ifa_ref = pose.energies().residue_total_energies(i)[scoring.ref]
        pepscore += ienergy
        pepscore_noref += ienergy - ifa_ref
        results[f'{pepseq[idx] + str(idx):>6}'].append(ienergy-ifa_ref)
#        print(f'{pepseq[idx] + str(idx):}: {ienergy-ifa_ref:6.3f}')

    # scorefxn_no_cst = scoring.deep_copy(scorefxn)
    # scorefxn_no_cst.set_weight(scoring.coordinate_constraint, 0.0);
    # scorefxn_no_cst.set_weight(scoring.atom_pair_constraint, 0.0);
    # scorefxn_no_cst.set_weight(scoring.angle_constraint, 0.0);
    # scorefxn_no_cst.set_weight(scoring.dihedral_constraint, 0.0);
    # import pdb; pdb.set_trace()

    #test.energies().show(1)

results = pd.DataFrame(results)

results.to_csv(output_csv, index=False, float_format='%6.3f')
