#!/bin/bash --noprofile
################################################################################
##                    Copyright (C) 2004 Carlo Sbraccia.                      ##
##                 This file is distributed under the terms                   ##
##                 of the GNU General Public License.                         ##
##                 See http://www.gnu.org/copyleft/gpl.txt .                  ##
##                                                                            ##
##    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,         ##
##    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF      ##
##    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND                   ##
##    NONINFRINGEMENT.  IN NO EVENT SHALL CARLO SBRACCIA BE LIABLE FOR ANY    ##
##    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,    ##
##    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE       ##
##    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                  ##
################################################################################
#
# ... Usage: pwscf_bench.sh [ number of tests ]
# ... number of tests can be 1 to a maximum of 4 different tests
# ... if nothing is specified, or nothing valid, 4 is assumed
#
# ... architecture to be tested
#
ARCH=Gold6354
#
# ... path to the pw.x executable
#
EXE="/opt/apps/qe-gnu/bin/pw.x"
#EXE="$HOME/espressostable/espresso-4.0.4/bin/pw.x"
#
# ... path to the scratch directory
#
SCRATCH_DIR="$HOME/scratch"
#
# ... variables for parallel execution
#
#PREFIX="mpirun -np 2 "
POSTFIX=""
#
################################################################################
################################################################################
######             DO NOT MODIFY THE SCRIPT UNDER THESE LINES             ######
################################################################################
################################################################################
#
if test "$#" != 0; then
   num_of_tests=$1
else
   num_of_tests=4
fi
echo $num_of_tests
#
if [[ ${num_of_tests} -gt 4 ||  ${num_of_tests} -lt 1 ]]; then
   #
   printf "\n num_of_tests = ${num_of_tests}  (must be > 0 and < 5):"
   printf "  num_of_tests set to 4 \n\n"
   #
   num_of_tests=4
   #
fi
#
#  ... reference results
#
REFERENCE="opteron-ictp-2cpu"
#
ref_t[1]=205.90
ref_t[2]=693.41
ref_t[3]=2854.13
ref_t[4]=4977.66
#
ref_e[1]=-253.633943480
ref_e[2]=-3541.13059179
ref_e[3]=-5057.82430045
ref_e[4]=-2588.56989200
#
printf "\n bechmarking PWscf on $ARCH :  ${num_of_tests} test to be done\n"
printf "\n reference system is $REFERENCE \n\n"
#
# ... output files are parsed here (the bench score is also computed here)
#
printf "\n %s   %s   %s    %s    %s     %s      %s\n\n" \
     "test" "nbndx" "npwx" "cpu-time" "total energy" "ref. energy"
#     "test" "nbndx" "npwx" "cpu-time" "I/O-time" "total energy" "ref. energy"
#
score="0.0"
#
for i in $( seq ${num_of_tests} ); do
   #
   file=test_${i}.out
   #
   check=$( grep "convergence has been achieved" ${file} | awk '{print $4}' )
   #
   if [[ "${check}" !=  "achieved" ]]; then
      #
      echo "test_${i} :  convergence has NOT been achieved"; exit
      #
   fi
   #
   tcpu=$( grep "electrons" ${file} | grep WALL  | awk '{print $5}' )
   #tcpu=$( grep "electrons" ${file} | grep CPU  | awk '{print $3}'  )
   #tcpu=${tcpu:0:${#tcpu}-1}
   #tio=$(  grep "davcio"            ${file}     | awk '{print $3}'  )

   # https://pranabdas.github.io/espresso/hands-on/scf
   #nbndx=$( grep "Kohn-Sham Wave" ${file} | cut -d'(' -f2 | awk '{print $2}' \
   #         | sed 's/)//' )
   nbndx=$( grep Sum ${file} | awk '{print $7}') # Number of plane waves
   #npwx=$(  grep "Kohn-Sham Wave" ${file} | cut -d'(' -f2 | awk '{print $1}' \
   #         | sed 's/,//' )
   npwx=$( grep Kohn-Sham ${file} | awk '{print $5}' ) # Number of bands

   ener=$( grep "!    total energy" ${file}     | awk '{print $5}' )

   printf "    %i    %4i  %5i  %10s  %16.8f %16.8f\n" \
        ${i} ${nbndx} ${npwx} ${tcpu} ${ener} ${ref_e[${i}]}
   
   tcpu=$( echo ${tcpu} | awk -F s '{print $1}' )
   #
   result=$( echo "(${ref_t[${i}]}/${tcpu}*100.0)/${num_of_tests}.0" | bc -l )
   #
   score=$( echo "${score} + ${result}" | bc -l )
   #
done
#
message="(100.00 is the score of the reference system)"
#
printf "\n $ARCH score is %6.2f ${message}\n\n" ${score}
#
# ... end of the script
#
