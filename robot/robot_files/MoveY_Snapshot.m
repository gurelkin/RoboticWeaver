function MoveY_Snapshot(y)
%MoveY Move Robot safely in the y axis
%   Detailed explanation goes here

Com_h = evalin('base','Com_h');
if (Com_h==0)
    sensitivity = 50; % Higher is less sensitive
    vel = 7;          % Set velocity
    P = GetFullPos();
    Number_of_moves = floor(abs((y-P(2))/sensitivity));
    Y_new = P(2);
%     Rot_z_new = y/15.333 - 88;
    for i=1:Number_of_moves
        if (y>P(2)) Y_new = Y_new + sensitivity; end
        if (y<P(2)) Y_new = Y_new - sensitivity; end
%         Rot_z_new = Y_new/15.333 - 88;
        MoveRobot(P(1),Y_new,P(3),P(4),P(5),P(6),'ROBOT',vel);
    end
    MoveRobot(P(1),y,P(3),P(4),P(5),P(6),'ROBOT',vel);
    pause(0.1);
else
    disp('Communication is not initialized correctly. Please apply "Com_h = Init()" first until Com_h==0.');
end
end

