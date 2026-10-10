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
        ax1 = subplot(2, 1, 1);
    else
        ax1 = subplot(1, 1, 1);
    end
    hold(ax1, 'on');
    plot(ax1, t, h, 'b-', 'LineWidth', 1.5, 'DisplayName', 'h(t), Euler');
    if hayInfo && isfield(info, 'hExacta') && numel(info.hExacta) == numel(t)
        plot(ax1, t, info.hExacta(:), '--', 'Color', [0.85 0.25 0.1], ...
            'LineWidth', 1.2, 'DisplayName', 'h(t), modelo lineal exacto');
    end
    if hayInfo && isfield(info, 'h0')
        plot(ax1, [t(1) t(end)], [info.h0 info.h0], 'k:', ...
            'LineWidth', 1, 'DisplayName', 'h_0 nominal');
    end
    if hayInfo && isfield(info, 'nivelesEquilibrio')
        niveles = unique(info.nivelesEquilibrio(:).');
        etiquetaPuesta = false;
        for i = 1:numel(niveles)
            if hayInfo && isfield(info, 'h0') && abs(niveles(i) - info.h0) < 1e-9
                continue
            end
            if ~etiquetaPuesta
                plot(ax1, [t(1) t(end)], [niveles(i) niveles(i)], '--', ...
                    'Color', [0.35 0.35 0.35], 'LineWidth', 0.9, ...
                    'DisplayName', 'equilibrio del escalon');
                etiquetaPuesta = true;
            else
                plot(ax1, [t(1) t(end)], [niveles(i) niveles(i)], '--', ...
                    'Color', [0.35 0.35 0.35], 'LineWidth', 0.9, ...
                    'HandleVisibility', 'off');
            end
        end
    end
    if hayInfo && isfield(info, 'retardo') && isfield(info, 'tau')
        t95 = info.retardo + 3 * info.tau;
        if t95 > t(1) && t95 < t(end)
            yl = ylim(ax1);
            plot(ax1, [t95 t95], yl, ':', 'Color', [0.1 0.45 0.15], ...
                'LineWidth', 1.1, 'DisplayName', 'L + 3\tau (95 %)');
            ylim(ax1, yl);
        end
    end
    hold(ax1, 'off');
    grid(ax1, 'on');
    xlabel(ax1, 'Tiempo t [s]');
    ylabel(ax1, 'Nivel h(t) [m]');
    title(ax1, 'Nivel del deposito');
    legend(ax1, 'Location', 'southwest');

    if hayCaudales
        ax2 = subplot(2, 1, 2);
        hold(ax2, 'on');
        stairs(ax2, t, qBomba, 'b-', 'LineWidth', 1.2, 'DisplayName', 'q_{bomba}(t)');
        stairs(ax2, t, qEntrada, 'r-', 'LineWidth', 1.2, 'DisplayName', 'q_{entrada}(t)');
        plot(ax2, t, qSalida, 'k-', 'LineWidth', 1.2, 'DisplayName', 'q_{salida}(t)');
        hold(ax2, 'off');
        grid(ax2, 'on');
        xlabel(ax2, 'Tiempo t [s]');
        ylabel(ax2, 'Caudal [m^3/s]');
    title(ax2, 'Caudales de bomba, de entrada y de salida');
    legend(ax2, 'Location', 'northeast');
        linkaxes([ax1, ax2], 'x');
    end

    drawnow;
    print(fig1, 'nivel_y_caudales.png', '-dpng', '-r150');

    if ~(hayCaudales && hayInfo && isfield(info, 'retardo') && isfield(info, 'tau'))
        return
    end

    % Ventana de unos pocos retardos: L ocupa bastante sitio y se ve
    % que el nivel sigue quieto hasta que llega el nuevo caudal.
    if info.retardo > 0
        tZoom = max(5 * info.retardo, info.retardo + 0.15 * info.tau);
    else
        tZoom = 0.15 * info.tau;
    end
    tZoom = min(t(end), max(tZoom, t(2)));
    mascara = t <= tZoom + 1e-9;

    fig2 = figure('Name', 'Detalle del retardo', 'Color', 'w', ...
        'Position', [140 120 980 640]);

    ax3 = subplot(2, 1, 1);
    hold(ax3, 'on');
    plot(ax3, t(mascara), h(mascara), 'b-', 'LineWidth', 1.5, 'DisplayName', 'h(t)');
    hZoom = h(mascara);
    margen = max(0.005, 0.2 * (max(hZoom) - min(hZoom)));
    ylim(ax3, [min(hZoom) - margen, max(hZoom) + margen]);
    if isfield(info, 'h0')
        plot(ax3, [t(1) tZoom], [info.h0 info.h0], 'k:', ...
            'LineWidth', 1, 'DisplayName', 'h_0');
    end
    if info.retardo > 0
        yl = ylim(ax3);
        plot(ax3, [info.retardo info.retardo], yl, 'r--', ...
            'LineWidth', 1.1, 'DisplayName', 't = L');
        ylim(ax3, yl);
    end
    hold(ax3, 'off');
    grid(ax3, 'on');
    xlabel(ax3, 'Tiempo t [s]');
    ylabel(ax3, 'Nivel h(t) [m]');
    title(ax3, 'El nivel espera al caudal que aun esta en el retardo');
    legend(ax3, 'Location', 'northwest');

    ax4 = subplot(2, 1, 2);
    hold(ax4, 'on');
    stairs(ax4, t(mascara), qBomba(mascara), 'b-', 'LineWidth', 1.2, ...
        'DisplayName', 'q_{bomba}');
    stairs(ax4, t(mascara), qEntrada(mascara), 'r-', 'LineWidth', 1.2, ...
        'DisplayName', 'q_{entrada}');
    plot(ax4, t(mascara), qSalida(mascara), 'k-', 'LineWidth', 1.2, ...
        'DisplayName', 'q_{salida}');
    if info.retardo > 0
        yl = ylim(ax4);
        plot(ax4, [info.retardo info.retardo], yl, 'r--', ...
            'LineWidth', 1.1, 'HandleVisibility', 'off');
        ylim(ax4, yl);
    end
    hold(ax4, 'off');
    grid(ax4, 'on');
    xlabel(ax4, 'Tiempo t [s]');
    ylabel(ax4, 'Caudal [m^3/s]');
    title(ax4, 'La bomba cambia en t = 0; el deposito lo recibe en t = L');
    legend(ax4, 'Location', 'southeast');
    linkaxes([ax3, ax4], 'x');

    drawnow;
    print(fig2, 'detalle_retardo.png', '-dpng', '-r150');
end
