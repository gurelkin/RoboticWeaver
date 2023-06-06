function MoveXYZ( x,y,z )

Com_h = evalin('base','Com_h');
if (Com_h==0)
   if (x>330 || x<-10) 
       disp(x);
       error('X out of proper range');
   end
   if (y>450 || y<-10) 
       error('Y out of proper range');
   end
   %%% CHECK Z HERE PLZ
   SetCurrPos([x, y]); 

   speed = 1 ; %Global_params('speed')
   % x,y transformation
   x = x + 550;
   y = y - 250;

   P = GetFullPos();
   MoveRobot(x,y,z,P(4),P(5),P(6),'ROBOT',speed);
   
%   co shai1202 HeadCorrection();

else
    disp('Communication is not initialized correctly. Please apply "Com_h = Init()" first until Com_h==0.');
end

end