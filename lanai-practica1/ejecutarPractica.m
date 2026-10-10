% PRACTICA 1. LANAI 2026-27
% Simulacion y representacion del nivel de un deposito.
%
% Orden de la practica:
%   1. La clase Deposito da un paso de simulacion cada vez que se llama
%      a actualizar(qBomba).
%   2. simularDeposito repite ese paso desde t = 0 hasta t = tf y hace
%      que el caudal de la bomba cambie a lo largo del tiempo.
%   3. representarResultados, llamada desde simularDeposito, dibuja
%      el nivel y los caudales.
%
% Con los datos por defecto del enunciado el caudal nominal es q0 y el
% nivel de equilibrio es h0 = 0.5 m. La bomba aplica tres escalones:
%   1.2*q0, despues 0.8*q0 y, al final, otra vez q0.
% Cada escalon dura 4*tau, por encima de los 3*tau que el enunciado da
% como tiempo practico de establecimiento.
%
% Otro deposito de ejemplo (hay que sustituir la linea del constructor):
%   deposito = Deposito('NivelNominal', 0.8, 'Retardo', 5, 'Ts', 0.05);
%   deposito = Deposito('AlturaInicial', 0.35);

estaCarpeta = fileparts(mfilename('fullpath'));
addpath(estaCarpeta);

deposito = Deposito();

fprintf('tau = %.3f s\n', deposito.obtenerConstanteTiempo());
fprintf('K   = %.3f s/m^2\n', deposito.obtenerGanancia());
fprintf('q0  = %.6f m^3/s\n', deposito.obtenerCaudalNominal());
fprintf('L   = %.3f s\n', deposito.obtenerRetardo());
fprintf('h0  = %.3f m\n', deposito.obtenerNivelNominal());
fprintf('Ts  = %.3f s\n', deposito.obtenerPaso());

simularDeposito(deposito);
