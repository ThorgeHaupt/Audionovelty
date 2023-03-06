function v = princip_argument(x)
%% maps function into a specific range of values
%input
%x = signal of interest
%
%output
%v = signal of interest in the predefined ranges

v = mod(x+0.5,1) -0.5;