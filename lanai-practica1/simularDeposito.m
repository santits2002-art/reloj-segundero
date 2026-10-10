function [t, h, qSalida] = simularDeposito(deposito, Ts)
% Simula el nivel desde t = 0.
% Guardar este archivo con el nombre simularDeposito.m
%
% deposito: el deposito creado en el script
% Ts: cada cuanto tiempo se da un paso, en segundos

    % La clase permite leer estos tres datos
    tau = deposito.obtenerConstanteTiempo();  % Segundos que tarda en reaccionar
    q0 = deposito.obtenerCaudalNominal();     % Caudal que mantiene el nivel quieto
    K = deposito.obtenerGanancia();
    h0 = K * q0 / 2;   % Nivel nominal. En el PDF, R*q0 = 2*h0, y K es R.

    % El enunciado dice que el nivel no se estabiliza hasta unos 3*tau.
    % Cada cambio de la bomba dura 4*tau, para ver el nivel ya quieto.
    duracion = 4 * tau;
    pasosPorTramo = round(duracion / Ts);   % Cuantos pasos caben en 4*tau
    pasosTotales = 3 * pasosPorTramo;       % Tres cambios: subir, bajar y volver

    % Listas de ceros. La posicion 1 sera el instante t = 0.
    t = zeros(1, pasosTotales + 1);
    h = zeros(1, pasosTotales + 1);
    qSalida = zeros(1, pasosTotales + 1);
    qBomba = zeros(1, pasosTotales + 1);

    h(1) = deposito.obtenerNivel();
    qSalida(1) = deposito.obtenerCaudalSalida();

    % k va tomando los valores 1, 2, 3, ... hasta pasosTotales
    for k = 1:pasosTotales
        tiempo = (k - 1) * Ts;    % 0, Ts, 2*Ts, 3*Ts, ...

        if tiempo < duracion
            qBomba(k) = 1.2 * q0;          % Mas caudal: el nivel sube
        elseif tiempo < 2 * duracion
            qBomba(k) = 0.8 * q0;          % Menos caudal: el nivel baja
        else
            qBomba(k) = q0;                % Otra vez el caudal de equilibrio
        end

        % actualizar avanza el deposito Ts segundos y devuelve el nivel nuevo
        h(k + 1) = deposito.actualizar(qBomba(k));
        qSalida(k + 1) = deposito.obtenerCaudalSalida();
        t(k + 1) = k * Ts;
    end

    qBomba(pasosTotales + 1) = qBomba(pasosTotales);

    % La grafica esta en otro archivo. Se llama desde aqui.
    representarResultados(t, h, qSalida, qBomba, h0);
end
