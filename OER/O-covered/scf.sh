#!/bin/bash
## author: nongw
## This is a Shell script for VASP to SCF
#---------------------------- Function ----------------------------#
#--------------------------- Calculations -------------------------#
makepot ${elements} 
#2 Static Self-consistent Calculation#
if [ ! -s "stopcar" ] && [ -s "POSCAR_opt" ];then
  cp POSCAR_opt POSCAR
  cp INCAR_scf INCAR
  #kpoints G 5 5 5
  source subvasp.sh std
  Et=`grep "energy  without entropy=" OUTCAR | tail -1 | awk '{printf "%12.6f \n", $7 }'`
  Ef=`grep "E-fermi" OUTCAR | tail -n 1 | awk '{printf "%1.4f", $3}'` 
  echo "Et = $Et eV, Ef = $Ef eV" > comment-E
  backbase scf-backup
  mv comment-E scf-backup/
  rm CHG WAVECAR
else
  echo "NO POSCAR_opt exists! Or a stopcar file existed."
  exit 3
fi
