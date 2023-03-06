function local_average = cmp_loc_avg(x,M)
%% compute local average 
%
%Input:
%x = signal of interest
%M = determines the size of the window (2M+1)
%
%Ouput:
%local average of window at that point

L = length(x);
local_average = zeros(1,L);
for m = 1:length(x)
    a = max(m - M,1);
    b = min(m + M + 1,L);
    local_average(1,m) = (1/(2*M+1))* sum(x(1,a:b));
end
