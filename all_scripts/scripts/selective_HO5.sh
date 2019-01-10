#!/bin/bash
#script to selectively deprotonate HGB chain, output is topol
#workflow:
# doglycans.sh -> pdb2gmx.sh -> glinks.sh (this stage:fully protonated system ready to go) -> selective_HO5.sh


f_path="./"
t_file="conf.pdb"

atoms_to_remove=(1 5 6)  #**** residues from which HO5 is deleted
for ((j=0; j<${#atoms_to_remove[@]}; j++)); do
             delet[j]=$(awk '{if ($3=="HO5" && $5=='${atoms_to_remove[j]}') print NR}' conf.pdb)
             sed -i "${delet[j]}d" conf.pdb
done

#correct for wonky columns
awk '{
split($0, a, FS, seps);
if (a[5] >=1) {
	a[2]=NR-2
	if (a[2] < 10) {
		seps[1] = "      ";
	} else if (a[2] < 100) {
	        seps[1] = "     ";
	} else if (a[2] < 1000) {
	        seps[1] = "    ";
	} 
for (i=1; i<=NF; i++)
		printf("%s%s", a[i], seps[i]);
		print "";
	}
else {
	print $0;
}

}' conf.pdb >conf1.pdb

rm conf.pdb
mv conf1.pdb conf.pdb

# If residues contain HO5 replace:
# AGAI ->AGHI
ho5=($(grep -n "HO5 AGAI" $f_path/$t_file | awk '{print $2}'))
l=${#ho5[@]}
echo ${ho5[@]}
#echo $l
x=2
y=21
for ((i=0; i<${#ho5[@]}; i++)); do
	a=$(expr ${ho5[i]} + ${x})
        b=$(expr ${a} - ${y})
	echo  $a $b
	sed -i "${b},${a} s/AGAI/AGHI/g" conf.pdb
done  

# AGAM -> AGHM
ho5=($(grep -n "HO5 AGAM" $f_path/$t_file | awk '{print $2}'))
l=${#ho5[@]}
echo ${ho5[@]}
#echo $l

x=2
y=19
for ((i=0; i<${#ho5[@]}; i++)); do
	a=$(expr ${ho5[i]} + ${x})
	b=$(expr ${a} - ${y})
	echo  $a $b
	sed -i "${b},${a} s/AGAM/AGHM/g" conf.pdb
done


# AGAM -> AGHM
ho5=($(grep -n "HO5 AGAT" $f_path/$t_file | awk '{print $2}'))
l=${#ho5[@]}
echo ${ho5[@]}
#echo $l

x=2
y=20
for ((i=0; i<${#ho5[@]}; i++)); do
	a=$(expr ${ho5[i]} + ${x})
	b=$(expr ${a} - ${y})
	echo  $a $b
	sed -i "${b},${a} s/AGAT/AGHT/g" conf.pdb
done

#choose the charmm36 NOV FF!!!!
gmx_mpi pdb2gmx -f conf.pdb -o conf1.pdb -water tip4p 

bash ./glinks.sh

rm conf.pdb 
mv conf1.pdb conf.pdb





#awk '{
#split($0, a, FS, seps);
#if (a[3]=/HO5/ && a[4]=/AGAI/) {
#	b=a[2];
#	c=b-22
#		sed -i "b,c s/AGAI/GALI/g"
#	
#for (i=1; i<=NF; i++)
#	printf("%s%s", a[i], seps[i]);
#	print "";
#}
#else {
#	 print $0;
#}
#}' conf.pdb >test.pdb
#
#rm conf.pdb

#gmx_mpi pdb2gmx -f conf.pdb -o conf1.pdb -water tip4p 








#alternative way; the patterning of deprotonation can be done directly via the 'for' range
#for ((i=0; i<=($len-2); i+=4)); do
#    #printf "%s %4s\n" ${arr[i]} ${arr[i+1]} 
#    delet=$(printf "%s  %s\n" ${arr[i]} ${arr[i+1]})
#    echo "${delet}"
#    #grep -v "${delet}" conf.pdb >> temp.tmp
#  
#    #sed -i "/${arr[i]}"  "${arr[i+1]}/d" conf.pdb 
#    sed -i "/${delet}/d" conf.pdb
#done










#echo ${stringH}


#IN="${stringH}"

#arr=$(echo $IN | tr " " "\n")

#for x in $arr
#do
#    echo $x
#done


#echo ${#stringH[@]}
#echo ${stringH[@]}

#cat conf.pdb | awk -v s="${stringH}" 'BEGIN{narr=split(s, arr, " ");flag=0;};
 #   echo ${narr} '


#NR>0{print $0;}
#$0 ~ /ATOM/ {flag=1} {
#    if (flag==1){
#        for (i=1;i<narr-1;i+=1) {awk "!/arr[i]/" };
#        
#    
#        flag=0;
#    }
#}' > temp.tmp



#t="22  HO5"
#grep -v "${t}" conf.pdb >temp.tmp





#awk '!/22  HO5/' conf.pdb > temp.tmp
#for ((i=0; i<=($lt); i++));do
#sed "/${t}/d" ./conf.pdb 
#done




