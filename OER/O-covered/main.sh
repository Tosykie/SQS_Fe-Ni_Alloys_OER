#!/bin/bash
#SBATCH -J SQS-FeNi-OER
#SBATCH -p bigdata
#SBATCH -N 3
#SBATCH --ntasks-per-node=24
potdir=~/softwares/VASP/pot/pot_PBE.54

source functions.sh
#---------------------------- Calculations ----------------------------#
xsd2pos.py
elements="Fe Ni O H" 
echo "Start: `date`" >> RunTime.log
POSCAR_input="POSCAR_*.vasp"
source opt.sh
source scf.sh
source dos.sh
source bader.sh
source zpe.sh
echo "End: `date`" >> RunTime.log
