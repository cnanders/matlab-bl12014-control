% test_parse_hsdmi_filename

cName = '20191220-132543-dose13-focus09-1kHz-DMI-HS-data.txt';

cExpression = 'dose';
[startIndex, endIndex] = regexp(cName, cExpression);

dDose = str2num(cName(endIndex + 1 : endIndex + 1 + 1))


cExpression = 'focus';
[startIndex, endIndex] = regexp(cName, cExpression);


dFocus = str2num(cName(endIndex + 1 : endIndex + 1 + 1))
