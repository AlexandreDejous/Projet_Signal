clc;
close all;
clear all;

[Num,Fe] = audioread('./pianoSoundFiles/ech1.wav');

Te = 1/Fe;
N=Fe;
T=(0:Te:(length(Num)-1)*Te);

figure (1)
plot(T,Num(:,1))
figure (2)
plot(T,Num(:,2))