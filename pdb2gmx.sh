#!/bin/bash
# H_AGALA

export cl=10                       #chain length ; number of agal sugar units in chain
let "mr =24 +19 * (cl-2)"          # mr; the last line which corresponds to AGAM residue, the AGAM lines start at 24 and increment as 1 resdiue =19 lines
export MR=$mr
let "lr =$MR +19"                  #lr; the last line which corresponds to AGAT residue
export LR=$lr
let "lr1 =$LR+1"
export H=$lr1                      #H; line on which the addition of HO5 starts


babel -h ${cl}HGB.pdb ${cl}HGB_H.pdb

# RENAME ATOMS AND RESIDUES 
sed -i  -e  's/H2O/HO2/g' -e 's/H3O/HO3/g' -e 's/H4O/HO4/g' -e 's/O6A/O61/g' -e 's/O6B/O62/g' -e 's/AGAI   0/AGAI   1/g' ${cl}HGB_H.pdb

sed -i -e '3,4 s/ROH A/AGAI/g' -e '4,23 s/4OA A/AGAI/g' -e "24,${MR} s/4OA A/AGAM/g" -e "${MR},${LR} s/0OA A/AGAT/g"  ${cl}HGB_H.pdb
    
sed -i 's/H   4OA A   2/HO5 AGAI   1/g' ${cl}HGB_H.pdb

sed -i 's/H   4OA A/HO5 AGAM/g' ${cl}HGB_H.pdb

sed -i 's/H   0OA A/HO5 AGAT/g' ${cl}HGB_H.pdb


# TAKE AWAY 1 FROM COLUMN 5, THIS IS FOR ATOMS EXCLUDING HO5 (ENSURES RESIDUES ARE NUMBERED CORRECTLY)
awk '{
split($0, a, FS, seps);  
if (a[2] >2 && a[2] <'${LR}-1') {
	a[5]=a[5]-1; 
	for (i=1; i<=NF;i++) 
		printf ("%s%s", a[i], seps[i]); 
		print ""; 
	}
else {
	print $0; 
}
}'  ${cl}HGB_H.pdb >test.pdb


# TAKE AWAY 1 FROM COLUMN 5, THIS FOR ATOMS HO5

awk '{
split($0, a, FS, seps);
if (a[2] >'${LR}-1' && a[2] <'${LR}+${cl}') {
        a[5]=a[5]-1;
        for (i=1; i<=NF;i++)
                printf ("%s%s", a[i], seps[i]);
                print "";
        }
else {
        print $0;
}
}' test.pdb >test1.pdb

#MOVES FIRST HO5 BELONGING TO AGAI
printf %s\\n ${H}m23 w q | ed -s test1.pdb

##MOVES ALL HO5s BELONGING TO AGAM
# ARRAY -F- WHICH ARE ALL THE LINES WITH HO5 THAT NEED TO BE MOVED
j=0
for((i=$H+1; i<=(($H+1)+ $cl-3); i++)); do

	F[$j]=$i;
	j=$((j+1))
				        
done

# ARRAY -T- WHICH ARE ALL THE LINES WHERE HO5 IS MOVED TO
k=0
for ((i=42; i<(42+(20*($cl-2))); i+=20)); do

	T[$k]=$i;
	k=$((k+1))					                     
done


export length=${#F[@]}

#COMMAND TO MOVE THE HO5 LINES 

for ((i=0; i<=($length); i++)); do
        #echo ${F[i]}m${T[i]}
       	mve=${F[i]}m${T[i]}
	printf  %s\\n "$mve" w q | ed -s test1.pdb
done

awk '{
split($0, a, FS, seps);
if (a[5] >=1 && a[5] <='${cl}') {
	a[2]=NR-2
	if (a[2] < 10) {
		seps[1] = "      ";
	} else if (a[2] < 100) {
		seps[1] = "     ";
	} else if (a[2] < 1000) {
		seps[1] = "    ";
	} else {
		seps[1] = "   ";
	}
	for (i=1; i<=NF;i++)
	printf ("%s%s", a[i], seps[i]);
	print "";
	}
	else {
        print $0;
		}
	}' test1.pdb >test2.pdb



gmx_mpi pdb2gmx -f test2.pdb -o conf.pdb -water tip4p 


#end
###########################################################################
#atom_name="HO5"
#atom_target="O4"
#
#awk 'BEGIN{name_id=0; target_id=0; header=0; footer=0; atomc=0; atomid=0}
#NR>0{
#    if($1 ~ /ATOM/){
#	atomc++
#	ac[atomc] = $2
#	arr[ac[atomc]] = $0
#	if($3 ~ /'${atom_name}'/){
#	    name_id++
#	    arr_id[name_id] = atomc
#        }
#    } else {
#        if(atomc==0){
#            header++
#	    head[header]=$0
#	}
#	if(NR-header>atomc){
#            footer++
#	    foot[footer]=$0
#	}
#    }
#} 
#END{
#for (i=1;i<header;i++){
#	print head[i]
#}
#for (i=1;i<atomc;i++){
#	atomid++
#        n=split(arr[ac[i]], a, FS, seps);
#        for (j=1; j<=n;j++) {
#	    if (j==2){
#                printf ("%s%s", atomid, seps[j]);
#	    } else {
#                printf ("%s%s", a[j], seps[j]);
#	    }
#        }
#        print "";
#	if(a[3] ~ /'${atom_target}'/){
#	    target_id++
#            m=split(arr[arr_id[target_id]], b, FS, s);
#	    atomid=a[2]+1
#            for (j=1; j<=m;j++) {
#		if (j==2){
#                    printf ("%s%s", atomid, s[j]);
#	        } else {
#                    printf ("%s%s", b[j], s[j]);
#		}
#            }
#            print "";
#        }
#}
#for (i=1;i<footer;i++){
#	print foot[i]
#}
#}' test1.pdb > test2.pdb



#printf %s\\n 82m23 w q | ed -s test1.pdb

#awk '{split($0, a, FS, seps);  a[5]=a[5]-1; for (i=1; i<=NF;i++) printf ("%s%s", a[i], seps[i]); print ""; }' ${cl}HGB_H.pdb >test.pdb                  
    


