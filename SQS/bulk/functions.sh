#!/bin/bash
#---------------------------- Functions ----------------------------#
function makepot(){
	if [ -f POTCAR ] ; then
		mv -f POTCAR POTCAR.old
	fi
	for pots in $*;
	do
		cat ${potdir}/${pots}/POTCAR >> POTCAR
	done
}

function kpoints(){
echo "K-POINTS" > KPOINTS
echo " 0" >> KPOINTS
if [ -z $1 ]||[ ${1:0:1} == "G" ]&&[ -z $2 ]
then
    echo "Gamma-Centered" >> KPOINTS
    echo " 1 1 1" >> KPOINTS
    echo " 0 0 0" >> KPOINTS
    exit
else
	if [ ${1:0:1} == "M" ] ; then
		echo "Monkhorst-Pack" >> KPOINTS
		if [ -z $2 ]; then
		    echo " 1 1 1" >> KPOINTS
			echo " 0 0 0" >> KPOINTS
			exit
		fi
	elif [ ${1:0:1} == "G" ]; then
			echo "Gamma-Centered" >> KPOINTS
	elif [[ $1 =~ ^[0-9]+$ ]]; then
			echo "Gamma-Centered" >> KPOINTS
			echo " $1 $2 $3" >> KPOINTS
			echo " 0 0 0" >> KPOINTS
			exit
	else
		echo "Your input is WRONG. TRY kpoint G 1 1 1"
		exit
	fi
	echo " $2 $3 $4" >> KPOINTS
	echo " 0 0 0" >> KPOINTS
fi
}

function ifreached(){
# Test If Reached Accuracy
	times=0
	res=`grep -s "reached required accuracy - stopping structural energy minimisation" OUTCAR`
	until [ ! -z "$res" ] ||  [ "${times}" -gt 3  ] || [ -s "stopcar" ]
	do
		cp POSCAR POSCAR-${times}
		cp OUTCAR OUTCAR-${times}
		cp XDATCAR XDATCAR-${times}
		cp CONTCAR CONTCAR-${times}
		cp OSZICAR OSZICAR-${times}
		cp CONTCAR POSCAR
		source subvasp.sh $1
		res=`grep -s "reached required accuracy - stopping structural energy minimisation" OUTCAR`
		times=$((times+1))
	done
	echo "Geometry optimization $1 repeats ${times} times, and reached required accuracy. Continue calculation!"  >> opt-state
}

function backbase(){
	mkdir $1
	cp INCAR KPOINTS POSCAR POTCAR OUTCAR CONTCAR IBZKPT XDATCAR OSZICAR DOSCAR vasprun.xml $1
}

function changetag(){
	TAGS=$1 ; value=$2
	sed -i "s/${TAGS}[[:space:]]*=[[:space:]]*[-Ee.0-9]*/${TAGS} = ${value}/" INCAR
}
