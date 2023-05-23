function MoveInitial(  )
%MoveInitial Moves robot to Initial position
%   Detailed explanation goes here

x_init = 0;
y_init = 0;
z_init = -130;

Com_h = evalin('base','Com_h');
if (Com_h==0)
   MoveXY(400,y_init);
   MoveZ(z_init);
   MoveX(x_init);  
else
    disp('Communication is not initialized correctly. Please apply "Com_h = Init()" first until Com_h==0.');
end

end
