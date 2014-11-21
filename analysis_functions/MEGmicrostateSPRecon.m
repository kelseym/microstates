%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (C) 2014 by EON Lab, Washington University School of Medicine
%
%%% Source space reconstruction of a microstate topo map
%  Given a head model and microstate map, compute an MNE source projection
%  
% Use as
%   [source] = MEGmicrostateSPRecon(cfg);
%
%  Input:
%  cfg.sourcemodel2d = source model from subjectid_MEG_anatomy_sourcemodel_2d.mat
%  cfg.headmodel = anatomy model from subjectid_MEG_anatomy_headmodel.mat
%  cfg.grad = sensor positions read by ft_read_sens() - assumed to be for gradiomoter
%  cfg.MicrostateTopo = Nsensors x M microstates - single time point
%                       topologies to map to source space
%  cfg.MicrostateLabels = Sensor labels matching the order of sensors in
%                         MicrostateTopo
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [source] = MEGmicrostateSPRecon(cfg)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup the execution environment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Modify the source and volume conduction models and sensor positions

sourcemodel2d=ft_convert_units(cfg.sourcemodel2d, 'cm');
sourcemodel2d.inside = 1:size(sourcemodel2d.pos,1);
sourcemodel2d.outside = [];
sourcemodelsubj = sourcemodel2d;

headmodel = ft_convert_units(cfg.headmodel, 'cm');

gradBalanced = cfg.grad;
gradBalanced = ft_apply_montage(gradBalanced, gradBalanced.balance.Supine, 'keepunused', 'yes', 'inverse', 'yes');
grad=gradBalanced;
grad = ft_convert_units(grad, 'cm');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up then process each microstate provided in cfg.MicrostateTopo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
channels = cfg.MicrostateLabels;
MicroStates = cfg.MicrostateTopo;

% create a 'timelock' structure
tlck = [];
tlck.label = channels;
tlck.cov = eye(numel(tlck.label)); 
tlck.time=1;
tlck.grad = grad;
tlck.dimord = 'chan_time';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute the forward solution
cfg = [];
cfg.vol = headmodel;
cfg.grid = sourcemodelsubj;
cfg.grad = grad;
cfg.channel = channels;
cfg.normalize = 'yes';
cfg.reducerank = 2;
gridLF = ft_prepare_leadfield(cfg);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% specify the static part of the cfg for the source reconstruction
% this parameter is hard-coded and will need to be tweaked for Microstates

noise_level = 8;
cfg               = [];
cfg.method        = 'mne';
cfg.grid          = gridLF;
cfg.vol           = headmodel;
cfg.channel       = channels;
cfg.mne.prewhiten = 'yes';
cfg.mne.noisecov  = eye(numel(channels))*noise_level;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop through the microstates

for ti=1:size(MicroStates,1)
    MicrostateTopo = MicroStates(ti,:);
    % normalisation of the topographies for ft_sourceanalysis. This will take
    % some tweaking
    for i = 1:size(MicrostateTopo, 2)
      val(i) = 0.01*max(abs(MicrostateTopo(:, i)));
      MicrostateTopo(:, i) = MicrostateTopo(:, i)/val(i);
    end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % do an MNE with different regularisation for each microstate
    
   % use the channel-level topography of the current Microstate
   tlck.avg = MicrostateTopo(:, ti);
   % estimate the snr of the current Microstate
   cfg.mne.snr = sqrt(mean((MicrostateTopo(:,ti)-mean(MicrostateTopo(:,ti))).^2))/noise_level;
   noisevec(ti) = cfg.mne.snr; 
   
  tmp = ft_sourceanalysis(cfg, tlck);
  
  if isfield(sourcemodelsubj,'tri'),            tmp.tri            = sourcemodelsubj.tri;            end
  if isfield(sourcemodelsubj,'brainstructure'), tmp.brainstructure = sourcemodelsubj.brainstructure; end
  if isfield(sourcemodelsubj,'brainstructurelabel'), tmp.brainstructurelabel = sourcemodelsubj.brainstructurelabel; end
  
  % Plot source space map for each microstate (need number of vertices)
  ft_plot_mesh(tmp,'vertexcolor',sourcemodelsubj.inside)
  view(-90,90)
  % Prepare output structure
  source(ti) = tmp;
end


end


