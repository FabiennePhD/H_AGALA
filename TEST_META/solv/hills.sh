#!/bin/bash

#exe="/home/chem/mstscj/CODES/PLUMED/plumed-2.4.1/BIN/bin/plumed sum_hills"
exe="/home/chem/mssnkt/CODES/PLUMED/plumed-2.4.2/BIN/bin/plumed sum_hills"

mpirun -np 2 $exe --hills HILLS --idw dh_2_1 --kt 2.5
#mpirun -np 2 $exe --hills HILLS --idw dh_2_1 --kt 2.5 --stride 5000  --mintozero

b=30

$exe --hills HILLS --idw dh_1_1,dh_1_2 --min -pi,-pi,-pi,-pi --max pi,pi,pi,pi --bin $b,$b,$b,$b --kt 2.5 --mintozero --stride 5000
