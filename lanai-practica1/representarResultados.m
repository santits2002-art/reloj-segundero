function representarResultados(t, h, qSalida, qBomba, qEntrada, info)
%REPRESENTARRESULTADOS Dibuja la evolucion del deposito.
%
%   representarResultados(t, h, qSalida)
%   representarResultados(t, h, qSalida, qBomba, qEntrada, info)
%
%   t: tiempos de simulacion [s], desde 0 hasta tf.
%   h: nivel del deposito [m] en esos instantes.
%   qSalida: caudal de salida [m^3/s] en esos instantes.
%   qBomba, qEntrada: caudales de bomba y de entrada [m^3/s].
%   info: estructura con h0, tau, retardo, hExacta y nivelesEquilibrio.
%
%   Se crean dos figuras:
%     1. Toda la simulacion (nivel y caudales).
%     2. Los primeros instantes, para ver el retardo L.
%   Tambien se guardan nivel_y_caudales.png y detalle_retardo.png
%   en la carpeta de trabajo actual.

    if nargin < 3
        error('Hay que pasar el tiempo, el nivel y el caudal de salida.');
    end

    t = t(:);
    h = h(:);
    qSalida = qSalida(:);
    if numel(t) ~= numel(h) || numel(t) ~= numel(qSalida)
        error('t, h y qSalida deben tener la misma longitud.');
    end
    if numel(t) < 2
        error('Hace falta al menos dos instantes para representar la evolucion.');
    end

    hayCaudales = nargin >= 5 && ~isempty(qBomba) && ~isempty(qEntrada);
    if hayCaudales
        qBomba = qBomba(:);
        qEntrada = qEntrada(:);
        if numel(qBomba) ~= numel(t) || numel(qEntrada) ~= numel(t)
            error('qBomba y qEntrada deben tener la misma longitud que t.');
        end
    end

    hayInfo = nargin >= 6 && isstruct(info);

    fig1 = figure('Name', 'Simulacion del deposito', 'Color', 'w', ...
        'Position', [80 80 980 720]);
    if hayCaudales
        tl1 = tiledlayout(fig1, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
    else
        tl1 = tiledlayout(fig1, 1, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
    end
    title(tl1, 'Deposito linealizado: respuesta a cambios del caudal de bomba');

    ax1 = nexttile(tl1);
    hold(ax1, 'on');
    plot(ax1, t, h, 'b-', 'LineWidth', 1.5, 'DisplayName', 'h(t), Euler');
    if hayInfo && isfield(info, 'hExacta') && numel(info.hExacta) == numel(t)
        plot(ax1, t, info.hExacta(:), '--', 'Color', [0.85 0.25 0.1], ...
            'LineWidth', 1.2, 'DisplayName', 'h(t), modelo lineal exacto');
    end
    if hayInfo && isfield(info, 'h0')
        yline(ax1, info.h0, 'k:', 'LineWidth', 1, 'DisplayName', 'h_0 nominal');
    end
    if hayInfo && isfield(info, 'nivelesEquilibrio')
        niveles = unique(info.nivelesEquilibrio(:).');
        etiquetaPuesta = false;
        for i = 1:numel(niveles)
            if hayInfo && isfield(info, 'h0') && abs(niveles(i) - info.h0) < 1e-9
                continue
            end
            if ~etiquetaPuesta
                yline(ax1, niveles(i), '--', 'Color', [0.35 0.35 0.35], ...
                    'LineWidth', 0.9, 'DisplayName', 'equilibrio del escalon');
                etiquetaPuesta = true;
            else
                yline(ax1, niveles(i), '--', 'Color', [0.35 0.35 0.35], ...
                    'LineWidth', 0.9, 'HandleVisibility', 'off');
            end
        end
    end
    if hayInfo && isfield(info, 'retardo') && isfield(info, 'tau')
        t95 = info.retardo + 3 * info.tau;
        if t95 > t(1) && t95 < t(end)
            xline(ax1, t95, ':', 'Color', [0.1 0.45 0.15], 'LineWidth', 1.1, ...
                'DisplayName', 'L + 3\tau (95 %)');
        end
    end
    hold(ax1, 'off');
    grid(ax1, 'on');
    xlabel(ax1, 'Tiempo t [s]');
    ylabel(ax1, 'Nivel h(t) [m]');
    title(ax1, 'Nivel del deposito');
    legend(ax1, 'Location', 'best');

    if hayCaudales
        ax2 = nexttile(tl1);
        hold(ax2, 'on');
        stairs(ax2, t, qBomba, 'b-', 'LineWidth', 1.2, 'DisplayName', 'q_{bomba}(t)');
        stairs(ax2, t, qEntrada, 'r-', 'LineWidth', 1.2, 'DisplayName', 'q_{entrada}(t)');
        plot(ax2, t, qSalida, 'k-', 'LineWidth', 1.2, 'DisplayName', 'q_{salida}(t)');
        hold(ax2, 'off');
        grid(ax2, 'on');
        xlabel(ax2, 'Tiempo t [s]');
        ylabel(ax2, 'Caudal [m^3/s]');
        title(ax2, 'Caudales de bomba, de entrada y de salida');
        legend(ax2, 'Location', 'best');
        linkaxes([ax1, ax2], 'x');
    end

    exportgraphics(fig1, 'nivel_y_caudales.png', 'Resolution', 150);

    if ~(hayCaudales && hayInfo && isfield(info, 'retardo') && isfield(info, 'tau'))
        return
    end

    % Ventana corta: el retardo se ve, y tambien el comienzo de la subida.
    if info.retardo > 0
        tZoom = info.retardo + 0.5 * info.tau;
    else
        tZoom = 0.5 * info.tau;
    end
    tZoom = min(t(end), max(tZoom, t(2)));
    mascara = t <= tZoom + 1e-9;

    fig2 = figure('Name', 'Detalle del retardo', 'Color', 'w', ...
        'Position', [140 120 980 640]);
    tl2 = tiledlayout(fig2, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(tl2, 'Detalle inicial: q_{entrada}(t) = q_{bomba}(t - L)');

    ax3 = nexttile(tl2);
    hold(ax3, 'on');
    plot(ax3, t(mascara), h(mascara), 'b-', 'LineWidth', 1.5, 'DisplayName', 'h(t)');
    if isfield(info, 'h0')
        yline(ax3, info.h0, 'k:', 'LineWidth', 1, 'DisplayName', 'h_0');
    end
    if info.retardo > 0
        xline(ax3, info.retardo, 'r--', 'LineWidth', 1.1, 'DisplayName', 't = L');
    end
    hold(ax3, 'off');
    grid(ax3, 'on');
    xlabel(ax3, 'Tiempo t [s]');
    ylabel(ax3, 'Nivel h(t) [m]');
    title(ax3, 'El nivel espera al caudal que aun esta en el retardo');
    legend(ax3, 'Location', 'best');

    ax4 = nexttile(tl2);
    hold(ax4, 'on');
    stairs(ax4, t(mascara), qBomba(mascara), 'b-', 'LineWidth', 1.2, 'DisplayName', 'q_{bomba}');
    stairs(ax4, t(mascara), qEntrada(mascara), 'r-', 'LineWidth', 1.2, 'DisplayName', 'q_{entrada}');
    plot(ax4, t(mascara), qSalida(mascara), 'k-', 'LineWidth', 1.2, 'DisplayName', 'q_{salida}');
    if info.retardo > 0
        xline(ax4, info.retardo, 'r--', 'LineWidth', 1.1, 'HandleVisibility', 'off');
    end
    hold(ax4, 'off');
    grid(ax4, 'on');
    xlabel(ax4, 'Tiempo t [s]');
    ylabel(ax4, 'Caudal [m^3/s]');
    title(ax4, 'La bomba cambia en t = 0; el deposito lo recibe en t = L');
    legend(ax4, 'Location', 'best');
    linkaxes([ax3, ax4], 'x');

    exportgraphics(fig2, 'detalle_retardo.png', 'Resolution', 150);
end
