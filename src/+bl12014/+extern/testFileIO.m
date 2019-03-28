function testFileIO()

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
fid = fopen(fullfile(cDirThis, 'read.txt'));
bytes = fread(fid, inf, '*char');
num = str2double(bytes);


outNum = num + 1;

fclose(fid);

fid = fopen(fullfile(cDirThis,'write.txt'), 'w');
fwrite(fid, sprintf('%0.2f', outNum));
fclose(fid);

fprintf('wrote to outfile: %0.2f\n', outNum);

