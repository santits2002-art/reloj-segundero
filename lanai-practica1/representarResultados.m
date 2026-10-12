function representarResultados(t, h, qSalida, qBomba, h0)
% Dibuja el nivel y los caudales.
% Guardar este archivo con el nombre representarResultados.m
%
% t: instantes de la simulacion, en segundos
% h: nivel del deposito en cada instante, en metros
% qSalida: caudal que sale del deposito
% qBomba: caudal que manda la bomba
% h0: nivel nominal

    figure   % Abre una ventana nueva

    % Grafica de arriba: el nivel
    subplot(2, 1, 1)
    plot(t, h, 'b', 'LineWidth', 1.5)
    hold on
    plot([t(1) t(end)], [h0 h0], 'k--')   % Linea horizontal en h0
    hold off
    grid on
    xlabel('Tiempo t [s]')
    ylabel('Nivel h [m]')
    title('Nivel del deposito')
    legend('Nivel h(t)', 'Nivel nominal h0')

    % Grafica de abajo: la bomba cambia, y la salida la sigue
    subplot(2, 1, 2)
    plot(t, qBomba, 'b', 'LineWidth', 1.2)
    hold on
    plot(t, qSalida, 'k', 'LineWidth', 1.2)
    hold off
    grid on
    xlabel('Tiempo t [s]')
    ylabel('Caudal [m^3/s]')
    title('Caudal de la bomba y caudal de salida')
    legend('Caudal de la bomba', 'Caudal de salida')
end
