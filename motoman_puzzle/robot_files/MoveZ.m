function MoveZ(z)
%MoveZ Move Robot safely in the z axis
%   Detailed explanation goes here

Com_h = evalin('base','Com_h');
if (Com_h==0)
%   co shai1202  sensitivity = 50; % Higher is less sensitive
     vel = 5;%Global_params('speed');          % Set velocity
     
     P = GetFullPos();
      
%     Number_of_moves = floor(abs((z-P(3))/sensitivity));
%     Z_new = P(3);
%     for i=1:Number_of_moves
%         if (z>P(3)) Z_new = Z_new + sensitivity; end
%         if (z<P(3)) Z_new = Z_new - sensitivity; end
%         MoveRobot(P(1),P(2),Z_new,P(4),P(5),P(6),'ROBOT',vel);
%  end co shai1202   end
    MoveRobot(P(1),P(2),z,P(4),P(5),P(6),'ROBOT',vel);
    pause(0.2);
else
    disp('Communication is not initialized correctly. Please apply "Com_h = Init()" first until Com_h==0.');
end
end