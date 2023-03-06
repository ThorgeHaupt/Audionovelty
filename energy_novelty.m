function [novelty, fs_new] = energy_novelty(x,fs,varargin)
%% local energy function 
%computes the energy rate of change at every sampling point
%Input:
%x = signal of interest (sample points x 1)
%fs = sampling rate
%
%Optional:
%N = integer,       smoothing window length(def: 2048)
%H = integer,       hop parameter (def: 128), larger value leads more
%                   spread out peaks
%M = interger       in s, determines (2M +1) window size for local average, if []
%                   local average will not be computed (def: 0.5s)
%log = logcial,     logarithmic compression (def: 1)
%gamma = integer    scaling factor before log (def: 10)
%norm = logical,    normalization of the novelty function (def: 1)
%plt =              plot the resulting novelty function and peaks (def: 0)
%                   is always displayed for the first 12 seconds
%
%
%Output:
%novelty - novelty function 
%fs_new - new sampling rate
%
%
%Note
%to compute the peaks use one of the following peak functions
%simp_peak(novelty,...)
%smooth_peak(novelty,...)


opt = propertylist2struct(varargin{:});
opt = set_defaults(opt,...
    'N',2048,...
    'H',128,...
    'M',0.5,...
    'log',1,...
    'gamma',10,...
    'norm',1,...
    'plt',0);



N = opt.N;
w = hann(N);
H = opt.H;
M = opt.M;
fs_new = fs/H;

%compute the local energy
energy_local = conv(x.^2,w.^2,'same');
energy_local = energy_local(1:H:end,1);

%take the log
if opt.log
    energy_local = log(1 + opt.gamma .* energy_local);
end

%take the derivative
energy_local_diff = diff(energy_local);
energy_local_diff = cat(1,energy_local_diff,zeros(1,1));

%set all neg values to 0
if ~isempty(opt.M) 
    M = fs_new*opt.M;
    l_avg = cmp_loc_avg(energy_local_diff',ceil(M));
    novelty_energy = energy_local_diff' - l_avg;
    novelty_energy(novelty_energy<0) = 0;
    novelty = novelty_energy';
end


%normalize
if opt.norm
    novelty_energy = novelty_energy/max(novelty_energy);
end

novelty = novelty_energy;

sec = 12;
if opt.plt
    figure(1),clf
    subplot(5,1,1)
    plot(x)
    set(gca,'Xlim',[0 fs*sec])
    title('audio')
    
    subplot(5,1,2)
    plot(energy_local)
    set(gca,'Xlim',[0 fs_new*sec])
    title('smoothed,squared audio signal')
    
    subplot(5,1,3)
    plot(energy_local_diff)
    set(gca,'Xlim',[0 fs_new*sec])
    title('rate of change')
    
    subplot(5,1,4)
    plot(novelty_energy)
    set(gca,'Xlim',[0 fs_new*sec])
    title('novelty energy')
    
    subplot(5,1,5)
    plot(simp_peak(novelty_energy,0.2))
    set(gca,'Xlim',[0 fs_new*sec])
    title('Peaks')
    
    sgtitle('energy novelty')


end
