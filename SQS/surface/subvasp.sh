#!/bin/bash
#PBS -N vasp-name-compute
#PBS -l select=1:ncpus=24,walltime=23:59:00
#PBS -j n
#PBS -q normal
#PBS -P Personal
#PBS -e ${PBS_JOBNAME}.err
#PBS -o ${PBS_JOBNAME}.out
#PBS -M nong0003@e.ntu.edu.sg
#PBS -m ae
cd $PBS_O_WORKDIR

#NP=`cat $PBS_NODEFILE|wc -l`
source /app/intel/compilers_and_libraries_2016.1.150/linux/mpi/intel64/bin/mpivars.sh
VASP_PATH=/home/users/ntu/nong0003/programs/VASP/vasp5.4-neb/vasp.5.4.4/bin
export PATH=${VASP_PATH}:$PATH
ulimit -s unlimited

#mpirun -np ${NP} -machinefile $PBS_NODEFILE vasp_$1 > ${PBS_JOBNAME}_${NP}Core_${PBS_JOBID}.out
mpirun -np ${NP} vasp_$1 >> ${PBS_JOBNAME}_${PBS_JOBID}.out
