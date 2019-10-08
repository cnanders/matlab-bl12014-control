try
    purge
catch mE
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));

buffer = bl12014.Buffer(3);
buffer.push(1);
buffer.avg()
buffer.push(2)
buffer.avg()
buffer.push(3)
buffer.avg()
buffer.push(1)

buffer(2) = bl12014.Buffer(3);
buffer(2).push(4)
buffer(2).avg()
buffer(2).push(10)
buffer(2).avg()

buffer(3) = bl12014.Buffer(3);
buffer(3).push(4)
buffer(3).avg()
buffer(3).push(10)
buffer(3).avg()


buffer(4) = bl12014.Buffer(3);
buffer(4).push(3)
buffer(4).avg()
buffer(4).push(4)
buffer(4).avg()