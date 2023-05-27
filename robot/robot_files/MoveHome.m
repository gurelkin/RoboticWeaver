function MoveHome()
%MoveHome Moves robot to Home position
%   

x_home = 300;
y_home = 460;
z_home = -50;

Com_h = evalin('base','Com_h');

if (Com_h==0)
   MoveXY(x_home,y_home);
   MoveZ(z_home); 
else
    disp('Communication is not initialized correctly. Please apply "Com_h = Init()" first until Com_h==0.');
end

end
