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
% Ts es el mismo numero que recibe el constructor. La clase lo guarda
% en privado, asi que la simulacion no puede leerlo: hay que pasarlo.
% Con Deposito() sin argumentos, el paso por defecto es 0.1 s.
% Si cambias el paso, usalo en los dos sitios:
%   Ts = 0.05;
%   deposito = Deposito('Ts', Ts, 'NivelNominal', 0.8, 'Retardo', 5);
%   deposito = Deposito('AlturaInicial', 0.35);

estaCarpeta = fileparts(mfilename('fullpath'));
addpath(estaCarpeta);

Ts = 0.1;
deposito = Deposito();

q0 = deposito.obtenerCaudalNominal();
K = deposito.obtenerGanancia();
h0 = K * q0 / 2;

fprintf('tau = %.3f s\n', deposito.obtenerConstanteTiempo());
fprintf('K   = %.3f s/m^2\n', K);
fprintf('q0  = %.6f m^3/s\n', q0);
fprintf('L   = %.3f s\n', deposito.obtenerRetardo());
fprintf('h0  = %.3f m\n', h0);
fprintf('Ts  = %.3f s\n', Ts);

simularDeposito(deposito, Ts);
