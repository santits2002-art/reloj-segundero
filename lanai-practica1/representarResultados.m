function representarResultados(t, h, qSalida, qBomba, h0)
%REPRESENTARRESULTADOS Dibuja el nivel y los caudales.

    figure
    subplot(2, 1, 1)
    plot(t, h, 'b', 'LineWidth', 1.5)
    hold on
    plot(t, h0 * ones(size(t)), 'k--')
    hold off
    grid on
    xlabel('Tiempo t [s]')
    ylabel('Nivel h [m]')
    title('Nivel del deposito')
    legend('h(t)', 'h_0', 'Location', 'best')

    subplot(2, 1, 2)
    stairs(t, qBomba, 'b', 'LineWidth', 1.2)
    hold on
    plot(t, qSalida, 'k', 'LineWidth', 1.2)
    hold off
    grid on
    xlabel('Tiempo t [s]')
    ylabel('Caudal [m^3/s]')
    title('Caudal de la bomba y caudal de salida')
    legend('q_{bomba}', 'q_{salida}', 'Location', 'best')
end
