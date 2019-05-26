clc;
close all;
clear all;
[Num,Fe] = audioread('./pianoSoundFiles/piano.wav');
%stereo to mono
Num(:,1) = (Num(:,1) + Num(:,2)) / 2;
Num(:,2) = [];

Te = 1/Fe;


%sound(Num(53759:79821),44100)

Num = Num(53759:79821);
sound(Num,Fe);
pause(1);

N=length(Num);
T=(0:Te:(length(Num)-1)*Te);
F = (  -Fe/2 : Fe/N : ((N/2)-1)*(Fe/N)  );
FNum = fft(Num);

figure(1);
plot (T,Num);
figure(2);
plot(F,abs(fftshift(FNum)));

%FNUM = cat (1,FNum, FNum)
%complex(zeros(1,5),ones(1,5))

Num = resample(Num,1,2);
T=(0:Te:(length(Num)-1)*Te);
%shiftNb = 5000
%Fnum = 

%Fnum = complex(Fnum,0);

%Num = real(ifft(FNum));

figure(3);
plot(T,Num);
sound(Num,44100);

