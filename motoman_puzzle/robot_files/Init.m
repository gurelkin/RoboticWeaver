function Com_h=Init( )
%INIT - Initialize robot.
%   Before running this function the robot must be on and in remote mode, 
%   Hardware key must be connected and compiler set to c++ 2008 SP1. 

num_of_attempts = 10;
attempts = 0;
Com_h = -1;

% must be called before all other attempts to communicate with the dll:
loadlibrary('MotoCom32.dll', 'MotoCom.h');

while (Com_h~=0 && attempts<num_of_attempts)
    %FUNCTION:Gets a communication handler
    %FORMAT: _declspec( dllexport ) short APIENTRY BscOpen(char *path,short mode);
    CurDir=pwd;
    pCurDir=libpointer('string', CurDir);
    Com_hPtr=calllib('MotoCom32', 'BscOpen',pCurDir, 1);
    setdatatype(Com_hPtr,'int8');
    Com_h=get(Com_hPtr);
    Com_h=Com_h.Value;
end

if Com_h==0 
    %FUNCTION:Sets communications parameters of the serial port.
    %FORMAT: _declspec( dllexport )short APIENTRY BscSetCom(short nCid,
    %short port, DWORD baud, short parity, short clen, short stp)
    t=calllib('MotoCom32', 'BscSetCom', Com_h, 1, 9600, 2, 8, 0); 

    %FUNCTION:Connects communications lines.
    %FORMAT: _declspec( dllexport ) short APIENTRY BscConnect(short nCid);
    calllib('MotoCom32', 'BscConnect', Com_h);
else 
    unloadlibrary('MotoCom32');
end

end

