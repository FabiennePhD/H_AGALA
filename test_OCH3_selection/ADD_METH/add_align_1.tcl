package require topotools
package require psfgen
package require pbctools

set pdb_file 3HGB.pdb
set meth_file meth_z_aligned.xyz

set midlist {}
set mol [mol new $pdb_file waitfor all]
lappend midlist $mol
set mol [mol new $meth_file waitfor all]
lappend midlist $mol
set mol [::TopoTools::mergemols $midlist]
animate write pdb merged.pdb $mol

exit

#vmd -dispdev none -e add_align_1.tcl 

