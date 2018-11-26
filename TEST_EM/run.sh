#!/bin/bash
# module load intel/2017.4.196-GCC-6.4.0-2.28 impi/2017.3.196 FFTW/3.3.6 imkl/2017.3.196
MKD="/home/chem/mssnkt/CODES/GROMACS/gromacs-5.1.4/BIN_MPI/bin/gmx_mpi make_ndx"
GROMPP="/home/chem/mssnkt/CODES/GROMACS/gromacs-5.1.4/BIN_MPI/bin/gmx_mpi grompp"
MDRUN="/home/chem/mssnkt/CODES/GROMACS/gromacs-5.1.4/BIN_MPI/bin/gmx_mpi mdrun"

#$MKD -f conf.pdb 
#$GROMPP -f grompp.mdp -c conf.pdb -p topol.top -o topol.tpr -n index.ndx
$MDRUN -ntomp 4 -maxh 48 -s topol.tpr -o traj.trr -x traj.xtc -c md.gro -e md.edr -g md.log > log.log 2>&1
