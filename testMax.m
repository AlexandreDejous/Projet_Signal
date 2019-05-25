clc;
close all;
clear all;



maxs = zeros(25,1);
for i = 1:25
	string = strcat('./pianoSoundFiles/ech',int2str(i),'.wav');
	[Num,Fe] = audioread(string);
    Te = 1/Fe;
    N=length(Num);
    T=(0:Te:(length(Num)-1)*Te);
    figure(i);
    plot(T,Num);
	%Num(:,1) = (Num(:,1) + Num(:,2)) / 2;
	%Num(:,2) = [];
	%maxs(i) = max(Num)
	%Num = []
end

string ='./pianoSoundFiles/piano.wav';
[Num,Fe] = audioread(string);
Num(:,1) = (Num(:,1) + Num(:,2)) / 2;
Num(:,2) = [];
maxs(26) = max(Num)
maxs(27) = 0
Num = []

plot(maxs)