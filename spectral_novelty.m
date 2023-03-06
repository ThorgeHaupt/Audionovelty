function [novelty, fs_new] = spectral_novelty(x,fs,varargin)
%% spectral based novelty
%derives the spectral change at a diff frequency bands over time
%
%Input:
%x = signal of interest (observations x 1)
%fs = sampling rate of the signal 
%
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

%motivated by polyphonic musical events
%1. convert into frequency bands
%2. capture frequency changes


opt = propertylist2struct(varargin{:});
opt = set_defaults(opt,...
    'N',2048,...
    'H',128,...
    'take_log',1,...
    'gamma',10,...
    'norm',1,...
    'M',0.5,...
    'plt',0);

N = opt.N;
H = opt.H;
gamma = opt.gamma;

%short fourier transformation
X = stft(x,fs,'window',hann(N),'OverlapLength',H,'FFTLength',N);

%take the log
Y = log(1 + gamma * abs(X));

%take the derivative
Y_diff = diff(Y,1,2);
Y_diff(Y_diff < 0) = 0;
nov = sum(Y_diff,1);
nov = cat(2,nov, zeros(size(Y,2)-size(Y_diff,2),1)');

%moving average
fs_new = fs/(N-H);
M = (0.1*fs_new);
l_avg = cmp_loc_avg(nov,ceil(M));
nov_norm =nov - l_avg;
nov_norm(nov_norm<0) = 0;
novelty = nov_norm;
%normalize 
if opt.norm 
    nov_norm = nov_norm/max(nov_norm);
    novelty = nov_norm;
end
sec = 15;

if opt.plt
    figure(2),clf
    subplot(4,1,1)
    plot(x)
    set(gca,'Xlim',[0 sec*fs])
    title('audio')
    
    subplot(4,1,2)
    plot(nov)
    set(gca,'Xlim',[0 sec*fs_new])
    title('rate of change summed over frequencies')
    
    subplot(4,1,3)
    plot(nov_norm)
    set(gca,'Xlim',[0 sec*fs_new])
    title('normalized and smoothed rate of change')
    
    subplot(4,1,4)
    plot(simp_peak(nov_norm,0.2))
    set(gca,'Xlim',[0 sec*fs_new])
    title('peaks')
    
    sgtitle('spectral novelty')
end