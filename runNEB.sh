#!/bin/bash

# This script runs the VASP NEB calculation for batch jobs.

# Inputs. num_img is the total number of images including endpoints.
POSCAR_in=POSCAR_initial
POSCAR_fin=POSCAR_final
num_img=10
cores=320
atom_sep=1.0 # Minimum atom separation in Angstroms

# Change IRR_NUM in INPUT as the directry name number.
dirname=$PWD
folder="${dirname%"${dirname##*[!/]}"}"
folder="${folder##*/}"
sed -i -e "s/XXX/$folder/g" INPUT

# Run makeNEB.sh
makeNEB.sh $POSCAR_in $POSCAR_fin $num_img > makeNEB.out

# Copy initial and final OUTCAR's to 00 and last image directory.
last_dir=$(($num_img-1))
cp ../inputs/OUTCAR_initial 00/OUTCAR
cp ../inputs/OUTCAR_final $(printf %02d $last_dir)/OUTCAR

# Only run VASP if valid irredicuble representation found.
done=$( tail -n 1 makeNEB.out )
if [$done == 'Done.']
then
    nebavoid.pl $atom_sep
    mpirun -np $cores vasp_std
    nebresults.pl
else
    echo "Invalid Irreducible Representation!"
fi
