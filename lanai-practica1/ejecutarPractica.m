% PRACTICA 1
% Este archivo es un script: no empieza por la palabra function.
% Guardalo con el nombre ejecutarPractica.m, en la misma carpeta que Deposito.m.
% Para lanzarlo: abre la carpeta en MATLAB y pulsa Ejecutar.

close all   % Cierra figuras de una ejecucion anterior

Ts = 0.1;                 % Segundos entre un calculo y el siguiente
deposito = Deposito();    % Crea el deposito con los datos del enunciado

simularDeposito(deposito, Ts);
