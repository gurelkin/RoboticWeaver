function MoveX(x)
%MoveX Move Robot safely in the x axis
%   Detailed explanation goes here

Com_h = evalin('base','Com_h');
if (Com_h==0)
    sensitivity = 50; % Higher is less sensitive
    vel = 10;          % Set velocity
    P = GetFullPos();
    Number_of_moves = floor(abs((x-P(1))/sensitivity));
    X_new = P(1);
    for i=1:Number_of_moves
        if (x>P(1)) X_new = X_new + sensitivity; end
        if (x<P(1)) X_new = X_new - sensitivity; end
        MoveRobot(X_new,P(2),P(3),P(4),P(5),P(6),'ROBOT',vel);
    end
    MoveRobot(x,P(2),P(3),P(4),P(5),P(6),'ROBOT',vel);
    pause(0.1);
else
    disp('Communication is not initialized correctly. Please apply "Com_h = Init()" first until Com_h==0.');
end
end

