function MoveZ(z)
%MoveZ Move Robot safely in the z axis
%   Detailed explanation goes here

Com_h = evalin('base','Com_h');
if (Com_h==0)
   if (z < -455) 
       error('Z out of proper range');
   end
%   co shai1202  sensitivity = 50; % Higher is less sensitive
    vel = 5;%Global_params('speed');          % Set velocity  
    P = GetFullPos(); 
    pos = GetCurrPos();
    x = pos(1) + 550;
    y = pos(2) - 250;
    MoveRobot(x,y,z,P(4),P(5),P(6),'ROBOT',vel);
    pause(0.2);
else
    disp('Communication is not initialized correctly. Please apply "Com_h = Init()" first until Com_h==0.');
end
end