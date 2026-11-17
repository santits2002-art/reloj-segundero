% Cada linea es una orden completa: picgui evalua el cuadro linea a linea.
% Busca numeros en Rn y, si ahi no hay, en R (el buffer grande de picgui).
if ~(exist('grafica','var') && ishandle(grafica) && exist('textoMedidas','var') && ishandle(textoMedidas)), figure('Name','Osciloscopio virtual - dsPIC','NumberTitle','off','Color','w'); grafica = plot(nan,nan,'b','LineWidth',1.25); grid on; xlabel('t (s)'); ylabel('V (V)'); title('Tension de entrada - ADC AN0'); xlim([0 0.5]); ylim([0 3.3]); textoMedidas = text('Units','normalized','Position',[0.98 0.96 0],'HorizontalAlignment','right','VerticalAlignment','top','BackgroundColor','w','EdgeColor',[0.45 0.45 0.45],'Margin',5,'String',sprintf('Maximo: --\nMinimo: --\nInstantaneo: --')); end
Ts = 1e-3; N = round(0.5/Ts);
src = [];
try, src = evalin('base','Rn'); end
if isempty(src) || ~any(isfinite(src(:))), try, src = evalin('base','R'); end, end
if isempty(src) || ~any(isfinite(src(:))), if exist('Rn','var') && ~isempty(Rn), src = Rn; end, end
if isempty(src) || ~any(isfinite(src(:))), if exist('R','var') && ~isempty(R), src = R; end, end
v = [];
if ~isempty(src), nfin = sum(isfinite(double(src)),1); [~,col] = max(nfin); if nfin(col) > 0, v = double(src(:,col)); v = v(isfinite(v)); end, end
if ~isempty(v) && max(v) > 3.6, v = v*(3.3/4095); end
if numel(v) > N, v = v(end-N+1:end); end
if isempty(v), set(grafica,'XData',nan,'YData',nan); set(textoMedidas,'String',sprintf('Maximo: --\nMinimo: --\nInstantaneo: --')); end
if ~isempty(v), set(grafica,'XData',(0:numel(v)-1)*Ts,'YData',v); set(textoMedidas,'String',sprintf('Maximo: %.3f V\nMinimo: %.3f V\nInstantaneo: %.3f V',max(v),min(v),v(end))); end
drawnow
