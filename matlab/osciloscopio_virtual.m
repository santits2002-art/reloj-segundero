% Osciloscopio virtual del dsPIC33EP256GP502 (ADC AN0).
%
% El modelo lee el potenciometro por AN0 y lo manda por UART Tx-Matlab,
% canal 1 (bloque "UART 1 Tx - Matlab" de la foto). picgui decodifica
% esas tramas en la matriz Rn y ejecuta este script cada Delay.
%
% En picgui, sin pulsar "plot uint16" (ese boton sustituye este script):
%   1. COM de la placa, 115200, flujo none. Special Channel = -1.
%   2. Buffer 50000, SubBuffer Rn 10000, Delay 0.1
%   3. Pega este script en el cuadro, o escribe:  osciloscopio_virtual
%   4. Conexion, luego Start. Al girar el potenciometro la curva se mueve.
%
% picgui ya repite el script: no pongas un while, o dejara de leer la UART.
% La figura se crea una vez. Despues solo se cambian los datos, que es lo
% que comento el profesor para que no parpadee:
%
%   grafica = plot(...)
%   set(grafica, 'XData', t, 'YData', v)
%   drawnow
%
% El UART Tx del sprintf ("Valor: %.3f V") no debe transmitir a la vez:
% picgui solo entiende el protocolo de Tx-Matlab. Si los dos escriben en
% la UART 1, la curva sale a ruido.
%
% TS_MODELO es el Sample time del bloque Tx-Matlab. Con 115200 baud el
% tope es 11.51 bytes por paso de 1 ms. Si la escala horizontal no cuadra
% con un giro real, pon aqui el sample time de ese bloque.

CANAL = 1;
VENTANA = 0.5;
TS_MODELO = 1e-3;

v = [];
tAbs = [];

if exist('Rn', 'var') && ~isempty(Rn) && size(Rn, 2) >= CANAL
    if exist('t_Rn', 'var')
        tRn = t_Rn(:);
    elseif exist('T_Rn', 'var')
        tRn = T_Rn(:);
    else
        tRn = [];
    end

    A = [];
    tPadr = [];
    if exist('picgui.padr', 'file')
        try
            if isempty(tRn)
                A = picgui.padr(Rn, CANAL);
            else
                [A, tPadr] = picgui.padr(Rn, CANAL, tRn);
            end
        catch
            A = [];
        end
    end
    if isempty(A) && exist('padr', 'file')
        try
            if isempty(tRn)
                A = padr(Rn, CANAL);
            else
                [A, tPadr] = padr(Rn, CANAL, tRn);
            end
        catch
            A = [];
        end
    end

    if ~isempty(A)
        columna = double(A(:, min(CANAL, size(A, 2))));
        if numel(tPadr) == numel(columna)
            tCol = double(tPadr(:));
        else
            tCol = nan(numel(columna), 1);
        end
    else
        columna = double(Rn(:, CANAL));
        if numel(tRn) == numel(columna)
            tCol = double(tRn(:));
        else
            tCol = nan(numel(columna), 1);
        end
    end

    if any(isfinite(tCol))
        validos = isfinite(columna) & isfinite(tCol);
        v = columna(validos);
        tAbs = tCol(validos);
    else
        v = columna(isfinite(columna));
        tAbs = [];
    end
end

v = v(:);
% Voltios (tras la ganancia 3.3/4095) se quedan como estan.
% Cuentas del ADC de 12 bits (0..4095) se pasan a voltios.
if ~isempty(v) && max(v) > 3.6
    v = v * (3.3/4095);
end

% Que se vea solo la ultima ventana de 0.5 s, con el dato nuevo a la derecha.
t = [];
if numel(tAbs) == numel(v) && numel(v) >= 2
    tAbs = tAbs(:);
    dt = diff(tAbs);
    dtPositivos = dt(dt > 0);
    if isempty(dtPositivos)
        dtMed = 0;
    else
        dtMed = median(dtPositivos);
    end
    if dtMed >= 1e-5 && dtMed <= 0.1 && all(dt >= -1e-6)
        tRel = tAbs - tAbs(end);
        enVentana = tRel >= -VENTANA;
        if any(enVentana)
            v = v(enVentana);
            t = tRel(enVentana) + VENTANA;
        end
    end
end

if isempty(t) && ~isempty(v)
    nWin = max(2, round(VENTANA / TS_MODELO));
    if numel(v) > nWin
        v = v(end-nWin+1:end);
    end
    t = (0:numel(v)-1)' * TS_MODELO;
end
t = t(:);
v = v(:);

figOsc = findobj(0, 'Type', 'figure', 'Tag', 'osc_dspic');
crear = isempty(figOsc) || ~ishandle(figOsc(1));
if ~crear
    figOsc = figOsc(1);
    grafica = findobj(figOsc, 'Tag', 'osc_linea_an0');
    textoMedidas = findobj(figOsc, 'Tag', 'osc_texto_an0');
    crear = isempty(grafica) || isempty(textoMedidas) ...
        || ~ishandle(grafica(1)) || ~ishandle(textoMedidas(1));
    if crear
        close(figOsc);
    else
        grafica = grafica(1);
        textoMedidas = textoMedidas(1);
    end
end

if crear
    figOsc = figure('Name', 'Osciloscopio virtual - dsPIC', ...
        'NumberTitle', 'off', ...
        'Tag', 'osc_dspic', ...
        'Color', 'w');
    axOsc = axes('Parent', figOsc, 'Tag', 'osc_ejes_an0');
    grafica = plot(axOsc, NaN, NaN, ...
        'Color', [0 0.4470 0.7410], ...
        'LineWidth', 1.25, ...
        'Tag', 'osc_linea_an0');
    xlabel(axOsc, 't (s)');
    ylabel(axOsc, 'V (V)');
    title(axOsc, 'Tension de entrada - ADC AN0');
    set(axOsc, ...
        'XGrid', 'on', ...
        'YGrid', 'on', ...
        'XLim', [0 VENTANA], ...
        'YLim', [0 3.3], ...
        'XTick', linspace(0, VENTANA, 11), ...
        'YTick', [0 0.5 1 1.5 2 2.5 3 3.3], ...
        'XLimMode', 'manual', ...
        'YLimMode', 'manual');
    textoMedidas = text('Parent', axOsc, ...
        'Units', 'normalized', ...
        'Position', [0.98 0.96 0], ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'top', ...
        'FontName', 'FixedWidth', ...
        'FontSize', 9, ...
        'BackgroundColor', 'w', ...
        'EdgeColor', [0.45 0.45 0.45], ...
        'Margin', 5, ...
        'Tag', 'osc_texto_an0', ...
        'String', '');
end

if isempty(v)
    set(textoMedidas, 'String', sprintf('Maximo:      --\nMinimo:      --\nInstantaneo: --'));
    drawnow;
    return;
end

set(grafica, 'XData', t, 'YData', v);
set(textoMedidas, 'String', sprintf( ...
    'Maximo:      %.3f V\nMinimo:      %.3f V\nInstantaneo: %.3f V', ...
    max(v), min(v), v(end)));
drawnow;
