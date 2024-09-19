cTransport = 'tcpip';
cAddress = '192.168.20.50';
dPort = 5020;

% Modbus spec
% http://www.bb-elec.com/Learning-Center/All-White-Papers/Modbus/The-Answer-to-the-14-Most-Frequently-Asked-Modbus.aspx

m = modbus(cTransport, cAddress, dPort);


% read encoder counts:
encoderCounts = read(m, 'holdingregs', 1, 1)


% move to count:
dTarget = 24000;

write(m, 'coils', 1, 1)

write(m,'holdingregs', 3, dTarget);



% Zero coils:
write(m, 'coils', 15, 1);


