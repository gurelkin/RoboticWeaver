function [ P ] = GetPos()
%GetPos return x,y,z position (Robot coordinate system)
Com_h = evalin('base','Com_h');
if Com_h==0
p1 = GetFullPos();
P = p1(1:3);
else
    disp('Communication is not initialized correctly. Please apply "Com_h = Init()" first until Com_h==0.');
end

end

