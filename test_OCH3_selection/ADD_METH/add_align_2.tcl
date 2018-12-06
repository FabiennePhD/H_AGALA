package require topotools
package require psfgen
package require pbctools

set pdb_file merged.pdb

# function to find the axis between atoms 1 and 2
proc find_axis {arg1 arg2} {
    set ox_x [ $arg1 get  { x } ]
    set ox_y [ $arg1 get  { y } ]
    set ox_z [ $arg1 get  { z } ]
    set ox_p "$ox_x $ox_y $ox_z"
    set oh_x [ $arg2 get { x } ]
    set oh_y [ $arg2 get { y } ]
    set oh_z [ $arg2 get { z } ]
    set oh_p "$oh_x $oh_y $oh_z"
    set ox_oh [vecadd $ox_p $oh_p]
    #set ox_ohn [vecnorm $ox_oh]
    return $ox_oh
}

# load .pdb
mol new $pdb_file waitfor all

## meth C-O axis along the z-axis - should not be necessary...
set meth [ atomselect top "name \".*XX\"" ] 
set cxx [ atomselect top "name CXX" ]
set oxx [ atomselect top "name OXX" ]
set cox_ax [find_axis $cxx $oxx]
set M [transvecinv $cox_ax]
$meth move $M
set M [transaxis y -90]
$meth move $M

# C6-C5 axis along the z-axis
set rest [atomselect top "not name \".*XX\"" ]
set co [ atomselect top "name C6X" ]
set ct [ atomselect top "name C5X" ]

# 
set ox_x [ $ct get  { x } ]
set ox_y [ $ct get  { y } ]
set ox_z [ $ct get  { z } ]
set ox_p "$ox_x $ox_y $ox_z"
set ox_oh_m [vecscale $ox_p -1]
$rest moveby $ox_oh_m

set co [ atomselect top "name C6X" ]
set ct [ atomselect top "name C5X" ]
set cc_ax [find_axis $ct $co]
set M [transvecinv $cc_ax]
$rest move $M
set M [transaxis y -90]
$rest move $M

# Fuck - this is the distance vector, not the versor...
# Not important - need to shift C5 in zero!
#
# DONE ! Now


set meth [ atomselect top "name \".*XX\"" ] 
set ox [ atomselect top "name OXX" ]
set oh [ atomselect top "name O6X" ]
$meth moveby [find_axis $ox $oh]
#
## Find the C6-C5 axis
#set c6 [ atomselect top "name C6X" ]
#set c5 [ atomselect top "name C5X" ]
#set c65_ax [find_axis $c6 $c5]
#
### Find the CXX OXX axis
##set cxx [ atomselect top "name CXX" ]
##set oxx [ atomselect top "name OXX" ]
##set cox_ax [find_axis $cxx $oxx]
##
###set rest [atomselect top "not name \".*XX\"" ]
###set M [transvecinv $c65_ax]
###$rest move $M
###set M [transaxis y -90]
###$rest move $M
##
##set M [transvecinv $cox_ax]
##$meth move $M
##set M [transaxis y -90]
##$meth move $M

set all [atomselect top "all"]
$all writepdb test.pdb 

# delete OXX - by not writin that selection!


exit

#vmd -dispdev none -e add_align_2.tcl 

