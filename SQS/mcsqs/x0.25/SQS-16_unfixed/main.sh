#!/bin/bash
#PBS -N SQS108
#PBS -l select=1:ncpus=1,walltime=2:00:00
#PBS -j oe
#PBS -q normal
#PBS -P Personal
#PBS -M nong0003@e.ntu.edu.sg
#PBS -m be
cd $PBS_O_WORKDIR

mcsqs -n=16
