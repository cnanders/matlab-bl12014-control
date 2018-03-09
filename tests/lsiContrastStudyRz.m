ceInts = app.uiApp.uiLSIAnalyze.ceInt;

N = 105;
xSec = zeros(length(ceInts), N);
for k = 1:length(ceInts)
    ceInt = ceInts{k};
    xSec(k, :) = ceInt(250, 75:(75+N-1));
    
    
end

plot(xSec')

fa = fft(xSec');
imagesc(abs(fa));
fi = abs(fa(6,:))./(fa(1,:));
