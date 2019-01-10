#!/bini/bash 
CM_pos=($(awk '/CM/{print NR}' plus.pdb)) #line numbers the methyl carbon is on
#echo "this is CM ${CM_pos[@]}"
echo "don't forget to set x and CL"
x=(1 5 10 15) # Residues which are methylated - needs to correspond to selective_HO5.sh						
CL=15	# total number of residues

for ((i=0; i<${#x[@]}; i++)); do

	O62_pos[i]=$(awk '{if ($3=="O62" && $5=='${x[i]}') print NR}' plus.pdb)
done
# finds lines ending with o62- the line number after o62 represent residues that have the methyl group added underneath

#ALTERNATIVE, IGNORE FOR NOW#
#for ((i=0; i<${#x[@]}; i++)); do
#grep -n "O62" plus_21.pdb | grep -w "AGAIX   ${x[i]} "|awk '{print $2 +1}' >>t0
#grep -n "O62" plus_21.pdb | grep -w "AGAMX  ${x[i]} "|awk '{print $2 +1}' >>t1
#grep -n "O62" plus_21.pdb | grep -w "AGAMX   ${x[i]} "|awk '{print $2 +1}' >>t2
#grep -n "O62" plus_21.pdb | grep -w "AGATX  ${x[i]} "|awk '{print $2 +1}' >>t3

#cat t* >>all
#sort -n all>> o62_pos
#rm -r -f t* all

#O62_pos=($(awk '{print $1}' <o62_pos))

#done
#rm o62_pos


# get line numbers of methyl groups, and o62, move lies using from-to command (from:lines with CM and HM to:lines under o62)

for ((i=0; i<${#CM_pos[@]}; i++)); do  #move the CMx and HMX values underneath the selected O62 residues
	shft=$(expr $i \* 4 - 1) #accounts for line number values of o62 shifting by 3,6,9,... for every methyl group moved underneath the previous o62 line
	new_O62=$(expr ${O62_pos[i]} + $shft)
	new_HX1=$(expr ${CM_pos[i]} + 1)
	new_HX2=$(expr ${CM_pos[i]} + 2)
	new_HX3=$(expr ${CM_pos[i]} + 3)
	
	CM_mve=${CM_pos[i]}m$(($new_O62+1))
	HX1_mve=${new_HX1}m$(($new_O62+2))
	HX2_mve=${new_HX2}m$(($new_O62+3))
	HX3_mve=${new_HX3}m$(($new_O62+4))
   
	#echo "this is line HM91 $(($new_O62+3)) " 
   	
	printf  %s\\n "$CM_mve" w q | ed -s plus.pdb
	printf  %s\\n "$HX1_mve" w q | ed -s plus.pdb
	printf  %s\\n "$HX2_mve" w q | ed -s plus.pdb
	printf  %s\\n "$HX3_mve" w q | ed -s plus.pdb

	
        sed -i -e "$(($new_O62+2))s/CM${x[i]}/C7 /g" plus.pdb
    	sed  -i -e  "$(($new_O62+3))s/HM${x[i]}/H91/g" plus.pdb
        sed  -i -e  "$(($new_O62+4))s/HM${x[i]}/H92/g" plus.pdb
	sed  -i -e  "$(($new_O62+5))s/HM${x[i]}/H93/g" plus.pdb


	if [ ${x[i]} == 1 ]; then
		#echo "first"
 		sed  -i -e "$(($new_O62+5 -25)),$(($new_O62+5)) s/AGAIX/OMEIX/g" plus.pdb  # inital residue line range is C1-H93, where 25 = line with H93 i.e $(($new_O62+5)
            	sed  -i -e "s/C7      X   1/C7  OMEIX   ${x[i]}/g" plus.pdb 
             	sed  -i -e "s/H91     X   1/H91 OMEIX   ${x[i]}/g" plus.pdb 
             	sed  -i -e "s/H92     X   1/H92 OMEIX   ${x[i]}/g" plus.pdb             
		sed  -i -e "s/H93     X   1/H93 OMEIX   ${x[i]}/g" plus.pdb  
	elif [ ${x[i]} == $CL ]; then
#		#echo "end"
     		sed  -i -e "$(($new_O62+5 -24)),$(($new_O62+5)) s/AGATX/OMETX/g" plus.pdb  # end residue H93  i.e.$(($new_O62+5) -> to C1 (H93-24=line C1)
		sed  -i -e "s/C7      X   1/C7  OMETX   ${x[i]}/g" plus.pdb 
                sed  -i -e "s/H91     X   1/H91 OMETX   ${x[i]}/g" plus.pdb 
                sed  -i -e "s/H92     X   1/H92 OMETX   ${x[i]}/g" plus.pdb             
                sed  -i -e "s/H93     X   1/H93 OMETX   ${x[i]}/g" plus.pdb 

	else
		#echo "middle"	
		sed  -i -e "$(($new_O62+5 -23)),$(($new_O62+5)) s/AGAMX/OMEMX/g" plus.pdb  # middle residues line range is line with H93 i.e.$(($new_O62+5) -> to C1 (H93-23=line C1)
		sed  -i -e "s/C7      X   1/ C7  OMEMX   ${x[i]}/g" plus.pdb 
		sed  -i -e "s/H91     X   1/ H91 OMEMX   ${x[i]}/g" plus.pdb 
		sed  -i -e "s/H92     X   1/ H92 OMEMX   ${x[i]}/g" plus.pdb 
		sed  -i -e "s/H93     X   1/ H93 OMEMX   ${x[i]}/g" plus.pdb 
	fi



done


#correct for wonky columns


awk '{
split($0, a, FS, seps);
if (a[5] >=1) {
        a[2]=NR-1
        if (a[2] < 10) {
                seps[1] = "      ";
        } else if (a[2] < 100) {
                seps[1] = "     ";
        } else if (a[2] < 1000) {
                seps[1] = "    ";
        } 
	seps[2] = "  "
	if (a[5] < 10){
	       seps[4] = "   ";
       }
	else if (a[5] < 100){
	 	seps[4] = "  ";
	}	
for (i=1; i<=NF; i++)
                printf("%s%s", a[i], seps[i]);
                print "";
        }
else {
        print $0;
}

}' plus.pdb >conf_plus.pdb


gmx_mpi pdb2gmx -f conf_plus.pdb -o conf1.pdb -water tip4p

bash ./glinks.sh


