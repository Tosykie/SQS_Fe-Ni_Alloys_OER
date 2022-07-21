#!/bin/bash
## author: nongw
## This is a Shell script for VASP to NSCF(DOS)
#---------------------------- Function ----------------------------#
#--------------------------- Calculations -------------------------#
makepot ${elements} 
#3 None Self-consistent Calculation, ICHARG = 11#
if [ ! -s "stopcar" ] && [ -s "POSCAR_opt" ] && [ -s CHGCAR ];then
  cp INCAR_nscf INCAR
  cp POSCAR_opt POSCAR
  #kpoints G 8 8 1
  source subvasp.sh std
  backbase dos-backup
  #rm WAVECAR
  rm CHG PROCAR
  gzip CHGCAR
  if [ -s "DOSCAR" ]; then (echo 503;echo Y;echo "-10 5")|vaspkit ;fi
fi
