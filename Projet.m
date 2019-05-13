clc;
close all;
clear all;

%import signal
[Num,Fe] = audioread('./pianoSoundFiles/ech1.wav');

%stereo to mono
Num(:,1) = (Num(:,1) + Num(:,2)) / 2;
Num(:,2) = [];

%classic variables init (T,Te,F,Fe... + FNum)
Te = 1/Fe;
N=length(Num);
T=(0:Te:(length(Num)-1)*Te);
%F = (  -Fe/2 : Fe/N : ((N/2)-1)*(Fe/N)  );
%FNum = abs(fftshift(fft(Num)));

%sliding window
window = 50;
nbWindow = floor(length(Num)/(2*window+1))%à changer
for i = (1+window:2*window+1:length(Num)-window)
	for j = (-window:window)
		
	end
end




figure (1);
plot(T,Num);

figure(2);
plot(F,FNum);

figure(3);
spectrogram(Num,256,250,256,Fe,'yaxis');


window = 50

%wt = cwt(Num);