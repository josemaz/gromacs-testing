
[[ -d scratch ]] && rm -rf scratch
mkdir scratch; cd scratch

#timeout 15m gmx mdrun -s ../villin.tpr -ntmpi 12 -ntomp 8 -pin on -nsteps 10000000
timeout 15m gmx mdrun -s ../dppc.tpr -ntmpi 1 -ntomp $(nproc) -pin on -nsteps 10000000
