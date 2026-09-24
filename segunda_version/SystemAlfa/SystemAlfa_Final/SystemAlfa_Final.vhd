library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SystemAlfa_Final is
    generic (
        FRECUENCIA_RELOJ_HZ : positive := 50000000;
        CICLOS_FILTRO       : positive := 500000;
        CICLOS_ATASCO       : positive := 250000000
    );
    port (
        RELOJ             : in std_logic;
        REINICIO_BAJO     : in std_logic;
        PRESENCIA         : in std_logic;
        CAMBIO_VELOCIDAD  : in std_logic;

        SELECTOR_COLOR  : in std_logic_vector(1 downto 0);
        SELECTOR_TAMANO : in std_logic;

        LINEA_MARCHA       : in std_logic;
        VER_HISTORIAL      : in std_logic;
        SIGUIENTE_HISTORIAL : in std_logic;

        LED_COLOR : out std_logic_vector(1 downto 0);
        LED_TAMANO : out std_logic;

        LINEA_ACTIVA : out std_logic;

        RUTA_PIEZA : out std_logic_vector(3 downto 0);

        ALARMA     : out std_logic;
        LED_LIMITE : out std_logic;

        VISOR_0 : out std_logic_vector(6 downto 0);
        VISOR_1 : out std_logic_vector(6 downto 0);
        VISOR_2 : out std_logic_vector(6 downto 0);
        VISOR_3 : out std_logic_vector(6 downto 0)
    );
end entity SystemAlfa_Final;

architecture estructural of SystemAlfa_Final is

    ------------------------------------------------------------
    -- COMPONENTES
    ------------------------------------------------------------

    component reinicio_seguro is
        port (
            reloj           : in std_logic;
            reinicio_bajo   : in std_logic;
            reinicio_salida : out std_logic
        );
    end component;

    component captura_pieza is
        generic (
            CICLOS_FILTRO : positive := 500000
        );
        port (
            reloj            : in std_logic;
            reinicio         : in std_logic;
            presencia_baja   : in std_logic;

            color_selector  : in std_logic_vector(1 downto 0);
            tamano_selector : in std_logic;

            nueva_pieza      : out std_logic;
            presencia_activa : out std_logic;

            color  : out std_logic_vector(1 downto 0);
            tamano : out std_logic
        );
    end component;

    component tabla_reglas is
        port (
            color  : in std_logic_vector(1 downto 0);
            tamano : in std_logic;

            ruta   : out std_logic_vector(3 downto 0);
            valida : out std_logic
        );
    end component;

    component selector_velocidad is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO       : positive := 500000
        );
        port (
            reloj      : in std_logic;
            reinicio   : in std_logic;
            boton_bajo : in std_logic;

            nivel_salida : out std_logic_vector(1 downto 0);
            pulso_linea  : out std_logic;
            segmentos    : out std_logic_vector(6 downto 0)
        );
    end component;

    component control_linea is
        port (
            reloj               : in std_logic;
            reinicio            : in std_logic;
            marcha              : in std_logic;
            bloqueo             : in std_logic;
            pulso_linea_entrada : in std_logic;

            pulso_motor : out std_logic;
            led_linea   : out std_logic;
            en_marcha   : out std_logic
        );
    end component;

    component supervisor_error is
        generic (
            CICLOS_ATASCO : positive := 250000000
        );
        port (
            reloj            : in std_logic;
            reinicio         : in std_logic;
            marcha           : in std_logic;
            presencia_activa : in std_logic;

            nueva_pieza  : in std_logic;
            pieza_valida : in std_logic;

            alarma : out std_logic
        );
    end component;

    component contador_ascendente is
        generic (
            ANCHO_BITS : positive := 4
        );
        port (
            reloj     : in std_logic;
            reinicio  : in std_logic;
            habilitar : in std_logic;

            CUENTA : out std_logic_vector(ANCHO_BITS-1 downto 0)
        );
    end component;

    component divisor_frecuencia is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000
        );
        port (
            reloj       : in std_logic;
            reinicio    : in std_logic;
            nivel       : in std_logic_vector(1 downto 0);
            pulso_linea : out std_logic
        );
    end component;

    component contador_segundos is
        port (
            reloj         : in std_logic;
            reinicio      : in std_logic;
            pulso_segundo : in std_logic;

            segundos : out std_logic_vector(7 downto 0)
        );
    end component;

    component historial is
        port (
            reloj     : in std_logic;
            reinicio  : in std_logic;
            escribir  : in std_logic;

            posicion_escritura :
                in std_logic_vector(2 downto 0);

            posicion_lectura :
                in std_logic_vector(2 downto 0);

            tiempo_entrada :
                in std_logic_vector(7 downto 0);

            identificador_entrada :
                in std_logic_vector(7 downto 0);

            color_entrada :
                in std_logic_vector(1 downto 0);

            tamano_entrada :
                in std_logic;

            tiempo_salida :
                out std_logic_vector(7 downto 0);

            identificador_salida :
                out std_logic_vector(7 downto 0);

            color_salida :
                out std_logic_vector(1 downto 0);

            tamano_salida :
                out std_logic;

            registro_valido :
                out std_logic
        );
    end component;

    component filtro_boton is
        generic (
            CICLOS_ESTABLES : positive := 500000
        );
        port (
            reloj         : in std_logic;
            reinicio      : in std_logic;
            boton_entrada : in std_logic;

            pulso_salida  : out std_logic;
            estado_salida : out std_logic
        );
    end component;

    component sincronizador is
        generic (
            ANCHO_BITS : positive := 1
        );
        port (
            reloj    : in std_logic;
            reinicio : in std_logic;

            entrada :
                in std_logic_vector(ANCHO_BITS-1 downto 0);

            salida :
                out std_logic_vector(ANCHO_BITS-1 downto 0)
        );
    end component;

    component decodificador_7segmentos is
        port (
            numero :
                in std_logic_vector(3 downto 0);

            segmentos :
                out std_logic_vector(6 downto 0)
        );
    end component;


	 component conversor_binario_decimal is
		 port (
            numero_binario :
               in std_logic_vector(9 downto 0);

            centenas :
               out std_logic_vector(3 downto 0);

            decenas :
               out std_logic_vector(3 downto 0);

            unidades :
               out std_logic_vector(3 downto 0)
		  );
	 end component;
	 
    ------------------------------------------------------------
    -- SENALES INTERNAS
    ------------------------------------------------------------

    signal reinicio_alto : std_logic;

    signal nueva_pieza :
        std_logic;

    signal presencia_activa :
        std_logic;

    signal color_actual :
        std_logic_vector(1 downto 0);

    signal tamano_actual :
        std_logic;

    signal ruta_actual :
        std_logic_vector(3 downto 0);

    signal pieza_valida :
        std_logic;


    ------------------------------------------------------------
    -- TRANSPORTE
    ------------------------------------------------------------

    signal pulso_linea :
        std_logic;

    signal marcha_real :
        std_logic;

    signal error :
        std_logic;

    signal bloqueo :
        std_logic;

    signal visor_velocidad :
        std_logic_vector(6 downto 0);


    ------------------------------------------------------------
    -- CONTEO DE PIEZAS VALIDAS
    ------------------------------------------------------------

    signal contar_pieza :
        std_logic;

	 signal total_piezas :
        std_logic_vector(9 downto 0);

    signal limite_total :
        std_logic;


    ------------------------------------------------------------
    -- HISTORIAL
    ------------------------------------------------------------

    signal guardar_historial :
        std_logic;

    signal identificador :
        std_logic_vector(7 downto 0);

    signal identificador_nuevo :
        std_logic_vector(7 downto 0);

    signal posicion_escritura :
        std_logic_vector(2 downto 0);

    signal posicion_lectura :
        std_logic_vector(2 downto 0);

    signal pulso_segundo :
        std_logic;

    signal segundos :
        std_logic_vector(7 downto 0);

    signal siguiente :
        std_logic;

    signal avanzar :
        std_logic;

    signal modo_entrada :
        std_logic_vector(0 downto 0);

    signal modo_historial :
        std_logic_vector(0 downto 0);


    ------------------------------------------------------------
    -- DATOS DEL HISTORIAL
    ------------------------------------------------------------

    signal tiempo_historial :
        std_logic_vector(7 downto 0);

    signal identificador_historial :
        std_logic_vector(7 downto 0);

    signal color_historial :
        std_logic_vector(1 downto 0);

    signal tamano_historial :
        std_logic;

    signal registro_valido :
        std_logic;


    ------------------------------------------------------------
    -- DATOS A MOSTRAR
    ------------------------------------------------------------

    signal color_vista :
        std_logic_vector(1 downto 0);

    signal tamano_vista :
        std_logic;

    signal ruta_vista :
        std_logic_vector(3 downto 0);

    signal regla_vista_valida :
        std_logic;

    signal identificador_vista :
        std_logic_vector(7 downto 0);

    signal tiempo_vista :
        std_logic_vector(7 downto 0);


    ------------------------------------------------------------
    -- DISPLAYS
    ------------------------------------------------------------

    signal total_bajo :
        std_logic_vector(6 downto 0);

    signal total_medio :
        std_logic_vector(6 downto 0);

    signal total_alto :
        std_logic_vector(6 downto 0);

	 signal digito_centenas :
		  std_logic_vector(3 downto 0);

    signal digito_decenas :
        std_logic_vector(3 downto 0);

    signal digito_unidades :
        std_logic_vector(3 downto 0);	  
		  
    signal id_bajo :
        std_logic_vector(6 downto 0);

    signal id_alto :
        std_logic_vector(6 downto 0);

    signal tiempo_bajo :
        std_logic_vector(6 downto 0);

    signal tiempo_alto :
        std_logic_vector(6 downto 0);

begin

    ------------------------------------------------------------
    -- RF1 / REINICIO
    ------------------------------------------------------------

    U_REINICIO : reinicio_seguro
        port map (
            reloj           => RELOJ,
            reinicio_bajo   => REINICIO_BAJO,
            reinicio_salida => reinicio_alto
        );


    ------------------------------------------------------------
    -- RF2 / CAPTURA
    ------------------------------------------------------------

    U_CAPTURA : captura_pieza
        generic map (
            CICLOS_FILTRO => CICLOS_FILTRO
        )
        port map (
            reloj            => RELOJ,
            reinicio         => reinicio_alto,
            presencia_baja   => PRESENCIA,

            color_selector  => SELECTOR_COLOR,
            tamano_selector => SELECTOR_TAMANO,

            nueva_pieza      => nueva_pieza,
            presencia_activa => presencia_activa,

            color  => color_actual,
            tamano => tamano_actual
        );


    ------------------------------------------------------------
    -- RF3 / CLASIFICACION
    ------------------------------------------------------------

    U_REGLAS : tabla_reglas
        port map (
            color  => color_actual,
            tamano => tamano_actual,

            ruta   => ruta_actual,
            valida => pieza_valida
        );


    ------------------------------------------------------------
    -- RF1 / VELOCIDAD
    ------------------------------------------------------------

    U_VELOCIDAD : selector_velocidad
        generic map (
            FRECUENCIA_RELOJ_HZ => FRECUENCIA_RELOJ_HZ,
            CICLOS_FILTRO       => CICLOS_FILTRO
        )
        port map (
            reloj      => RELOJ,
            reinicio   => reinicio_alto,
            boton_bajo => CAMBIO_VELOCIDAD,

            nivel_salida => open,
            pulso_linea  => pulso_linea,
            segmentos    => visor_velocidad
        );


    ------------------------------------------------------------
    -- ERRORES
    ------------------------------------------------------------

    U_ERRORES : supervisor_error
        generic map (
            CICLOS_ATASCO => CICLOS_ATASCO
        )
        port map (
            reloj            => RELOJ,
            reinicio         => reinicio_alto,
            marcha           => marcha_real,
            presencia_activa => presencia_activa,

            nueva_pieza  => nueva_pieza,
            pieza_valida => pieza_valida,

            alarma => error
        );


    ------------------------------------------------------------
    -- LIMITE DEL CONTADOR
    ------------------------------------------------------------

    limite_total <= '1'
		when unsigned(total_piezas) = 999
		else '0';

    bloqueo <= error or limite_total;


    ------------------------------------------------------------
    -- RF1 / CONTROL DE LINEA
    ------------------------------------------------------------

    U_LINEA : control_linea
        port map (
            reloj               => RELOJ,
            reinicio            => reinicio_alto,
            marcha              => LINEA_MARCHA,
            bloqueo             => bloqueo,
            pulso_linea_entrada => pulso_linea,

            pulso_motor => open,
            led_linea   => LINEA_ACTIVA,
            en_marcha   => marcha_real
        );


    ------------------------------------------------------------
    -- RF5 / CONTEO
    ------------------------------------------------------------

    contar_pieza <=
        nueva_pieza and
        pieza_valida and
        marcha_real and
        not limite_total;

    U_TOTAL : contador_ascendente
        generic map (
            ANCHO_BITS => 10
        )
        port map (
            reloj     => RELOJ,
            reinicio  => reinicio_alto,
            habilitar => contar_pieza,
            CUENTA    => total_piezas
        );


    ------------------------------------------------------------
    -- RF4 / IDENTIFICADOR DE EVENTOS
    ------------------------------------------------------------

    guardar_historial <=
        nueva_pieza
        when identificador /= x"FF"
        else '0';

    identificador_nuevo <=
        std_logic_vector(unsigned(identificador) + 1);

    U_IDENTIFICADOR : contador_ascendente
        generic map (
            ANCHO_BITS => 8
        )
        port map (
            reloj     => RELOJ,
            reinicio  => reinicio_alto,
            habilitar => guardar_historial,
            CUENTA    => identificador
        );


    ------------------------------------------------------------
    -- POSICION DE ESCRITURA
    ------------------------------------------------------------

    U_POSICION_ESCRITURA : contador_ascendente
        generic map (
            ANCHO_BITS => 3
        )
        port map (
            reloj     => RELOJ,
            reinicio  => reinicio_alto,
            habilitar => guardar_historial,
            CUENTA    => posicion_escritura
        );


    ------------------------------------------------------------
    -- RELOJ DE UN SEGUNDO
    ------------------------------------------------------------

    U_SEGUNDO : divisor_frecuencia
        generic map (
            FRECUENCIA_RELOJ_HZ => FRECUENCIA_RELOJ_HZ
        )
        port map (
            reloj       => RELOJ,
            reinicio    => reinicio_alto,
            nivel       => "01",
            pulso_linea => pulso_segundo
        );


    U_CONTADOR_TIEMPO : contador_segundos
        port map (
            reloj         => RELOJ,
            reinicio      => reinicio_alto,
            pulso_segundo => pulso_segundo,
            segundos      => segundos
        );


    ------------------------------------------------------------
    -- MODO HISTORIAL
    ------------------------------------------------------------

    modo_entrada(0) <= VER_HISTORIAL;

    U_MODO : sincronizador
        generic map (
            ANCHO_BITS => 1
        )
        port map (
            reloj    => RELOJ,
            reinicio => reinicio_alto,
            entrada  => modo_entrada,
            salida   => modo_historial
        );


    ------------------------------------------------------------
    -- BOTON SIGUIENTE
    ------------------------------------------------------------

    U_SIGUIENTE : filtro_boton
        generic map (
            CICLOS_ESTABLES => CICLOS_FILTRO
        )
        port map (
            reloj         => RELOJ,
            reinicio      => reinicio_alto,
            boton_entrada => SIGUIENTE_HISTORIAL,

            pulso_salida  => siguiente,
            estado_salida => open
        );

    avanzar <=
        siguiente and modo_historial(0);


    ------------------------------------------------------------
    -- POSICION DE LECTURA
    ------------------------------------------------------------

    U_POSICION_LECTURA : contador_ascendente
        generic map (
            ANCHO_BITS => 3
        )
        port map (
            reloj     => RELOJ,
            reinicio  => reinicio_alto,
            habilitar => avanzar,
            CUENTA    => posicion_lectura
        );


    ------------------------------------------------------------
    -- MEMORIA
    ------------------------------------------------------------

    U_HISTORIAL : historial
        port map (
            reloj     => RELOJ,
            reinicio  => reinicio_alto,
            escribir  => guardar_historial,

            posicion_escritura => posicion_escritura,
            posicion_lectura   => posicion_lectura,

            tiempo_entrada =>
                segundos,

            identificador_entrada =>
                identificador_nuevo,

            color_entrada =>
                color_actual,

            tamano_entrada =>
                tamano_actual,

            tiempo_salida =>
                tiempo_historial,

            identificador_salida =>
                identificador_historial,

            color_salida =>
                color_historial,

            tamano_salida =>
                tamano_historial,

            registro_valido =>
                registro_valido
        );


    ------------------------------------------------------------
    -- DATOS VISIBLES
    ------------------------------------------------------------

    color_vista <=
        color_historial
        when modo_historial(0) = '1'
        and registro_valido = '1'
        else color_actual;

    tamano_vista <=
        tamano_historial
        when modo_historial(0) = '1'
        and registro_valido = '1'
        else tamano_actual;

    identificador_vista <=
        identificador_historial
        when modo_historial(0) = '1'
        and registro_valido = '1'
        else identificador;

    tiempo_vista <=
        tiempo_historial
        when modo_historial(0) = '1'
        and registro_valido = '1'
        else segundos;


    ------------------------------------------------------------
    -- REGLA DE LA PIEZA VISIBLE
    ------------------------------------------------------------

    U_REGLA_VISTA : tabla_reglas
        port map (
            color  => color_vista,
            tamano => tamano_vista,

            ruta   => ruta_vista,
            valida => regla_vista_valida
        );

	 ------------------------------------------------------------
    -- CONVERSION DEL TOTAL A DECIMAL
    ------------------------------------------------------------

    U_CONVERSOR_DECIMAL : conversor_binario_decimal
        port map (
            numero_binario => total_piezas,

            centenas => digito_centenas,
            decenas  => digito_decenas,
            unidades => digito_unidades
        );

		  
	------------------------------------------------------------
   -- DISPLAY DE UNIDADES
   ------------------------------------------------------------

    U_TOTAL_UNIDADES : decodificador_7segmentos
        port map (
            numero    => digito_unidades,
            segmentos => total_bajo
        );


   ------------------------------------------------------------
   -- DISPLAY DE DECENAS
   ------------------------------------------------------------

    U_TOTAL_DECENAS : decodificador_7segmentos
        port map (
            numero    => digito_decenas,
            segmentos => total_medio
        );


   ------------------------------------------------------------
   -- DISPLAY DE CENTENAS
   ------------------------------------------------------------

    U_TOTAL_CENTENAS : decodificador_7segmentos
        port map (
            numero    => digito_centenas,
            segmentos => total_alto
        );
		  
	 -------------------------------------------
    -- DECODIFICADORES DEL HISTORIAL
    ------------------------------------------

    U_ID_BAJO : decodificador_7segmentos
        port map (
            numero    => identificador_vista(3 downto 0),
            segmentos => id_bajo
        );

    U_ID_ALTO : decodificador_7segmentos
        port map (
            numero    => identificador_vista(7 downto 4),
            segmentos => id_alto
        );

    U_TIEMPO_BAJO : decodificador_7segmentos
        port map (
            numero    => tiempo_vista(3 downto 0),
            segmentos => tiempo_bajo
        );

    U_TIEMPO_ALTO : decodificador_7segmentos
        port map (
            numero    => tiempo_vista(7 downto 4),
            segmentos => tiempo_alto
        );


    ------------------------------------------------------------
    -- SALIDAS
    ------------------------------------------------------------

    LED_COLOR <= color_vista;
    LED_TAMANO <= tamano_vista;

    RUTA_PIEZA <= ruta_vista;

    ALARMA <= error;
    LED_LIMITE <= limite_total;


    ------------------------------------------------------------
    -- VISUALIZACION
    --
    -- MODO NORMAL:
    -- HEX0 = total bajo
    -- HEX1 = velocidad
    -- HEX2 = total medio
    -- HEX3 = total alto
    --
    -- MODO HISTORIAL:
    -- HEX0 = identificador bajo
    -- HEX1 = identificador alto
    -- HEX2 = tiempo bajo
    -- HEX3 = tiempo alto
    ------------------------------------------------------------

    VISOR_0 <=
        id_bajo
        when modo_historial(0) = '1'
        else total_bajo;

    VISOR_1 <=
        id_alto
        when modo_historial(0) = '1'
        else visor_velocidad;

    VISOR_2 <=
        tiempo_bajo
        when modo_historial(0) = '1'
        else total_medio;

    VISOR_3 <=
        tiempo_alto
        when modo_historial(0) = '1'
        else total_alto;

end architecture estructural;