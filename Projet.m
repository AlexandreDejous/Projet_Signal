clc;
close all;
clear all;

%import signal
[Num,Fe] = audioread('./pianoSoundFiles/piano.wav');

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
% window = 13486;
% fullWindowSize = 2*window+1;
% arrayWindow = zeros(fullWindowSize,1);%init array holding values of current window for fft
% F = (  -Fe/2 : Fe/N : ((N/2)-1)*(Fe/N)  );%
% nbWindow = floor(length(Num)/(fullWindowSize)); %number of entire windows we can put in Num 
% for i = (1+window:fullWindowSize:nbWindow*fullWindowSize-window)
% 	for j = (-window:window)
% 		arrayWindow(window+j+1) = Num(i+j);
% 		
% 	end
% 
% end


for i = (1:25)
	figure (i);
	[Num,Fe] = audioread(strcat('./pianoSoundFiles/ech',int2str(i),'.wav'));
	spectrogram(Num(:,1),6000,0,6000,Fe,'yaxis');
end

%figure(2);
%spectrogram(Num,6000,0,6000,44000,'yaxis')



%wt = cwt(Num);