#!/bin/bash
#------------------------------
# This script finds data file matching the env var EXPERIMENTID and passes them to the eon_microstates script

# SET ENVIRONMENT VARIABLES NEEDED FOR SUBSEQUENT SCRIPT
MCRDIR="/export/matlab/MCR/R2012b/v80"     # This is the directory where Matlab MCR libraries are located 
PROJECTHOME="/home/mkelse01/eon/eon_microstates"
BINEXECDIR="$PROJECTHOME/bin"       # This is the directory where the megconnectome.sh and megconnectome executables are located. 
ADDPATH="$PROJECTHOME/template"     # This variable contains all the directories to be added in the matlab path at the beginnning of each pipeline.  
DATADIR="/BlueArc-scratch/kelseym/MEG_20_Subjects/hcp_microstate_data_restin"     # This is the directory containing MEG data to be processed
OUTPUTDIR="/home/mkelse01/eon/pipeline_output"

echo "EXPERIMENTID      =" $EXPERIMENTID

#------------------------------
# Find list of filenames that contain EXPERIMENTID
#------------------------------

MATLABFILENAME="{"
FILES=`find $DATADIR -name "*$EXPERIMENTID*.mat"`;
for F in $FILES
do
  MATLABFILENAME="$MATLABFILENAME'$F',"
done
MATLABFILENAME="$MATLABFILENAME}"

SUBJECTID=`echo $EXPERIMENTID | cut -d '_' -f 1`


echo
echo "SUBJECTID      =" $SUBJECTID
echo "NUMMICROSTATES =" $NUMMICROSTATES
echo "OUTPUTDIR      =" $OUTPUTDIR 
echo "MATLABFILENAME =" $MATLABFILENAME



#------------------------------
#------------------------------
#RUN PIPELINE SCRIPT 
 echo " Starting pipeline " 
 echo " ======================================================= " 
sh $BINEXECDIR/eon_microstates.sh $MCRDIR  $PROJECTHOME/pipeline_scripts/BandLimitedTopographyStabilityPipeline.m --subjectid $SUBJECTID --filename $MATLABFILENAME --numMicrostates $NUMMICROSTATES --outputDir $OUTPUTDIR --path $ADDPATH
#------------------------------
