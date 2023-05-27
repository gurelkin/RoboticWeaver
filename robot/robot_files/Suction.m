function Suction( )
%Suction Toggle Suction mode
Com_h = evalin('base','Com_h');
if Com_h==0
calllib('MotoCom32', 'BscContinueJob',Com_h);
calllib('MotoCom32', 'BscContinueJob',Com_h);
else
    disp('Communication is not initialized correctly. Please apply "Com_h = Init()" first until Com_h==0.');
end
end

