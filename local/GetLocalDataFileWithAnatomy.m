%% Return data file (with path) on the local file system
%  This .m file should be edited to point to a local directory
%  Changes to this file should not be checked into the repository

function [dataFileName, headModelFileName, sourceModelFileName] = GetLocalDataFileWithAnatomy()

dataFileName = '/Users/Kelsey/Projects/EON/MEG 20 subjects/hcp_microstate_data_restin/105923_MEG_3-Restin_rmegpreproc.mat';
headModelFileName = '/Users/Kelsey/Projects/EON/MEG 20 subjects/anatomy/105923_MEG_anatomy_headmodel.mat';
sourceModelFileName = '/Users/Kelsey/Projects/EON/MEG 20 subjects/anatomy/105923_MEG_anatomy_sourcemodel_2d.mat';

end