#!/bin/bash
## author: nongw
## This is a Shell script for VASP to ZPE
#---------------------------- Function ----------------------------#
#--------------------------- Calculations -------------------------#
makepot ${elements}
#sed -e '7a\Selective dynamics' -e '9,86s/$/ F F F/' -e '10,12s/F/T/g' -e '85,86s/F/T/g' POSCAR_opt > POSCAR_selective
sed '10,77s/T/F/g' POSCAR_opt > POSCAR_selective
#4 Zero-point Energy from Harmonic Approximations#
if [ ! -s "stopcar" ] && [ -s "POSCAR_selective" ];then
  if [ -s "CHGCAR.gz" ]; then gzip -d CHGCAR.gz ; fi
  cp POSCAR_selective POSCAR
  cp INCAR_zpe INCAR
  #kpoints G 1 1 1
  changetag KSPACING 1.0
  source subvasp.sh gam
  grep cm-1 OUTCAR > comment-fr
  zpevalue=`echo "scale=3;$(grep 'f  =' OUTCAR | awk '{print $10}' | paste -sd+ |bc)/2.0/1000.0" | bc` 
  echo "ZPE is $zpevalue eV!" >>comment-fr
  backbase zpe-backup
  if [ -s "comment-fr" ];then gzip CHGCAR ; fi
  mv comment-fr zpe-backup/
else
  echo "MISSING ERRO: NO POSCAR_selective exists! Or a stopcar file existed."
  exit 3
fi
