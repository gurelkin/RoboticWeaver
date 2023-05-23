function [ ] = ServoOff( )
%ServoOff turn servo off without closing communication or unload motocom library
Com_h = evalin('base','Com_h');
if Com_h==0
calllib('MotoCom32', 'BscServoOff', Com_h); % Turn servo off
else
    disp('Communication is not initialized correctly. Please apply "Com_h = Init()" first until Com_h==0.');
end

end

