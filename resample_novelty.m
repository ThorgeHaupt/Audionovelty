function [nov_out, fs_out] = resample_novelty(nov, fs_in, varargin)
%% This function resamples the novelty function to a desired sampling rate
% (may be done before peak determination)
%Input:
%nov =      novelty function (1 x sample points) 
%fs_in =    the initial sampling rate
%
%Optional:
%fs_out =   the desired sampling rate (def 100Hz)
%norm =     bool, apply normalization to the novelty function (def: 1) 
%smooth =   bool, apply smoothing Gaussian (def 0)
%sigma =    integer, applying a smoothing Gaussian (def: 4)
%sec =      integer, size of the smoothing Gaussian ins sec (def: 1)
%
%
%Output:
%nov_out =  resampled output signal 
%fs_out =   new feature rate of the output signal 

opt = propertylist2struct(varargin{:});
opt = set_defaults(opt,...
    'fs_out',100,...
    'sigma',4,...
    'smooth',0,...
    'norm',1,...
    'sec',1);

if opt.smooth
    w = gauss(opt.sec*fs_in,opt.sigma);
    nov = conv(nov,w,'same');
end

t_coef_in = (1:size(nov,2))/fs_in;
time_in_max_sec = t_coef_in(1,end);

N_out = ceil(time_in_max_sec*opt.fs_out);
t_coef_out = (1:N_out)/ opt.fs_out;

if t_coef_out(1,end) > time_in_max_sec
    nov = [nov 0];
    t_coef_in = [t_coef_in t_coef_out(1,end)];
end

nov_out = interp1(t_coef_in,nov,t_coef_out,'linear');

if opt.norm
    nov_out = nov_out/max(nov_out);
end
fs_out = opt.fs_out;







