# Supporting Information: Input and output files in DFT calculations

This repo stores some of the input and output files used in `mcsqs` and VASP calculations of oxygen reduction reaction (OER) for the manuscript (ID: smll.202203340).

Codes used,

- modeling random alloys: `mcsqs` in Alloy Theoretic Automated Toolkit (ATAT)[https://www.brown.edu/Departments/Engineering/Labs/avdw/atat/]
- DFT calculations: `VASP5.4.4`[https://www.vasp.at/]
- Data post-processing: `VASPKIT`[https://vaspkit.com/], `pymatgen` (Python)[https://pymatgen.org/]

**COPYRIGHT Note:** to use the **pseudo potential (POTCAR)** files only when you have the license from VASP team.

## Files Description

- `./` includes excel data sheets of raw data, `R` and `Python` scripts for figure drawings, and additional `Origin` files.

- `./SQS` includes 

  1. using `mcsqs` to generate special quasi-random structures (SQS) for Fe$_x$Ni$_{1-x}$ disordered alloys (x = 0.25, 0.50 and 0.75) (`./SQS/mcsqs`);

  1. using `VASP` to relax structures and get total energies of bulks (`./SQS/bulk`) and slabs (`./SQS/surface`), for bulk  there are four groups of SQS with different number of atoms (*n* = 16, 32, 48, 108) and cell shapes.

- `./OER` includes the OER calculations on 1/4 monolayer(ML) O-covered surfaces

  1. `slab, OH, O, OOH`, four groups of relaxed and scf calculations;

  1. Density of states (DOS) calculations in `slab` , crystal orbital Hamilton population (COHP) in `OH`, and d-band centers data in both.







