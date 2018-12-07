#!/bin/bash

where=`pwd`
i_file="3HGB.pdb" # .pdb file containing the inital structure
o_name="O6A" # atom type of the oxygen (in the .pdb) we want to add the CH_3 to - I did not check  it's the right one, can be O6B as well...
pdb_file="3HGB.pdb" # original configuration
meth_file="meth_z_aligned.xyz" # .xyz containing the methyesterified residue + oxygen (the latter to be removed): O-C-H_3
#VMD="/Applications/VMD 1.9.1.app/Contents/vmd/vmd_MACOSXX86"
VMD="/home/chem/mssnkt/CODES/VMD/vmd-1.9.3/VMD_BIN/vmd"

cd $where

n_res=`grep $o_name $i_file | wc -l` # get the number of residues

# Check that we have unique identifiers for C5, C6 and O6B in the initial .pdb
t=`grep C5 $pdb_file | wc -l`
if [[ $t -ne $n_res ]]; then
   "Check your .pdb"
   exit 0
fi
t=`grep C6 $pdb_file | wc -l`
if [[ $t -ne $n_res ]]; then
   "Check your .pdb"
   exit 0
fi
t=`grep O6B $pdb_file | wc -l`
if [[ $t -ne $n_res ]]; then
   "Check your .pdb"
   exit 0
fi

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
       sed -i "s/PDB_TBF/$pdb_file/g" tmp.tcl 
       sed -i "s/METH_TBF/$meth_file/g" tmp.tcl
       "$VMD" -dispdev none -e tmp.tcl > vmd.log
       # Modify the resulting merged.pdb file to flag the atoms we need to move/rotate stuff...
       # Flag C5 - within the right residue
       line=`grep -n C5 merged.pdb | head -${which_res[$i]} | tail -1 | cut -d":" -f1`
       sed -i ""$line"s/C5 /C5X/g" merged.pdb    
       # Flag C6 - within the right residue
       line=`grep -n C6 merged.pdb | head -${which_res[$i]} | tail -1 | cut -d":" -f1`
       sed -i ""$line"s/C6 /C6X/g" merged.pdb
       # Flag O6B - within the right residue
       line=`grep -n O6B merged.pdb | head -${which_res[$i]} | tail -1 | cut -d":" -f1`
       sed -i ""$line"s/O6B/O6X/g" merged.pdb
       # Do the magic
       "$VMD" -dispdev none -e add_align_2.tcl > vmd.log
    fi
    if [[ $i -gt 1 ]]; then
       # We are adding other CH3 groups!
       cp add_align_1.tcl tmp.tcl
       sed -i "s/PDB_TBF/plus.pdb/g" tmp.tcl 
       sed -i "s/METH_TBF/$meth_file/g" tmp.tcl
       "$VMD" -dispdev none -e tmp.tcl > vmd.log
       # Modify the resulting merged.pdb file to flag the atoms we need to move/rotate stuff...
       # Flag C5 - within the right residue
       line=`grep -n C5 merged.pdb | head -${which_res[$i]} | tail -1 | cut -d":" -f1`
       sed -i ""$line"s/C5 /C5X/g" merged.pdb
       # Flag C6 - within the right residue
       line=`grep -n C6 merged.pdb | head -${which_res[$i]} | tail -1 | cut -d":" -f1`
       sed -i ""$line"s/C6 /C6X/g" merged.pdb
       # Flag O6B - within the right residue
       line=`grep -n O6B merged.pdb | head -${which_res[$i]} | tail -1 | cut -d":" -f1`
       sed -i ""$line"s/O6B/O6X/g" merged.pdb
       # Do the magic
       "$VMD" -dispdev none -e add_align_2.tcl > vmd.log
    fi
done

# cleanup
rm -r -f log.log tmp_1.tcl vmd.log add_align_1.tcl tmp.tcl

exit 0

