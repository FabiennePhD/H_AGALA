#!/bin/bash

where=`pwd`

###
# Choose your .pdf file and your oxygen name - to add stuff to!!
pdb_file="conf.pdb" # original configuration
#o_name="O62"
#pdb_file="10HGB.pdb"
o_name="O62"
###

meth_file="meth_z_aligned.xyz" # .xyz containing the methyesterified residue + oxygen (the latter to be removed): O-C-H_3
oh_file="oh_aligned.xyz"

###
# Change stuff according to whether you are running LiNuX or MacOS...
# sed executable
# MacOS...
#ssed="/opt/local/bin/gsed"
# Linux
ssed=/usr/bin/sed

# sed executable
# MacOS...
#vmd_d="cave"
# Linux
vmd_d=none

# VMD executable - machine dependent
#VMD="/Applications/VMD 1.9.1.app/Contents/vmd/vmd_MACOSXX86"
#VMD="/home/chem/mssnkt/CODES/VMD/vmd-1.9.3/VMD_BIN/vmd"
# On SCRTP machines:
VMD="/warwick/vmd/1.9.1/x86_64/bin/vmd"
###

cd $where

n_res=`grep $o_name $pdb_file | wc -l` # get the number of residues

# Check that we have unique identifiers for C5, C6 and O6B in the initial .pdb
t=`grep C5 $pdb_file | wc -l`
if [[ $t -ne $n_res ]]; then
   echo "Check your .pdb"
   exit 0
fi
t=`grep C6 $pdb_file | wc -l`
if [[ $t -ne $n_res ]]; then
   echo "Check your .pdb"
   exit 0
fi
t=`grep $o_name $pdb_file | wc -l`
if [[ $t -ne $n_res ]]; then
   echo "Check your .pdb"
   exit 0
fi

# +CH3 part

echo "There are " $n_res " residues in this configuration..."
ck=0
c=0
ch3_flag=0
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

if [[ $c -ne 0 ]]; then
   ch3_flag=1

   echo "You have chosen to add a CH_3 group to residues n."
   for (( i=1; i<=$c; i++ )); do
       echo ${which_res[$i]}
       test_ch3_h[$i]=${which_res[$i]}
   done
   c_ch3=$c

   for (( i=1; i<=$c; i++ )); do
       echo "adding -CH_3 to carboxylic oxygen: " $i " of " $c
       if [[ $i -eq 1 ]]; then
          cp add_align_1.tcl tmp.tcl
          $ssed -i "s/PDB_TBF/$pdb_file/g" tmp.tcl 
          $ssed -i "s/METH_TBF/$meth_file/g" tmp.tcl
          "$VMD" -dispdev $vmd_d -e tmp.tcl > vmd.log
          # Modify the resulting merged.pdb file to flag the atoms we need to move/rotate stuff...
          # Flag C5 - within the right residue
          line=`grep -n C5 merged.pdb | head -${which_res[$i]} | tail -1 | cut -d":" -f1`
          $ssed -i ""$line"s/C5 /C5X/g" merged.pdb    
          # Flag C6 - within the right residue
          line=`grep -n C6 merged.pdb | head -${which_res[$i]} | tail -1 | cut -d":" -f1`
          $ssed -i ""$line"s/C6 /C6X/g" merged.pdb
          # Flag O6B - within the right residue
          line=`grep -n $o_name merged.pdb | head -${which_res[$i]} | tail -1 | cut -d":" -f1` # CHECK!
          $ssed -i ""$line"s/$o_name/O6X/g" merged.pdb
          # Do the magic
          cp add_align_2.tcl tmp.tcl
          $ssed -i "s/WRRR/${which_res[$i]}/g" tmp.tcl
          $ssed -i "s/O_NAME/$o_name/g" tmp.tcl
          "$VMD" -dispdev $vmd_d -e tmp.tcl > vmd.log
       fi
       if [[ $i -gt 1 ]]; then
          # We are adding other CH3 groups!
          cp add_align_1.tcl tmp.tcl
          $ssed -i "s/PDB_TBF/plus.pdb/g" tmp.tcl 
          $ssed -i "s/METH_TBF/$meth_file/g" tmp.tcl
          "$VMD" -dispdev $vmd_d -e tmp.tcl > vmd.log
          # Modify the resulting merged.pdb file to flag the atoms we need to move/rotate stuff...
          # Flag C5 - within the right residue
          line=`grep -n C5 merged.pdb | head -${which_res[$i]} | tail -1 | cut -d":" -f1`
          $ssed -i ""$line"s/C5 /C5X/g" merged.pdb
          # Flag C6 - within the right residue
          line=`grep -n C6 merged.pdb | head -${which_res[$i]} | tail -1 | cut -d":" -f1`
          $ssed -i ""$line"s/C6 /C6X/g" merged.pdb
          # Flag O6B - within the right residue
          line=`grep -n $o_name merged.pdb | head -${which_res[$i]} | tail -1 | cut -d":" -f1`
          $ssed -i ""$line"s/$o_name/O6X/g" merged.pdb
          # Do the magic
          echo ${which_res[$i]}
          cp add_align_2.tcl tmp.tcl
          $ssed -i "s/WRRR/${which_res[$i]}/g" tmp.tcl
          $ssed -i "s/O_NAME/$o_name/g" tmp.tcl
          "$VMD" -dispdev $vmd_d -e tmp.tcl > vmd.log
       fi
   done
   
   # cleanup
   rm -r -f log.log tmp_1.tcl vmd.log tmp.tcl merged.pdb test.pdb 

else
   echo "We are not adding any CH3!"
fi


# +H part

echo "There are " $n_res " residues in this configuration..."
ck=0
c=0
while [[ $ck -ne 1 ]]; do
   echo "Type the index of the residue you want to add the H to, followed by [ENTER]. Type 0 when you are done"
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

echo "You have chosen to add a H to residues n."
for (( i=1; i<=$c; i++ )); do
    echo ${which_res[$i]}
done

# Check that you are not protonating methylesterified residues

for (( i=1; i<=$c; i++ )); do
    for (( j=1; j<=$c_ch3; j++ )); do
        k=${which_res[$i]} 
        l=${test_ch3_h[$j]}
        if [[ $k -eq $l ]]; then
           echo "Cannot add H on CH3 !!"
           exit 0
        fi
    done
done

# if we did not add CH3, we should start from pdb_file
# if we did add some CH3, we should start from plus.pdb

if [[ $ch3_flag -eq 0 ]]; then
   cp $pdb_file plus.pdb
fi   

for (( i=1; i<=$c; i++ )); do
    echo "adding H to carboxylic oxygen: " $i " of " $c
    cp add_align_1.tcl tmp.tcl
    $ssed -i "s/PDB_TBF/plus.pdb/g" tmp.tcl
    $ssed -i "s/METH_TBF/$oh_file/g" tmp.tcl
    "$VMD" -dispdev $vmd_d -e tmp.tcl > vmd.log
    # Modify the resulting merged.pdb file to flag the atoms we need to move/rotate stuff...
    # Flag C5 - within the right residue
    line=`grep -n C5 merged.pdb | head -${which_res[$i]} | tail -1 | cut -d":" -f1`
    $ssed -i ""$line"s/C5 /C5X/g" merged.pdb
    # Flag C6 - within the right residue
    line=`grep -n C6 merged.pdb | head -${which_res[$i]} | tail -1 | cut -d":" -f1`
    $ssed -i ""$line"s/C6 /C6X/g" merged.pdb
    # Flag O6B - within the right residue
    line=`grep -n $o_name merged.pdb | head -${which_res[$i]} | tail -1 | cut -d":" -f1` # CHECK!
    $ssed -i ""$line"s/$o_name/O6X/g" merged.pdb
    # Do the magic
    cp add_align_3.tcl tmp.tcl
    $ssed -i "s/WRRR/${which_res[$i]}/g" tmp.tcl
    "$VMD" -dispdev $vmd_d -e tmp.tcl > vmd.log
done

# cleanup
rm -r -f log.log tmp_1.tcl vmd.log tmp.tcl merged.pdb test.pdb 

# final result in plus.pdb


exit 0

