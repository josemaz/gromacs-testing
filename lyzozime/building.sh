#! Only production
gmx grompp -f md.mdp -c ../npt/npt.gro -t ../npt/npt.cpt -p ../topol.top -o md_0_1.tpr
gmx mdrun -deffnm md_0_1 -nsteps 10000000

