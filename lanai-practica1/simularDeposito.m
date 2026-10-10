function [t, h, qSalida, qBomba, qEntrada] = simularDeposito(deposito, tFinal, qBombaUsuario)
%SIMULARDEPOSITO Simula el nivel desde t = 0 hasta t = tFinal.
%
%   [t, h, qSalida, qBomba, qEntrada] = simularDeposito(deposito)
%   [t, h, qSalida, qBomba, qEntrada] = simularDeposito(deposito, tFinal)
%   [t, h, qSalida, qBomba, qEntrada] = simularDeposito(deposito, tFinal, qBomba)
%
%   deposito: objeto de la clase Deposito.
%   tFinal: instante final [s]. Si se omite, se simulan tres tramos de
%           4*tau para ver el regimen permanente de cada escalon.
%   qBomba: caudal de la bomba en cada paso [m^3/s]. Si se omite, la
%           funcion construye tres escalones:
%               1.2*q0,  0.8*q0,  q0
%           Cada escalon dura 4*tau. El enunciado recuerda que un sistema
%           de primer orden no se da por estabilizado hasta ts ≈ 3*tau
%           (entonces ha recorrido el 95 % del cambio). El cuarto tau deja
%           un tramo ya practicamente plano antes del cambio siguiente.
%
%   Salidas (vectores columna, un valor por instante t = 0, Ts, 2*Ts, ...):
%       h         nivel [m]
%       qSalida   caudal de salida del modelo lineal [m^3/s]
%       qBomba    caudal mandado a la bomba [m^3/s]
%       qEntrada  caudal que entra al deposito, qBomba retrasado L [m^3/s]
%
%   Al terminar llama a representarResultados.

    if nargin < 1 || ~isa(deposito, 'Deposito')
        error('El primer argumento debe ser un objeto Deposito.');
    end

    Ts = deposito.obtenerPaso();
    tau = deposito.obtenerConstanteTiempo();
    q0 = deposito.obtenerCaudalNominal();
    L = deposito.obtenerRetardo();
    h0 = deposito.obtenerNivelNominal();
    K = deposito.obtenerGanancia();

    % Cada escalon se mantiene 4 constantes de tiempo.
    nTramo = max(1, round(4 * tau / Ts));

    if nargin < 2 || isempty(tFinal)
        nPasos = 3 * nTramo;
    else
        if ~isnumeric(tFinal) || ~isscalar(tFinal) || ~isreal(tFinal) || ~isfinite(tFinal) || tFinal <= 0
            error('tFinal debe ser un escalar real, finito y positivo.');
        end
        nPasos = round(tFinal / Ts);
        if nPasos < 1
            error('tFinal debe contener al menos un paso de integracion.');
        end
        if abs(nPasos * Ts - tFinal) > 1e-6 * max(1, abs(tFinal))
            warning('simularDeposito:tFinal', ...
                'tFinal no es multiplo de Ts. Se simulara hasta %.6g s.', nPasos * Ts);
        end
        if nPasos * Ts < 3 * tau
            warning('simularDeposito:duracion', ...
                ['La simulacion (%.3g s) es mas corta que 3*tau (%.3g s). ', ...
                 'El nivel todavia estara en transitorio al terminar.'], ...
                nPasos * Ts, 3 * tau);
        end
    end

    usarSenalPropia = nargin < 3 || isempty(qBombaUsuario);
    if ~usarSenalPropia
        qBombaUsuario = qBombaUsuario(:);
        if numel(qBombaUsuario) ~= nPasos && numel(qBombaUsuario) ~= nPasos + 1
            error('qBomba debe tener %d valores (uno por paso) o %d (uno por instante).', ...
                nPasos, nPasos + 1);
        end
    end

    t = (0:nPasos).' * Ts;
    h = zeros(nPasos + 1, 1);
    qSalida = zeros(nPasos + 1, 1);
    qBomba = zeros(nPasos + 1, 1);
    qEntrada = zeros(nPasos + 1, 1);
    hExacta = zeros(nPasos + 1, 1);

    % Estado inicial: el que tenga ahora el objeto (h0 si se acaba de crear
    % sin AlturaInicial, o el valor con el que se haya llamado a reiniciar).
    h(1) = deposito.obtenerNivel();
    qSalida(1) = deposito.obtenerCaudalSalida();
    hExacta(1) = h(1);

    % Factor exacto del modelo lineal en un paso, con caudal de entrada constante.
    %   DeltaH(k+1) = exp(-Ts/tau)*DeltaH(k) + K*(1-exp(-Ts/tau))*DeltaQentrada(k)
    % Euler es la aproximacion exp(-Ts/tau) ≈ 1 - Ts/tau de esta misma formula.
    alpha = exp(-Ts / tau);

    for k = 1:nPasos
        if usarSenalPropia
            qBomba(k) = caudalEscalon(k - 1, nTramo, q0);
        else
            qBomba(k) = qBombaUsuario(k);
        end

        % actualizar aplica el retardo, integra un paso de Euler y refresca qSalida.
        [h(k + 1), qEntrada(k)] = deposito.actualizar(qBomba(k));
        qSalida(k + 1) = deposito.obtenerCaudalSalida();

        deltaQEntrada = qEntrada(k) - q0;
        hExacta(k + 1) = h0 + (hExacta(k) - h0) * alpha + K * deltaQEntrada * (1 - alpha);
    end

    % En t = tFinal no empieza otro paso. Se repite el ultimo caudal para
    % que stairs dibuje el tramo final hasta el ultimo instante.
    qBomba(end) = qBomba(end - 1);
    qEntrada(end) = qEntrada(end - 1);

    errorMaximo = max(abs(h - hExacta));

    fprintf('\n--- Simulacion del deposito ---\n');
    fprintf('h0 = %.4f m,  q0 = %.6f m^3/s\n', h0, q0);
    fprintf('K = R = %.4f s/m^2,  tau = %.4f s,  L = %.4f s,  Ts = %.4f s\n', K, tau, L, Ts);
    fprintf('tFinal = %.4f s  (%.2f tau)\n', t(end), t(end) / tau);
    fprintf('Error maximo |Euler - solucion exacta del lineal| = %.3e m\n', errorMaximo);

    if usarSenalPropia
        fprintf('Escalones de bomba: 1.2*q0, 0.8*q0 y q0. Cada uno dura %.2f s.\n', nTramo * Ts);
        fprintf('Equilibrios del modelo lineal: h = %.4f m, %.4f m y %.4f m.\n', ...
            h0 + K * 0.2 * q0, h0 - K * 0.2 * q0, h0);
        indices = [nTramo, 2 * nTramo, nPasos];
        indices = indices(indices >= 1 & indices <= nPasos);
        for i = 1:numel(indices)
            idx = indices(i) + 1;
            fprintf('  Fin de tramo en t = %7.2f s:  h = %.4f m,  qSalida = %.6f m^3/s\n', ...
                t(idx), h(idx), qSalida(idx));
        end
    end

    info.h0 = h0;
    info.tau = tau;
    info.retardo = L;
    info.q0 = q0;
    info.K = K;
    info.hExacta = hExacta;
    if usarSenalPropia
        info.nivelesEquilibrio = [h0 + K * 0.2 * q0, h0 - K * 0.2 * q0, h0];
    else
        info.nivelesEquilibrio = h0;
    end

    representarResultados(t, h, qSalida, qBomba, qEntrada, info);
end

function q = caudalEscalon(indicePaso, nTramo, q0)
% Caudal de bomba constante a tramos, a partir del indice de paso 0, 1, 2, ...
    if indicePaso < nTramo
        q = 1.2 * q0;
    elseif indicePaso < 2 * nTramo
        q = 0.8 * q0;
    else
        q = q0;
    end
end
