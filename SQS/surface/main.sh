#!/bin/bash
#PBS -N Suface64
#PBS -l select=3:ncpus=24,walltime=12:00:00
#PBS -j oe
#PBS -q normal
#PBS -P Personal
#PBS -M nong0003@e.ntu.edu.sg
#PBS -m be
cd $PBS_O_WORKDIR

NP=72
potdir=/home/users/ntu/nong0003/programs/VASP/pot/potpaw_PBE.54
source functions.sh
#---------------------------- Calculations ----------------------------#
elements="Fe Ni"
POSCAR_input="*POSCAR*.vasp"
echo "Start: `date`" >> RunTime.log
source opt.sh
source scf.sh
source scf-vdw.sh
source dos.sh
source bader.sh
#source band.sh
#source test.sh
echo "End: `date`" >> RunTime.log
