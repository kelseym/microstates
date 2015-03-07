#!/bin/bash
LOGDIR=/home/kelseym/eon/pipeline_logs
QSUBDIR=/home/kelseym/eon/eon_microstates/bin/
PIPELINE="BandLimitedTopographyStability"
#-------------------------------------------------------------- 

qsub -V -q dque -l walltime=23:59:59,mem=24gb,vmem=24gb  -o $LOGDIR/OUTLOG_$PIPELINE_$EXPERIMENTID.log -e $LOGDIR/ERRORLOG_$PIPELINE_$EXPERIMENTID.log $QSUBDIR/band_limited_topography_stability.pbs > $LOGDIR/jobids-$PIPELINE_$EXPERIMENTID.txt

#-------------------------------------------------------------- 
