#!/bin/bash

exe="/home/chem/mstscj/CODES/PLUMED/plumed-2.4.1/BIN/bin/plumed sum_hills"

mpirun -np 2 $exe --hills HILLS --idw dh_2_1 --kt 2.5


#mpirun -np 2 $exe --hills HILLS --idw dh_2_1 --kt 2.5 --stride 5000  --mintozero

