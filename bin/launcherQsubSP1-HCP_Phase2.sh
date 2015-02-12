#!/bin/bash
LOGDIR=/BlueArc-scratch/kelseym/v2.x_runlogs
#LOGDIR=/home/kelseym/LaunchSP1-HCP_Phase2
QSUBDIR=/home/kelseym/LaunchSP1-HCP_Phase2
#-------------------------------------------------------------- 
#-------------------------------------------------------------- 
#-------------------------------------------------------------- 
qsub -V -q pe1_iD_48hr -l walltime=47:59:00,mem=16gb,vmem=16gb  -o $LOGDIR/OUTLOG_SP1-HCP_Phase2-$EXPERIMENTID-1-Rnoise.log -e $LOGDIR/ERRORLOG_SP1-HCP_Phase2-$EXPERIMENTID-1-Rnoise.log $QSUBDIR/SP1-HCP_Phase2-1-Rnoise.pbs > $QSUBDIR/SP1-jobids-HCP_Phase2-$EXPERIMENTID.txt
#===============================================================================
qsub -V -q pe1_iD_48hr -l walltime=47:59:00,mem=16gb,vmem=16gb  -o $LOGDIR/OUTLOG_SP1-HCP_Phase2-$EXPERIMENTID-2-Pnoise.log -e $LOGDIR/ERRORLOG_SP1-HCP_Phase2-$EXPERIMENTID-2-Pnoise.log $QSUBDIR/SP1-HCP_Phase2-2-Pnoise.pbs > $QSUBDIR/SP1-jobids-HCP_Phase2-$EXPERIMENTID.txt
#===============================================================================
#===============================================================================
qsub -V -q pe1_iD_48hr -l walltime=47:59:00,mem=20gb,vmem=20gb  -o $LOGDIR/OUTLOG_SP1-HCP_Phase2-$EXPERIMENTID-3-Restin.log -e $LOGDIR/ERRORLOG_SP1-HCP_Phase2-$EXPERIMENTID-3-Restin.log $QSUBDIR/SP1-HCP_Phase2-3-Restin.pbs >> $QSUBDIR/SP1-jobids-HCP_Phase2-$EXPERIMENTID.txt
#===============================================================================
qsub -V -q pe1_iD_48hr -l walltime=47:59:00,mem=20gb,vmem=20gb  -o $LOGDIR/OUTLOG_SP1-HCP_Phase2-$EXPERIMENTID-4-Restin.log -e $LOGDIR/ERRORLOG_SP1-HCP_Phase2-$EXPERIMENTID-4-Restin.log $QSUBDIR/SP1-HCP_Phase2-4-Restin.pbs >> $QSUBDIR/SP1-jobids-HCP_Phase2-$EXPERIMENTID.txt
#===============================================================================
qsub -V -q pe1_iD_48hr -l walltime=47:59:00,mem=20gb,vmem=20gb  -o $LOGDIR/OUTLOG_SP1-HCP_Phase2-$EXPERIMENTID-5-Restin.log -e $LOGDIR/ERRORLOG_SP1-HCP_Phase2-$EXPERIMENTID-5-Restin.log $QSUBDIR/SP1-HCP_Phase2-5-Restin.pbs >> $QSUBDIR/SP1-jobids-HCP_Phase2-$EXPERIMENTID.txt
#===============================================================================
#===============================================================================
qsub -V -q pe1_iD_48hr -l walltime=47:59:00,mem=40gb,vmem=40gb  -o $LOGDIR/OUTLOG_SP1-HCP_Phase2-$EXPERIMENTID-6-Wrkmem.log -e $LOGDIR/ERRORLOG_SP1-HCP_Phase2-$EXPERIMENTID-6-Wrkmem.log $QSUBDIR/SP1-HCP_Phase2-6-Wrkmem.pbs >> $QSUBDIR/SP1-jobids-HCP_Phase2-$EXPERIMENTID.txt
#===============================================================================
qsub -V -q pe1_iD_48hr -l walltime=47:59:00,mem=40gb,vmem=40gb  -o $LOGDIR/OUTLOG_SP1-HCP_Phase2-$EXPERIMENTID-7-Wrkmem.log -e $LOGDIR/ERRORLOG_SP1-HCP_Phase2-$EXPERIMENTID-7-Wrkmem.log $QSUBDIR/SP1-HCP_Phase2-7-Wrkmem.pbs >> $QSUBDIR/SP1-jobids-HCP_Phase2-$EXPERIMENTID.txt
#===============================================================================
qsub -V -q pe1_iD_48hr -l walltime=47:59:00,mem=40gb,vmem=40gb  -o $LOGDIR/OUTLOG_SP1-HCP_Phase2-$EXPERIMENTID-8-StoryM.log -e $LOGDIR/ERRORLOG_SP1-HCP_Phase2-$EXPERIMENTID-8-StoryM.log $QSUBDIR/SP1-HCP_Phase2-8-StoryM.pbs >> $QSUBDIR/SP1-jobids-HCP_Phase2-$EXPERIMENTID.txt
#===============================================================================
qsub -V -q pe1_iD_48hr -l walltime=47:59:00,mem=40gb,vmem=40gb  -o $LOGDIR/OUTLOG_SP1-HCP_Phase2-$EXPERIMENTID-9-StoryM.log -e $LOGDIR/ERRORLOG_SP1-HCP_Phase2-$EXPERIMENTID-9-StoryM.log $QSUBDIR/SP1-HCP_Phase2-9-StoryM.pbs >> $QSUBDIR/SP1-jobids-HCP_Phase2-$EXPERIMENTID.txt
#===============================================================================
qsub -V -q pe1_iD_48hr -l walltime=47:59:00,mem=40gb,vmem=40gb  -o $LOGDIR/OUTLOG_SP1-HCP_Phase2-$EXPERIMENTID-10-Motort.log -e $LOGDIR/ERRORLOG_SP1-HCP_Phase2-$EXPERIMENTID-10-Motort.log $QSUBDIR/SP1-HCP_Phase2-10-Motort.pbs >> $QSUBDIR/SP1-jobids-HCP_Phase2-$EXPERIMENTID.txt
#===============================================================================
qsub -V -q pe1_iD_48hr -l walltime=47:59:00,mem=40gb,vmem=40gb  -o $LOGDIR/OUTLOG_SP1-HCP_Phase2-$EXPERIMENTID-11-Motort.log -e $LOGDIR/ERRORLOG_SP1-HCP_Phase2-$EXPERIMENTID-11-Motort.log $QSUBDIR/SP1-HCP_Phase2-11-Motort.pbs >> $QSUBDIR/SP1-jobids-HCP_Phase2-$EXPERIMENTID.txt
#===============================================================================

chown :hcpi $LOGDIR -R
chmod 740 $LOGDIR -R

