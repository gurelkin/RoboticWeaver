function [ ] = MoveRobot(x,y,z,Rot_x,Rot_y,Rot_z,mode,spd)
%Move Robot
%   Moves the robot to a specific location
%   x,y,z - Coordinates in space (Cartesian coordinate system)
%   Rot_x,Rot_y,Rot_z - Robot's head coordinates
%   mode - Coordinate name; BASE : Base coordinate;
%                           ROBOT : Robot coordinate;
%   spd - Move speed (0.01 to 100.0%)

Com_h = evalin('base','Com_h');
if (Com_h==0)
    P=zeros(1,12);
    P(1)=x;P(2)=y;P(3)=z;P(4)=Rot_x;P(5)=Rot_y;P(6)=Rot_z;
    pDat=libpointer('doublePtr', P);
    calllib('MotoCom32','BscMovj', Com_h,spd,mode,0,0,pDat);
else
    disp('Communication is not initialized correctly. Please apply "Com_h = Init()" first until Com_h==0.');
end
end

