function [ P ] = GetFullPos()
%GetFullPos return 6 bits of position (Robot coordinate system)
%   works only if Com_h is valid (meaning equals to zero)
%   P[0] X-axis coordinate (unit: mm)
%   P[1] Y-axis coordinate (unit: mm)
%   P[2] Z-axis coordinate (unit: mm)
%   P[3] Wrist angle Rx
%   P[4] Wrist angle Ry
%   P[5] Wrist angle Rz 
%   P[6] 7th axis pulse number (mm for traveling axis)
%   P[7] 8th axis pulse number (mm for traveling axis)
%   P[8] 9th axis pulse number (mm for traveling axis)
%   P[9] 10th axis pulse number
%   P[10] 11th axis pulse number
%   P[11] 12th axis pulse number
Com_h = evalin('base','Com_h');
if Com_h==0
    PRec=zeros(1,12);
    pDatRec=libpointer('doublePtr', PRec);
    calllib('MotoCom32','BscIsRobotPos',Com_h,'ROBOT',0,0,0,pDatRec);
    P=get(pDatRec,'value');
    P = P(1:6);
else
    disp('Communication is not initialized correctly. Please apply "Com_h = Init()" first until Com_h==0.');
end

end

