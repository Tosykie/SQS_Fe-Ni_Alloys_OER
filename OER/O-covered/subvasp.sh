#!/bin/bash
export LD_LIBRARY_PATH=/BIGDATA1/app/intelcompiler/14.0.2/composer_xe_2013_sp1.2.144/bin/intel64:/BIGDATA1/app/intelcompiler/14.0.2/composer_xe_2013_sp1.2.144/compiler/lib/intel64:$LD_LIBRARY_PATH
source /BIGDATA1/app/intelcompiler/14.0.2/composer_xe_2013_sp1.2.144/mkl/bin/mklvars.sh intel64
VASP_PATH=~/softwares/VASP/vasp5.4-v3/vasp.5.4.4/bin
export PATH=${VASP_PATH}:$PATH

yhrun -N $SLURM_NNODES -n $SLURM_NTASKS vasp_$1
