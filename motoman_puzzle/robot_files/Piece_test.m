% UNSAFE CODE
HeadCorrection(Com_h)
pause(1);
MoveXY( 30,0,Com_h )
MovePiece( 100,700,Com_h )
MoveZ( -190,Com_h )
P = GetFullPos(Com_h);
MoveRobot(P(1),P(2),P(3),P(4),P(5),-148,'ROBOT',5);
pause(1.5);
MoveRobot(P(1)+6,P(2)+38,P(3),P(4),P(5),-148,'ROBOT',5);
pause(1);
MoveZ( -216,Com_h )
Suction( Com_h )
MoveZ( -190,Com_h )
pause(0.5);
HeadCorrection(Com_h)
pause(3.5);
MoveXY(0,920,Com_h)
Suction(Com_h)

%%
P = GetFullPos(Com_h);
MoveRobot(P(1),P(2),P(3),-87,44,-88,'ROBOT',5);

%%
for z=4:0.01:7
    if (mod(28.85,z)<1 && mod(21.1,z)<1)
       disp('z = '); disp(z);
       disp('x = '); disp(28.85/z);
       disp('y = '); disp(21.1/z);
    end
end