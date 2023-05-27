%% Run before running the main code for the first time:
Com_h=Init(); % Initialize Robot - Run until Com_h=0
%% main code
Play_and_ServoOn(); % Set robot to Play mode and turn servo on
%Weave();
MoveXYZ(-5,0,-410);
MoveXYZ(-5,330, -360);
MoveZ(-410)
%MoveXYZ(295,20,-300);
%MoveZ(-400)
P = GetCurrPos();
disp(P);
%ServoOff();
%% drill
Play_and_ServoOn(); % Set robot to Play mode and turn servo on
MoveXYZ(150,150,-200);
ServoOff();

