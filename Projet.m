clc;
close all;
clear all;

%import signal
[Num,Fe] = audioread('./pianoSoundFiles/piano.wav');



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
threshold = 20 % MEAN * 190 seuil facile 60 seuil difficile

%creating array for extraction of VOI (values of interest) from the spectrogram
VOI = zeros(resolution,segments);%matrix of VOI (which will later be converted in frequencies)

%extraction of frequencies that are > than threshold
for i = (1:segments)
	
	for j = (1:resolution)
		
		if (spectro(j,i) > threshold)
			VOI(j,i) = spectro(j,i);
		end
	end
end

figure(1);
image(VOI);

VOI2 = zeros(resolution,segments);

%extraction of peak values from VOI
for i = (1:segments)
	
	for j = (2:resolution-1)
		
		if ((VOI(j+1,i) < VOI(j,i)) && (VOI(j-1,i) < VOI(j,i)))
			VOI2(j,i) = VOI(j,i);
		end
	end
end

figure(3);
image(VOI2);

funOrHar = zeros(resolution,segments);
interval = 5; %marge d'erreur pour la détection d'harmoniques dans le domaine digital (celles ci ne prennent pas forcément des valeurs exactes)

for i = (1:segments)
	
	for j = (1:resolution)
		
		if ((VOI2(j,i) ~= 0) && (funOrHar(j,i) ~= 2))%si on détecte une freq dans VOI2 et que celle ci n'est pas une harmonique ( != 2 dans funOrHar )
			funOrHar(j,i) = 1; %la noter comme fondamentale (mettre = 1)
			for multiple = (2:7) %parcourir les possibles positions de ses harmoniques (multiples de la fondamentale) et les noter comme telles dans funOrHar ( mettre = 2)
				for k = (((multiple*j)-interval):((multiple*j)+interval)) %si j = 200 et multiple = 2 alors cela parcourt les harmoniques (398,399,400,401,402) (pas seulement 400 pour avoir une marge d'erreur)
					if(k <= length(funOrHar(:,1)))
						funOrHar(k,i) = 2; %2 correspond à une harmonique
					end
				end
			end
		end
	end
end


score = zeros(resolution,segments); %contient un score donné à chaque fondamentale
interval2 = 2;
for i = (1:segments)
	
	for j = (1:resolution)
		
		if ((VOI2(j,i) ~= 0) && (funOrHar(j,i) == 1))%si on détecte une freq dans VOI2 et que celle ci est fondamentale
			for multiple = (2:7) %parcourir les possibles positions de ses harmoniques (multiples de la fondamentale) et les noter comme telles dans funOrHar ( mettre = 2)
				for k = (((multiple*j)-interval2):((multiple*j)+interval2)) %si j = 200 et multiple = 2 alors cela parcourt les harmoniques (398,399,400,401,402) (pas seulement 400 pour avoir une marge d'erreur)
					score(j,i) = score(j,i) + VOI2(j,i); %2 correspond à une harmonique
				end
			end
		end
	end
end




figure(4);
image(funOrHar,'CDataMapping','scale');
colorbar;

figure(5);
image(score,'CDataMapping','scale');
colorbar;

thresholdScore = 2500;

VOI3 = zeros(resolution,segments);

for i = (1:segments)
	
	for j = (2:resolution-1)
		
		if (score(j,i)>thresholdScore)
			VOI3(j,i) = VOI(j,i);
		end
	end
end

figure(6);
image(VOI3,'CDataMapping','scale');
colorbar;




%Step 1 : faire une matrix de taille "originale" ou on met les valeurs au dela d'un certain seuil (VOI)
%Step 2 : considérer les maximas locaux comme des notes , enlever ce qu'il y a autour (VOI2)
%Step 3 : Créer une matrice de taille originale (funOrHar) pour classifier les notes 0=rien, 1 = fondamentale, 2 = harmonique
%en parrallèle, attribuer les scores aux notes de VOI2 dans VOI3 en vérifiant leur classification dans funOrHar et en les classifiant petit à petit
%

