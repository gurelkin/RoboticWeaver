function HeadCorrection()
%HeadCorrection Sets proper head values
%   proper head values are the values in which the suction cup can touch
%   the table without the robot hitting it
Com_h = evalin('base','Com_h');
if (Com_h==0)
P = GetFullPos();
Rot_z = P(2)/15.333 - 88;
MoveRobot(P(1),P(2),P(3),-87,44,Rot_z,'ROBOT',5);
else
    disp('Communication is not initialized correctly. Please apply "Com_h = Init()" first until Com_h==0.');
end
end

