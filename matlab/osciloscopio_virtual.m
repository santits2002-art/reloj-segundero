% Pega este script en el cuadro de picgui.
% Canal 1, ventana de 0.5 s. picgui lo repite solo: no pongas un while.

Ts = 1e-3;
N = round(0.5 / Ts);

if ~exist('Rn', 'var') || isempty(Rn)
    return
end

v = Rn(:, 1);
v = v(isfinite(v));
if isempty(v)
    return
end

% Voltios se quedan igual. Cuentas del ADC (0..4095) se pasan a voltios.
if max(v) > 3.6
    v = v * (3.3/4095);
end

if numel(v) > N
    v = v(end-N+1:end);
end
t = (0:numel(v)-1) * Ts;

if ~exist('grafica', 'var') || ~ishandle(grafica)
    figure('Name', 'Osciloscopio virtual - dsPIC', 'NumberTitle', 'off', 'Color', 'w')
    grafica = plot(nan, nan, 'LineWidth', 1.25);
    grid on
    xlabel('t (s)')
    ylabel('V (V)')
    title('Tension de entrada - ADC AN0')
    xlim([0 0.5])
    ylim([0 3.3])
    textoMedidas = text('Units', 'normalized', 'Position', [0.98 0.96 0], ...
        'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', ...
        'BackgroundColor', 'w', 'EdgeColor', [0.45 0.45 0.45], 'Margin', 5);
end

set(grafica, 'XData', t, 'YData', v)
set(textoMedidas, 'String', sprintf('Maximo: %.3f V\nMinimo: %.3f V\nInstantaneo: %.3f V', ...
    max(v), min(v), v(end)))
drawnow
