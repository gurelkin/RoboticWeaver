function [ ] = Play_and_ServoOn( )
%Play_and_ServoOn Simply set robot to play mode and turn servo on
% works only if Com_h is valid (meaning equals to zero)
Com_h = evalin('base','Com_h');
if Com_h==0
calllib('MotoCom32', 'BscSelectMode', Com_h,2); % Set robot to play mode.
calllib('MotoCom32', 'BscServoOn', Com_h); % Turn servo on
else
    disp('Communication is not initialized correctly. Please apply "Com_h = Init()" first until Com_h==0.');
end

end

