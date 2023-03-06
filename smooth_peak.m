function peak = smooth_peak(x,fs,varargin)
%% adaptive thresholding based on local smoothing
%Input
%x = signal 1x sample points
%fs = sampling rate -> crucial for gaussian smoothing filter
%
%optional:
%median_len = length of the media filter used for adaptive filtering
%(default 1024)
%offset_rel = additional offset usef for adaptive thresholding (default =
%0.05)
%sigma = variance for Gaussian Kernal used for smoothing the novelty
%function (default
%sec = length of the gaussian filter in sec (default = 1s)
%plt = plotting the different novelty functions (default=0
%
%
%Ouput:
%peaks = array of peak positions
%x = local threshold
%threshold local = filtered novelty curve
%
%
%Note:
%this function heavily relies on the onset and the median len, plot for at
%your convenience

opt = propertylist2struct(varargin{:});
opt = set_defaults(opt,...
    'median_len',1024,...
    'offset_rel',0.05,...
    'sigma',4,...
    'sec',1,...
    'plt',0);
    

offset = mean(x) * opt.offset_rel;
frame = 1*fs;
w = gauss(ceil(frame),opt.sigma);
w = w/sum(w);
x_conv = conv(x,w,'same');
threshold_local = medfilt1(x_conv,opt.median_len) + offset;
peaks = [];
for i = 2:size(x_conv,2)-1
    if x_conv(i-1) < x_conv(i) && x_conv(i) > x_conv(i+1)
        if x(i) > threshold_local(i)
            peaks = [peaks i];
            
        end
    end
end
if size(x,1) > size(x,2)
    peak = zeros(length(x),1);
else
    peak = zeros(1,length(x));
end
peak(peaks) = 1;

if opt.plt
    figure(10),clf
    plot(x)
    hold on
    plot(x_conv)
    hold on
    plot(threshold_local)
    hold on 
    plot(peak)
    legend('novelty','smoothed','local threshold', 'peaks detected')
end