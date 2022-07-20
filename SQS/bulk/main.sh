#!/bin/bash
#PBS -N SQS16
#PBS -l select=1:ncpus=24,walltime=2:00:00
#PBS -j oe
#PBS -q normal
#PBS -P Personal
#PBS -M nong0003@e.ntu.edu.sg
#PBS -m be
cd $PBS_O_WORKDIR

NP=24
potdir=/home/users/ntu/nong0003/programs/VASP/pot/potpaw_PBE.54
source functions.sh
#---------------------------- Calculations ----------------------------#
elements="Ni Fe"
POSCAR_input="*POSCAR*.vasp"
echo "Start: `date`" >> RunTime.log
source opt.sh
source scf.sh
source dos.sh
#source band.sh
#source test.sh
echo "End: `date`" >> RunTime.log
