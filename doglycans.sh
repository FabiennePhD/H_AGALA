#!/bin/bash
#source activate doglycans
export cl=10 # chain length

dg_path="/home/chem/mssnkt/CODES/DO_GLYCANS/biophys-uh-doglycans-0f1a8c993a91"

python $dg_path/prepreader.py [-Wmdt] -f $dg_path/dat/glycam06h.itp -p $dg_path/dat/GLYCAM_06h.prep -s seqfile.seq -c ${cl}HGB.pdb -o ${cl}HGB.itp -- charmm
