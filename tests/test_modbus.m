cTransport = 'tcpip';
cAddress = '192.168.10.26';

% Modbus spec
% http://www.bb-elec.com/Learning-Center/All-White-Papers/Modbus/The-Answer-to-the-14-Most-Frequently-Asked-Modbus.aspx

m = modbus(cTransport, cAddress);

% Read one value from coil
% FC1 
d1 = read(m, 'coils', 1, 1)
d2 = read(m, 'coils', 2, 1)

return

% FC5
write(m, 'coils', 1, 1)
write(m, 'coils', 2, 1)

% FC1
d1 = read(m, 'coils', 1, 1)

% writeRead is a F6 (write output holding register), F3 (read output holding register) 
% d2 = writeRead(m, 2, 1, 2, 1)

% Writing to holding registers is a way to set many bits at once. 
%
% Matlab's API takes doubles as the "value", and then, by default, converts them to 16-bit for
% setting bits of the coils. (Optionally, you can decide how many bits it
% writes to the holding retister
%
% Example
% write(m , 'holdingregs', 1, 15) is equivalent to:
% write(m , 'holdingregs', 1, bin2dec('1111'))
% The latter makes it evident that it will, starting at address 1,
% set the next sixteen bits to 1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0
% 
% Similarly, sending the following:
% write(m, 'holdingregs', 1, 0) is equivalent to:
% write(m, 'holdingregs', 1, bin2dec('0000000000000000')), which starting
% at address 1, sets the next sixteen bits to zero.
%
% To turn on only bit 4 (address 4), need to send:
% write(m, 'holdingregs', 1, bin2dec('1000')) which is equivalent to:
% write(m, 'holdingregs', 1, 8)


% Remember that holding registers are analog and 16-bit. 

% FC4
read(m, 'inputregs', 1, 100)


% FC3
read(m, 'holdingregs', 1, 100)


% FC6 (or FC16?)
write(m,'holdingregs', 1, 0)

read(m, 'holdingregs', 1, 100)