function [ ] = printme( fig, path, suppressOutput )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if (suppressOutput == false)
    print(fig, '-depsc', path);
end

end

