#!/bin/bash
LOGDIR=/home/kelseym/eon/pipeline_logs
QSUBDIR=/home/kelseym/eon/eon_microstates/bin/
#PIPELINE="BandLimitedTopographyStability"
PIPELINE="RegionalBandLimitedGEV"


#-------------------------------------------------------------- 

DATADIR="/BlueArc-scratch/kelseym/MEG_20_Subjects/hcp_microstate_data_restin"     # This is the directory containing MEG data to be processed
DATAFILES=`find $DATADIR -name "*.mat"`;
for ff in $DATAFILES
do
  export EXPERIMENTID=${ff:2:19}
  while read BAND; do
    export BANDS=$BAND
    qsub -V -q dque -l walltime=8:59:59,mem=16gb,vmem=16gb  -o $LOGDIR/OUTLOG_$PIPELINE_$EXPERIMENTID.log -e $LOGDIR/ERRORLOG_$PIPELINE_$EXPERIMENTID.log $QSUBDIR/$PIPELINE.pbs > $LOGDIR/jobids-$PIPELINE_$EXPERIMENTID.txt
  done < bandList.txt
done

#-------------------------------------------------------------- 
