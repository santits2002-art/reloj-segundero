function [t, h, qSalida] = simularDeposito(deposito, Ts)
%SIMULARDEPOSITO Simula el deposito desde t = 0.
%   El caudal de la bomba da tres escalones: 1.2*q0, 0.8*q0 y q0.
%   Cada uno dura 4*tau, mas que los 3*tau del enunciado, para que el
%   nivel llegue a estabilizarse antes del siguiente cambio.
%   Ts tiene que ser el mismo paso con el que se creo el deposito.

    tau = deposito.obtenerConstanteTiempo();
    q0 = deposito.obtenerCaudalNominal();
    K = deposito.obtenerGanancia();
    h0 = K * q0 / 2;   % Porque R*q0 = 2*h0

    nTramo = round(4 * tau / Ts);
    nPasos = 3 * nTramo;
    t = (0:nPasos)' * Ts;

    h = zeros(nPasos + 1, 1);
    qSalida = zeros(nPasos + 1, 1);
    qBomba = zeros(nPasos + 1, 1);

    h(1) = deposito.obtenerNivel();
    qSalida(1) = deposito.obtenerCaudalSalida();

    for k = 1:nPasos
        if k <= nTramo
            qBomba(k) = 1.2 * q0;
        elseif k <= 2 * nTramo
            qBomba(k) = 0.8 * q0;
        else
            qBomba(k) = q0;
        end

        h(k + 1) = deposito.actualizar(qBomba(k));
        qSalida(k + 1) = deposito.obtenerCaudalSalida();
    end
    qBomba(end) = qBomba(end - 1);

    representarResultados(t, h, qSalida, qBomba, h0);
end
