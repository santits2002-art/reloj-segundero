% Pega este texto en picgui, sustituyendo el anterior. Cada linea es una orden completa.
% La ventana se abre al pulsar Start, aunque todavia no haya muestras en Rn.
if ~(exist('grafica','var') && ishandle(grafica) && exist('textoMedidas','var') && ishandle(textoMedidas)), figure('Name','Osciloscopio virtual - dsPIC','NumberTitle','off','Color','w'); grafica = plot(nan,nan,'b','LineWidth',1.25); grid on; xlabel('t (s)'); ylabel('V (V)'); title('Tension de entrada - ADC AN0'); xlim([0 0.5]); ylim([0 3.3]); textoMedidas = text('Units','normalized','Position',[0.98 0.96 0],'HorizontalAlignment','right','VerticalAlignment','top','BackgroundColor','w','EdgeColor',[0.45 0.45 0.45],'Margin',5,'String',sprintf('Maximo: --\nMinimo: --\nInstantaneo: --')); end
Ts = 1e-3; N = round(0.5/Ts);
v = [];
if exist('Rn','var') && ~isempty(Rn), v = Rn(:,1); v = v(isfinite(v)); end
if ~isempty(v) && max(v) > 3.6, v = v*(3.3/4095); end
if numel(v) > N, v = v(end-N+1:end); end
if isempty(v), set(grafica,'XData',nan,'YData',nan); set(textoMedidas,'String',sprintf('Maximo: --\nMinimo: --\nInstantaneo: --')); end
if ~isempty(v), set(grafica,'XData',(0:numel(v)-1)*Ts,'YData',v); set(textoMedidas,'String',sprintf('Maximo: %.3f V\nMinimo: %.3f V\nInstantaneo: %.3f V',max(v),min(v),v(end))); end
drawnow
