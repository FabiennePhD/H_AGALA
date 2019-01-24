package require topotools
package require psfgen
package require pbctools

set pdb_file merged.pdb

set which_res WRRR

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

## orient the meth C-O axis along the z-axis - should not be necessary, but hey...
#set meth [ atomselect top "name \".*XX\"" ] 
#set cxx [ atomselect top "name CXX" ]
#set oxx [ atomselect top "name OXX" ] ;****was OXX
#set cox_ax [find_axis $cxx $oxx]
#set M [transvecinv $cox_ax]
#$meth move $M
#set M [transaxis y -90]
#$meth move $M

# Move C5X in { 0 0 0 }
set rest [atomselect top "not name \".*XX\"" ]
set co [ atomselect top "name C6X" ]
set ct [ atomselect top "name C5X" ]
set ox_x [ $ct get  { x } ]
set ox_y [ $ct get  { y } ]
set ox_z [ $ct get  { z } ]
set ox_p "$ox_x $ox_y $ox_z"
set ox_oh_m [vecscale $ox_p -1]
$rest moveby $ox_oh_m

# orient the C6-C5 axis along the z-axis
set co [ atomselect top "name C6X" ]
set ct [ atomselect top "name C5X" ]
set cc_ax [find_axis $ct $co]
set M [transvecinv $cc_ax]
$rest move $M
set M [transaxis y -90]
$rest move $M

# move the meth group on top
set meth [ atomselect top "name \".*XX\"" ] 
set ox [ atomselect top "name OXX" ]
set oh [ atomselect top "name O6X" ]
$meth moveby [find_axis $ox $oh]

# un-flag the X atoms... needed for more CH3 groups later on!
$co set name "C6 "
$ct set name "C5 "
$oh set name "O_NAME"
set cx [ atomselect top "name CXX" ]
set A CM
set B $which_res
set C [concat $A $B]
set D [string map {" " ""} $C]
$cx set name $D
set hx [ atomselect top "name HXX" ]
set A HM
set C [concat $A $B]
set D [string map {" " ""} $C]
$hx set name $D

# delete OXX - by not writing it down...
set all [atomselect top "not name OXX"]
$all writepdb plus.pdb 

exit

#vmd -dispdev none -e add_align_2.tcl 

