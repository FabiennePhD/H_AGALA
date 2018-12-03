#!/bin/bash

#exe="/home/chem/mstscj/CODES/PLUMED/plumed-2.4.1/BIN/bin/plumed driver"
exe="/home/chem/mstscj/CODES/PLUMED_HIN_IFORT/plumed2/BIN/bin/plumed driver"


mpirun -np 2 $exe  --igro ./npt.gro --mf_trr ./md.trr --plumed plumed.dat --timestep 0.002 
