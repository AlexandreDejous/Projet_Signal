clc;
close all;
clear all;

%import signal
[Num,Fe] = audioread('./pianoSoundFiles/ech22.wav');



% surNum = zeros(length(2*length(Num)-1),1); %initialisation array d'acceuil du signal suréchantilloné de taille 2*Num-1
% for i =(1:length(Num(:,1)))
% 	surNum(2*(i-1)+1,1) = Num(i,1); %attrib. des valeurs de num aux échantillons d'index 2k+1 de surNum
% 	
% end
% for i =(1:length(Num(:,1))-1)
% 	surNum(2*i,1) = 0.5*(Num(i,1)+Num(i+1,1));%attrib des valeurs moyennes
% end
% surFe = 2*Fe;
%Num = surNum; %on veut garder le nom Num


%stereo to mono
% Num(:,1) = (Num(:,1) + Num(:,2)) / 2;
% Num(:,2) = [];

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


% for i = (1:25)
% 	figure (i);
% 	[Num,Fe] = audioread(strcat('./pianoSoundFiles/ech',int2str(i),'.wav'));
% 	spectrogram(Num(:,1),6000,0,6000,Fe,'yaxis');
% end
figure(2);
spectro = spectrogram(Num(:,1),6000,0,6000,Fe,'yaxis');
spectro = abs(spectro);
imagesc(spectro);

maximums = max(spectro);
%figure(3);
%spectrogram(Num(:,1),6000,0,6000,Fe,'yaxis');


segments = length(spectro(1,:));%temporal segments
resolution = length(spectro(:,1));%freq intervals

%find the mean (used in threshold)
MEAN = zeros(segments,1);
for i = (1:segments)
	MEAN(i,1) = mean(spectro(:,i))
end
MEAN(1,1) = mean(MEAN(:,1));
MEAN = MEAN(1,1);

%defining threshold
threshold = MEAN * 150

%creating array for extraction of VOI (values of interest) from the spectrogram
VOI = zeros(segments,1);%matrix of VOI (which will later be converted in frequencies)

%extraction of frequencies that are > than threshold
for i = (1:segments), k=1
	
	for j = (1:resolution)
		
		if (spectro(j,i) > threshold)
			VOI(i,k) = j;
			k = k+1;
		end
	end
end



 


%wt = cwt(Num);

