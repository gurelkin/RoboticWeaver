function MoveToStart()
%MoveToStart Moves robot to Start position
%   

Com_h = evalin('base','Com_h');

if (Com_h==0)
  % MoveRobot(510,230,320,-87,44,-98,'ROBOT',5); %shai co 82
    MoveRobot(605,174,226,178,-2.4,-132.2,'ROBOT',5); %shai  82
else
    disp('Communication is not initialized correctly. Please apply "Com_h = Init()" first until Com_h==0.');
end

end
