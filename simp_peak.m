function peak = simp_peak(x,thresh)
%%a function that returns the peaks of a novelty function 
%x = 1 dimensional data
%thresh = threshold for which to determine the peaks

if isempty(thresh)
    thresh = 0.2;
end
peaks = [];
for i =2:length(x)-1
    
    if x(i-1) < x(i) && x(i) > x(i+1)
        
        if x(i) > thresh
            
            peaks = [peaks, i];
            
        end        
    end
end
if size(x,1) > size(x,2)
    peak = zeros(length(x),1);
else
    peak = zeros(1,length(x));
end
peak(peaks) = 1;

