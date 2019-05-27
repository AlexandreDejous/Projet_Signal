clc;
close all;
clear all;
[Water,Fe] = audioread('./watermark_DB.wav');
Te = 1/Fe;
Water = Water / 12;
%Water = resample(Water,1,100);


N=length(Water);
T=(0:Te:(length(Water)-1)*Te);

F = (  -Fe/2 : Fe/N : ((N/2)-1)*(Fe/N)  );
FWater = fft(Water);

figure(1);
plot (T,Water);
figure(2);
plot(F,abs(fftshift(FWater)));



sound(Water,44100);