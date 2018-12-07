# from meth.xyz to meth_z_aligned.xyz

set oxy [atomselect top "index 1" ]
set carb [atomselect top "index 0" ]
set c_oxy_x [ $oxy get  { x } ]
set c_oxy_y [ $oxy get  { y } ]
set c_oxy_z [ $oxy get  { z } ]
set c_oxy "$c_oxy_x $c_oxy_y $c_oxy_z"
set c_carb_x [ $carb get { x } ]
set c_carb_y [ $carb get { y } ]
set c_carb_z [ $carb get { z } ]
set c_carb "$c_carb_x $c_carb_y $c_carb_z" 
set co_axis [vecadd $c_carb $c_oxy]

set sel [atomselect top all] 
set M [transvecinv $co_axis] 
$sel move $M 
set M [transaxis y -90] 
$sel move $M 
