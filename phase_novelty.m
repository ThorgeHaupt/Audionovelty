function [novelty, fs_new] = phase_novelty(x,fs_old, varargin)
%% this computes the novelty function based on phase information
%Input:
%x =            signal of interest (sample points x 1)
%fs_old =       sampling rate of the signal 
%
%Optional
%N =            determines the size of the hann window for the STFT (def:
%               1024)
%H =            hop parameter, specifies the overlap length of the STFT
%               (def: 768, note -> this parameter leads to fs_new = 256)
%M =            in s, determines (2M +1) window size for local average, if []
%               local average will not be computed (def: 0.5s)
%norm =         bool, applies normalization of the signal (centers [0 1]
%plt =          plots the different stages of this process
%
%
%Ouput:
%novelty =      the phase based novelty function
%fs_new =       the new sampling rate


opt = propertylist2struct(varargin{:});
opt = set_defaults(opt,...
    'N',1024,...
    'H',768,...
    'M',0.5,...
    'gamma',10,...
    'norm',1,...
    'plt',0);


N = opt.N;
H = opt.H;
gamma = opt.gamma;


%short fourier transformation
X = stft(x,fs_old,'window',hann(N),'OverlapLength',H,'FFTLength',N);

fs_new = fs_old/(N-H);

phase = angle(X) / (pi*2);
phase_diff = normalize(diff(phase,1,2),'range',[-0.5,0.5]);
phase_diff2 = normalize(diff(phase_diff,1,2),'range',[-0.5,0.5]);

%sum over different frequency bins
novelty_phase = sum(abs(phase_diff2),1);

%cat to ensure equal length 
novelty_phase = cat(2,novelty_phase, zeros(size(phase,2)-size(phase_diff,2),1)');

%novelty phase function
novelty = novelty_phase;

%remove local average
if ~isempty(opt.M)
    M = opt.M*fs_old;
    l_avg = cmp_loc_avg(novelty_phase,ceil(M));
    novelty_phase_norm =novelty_phase - l_avg;
    novelty_phase_norm(novelty_phase_norm<0) = 0;
    novelty = novelty_phase_norm;

end

%normalization of the data
if opt.norm
    novelty_phase_norm = novelty_phase_norm/max(novelty_phase_norm);
    novelty = novelty_phase_norm;
end


if opt.plt
    sec = 12;
    figure(3),clf
    subplot(4,1,1)
    plot(x)
    set(gca,'Xlim',[0 sec*fs_old])
    title('audio')
    
    subplot(4,1,2)
    imagesc(phase)
    set(gca,'Xlim',[0 sec*fs_new])
    title('phase')
    
    subplot(4,1,3)
    imagesc(phase_diff2)
    set(gca,'Xlim',[0 sec*fs_new])
    title('2 derivative of phase')
    
    subplot(4,1,4)
    plot(novelty_phase_norm)
    set(gca,'Xlim',[0 sec*fs_new])
    title('peaks')
    xlabel('12 seconds')
    
    sgtitle('pahse novelty')

    
    
end