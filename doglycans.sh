#!/bin/bash
source activate doglycans
export cl=10

python /home/chem/mstscj/DOGLYCANS/doglycans/prepreader.py [-Wmdt] -f /home/chem/mstscj/DOGLYCANS/doglycans/dat/glycam06h.itp -p /home/chem/mstscj/DOGLYCANS/doglycans/dat/GLYCAM_06h.prep -s seqfile.seq -c ${cl}HGB.pdb -o ${cl}HGB.itp -- charmm
