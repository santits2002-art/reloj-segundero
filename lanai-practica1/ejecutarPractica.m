% Practica 1. LANAI
% Pon este archivo en la misma carpeta que Deposito.m y pulsa Ejecutar.
% Ts = 0.1 s es el paso por defecto de la clase.

addpath(fileparts(mfilename('fullpath')));

Ts = 0.1;
deposito = Deposito();
simularDeposito(deposito, Ts);
