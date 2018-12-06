#!/bin/bash

where=`pwd`
i_file="3HGB.pdb" # .pdb file containing the inital structure
o_name="O6A" # atom type of the oxygen (in the .pdb) we want to add the CH_3 to - I did not check  it's the right one, can be O6B as well...
pdb_file="3HGB.pdb" # original configuration
meth_file="meth_z_aligned.xyz" # .xyz containing the methyesterified residue + oxygen (the latter to be removed): O-C-H_3
VMD="/Applications/VMD 1.9.1.app/Contents/vmd/vmd_MACOSXX86"

cd $where

n_res=`grep $o_name $i_file | wc -l` # get the number of residues

echo "There are " $n_res " residues in this configuration..."
ck=0
c=0
while [[ $ck -ne 1 ]]; do
   echo "Type the index of the residue you want to add the CH_3 group to, followed by [ENTER]. Type 0 when you are done"
   read var
   if [[ $var -lt 0 ]]; then
      echo "Not a valid residue number..."
      exit 0
   fi
   if [[ $var -gt $n_res ]]; then
      echo "Not a valid residue number..."
      exit 0
   fi
   if [[ $var -eq 0 ]]; then
      ck=1
   else
      let c=c+1
      which_res[$c]=$var
   fi
done

echo "You have chosen to add a CH_3 group to residues n."
for (( i=1; i<=$c; i++ )); do
    echo ${which_res[$i]}
done

for (( i=1; i<=$c; i++ )); do
    echo "adding -CH_3 to carboxylic oxygen: " $i " of " $c
    if [[ $i -eq 1 ]]; then
    cp add_align_1.tcl tmp.tcl
    cat tmp.tcl | sed "s/PDB_TBF/$pdb_file/g" > tmp_1.tcl # silly, but -i doe snot work on MacOS... uff.
    cat tmp_1.tcl | sed "s/METH_TBF/$meth_file/g" > tmp.tcl
    "$VMD" -dispdev none -e tmp.tcl > vmd.log
    
    fi
done

exit 0

