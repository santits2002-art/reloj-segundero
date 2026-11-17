% Cada linea es una orden completa: picgui evalua el cuadro linea a linea.
% SubBuffer Rn = 500. Se dibujan los primeros 500 datos del buffer.
if ~(exist('grafica','var') && ishandle(grafica) && exist('textoMedidas','var') && ishandle(textoMedidas)), figure('Name','Osciloscopio virtual - dsPIC','NumberTitle','off','Color','w'); grafica = plot(nan,nan,'b','LineWidth',1.25); grid on; xlabel('t (s)'); ylabel('V (V)'); title('Tension de entrada - ADC AN0'); xlim([0 0.5]); ylim([0 3.3]); textoMedidas = text('Units','normalized','Position',[0.98 0.96 0],'HorizontalAlignment','right','VerticalAlignment','top','BackgroundColor','w','EdgeColor',[0.45 0.45 0.45],'Margin',5,'String',sprintf('Maximo: --\nMinimo: --\nInstantaneo: --')); end
Ts = 1e-3; N = 500;
M = []; nBest = 0;
try, cand = Rn; nFin = sum(isfinite(cand(:))); if nFin > nBest, M = cand; nBest = nFin; end, end
try, cand = evalin('base','Rn'); nFin = sum(isfinite(cand(:))); if nFin > nBest, M = cand; nBest = nFin; end, end
try, cand = R; nFin = sum(isfinite(cand(:))); if nFin > nBest, M = cand; nBest = nFin; end, end
try, cand = evalin('base','R'); nFin = sum(isfinite(cand(:))); if nFin > nBest, M = cand; nBest = nFin; end, end
v = [];
if ~isempty(M), nPorCol = sum(isfinite(M),1); [nColMax, iCol] = max(nPorCol); if nColMax > 0, v = M(:,iCol); v = v(isfinite(v)); end, end
if ~isempty(v) && max(v) > 3.6, v = v*(3.3/4095); end
if numel(v) > N, v = v(1:N); end
if isempty(v), set(grafica,'XData',nan,'YData',nan); set(textoMedidas,'String',sprintf('Maximo: --\nMinimo: --\nInstantaneo: --')); end
if ~isempty(v), t = (0:numel(v)-1)*Ts; set(grafica,'XData',t,'YData',v); set(textoMedidas,'String',sprintf('Maximo: %.3f V\nMinimo: %.3f V\nInstantaneo: %.3f V',max(v),min(v),v(end))); end
drawnow
