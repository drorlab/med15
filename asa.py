import pandas as pd

import os
import subprocess
import sys

if len(sys.argv) < 3:
    print("Usage: python asa.py /path/to/freesasa input.pdb")
    sys.exit(1)

freesasa_path = sys.argv[1]
input_file = sys.argv[2]

# Get only peptide ASA
freesasa = \
    f'{freesasa_path:} -C -R {input_file:} | ' + \
    'grep "SEQ B" | tr -s " " | rev | cut -d " " -f 1 | rev'
process = subprocess.Popen(freesasa, stdout=subprocess.PIPE, shell=True)
output, error = process.communicate()
output = output.decode("utf-8")
pASA = [float(x) for x in output.split('\n') if len(x) > 0]

# Get complex ASA
freesasa = \
    f'{freesasa_path:} -R {input_file:} | ' + \
    'grep "SEQ B" | tr -s " " | rev | cut -d " " -f 1 | rev'
process = subprocess.Popen(freesasa, stdout=subprocess.PIPE, shell=True)
output, error = process.communicate()
output = output.decode("utf-8")
cASA = [float(x) for x in output.split('\n') if len(x) > 0]

freesasa = \
    f'{freesasa_path:} -R {input_file:} | ' + \
    'grep "SEQ B" | tr -s " " | cut -d " " -f 3'
process = subprocess.Popen(freesasa, stdout=subprocess.PIPE, shell=True)
output, error = process.communicate()
output = output.decode("utf-8")
resnums = [int(x) for x in output.split('\n') if len(x) > 0]

freesasa = \
    f'{freesasa_path:} -R {input_file:} | ' + \
    'grep "SEQ B" | tr -s " " | cut -d " " -f 4'
process = subprocess.Popen(freesasa, stdout=subprocess.PIPE, shell=True)
output, error = process.communicate()
output = output.decode("utf-8")
resnames = [x for x in output.split('\n') if len(x) > 0]

# Max ASA. From Tein et al. 2013 (theoretical)
mASA_lookup = {
    'ALA': 129.0,
    'ARG': 274.0,
    'ASN': 195.0,
    'ASP': 193.0,
    'CYS': 167.0,
    'GLU': 223.0,
    'GLN': 225.0,
    'GLY': 104.0,
    'HIS': 224.0,
    'ILE': 197.0,
    'LEU': 201.0,
    'LYS': 236.0,
    'MET': 224.0,
    'PHE': 240.0,
    'PRO': 159.0,
    'SER': 155.0,
    'THR': 172.0,
    'TRP': 285.0,
    'TYR': 263.0,
    'VAL': 174.0,
}

mASA = [mASA_lookup[x] for x in resnames]

df = pd.DataFrame({
    'resname': resnames,
    'residue': resnums,
    'mASA': mASA,
    'pASA': pASA,
    'cASA': cASA,
})

df['bpASA'] = df['mASA'] - df['pASA']
df['bcASA'] = df['pASA'] - df['cASA']

output_file = os.path.splitext(input_file)[0] + '_asa.csv'
df.to_csv(output_file, index=False, float_format='%.2f')
