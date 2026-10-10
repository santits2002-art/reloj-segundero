classdef Deposito < handle
    % Deposito con salida por gravedad y retardo en el caudal de entrada.
    % Modelo linealizado alrededor de h0.
    % Resolucion de la ED mediante aproximacion de Euler.
    % Construccion: Deposito() o Deposito('Nombre', valor, ...).
    %   Nombres de los parametros (entre comillas simples -array de caracteres- o dobles -string-):
    %       AreaDeposito
    %       AreaSalida
    %       CoefDescarga
    %       NivelNominal
    %       Retardo
    %       Ts
    %       AlturaInicial
    %   En el caso de que no se especifiquen valores, se inicializaran con valores por defecto.
    %   Ejemplo: mi_deposito = Deposito('AreaDeposito', 7, 'CoefDescarga', 0.3);
    %
    % Metodos de consulta anadidos para poder simular desde fuera de la clase:
    %   obtenerPaso          -> Ts [s]
    %   obtenerNivelNominal  -> h0 [m]
    % Ts y h0 siguen siendo privados; estos metodos solo los leen.

    properties (Access = private)
        AreaDeposito         % Seccion horizontal del deposito [m^2]
        AreaSalida           % Area del orificio de salida [m^2]
        CoefDescarga         % Coeficiente de descarga: 0 < Cd <= 1
        NivelNominal         % Nivel h0 de linealizacion [m]
        CaudalNominal        % Caudal q0 que mantiene el nivel h0 [m^3/s]
        CaudalSalida         % Caudal de salida al nivel actual [m^3/s]
        Resistencia          % Resistencia incremental de la salida [s/m^2]
        Tau                  % Constante de tiempo A*R [s]
        Retardo              % Retardo representado en la simulacion [s]
        Ts                   % Paso de integracion [s]
        Nivel                % Nivel actual [m]
        NumeroPasosRetardo   % Numero N de pasos Ts, que hay en el retardo L.
        CaudalesAnteriores   % Caudales de la bomba en los N pasos anteriores [m^3/s]
    end

    methods
        function obj = Deposito(varargin)
            % Se crea el deposito con valores predeterminados.
            A = pi*(1/2)^2;     % Area de un deposito de diametro = 1 m
            a = pi*(0.1/2)^2;   % Area de un orificio de salida de diametro = 10 cm
            Cd = 0.6;           % Coeficiente de descarga
            h0 = 0.5;           % Nivel nominal
            L = 2;              % Retardo de transporte
            Ts = 0.1;           % Paso de integracion
            hInicial = [];      % Sin especificar. Se tomara el nivel nominal

            % Se verifica que, a cada nombre le siga un valor.
            % Si todo es correcto, se inicializan las variables
            if mod(nargin, 2) ~= 0 % Primero: numero de parametros impar
                error('Los parametros deben indicarse en parejas nombre-valor.');
            end
            for i = 1:2:nargin % Segundo: se recorren las parejas. Tiene que haber un nombre en i y un valor en i+1.
                nombre = varargin{i};
                valor = varargin{i+1};

                if  ~((ischar(nombre) && isrow(nombre)) || (isstring(nombre) && isscalar(nombre)))
                    error('El nombre de cada parametro debe ser un texto.');
                end
                nombre = char(nombre);
                if ~isnumeric(valor) || ~isscalar(valor) || ~isreal(valor) || ~isfinite(valor)
                    error('El valor de %s debe ser un escalar, real y finito.', nombre);
                end

                % Sustituir el valor predeterminado del parametro indicado.
                switch lower(nombre)
                    case 'areadeposito'
                        A = valor;
                    case 'areasalida'
                        a = valor;
                    case 'coefdescarga'
                        Cd = valor;
                    case 'nivelnominal'
                        h0 = valor;
                    case 'retardo'
                        L = valor;
                    case 'ts'
                        Ts = valor;
                    case 'alturainicial'
                        hInicial = valor;
                    otherwise
                        error('Parametro desconocido: %s.', nombre);
                end
            end

            % Si no se indica AlturaInicial, se comienza en el nivel nominal elegido.
            if isempty(hInicial)
                hInicial = h0;
            end

            % Verificar que los parametros tienen valores admisibles.
            if A <= 0 || a <= 0 || Cd <= 0 || Cd > 1 || h0 <= 0 || Ts <= 0 || L < 0 || hInicial < 0
                error('Los parametros del deposito no son validos.');
            end

            obj.AreaDeposito = A;
            obj.AreaSalida = a;
            obj.CoefDescarga = Cd;
            obj.NivelNominal = h0;
            obj.Ts = Ts;

            % Aproximar L mediante el numero entero de pasos mas cercano.
            obj.NumeroPasosRetardo = round(L / Ts);
            obj.Retardo = obj.NumeroPasosRetardo * Ts;

            % Caudal de equilibrio y parametros del modelo linealizado.
            g = 9.81; % Gravedad [m/s^2]
            coefSalida = obj.CoefDescarga * obj.AreaSalida * sqrt(2*g); % qSalida = coefSalida*sqrt(h)
            obj.CaudalNominal = coefSalida * sqrt(obj.NivelNominal);    % q0 = cs*sqrt(h0)
            obj.Resistencia = 2 * sqrt(obj.NivelNominal) / coefSalida;  % R = [2*sqrt(h0)]/cs
            obj.Tau = obj.AreaDeposito * obj.Resistencia;               % tau = A*R

            if Ts >= 2 * obj.Tau % Se comprueba la estabilidad numerica de Euler.
                error('El paso de integracion Ts debe ser menor que 2*Tau.');
            elseif Ts > obj.Tau/10  % Se recomienda un paso menor para mejorar la precision.
                warning('Se recomienda utilizar Ts <= Tau/10.');
            end

            obj.reiniciar(hInicial); % Inicializacion del estado en t = 0
        end

        function h = obtenerNivel(obj)
            % Devuelve el nivel actual del deposito [m].
            h = obj.Nivel;
        end

        function q0 = obtenerCaudalNominal(obj)
            % Devuelve el caudal que mantiene el nivel nominal [m^3/s].
            q0 = obj.CaudalNominal;
        end

        function q = obtenerCaudalSalida(obj)
            % Devuelve el caudal de salida del modelo [m^3/s].
            q = obj.CaudalSalida;
        end

        function L = obtenerRetardo(obj)
            % Devuelve el retardo simulado [s], redondeado a un numero de pasos Ts.
            L = obj.Retardo;
        end

        function Tau = obtenerConstanteTiempo(obj)
            % Devuelve la constante de tiempo del sistema [s].
            Tau = obj.Tau;
        end

        function K = obtenerGanancia(obj)
            % Devuelve la ganancia estatica del modelo linealizado [s/m^2].
            K = obj.Resistencia;
        end

        function Ts = obtenerPaso(obj)
            % Devuelve el paso de integracion [s].
            Ts = obj.Ts;
        end

        function h0 = obtenerNivelNominal(obj)
            % Devuelve el nivel nominal de linealizacion [m].
            h0 = obj.NivelNominal;
        end

        function [h, qEntrada] = actualizar(obj, qBomba)
            % Avanzar un paso Ts, manteniendo constante el caudal de la bomba.
            % qBomba: caudal suministrado por la bomba en este paso [m^3/s].
            % qEntrada: caudal que llega al deposito tras el retardo [m^3/s].
            % h: nivel al terminar el paso [m].
            if nargin < 2
                error('Debe indicarse el caudal de la bomba.');
            end
            if ~isnumeric(qBomba) || ~isscalar(qBomba) || ~isreal(qBomba) || ~isfinite(qBomba) || qBomba < 0
                error('El caudal debe ser un numero real, finito y no negativo.');
            end

            if obj.NumeroPasosRetardo == 0
                qEntrada = qBomba;
            else
                % Recuperar el caudal de la bomba de N pasos antes.
                qEntrada = obj.CaudalesAnteriores(1);
                % Descartar el dato usado y anadir el caudal actual.
                obj.CaudalesAnteriores = [obj.CaudalesAnteriores(2:end), qBomba];
            end

            % Balance de caudales: dh/dt = (qEntrada - qSalida)/A.
            derivadaNivel = (qEntrada - obj.CaudalSalida)/obj.AreaDeposito;
            % Actualizacion del nivel mediante Euler hacia delante.
            obj.Nivel = obj.Nivel + obj.Ts * derivadaNivel;

            % Calcular la salida correspondiente al nuevo nivel.
            obj.CaudalSalida = obj.CaudalNominal + (obj.Nivel - obj.NivelNominal)/obj.Resistencia;
            h = obj.Nivel;
        end

        function reiniciar(obj, hInicial)
            % Se reinicia el nivel [m] y el historial. Sin argumento, se usa h0.
            if nargin < 2
                hInicial = obj.NivelNominal;
            end
            if ~isnumeric(hInicial) || ~isscalar(hInicial) || ~isreal(hInicial) || ~isfinite(hInicial) || hInicial < 0
                error('El nivel debe ser un numero real, finito y no negativo.');
            end

            obj.Nivel = hInicial;
            % Caudal de salida al nivel inicial; es q0 si hInicial = h0.
            obj.CaudalSalida = obj.CaudalNominal + (obj.Nivel - obj.NivelNominal)/obj.Resistencia;
            % Suponer que la bomba suministraba q0 antes de iniciar la simulacion.
            obj.CaudalesAnteriores = obj.CaudalNominal * ones(1, obj.NumeroPasosRetardo);
        end
    end
end
