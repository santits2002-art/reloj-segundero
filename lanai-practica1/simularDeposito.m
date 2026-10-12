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
    % Hay tres cambios, asi que la simulacion dura 3 veces eso.
    duracion = 4 * tau;
    tFinal = 3 * duracion;

    % En el instante 0 el deposito acaba de crearse
    k = 1;
    t(1) = 0;
    h(1) = deposito.obtenerNivel();
    qSalida(1) = deposito.obtenerCaudalSalida();

    % Se repite mientras no se haya llegado al tiempo final.
    % Cada vuelta suma Ts segundos: 0, 0.1, 0.2, 0.3, ...
    while t(k) < tFinal
        if t(k) < duracion
            qBomba(k) = 1.2 * q0;          % Mas caudal: el nivel sube
        elseif t(k) < 2 * duracion
            qBomba(k) = 0.8 * q0;          % Menos caudal: el nivel baja
        else
            qBomba(k) = q0;                % Otra vez el caudal de equilibrio
        end

        % actualizar avanza el deposito Ts segundos y devuelve el nivel nuevo
        h(k + 1) = deposito.actualizar(qBomba(k));
        qSalida(k + 1) = deposito.obtenerCaudalSalida();
        t(k + 1) = t(k) + Ts;
        k = k + 1;
    end

    % El ultimo punto de la bomba, para que la grafica llegue hasta el final
    qBomba(k) = qBomba(k - 1);

    % La grafica esta en otro archivo. Se llama desde aqui.
    representarResultados(t, h, qSalida, qBomba, h0);
end
