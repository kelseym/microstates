#!/bin/bash
LOGDIR=/home/kelseym/eon/pipeline_logs
QSUBDIR=/home/kelseym/eon/eon_microstates/bin/
#PIPELINE="BandLimitedTopographyStability"
PIPELINE="BandLimitedGEV"


#-------------------------------------------------------------- 

DATADIR="/BlueArc-scratch/kelseym/MEG_20_Subjects/hcp_microstate_data_restin"     # This is the directory containing MEG data to be processed
DATAFILES=`find $DATADIR -type f -name "*3-Restin*.mat" -print0 | xargs --null -n1 basename`;
for ff in $DATAFILES
do
  export EXPERIMENTID=${ff:0:19}
  echo $EXPERIMENTID
  qsub -V -q dque -l walltime=23:59:59,mem=12gb,vmem=12gb  -o $LOGDIR/OUTLOG_$PIPELINE_$EXPERIMENTID.log -e $LOGDIR/ERRORLOG_$PIPELINE_$EXPERIMENTID.log $QSUBDIR/$PIPELINE.pbs > $LOGDIR/jobids-$PIPELINE_$EXPERIMENTID.txt
done

#-------------------------------------------------------------- 
