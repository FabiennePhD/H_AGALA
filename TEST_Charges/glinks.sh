#!/bin/bash
#this will work with any topology file (input it based on topol.top as per the grep commands below)  that has any chain length and is protonated, jusit bash glinks.sh - the final output is topol4.top

# Needs:
# source activate doglycans || assuming one has a working conda environement...

# Do not use absolute paths, especially if repeating the same path multiple times.
# Use variables instead

f_path="./"
t_file="topol.top"


# The way in which you store the result of whatever command into a SINGLE variable is:
# variable=`command` # note the ` symbol (infamously difficult to get consistently right across different keyboards)

# Now, things are a tad bit more complex here, because you have to store not a single number/string/wathever, but
# an array of numbers. Say, grep -n "CC3162" $f_path/$t_file | awk '{print $2}' gives you not one, but 10 numbers.
# The way to go about that is to use something like: C1=($(command)). In this case, for example:
# 	C1=($(grep -n "CC3162" $f_path/$t_file | awk '{print $2}'))
# Note that now C1 is an array, so that in order to access, say, its 4th element, you'll have to go: 
# 	echo ${C1[3]}
# And yes, an array with 10 elements has indexes from 0 to 9 - VMD/Python like. 
# This is NOT ALWAYS the case in bash... check!

grep -n "OC301"  $f_path/$t_file | awk '{print $2}' > O4
grep -n "CC3162" $f_path/$t_file | awk '{print $2}' > C1
grep -n "CC3161" $f_path/$t_file | grep "C4" | awk '{print $2}' > C4
grep -n "HCA1"   $f_path/$t_file | grep "H1"| awk '{print $2}' > H1
grep -n "OC3C61" $f_path/$t_file | grep "O5"| awk '{print $2}' > O5
grep -n "CC3161" $f_path/$t_file | grep "C2"| awk '{print $2}' > C2
grep -n "HCA1"   $f_path/$t_file | grep "H4"| awk '{print $2}' > H4
grep -n "CC3163" $f_path/$t_file | grep "C5"| awk '{print $2}' > C5
grep -n "HCA1"   $f_path/$t_file | grep "H2"| awk '{print $2}' > H2
grep -n "OC311"  $f_path/$t_file | grep "O2"| awk '{print $2}' > O2
grep -n "CC3161" $f_path/$t_file | grep -w "C3"| awk '{print $2}' > C3

O4=($(awk '{print $1}' < O4))
lO4=${#O4[@]}

C1=($(awk '{print $1}' < C1))

C4=($(awk '{print $1}' < C4))

H1=($(awk '{print $1}' < H1))

O5=($(awk '{print $1}' < O5))

C2=($(awk '{print $1}' < C2))

H4=($(awk '{print $1}' <H4))

C5=($(awk '{print $1}' < C5))

H2=($(awk '{print $1}' < H2))

O2=($(awk '{print $1}' < O2))

C3=($(awk '{print $1}' < C3))


###### SED WAY #######################
#var=()
#for ((i=0; i<=($l); i++)); do
#	echo ${O[i]} ${C1[i+1]} 
#	var+=("${O[i]} ${C1[i+1]} 1")
#        sed -i "/\[ bonds\ ]/a ${var[i]     1} " topol.top
#done



#################### awk way ##############################################################

######## ~~~ BONDS C1 -> O4 ~~~ ############

#IFS='%'
for ((i=0; i<=($lO4); i++)); do
#strvar+=" ${O[i]}     ${C1[i+1]}     1"$':'
strvar2+="${O4[i]}"$':'"${C1[i+1]}"$':'"1"$':'
done

#for ((i=0; i<=(${#var[@]}); i++)); do
#	echo ${var[i]}
#done

cat topol.top | awk -v s="${strvar2}" 'BEGIN{narr=split(s, arr, ":");flag=0;};
NR>0{print $0;}
$0 ~ /\[ bonds/ {flag=1} 
$0 ~ /funct/ {
    if (flag==1){
        for (i=1;i<narr-3;i+=3) {printf "%5s %5s %5s\n",arr[i],arr[i+1],arr[i+2]};
        flag=0;
    }
}' > topol2.top



############# ~~~ ANGLES ~~~ #################

for ((i=0; i<($lO4); i++)); do

    strvar_A+="${C4[i]}"$':'"${O4[i]}"$':'"${C1[i+1]}"$':'"5"$':'    # C4-O4-C1
    strvar_B+="${O4[i]}"$':'"${C1[i+1]}"$':'"${H1[i+1]}"$':'"5"$':'  # O4-C1-H1
    strvar_C+="${O4[i]}"$':'"${C1[i+1]}"$':'"${O5[i+1]}"$':'"5"$':'  # O4-C1-O5
    strvar_D+="${O4[i]}"$':'"${C1[i+1]}"$':'"${C2[i+1]}"$':'"5"$':'  # O4-C1-C2
done


string="$strvar_A$strvar_B$strvar_C$strvar_D"


#echo ${string}

#echo ${strvar_A[@]}
#echo ${strvar_B[@]}
#echo ${strvar_C[@]}
#echo ${strvar_D[@]}
cat topol2.top | awk -v s="${string}" 'BEGIN{narrA=split(s, arrA,":");flag=0;};
NR>0{print $0;}
$0 ~ /\[ angles/ {flag=1} 
$0 ~ /funct/ {
   if (flag==1){
             for (i=1;i<narrA;i+=4) {printf "%5s %5s %5s %5s\n",arrA[i],arrA[i+1],arrA[i+2], arrA[i+3]};      flag=0;
    }
}' > topol3.top

######### ~~~ DIHEDRALS ~~~ ##############

for ((i=0; i<($lO4); i++)); do

    strvar_a+="${C5[i]}"$':'"${C4[i]}"$':'"${O4[i]}"$':'"${C1[i+1]}"$':'"9"$':' 
    strvar_b+="${C3[i]}"$':'"${C4[i]}"$':'"${O4[i]}"$':'"${C1[i+1]}"$':'"9"$':'
    strvar_c+="${H4[i]}"$':'"${C4[i]}"$':'"${O4[i]}"$':'"${C1[i+1]}"$':'"9"$':'
    strvar_d+="${C4[i]}"$':'"${O4[i]}"$':'"${C1[i+1]}"$':'"${H1[i+1]}"$':'"9"$':'
    strvar_e+="${C4[i]}"$':'"${O4[i]}"$':'"${C1[i+1]}"$':'"${C2[i+1]}"$':'"9"$':'
    strvar_f+="${O4[i]}"$':'"${C1[i+1]}"$':'"${O5[i+1]}"$':'"${C5[i+1]}"$':'"9"$':'
    strvar_g+="${O4[i]}"$':'"${C1[i+1]}"$':'"${C2[i+1]}"$':'"${H2[i+1]}"$':'"9"$':'
    strvar_h+="${O4[i]}"$':'"${C1[i+1]}"$':'"${C2[i+1]}"$':'"${O2[i+1]}"$':'"9"$':'
    strvar_i+="${O4[i]}"$':'"${C1[i+1]}"$':'"${C2[i+1]}"$':'"${C3[i+1]}"$':'"9"$':'
    strvar_j+="${C4[i]}"$':'"${O4[i]}"$':'"${C1[i+1]}"$':'"${O5[i+1]}"$':'"9"$':'
done

   string_1="$strvar_a$strvar_b$strvar_c$strvar_d$strvar_e$strvar_f$strvar_g$strvar_h$strvar_i$strvar_j"

   #echo${string_1}
cat topol3.top | awk -v s="${string_1}" 'BEGIN{narrA=split(s, arrA,":");flag=0;};
   NR>0{print $0;}
    $0 ~ /\[ dihedrals/ {flag=1} 
    $0 ~ /funct/ {
        if (flag==1){
        for (i=1;i<narrA;i+=5) {printf "%5s %5s %5s %5s %5s\n",arrA[i],arrA[i+1],arrA[i+2],arrA[i+3], arrA[i+4]};      flag=0;
}
}' > topol4.top



######### ~~~~ PAIRS ~~~~######

for ((i=0; i<($lO4); i++)); do

    strvar_AA+="${C5[i]}"$':'"${C1[i+1]}"$':'"1"$':'    # C5 C1
    strvar_BB+="${C3[i]}"$':'"${C1[i+1]}"$':'"1"$':'  # C3 C1
    strvar_CC+="${C4[i]}"$':'"${H1[i+1]}"$':'"1"$':'  # C4 H1
    strvar_DD+="${C4[i]}"$':'"${O5[i+1]}"$':'"1"$':'  # C4 O5
    strvar_EE+="${C4[i]}"$':'"${C2[i+1]}"$':'"1"$':'    # C4 C2
    strvar_FF+="${H4[i]}"$':'"${C1[i+1]}"$':'"1"$':'  # H4 C1
    strvar_GG+="${O4[i]}"$':'"${C5[i+1]}"$':'"1"$':'  # O4 C5
    strvar_HH+="${O4[i]}"$':'"${H2[i+1]}"$':'"1"$':'  # O4 H2
    strvar_II+="${O4[i]}"$':'"${O2[i+1]}"$':'"1"$':'    # O4 O2
    strvar_JJ+="${O4[i]}"$':'"${C3[i+1]}"$':'"1"$':'  # O4 C3
    
done


 string_11="$strvar_AA$strvar_BB$strvar_CC$strvar_DD$strvar_EE$strvar_FF$strvar_GG$strvar_HH$strvar_II$strvar_JJ"

cat topol4.top | awk -v s="${string_11}" 'BEGIN{narrA=split(s, arrA,":");flag=0;};
   NR>0{print $0;}
    $0 ~ /\[ pairs/ {flag=1} 
    $0 ~ /funct/ {
        if (flag==1){
        for (i=1;i<narrA;i+=3) {printf "%5s %5s %5s \n",arrA[i],arrA[i+1],arrA[i+2]};      flag=0;
}
}' > topol5.top







#cat topol.top | awk -v s="${strvar}" 'BEGIN{narr=split(s, arr, ":");flag=0;};
#NR>0{print $0;}
#$0 ~ /\[ bonds/ {flag=1} 
#$0 ~ /funct/ {
#    if (flag==1){
#        for (i=0;i<narr;i++) {printf "%25s\n", arr[i]};
#        flag=0;
#    }
#}' > topol2.top


# cat: read topol and pipe to awk, then turn your string into an array via split fx
# NR: starting from top of topol print every line...
# $0: until you get to 'bonds' which is then flagged to do something
# $0: 'funct' not sure about this part...
# if: when at 'bonds' print the array variables i.e. i= 18 23, i+=38 43, i++58 63... print as string, for each i value we have a new line

# clean up the temporary files you created...
rm -r -f O4 C1 C4 H1 O5 C2 H4 C5 H2 O2 C3 topol2.top topol3.top topol4.top topol.top
mv topol5.top topol.top
