function MovePiece_old( x,y )
%MovePiece Move Piece to x,y 
% MovePiece start suction (for lifting puzzle piece), move to a new
% location, then turn suction off.


z_high = -180;
z_middle = -190;
z_low = -216;

% x,y transformation
x_robot = 800 - x;
y_robot = 460 - y;
Com_h = evalin('base','Com_h');
if (Com_h==0)
   if (x_robot>800 || x_robot<380) 
       error('X out of proper range');
   end
   if (y_robot>460 || y_robot<-460) 
       error('Y out of proper range');
   end
   P_start = GetFullPos();
   Suction();
   MoveZ(z_high);
   MoveX(800); % robot coordinates
   MoveY(0);   % robot coordinates
   pause(0.3);
   
   % Move piece to safe location
   P = GetFullPos();
   MoveRobot(880,0,z_middle,P(4),P(5),P(6),'ROBOT',5);
   pause(1);
   MoveZ(z_low);
   pause(0.3);
   Suction();
   
   % Arrange peice direction
   MoveZ(z_middle);
   P = GetFullPos();
   rot_z_init = P_start(2)/15.333 - 88;
   rot_z_des = y_robot/15.333 - 88;
   rot_z_new = -88+(rot_z_des-rot_z_init);
   MoveRobot(P(1),P(2),P(3),P(4),P(5),rot_z_new,'ROBOT',5);
   pause(1);
   
   x_ver = 0;
   y_ver = (rot_z_init-rot_z_des)*0.6333;
   MoveRobot(P(1)+x_ver,P(2)+y_ver,P(3),P(4),P(5),rot_z_new,'ROBOT',5);
   pause(1);
   
   % Move to final location
   MoveZ(z_low);
   Suction();
   MoveZ(z_middle);
   pause(0.3);
   HeadCorrection();
   pause(1);
   MoveXY(x,y);
   Suction();
   
else
    disp('Communication is not initialized correctly. Please apply "Com_h = Init()" first until Com_h==0.');
end

end



