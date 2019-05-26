clc;
close all;
clear all;

%import signal
[Num,Fe] = audioread('./pianoSoundFiles/ech5.wav');



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
spectroParam = 6000;
figure(2);
spectro = spectrogram(Num(:,1),spectroParam,0,spectroParam,Fe,'yaxis');
spectro = abs(spectro);
imagesc(spectro);

maximums = max(spectro);



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
					score(j,i) = score(j,i) + VOI2(j,i); %le score est la somme des valeurs sur la fondamentale + ses harmoniques
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


%En fonction du score, on décide de garder ou pas la valeur détectée
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

%On convertit cette valeur (prise dans VOI3) en fréquence puis note de musique

%On veut que notre prochaine matrice contenant les vraies fréquences aie des dimensiosn moins exorbitantes que les précédentes
%En effet, cette dernière sera utilisée directement lors du plot
% indexCut = 0;
% for i = (1:segments), count=0;
% 	for j = (1:resolution)
% 		if((VOI3(j,i))~=0)
% 			count = count +1;
% 		end
% 	end
% 	indexCut = max([count, indexCut]);
% end

%définition de la matrice de recueil des frequences (en realite des index qui pointent dans le tableau frequencies la frequence correspondante)
%freq = zeros(indexCut,segments);
freq = zeros(1,segments);
%list of frequencies strating from C0 to A5
frequencies = [16.351 17.324 18.354 19.445 20.601 21.827 23.124 24.499 25.956 27.5 29.135 30.868 32.703 34.648 36.708 38.891 41.203 43.654 46.249 48.999 51.913 55 58.27 61.735 65.406 69.296 73.416 77.782 82.407 87.307 92.499 97.999 103.826 110 116.541 123.471 130.813 138.591 146.832 155.563 164.814 174.614 184.997 195.998 207.652 220 233.082 246.942 261.626 277.183 293.665 311.127 329.628 349.228 369.994 391.995 415.305 440 466.164 493.883 523.251 554.365 587.33 622.254 659.255 698.456 739.989 783.991 830.609 880];


for i = (1:segments), count=0;
	for j = (1:resolution)
		if((VOI3(j,i))~=0)%si la valeur de VOI3 sur laquelle on est est non nulle
			count = count +1;%on la mettra à cette valeur de colonne dans freq (freq contient les index en fonction du temps, mais il peut se jouer plusieurs note en même temps, d'ou le besoin pour count)
			frequency = (j-1)*Fe/spectroParam;
			past = 10000;
			for k = (1:length(frequencies))
				current = abs(frequencies(k)-frequency);
				if(past < current)
					freq(count,i) = k;
					break;
				end
				past = current;
			end
		end
	end
end


%defining time segments for notes plot
timeSegments = (1:segments);
timeSegments = timeSegments * spectroParam/Fe;


figure(7);
for i = (1:length(freq(:,1)))
	scatter(timeSegments,freq(i,:),'k');
	hold on;
end

ticks = [find(frequencies==16.351),find(frequencies==32.703),find(frequencies==65.406),find(frequencies==130.813),find(frequencies==261.626),find(frequencies==523.251)];
yticks(ticks);
xlim([0,timeSegments(length(timeSegments))]);
ylim([1,length(frequencies)]);
yticklabels({'C0','C1','C2','C3','C4','C5'});


%récupération des VOI depuis VOI3 en fonction du temps dans freq puis conversion en fréquences
% for i = (1:segments)
% 	
% 	for j = (1:resolution)
% 		
% 		if (sumscore(j,i)>thresholdScore)
% 			VOI3(j,i) = VOI(j,i);
% 		end
% 	end
% end


%Step 1 : faire une matrix de taille "originale" ou on met les valeurs au dela d'un certain seuil (VOI)
%Step 2 : considérer les maximas locaux comme des notes , enlever ce qu'il y a autour (VOI2)
%Step 3 : Créer une matrice de taille originale (funOrHar) pour classifier les notes 0=rien, 1 = fondamentale, 2 = harmonique
%en parrallèle, attribuer les scores aux notes de VOI2 dans VOI3 en vérifiant leur classification dans funOrHar et en les classifiant petit à petit
%

