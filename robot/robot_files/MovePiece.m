function MovePiece( x,y )
%MovePiece Move Piece to x,y 
% MovePiece start suction (for lifting puzzle piece), move to a new
% location, then turn suction off.


% z_high = -145;
% z_low = -165; 
%shai 1202
z_high = -145;
z_low = -192; 



% x,y transformation
x_robot = 800 - x;
y_robot = 400 - y; % shai change from 460 1302

Com_h = evalin('base','Com_h');
if (Com_h==0)
   if (x_robot>800 || x_robot<400) 
       error('X out of proper range');
   end
   if (y_robot>460 || y_robot<-460) 
       error('Y out of proper range');
   end
   
   % Arrange peice direction
%    P = GetFullPos();
   %co shai1202 MoveZ(z_high);
   %co shai1202 rot_z_des = y_robot/15.333 - 88;
%    MoveRobot(P(1),P(2),z_high,P(4),P(5),rot_z_des,'ROBOT',5);
%    pause(0.7);
%    
%    y_ver = (P(6)-rot_z_des)*0.6333;
%    x_ver = y_ver/2;
%    MoveRobot(P(1)-x_ver,P(2)+y_ver,P(3),P(4),P(5),rot_z_des,'ROBOT',5);
%    pause(0.7);
   
   MoveZ(z_low);
   pause(1);
   Suction();
   MoveZ(z_high);
   pause(1);
   MoveXY(x,y);
   pause(4);
   MoveZ(z_low);
   pause(1);
   Suction();
   MoveZ(z_high);
   pause(1);
   
   
else
    disp('Communication is not initialized correctly. Please apply "Com_h = Init()" first until Com_h==0.');
end

end



