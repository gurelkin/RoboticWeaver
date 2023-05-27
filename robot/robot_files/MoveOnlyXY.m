function MoveOnlyXY( x,y )
%MoveXY Move the robot to given x,y coordinates and set the suction cup close to the table 
%------------Table Overhead look--------------
%(0,0)----------------y----------------(0,920)
%---------------------------------------------
%--x------------------------------------------
%---------------------------------------------
%---------------------------------------------
%(420,0)-----------------------------(420,920)

% x,y transformation
x = 800 - x;
y = 460 - y;

Com_h = evalin('base','Com_h');
if (Com_h==0)
   if (x>800 || x<400) 
       error('X out of proper range');
   end
   if (y>460 || y<-460) 
       error('Y out of proper range');
   end
   MoveX(x);
   MoveY(y);

else
    disp('Communication is not initialized correctly. Please apply "Com_h = Init()" first until Com_h==0.');
end

end

