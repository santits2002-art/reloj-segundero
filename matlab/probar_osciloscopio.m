% Vista previa sin la placa. Simula Rn como lo haria picgui y llama
% al mismo script del osciloscopio. En el laboratorio no hace falta:
% picgui llama a osciloscopio_virtual solo.
%
%   >> cd('matlab')
%   >> probar_osciloscopio

close all

fs = 1000;
duracion = 2.0;
n = round(duracion * fs);
k = (0:n-1)';
% Giro de potenciometro parecido a la captura de clase, y luego sube.
forma = 1.35 + 0.45*sin(2*pi*0.7*k/fs) .* exp(-((k/fs - 1.0)/0.55).^2);
forma = min(3.3, max(0, forma));

figPrueba = [];
cuentas = round(forma * 4095 / 3.3);
for i = 100:50:n
    Rn = cuentas(1:i);
    t_Rn = (0:i-1)' / fs;
    osciloscopio_virtual
    drawnow
    if isempty(figPrueba) || ~ishandle(figPrueba)
        figPrueba = findobj(0, 'Type', 'figure', 'Name', 'Osciloscopio virtual - dsPIC');
    end
end

