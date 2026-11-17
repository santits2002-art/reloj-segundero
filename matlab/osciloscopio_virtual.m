v = Rn(:,1);
v = v(isfinite(v));
if numel(v) > 500, v = v(1:500); end
v = v*(3.3/4095);
t = (0:numel(v)-1)*0.001;
if ~(exist('grafica','var') && ishandle(grafica)), figure('Name','Osciloscopio virtual - dsPIC','NumberTitle','off'); grafica = plot(nan,nan); grid on; xlabel('t (s)'); ylabel('V (V)'); title('Tension de entrada - ADC AN0'); xlim([0 0.5]); ylim([0 3.3]); end
if ~isempty(v), set(grafica,'XData',t,'YData',v); end
drawnow
