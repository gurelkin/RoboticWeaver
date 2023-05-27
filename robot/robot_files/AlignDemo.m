function AlignDemo()
% align demo

Com_h = evalin('base','Com_h');
if (Com_h==0)
MoveXY(210,460);
MovePiece(210,0);
MovePiece(210,460);
MovePiece(210,920);
MovePiece(210,460);
end
end