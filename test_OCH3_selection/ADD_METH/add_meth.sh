#!/bin/bash

where=`pwd`
i_file="3HGB.pdb" # .pdb file containing the inital structure
o_name="O6A" # atom type of the oxygen (in the .pdb) we want to add the CH_3 to - I did not check  it's the right one, can be O6B as well...

cd $where

n_o=`grep $o_name $i_file | wc -l` # get the number of oxygen to add the CH_3 to 

for (( i=1; i<=$n_o; i++ )); do
    echo "adding -CH_3 to carboxylic oxygen: " $i " of " $n_o
    # change O6A i to O6AX HERE
    
done

exit 0

