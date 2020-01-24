% textscan test

dVals = rand(1, 100);
dNum = length(dVals);

dTic = tic;
fid = fopen('test.csv', 'a'); 
for m = 1 : dNum
    fprintf(fid, '%1.5f', dVals(m));
    if m < dNum
        fprintf(fid, ',');
    end
end
fclose(fid);
dElapsedTime = toc(dTic)

% commens