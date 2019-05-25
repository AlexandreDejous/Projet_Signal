clc;
close all;
clear all;

[Num,Fe] = audioread('./pianoSoundFiles/ech21.wav');

Te = 1/Fe;
N=66000-48000+1;
T=(0:Te:(length(Num)-1)*Te);
Num2 = Num(48000:66000)
F = (  -Fe/2 : Fe/N : ((N/2)-1)*(Fe/N)  );
FNum = abs(fftshift(fft(Num2)));
plot(F,FNum);