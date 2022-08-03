#!/bin/bash
## author: nongw
## This is a Shell script for VASP to strucrure optimization
#---------------------------- Function ----------------------------#
#--------------------------- Calculations -------------------------#
makepot ${elements} 
#1 Geometry Optimization#
if [ -s ${POSCAR_input} ];then cp ${POSCAR_input} POSCAR ;
else echo "The input POSCAR NOT exits."; exit 3; fi
xopt=3
incar=(2 3 3 3)
#kmesh=("G 1 1 1" "G 3 3 3" "G 3 3 3" "G 5 5 5")
kspacing=(1.0 0.5 0.4 0.3)
version=(gam std std std)
for step in `seq 0 ${xopt}`
do
  if [ ! -s "stopcar" ];then
    cp INCAR_opt${incar[step]} INCAR
    #kpoints ${kmesh[step]}
    changetag KSPACING ${kspacing[step]}
    source subvasp.sh ${version[step]}
    ifreached ${version[step]}
    backbase opt-backup$((step+1))
    mv POSCAR-* OUTCAR-* XDATCAR-* CONTCAR-* OSZICAR-* opt-backup$((step+1))
    if [ ! -s CONTCAR ];then break ; fi
    cp CONTCAR POSCAR_opt$((step+1))
    cp POSCAR_opt$((step+1)) POSCAR
    if [ ${step} -eq ${xopt} ];then cp POSCAR_opt$((step+1)) POSCAR_opt;fi
  else
    break
  fi
done
