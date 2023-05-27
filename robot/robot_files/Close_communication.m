function [ ] = Close_communication()
%Close_communication turn servo off, close communication and unload motocom library
% works only if Com_h is valid (meaning equals to zero)
Com_h = evalin('base','Com_h');
if Com_h==0
    %FUNCTION: Sets servo power supply OFF.
    %FORMAT: _declspec( dllexport ) short APIENTRY BscServoOff(short nCid);
    calllib('MotoCom32', 'BscServoOff', Com_h);
    %FUNCTION: Releases a communication handler.
    %FORMAT: _declspec( dllexport ) short APIENTRY BscClose(short nCid);
    calllib('MotoCom32', 'BscClose', Com_h);
    unloadlibrary('MotoCom32')
else
    disp('Communication is not initialized correctly. Please apply "Com_h = Init()" first until Com_h==0.');
end

end

