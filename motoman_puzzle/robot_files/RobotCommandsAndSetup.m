%---------------------------------%
%% Robot Commands and Setup File %%
%---------------------------------%

%% Setup Instractions:
%  1. Turn on the robot.
%  2. Set the key to remote mode.
%  3. Insert Hardware Key (DiskOnKey) to USB socket.
%  4. Set compiler to Visual C++ 2008 by "mex -setup" command.
%  5. Run: "Com_h=Init();". (Must return 0 for proper functionality)
         
cd('D:\motoman_puzzle\robot_files');
addpath('D:\motoman_puzzle\robot_files');
addpath('D:\motoman_puzzle\puzzle_solver');
%% Commands:
Com_h=Init(); % Initialize Robot - Run until Com_h=0
Play_and_ServoOn(); % Set robot to Play mode and turn servo on
global Global_params
Global_params = containers.Map(...
    {'z_min', 'z_max', 'speed'}, ...
    {-185, 200,5});

%%
Close_communication(); % turn servo off, close communication and unload motocom library
ServoOff(); % turn servo off without closing communication or unload motocom library
P = GetFullPos(); % return 12 bits of position (Robot coordinate system)
P = GetPos(); % return x,y,z position (Robot coordinate system)
MoveRobot(x,y,z,Rot_x,Rot_y,Rot_z,mode,spd); % Moves the robot to a specific location
MoveXY(x,y); % Move the robot to given x,y coordinates and set the suction cup close to the table 
MoveInitial(); % Moves robot to Initial position
MoveHome(); % Moves robot to Home position
MoveX(x); % Move Robot safely in the x axis
MoveY(y); % Move Robot safely in the y axis
MoveZ(z); % Move Robot safely in the z axis
Suction(); % Toggle Suction mode
HeadCorrection(); % Sets proper head values
%%
MoveXY(0,0);

%%
%save all figures
h = get(0,'children');
h = sort(h);
for i=1:length(h)
  saveas(h(i), ['C:\Users\admin\Desktop\new puzzle tests\test6_' num2str(i)], 'png');
end

