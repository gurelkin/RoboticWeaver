coil=1;
pcoil = libpointer('int16',coil);
% BscReadIO2(short nCid,DWORD add,short num,short *stat);
% short APIENTRY BscWriteIO(short nCid,short add,short num,short *stat);
pcoil = calllib('MotoCom32', 'BscWriteIO',Com_h,10011,1,pcoil);

%%
c = 'VOFF';
CP = libpointer('string', c);
A = calllib('MotoCom32', 'BscSelectJob',Com_h,CP);
setdatatype(A,'int16Ptr',1,1);
get(A);

calllib('MotoCom32', 'BscHoldOff',Com_h);
calllib('MotoCom32', 'BscStartJob',Com_h);
calllib('MotoCom32', 'BscContinueJob',Com_h);

calllib('MotoCom32', 'BscJobWait',Com_h, 3);


calllib('MotoCom32', 'BscReset',Com_h);
calllib('MotoCom32', 'BscCancel',Com_h);

c = 'VON';
CP = libpointer('string', c);
calllib('MotoCom32', 'BscSelectJob',Com_h,CP);


a = calllib('MotoCom32', 'BscIsJobLine',Com_h);
setdatatype(a,'int8Ptr',1,8);

c = 10010;
CP = libpointer('shortPtr', c);
c1 = 0;
CP1 = libpointer('int16', c1);
calllib('MotoCom32', 'BscWriteIO',Com_h, 10010,1,CP1);