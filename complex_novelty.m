function [novelty, fs_new] = complex_novelty(x,fs_old,varargin)
%% Complex Domain novelty
%%Input:
%x =            signal of interest (sample points x 1)
%fs_old =       sampling rate of the signal 
%
%Optional
%N =            determines the size of the hann window for the STFT (def:
%               1024)
%H =            hop parameter, specifies the overlap length of the STFT
%               (def: 768, note -> this parameter leads to fs_new = 256)
%take_log =     bool, determines whether the data is log compressed             
%               (def: 1)
%gamma =        compression factor for the log
%M =            in s, determines (2M +1) window size for local average, if []
%               local average will not be computed (def: 0.5s)
%norm =         bool, applies normalization of the signal (centers [0 1]
%plt =          plots the different stages of this process
%
%
%Ouput:
%novelty =      the phase based novelty function
%fs_new =       the new sampling rate
%



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
X = stft(x,fs_old,'window',hann(N),'OverlapLength',H,'FFTLength',N);
fs_new = fs_old/(N-H);

Y = abs(X);
%take the log
if opt.take_log
    Y = log(1 + gamma * Y);
end


phase = angle(X) / (pi*2);
phase_diff = diff(phase,1,2);
phase_diff = cat(2,phase_diff, zeros(size(phase,2)-size(phase_diff,2),size(phase,1))');

X_hat = Y .* exp(2*pi*1i*(phase+phase_diff));
X_prime = abs(X_hat-X);
X_plus = repmat(X_prime,1);

for i = 2:size(X,1)
    idx = Y(i,:) < Y(i-1,:);
    X_plus(i,idx) = 0;
end
novelty_complex = sum(X_plus,1);

novelty = novelty_complex;
%smooth the function
if ~isempty(opt.M) 
    M = fs_new*opt.M;
    l_avg = cmp_loc_avg(novelty_complex,ceil(M));
    novelty_complex =novelty_complex - l_avg;
    novelty_complex(novelty_complex<0) = 0;
    novelty = novelty_complex;
end

%normalize
if opt.norm
    novelty_complex_norm = novelty_complex/max(novelty_complex);
    novelty = novelty_complex_norm;
end

if opt.plt
    sec = 12;
    
    figure(4),clf
    subplot(6,1,1)
    plot(x)
    set(gca,'Xlim',[0 sec*fs_old])
    title('audio')
    
    subplot(6,1,2)
    imagesc(phase)
    set(gca,'Xlim',[0 sec*fs_new])
    title('phase')
    
    subplot(6,1,3)
    imagesc(real(X_hat))
    set(gca,'Xlim',[0 sec*fs_new])
    title('magnitude')
    
    subplot(6,1,4)
    imagesc(X_prime)
    set(gca,'Xlim',[0 sec*fs_new])
    title('measure of novelty')
    
    subplot(6,1,5)
    plot(novelty_complex)
    set(gca,'Xlim',[0 sec*fs_new])
    title('novelty function')
    
    subplot(6,1,6)
    plot(novelty_complex_norm)
    set(gca,'Xlim',[0 sec*fs_new])
    title('novelty function normalized')
    
    sgtitle('complex novelty')

    
end
