library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RF4_Historial is
    generic (
        FRECUENCIA_RELOJ_HZ : positive := 50000000;
        CICLOS_FILTRO : positive := 500000
    );
    port (
        RELOJ, REINICIO_BAJO, PRESENCIA : in std_logic;
        SELECTOR_COLOR : in std_logic_vector(1 downto 0);

        SELECTOR_TAMANO, VER_HISTORIAL, SIGUIENTE_HISTORIAL :
            in std_logic;

        VISOR_TOTAL, VISOR_TOTAL_ALTO :
            out std_logic_vector(6 downto 0);

        TIEMPO_HISTORIAL_ALTO, TIEMPO_HISTORIAL_BAJO :
            out std_logic_vector(6 downto 0);

        LED_COLOR : out std_logic_vector(1 downto 0);

        LED_TAMANO, LED_REGISTRO_VALIDO,
        LED_REGLA_VALIDA, LED_LIMITE :
            out std_logic;

        RUTA_REGLA : out std_logic_vector(3 downto 0)
    );
end entity RF4_Historial;

architecture estructural of RF4_Historial is

    component reinicio_seguro is
        port (
            reloj, reinicio_bajo : in std_logic;
            reinicio_salida : out std_logic
        );
    end component;

    component captura_pieza is
        generic (
            CICLOS_FILTRO : positive := 500000
        );
        port (
            reloj, reinicio, presencia_baja : in std_logic;
            color_selector : in std_logic_vector(1 downto 0);
            tamano_selector : in std_logic;

            nueva_pieza, presencia_activa : out std_logic;
            color : out std_logic_vector(1 downto 0);
            tamano : out std_logic
        );
    end component;

    component contador_ascendente is
        generic (
            ANCHO_BITS : positive := 4
        );
        port (
            reloj, reinicio, habilitar : in std_logic;
            CUENTA : out std_logic_vector(ANCHO_BITS-1 downto 0)
        );
    end component;

    component divisor_frecuencia is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000
        );
        port (
            reloj, reinicio : in std_logic;
            nivel : in std_logic_vector(1 downto 0);
            pulso_linea : out std_logic
        );
    end component;

    component contador_segundos is
        port (
            reloj, reinicio, pulso_segundo : in std_logic;
            segundos : out std_logic_vector(7 downto 0)
        );
    end component;

    component sincronizador is
        generic (
            ANCHO_BITS : positive := 1
        );
        port (
            reloj, reinicio : in std_logic;
            entrada : in std_logic_vector(ANCHO_BITS-1 downto 0);
            salida : out std_logic_vector(ANCHO_BITS-1 downto 0)
        );
    end component;

    component filtro_boton is
        generic (
            CICLOS_ESTABLES : positive := 500000
        );
        port (
            reloj, reinicio, boton_entrada : in std_logic;
            pulso_salida, estado_salida : out std_logic
        );
    end component;

    component historial is
        port (
            reloj, reinicio, escribir : in std_logic;

            posicion_escritura, posicion_lectura :
                in std_logic_vector(2 downto 0);

            tiempo_entrada, identificador_entrada :
                in std_logic_vector(7 downto 0);

            color_entrada : in std_logic_vector(1 downto 0);
            tamano_entrada : in std_logic;

            tiempo_salida, identificador_salida :
                out std_logic_vector(7 downto 0);

            color_salida : out std_logic_vector(1 downto 0);
            tamano_salida, registro_valido : out std_logic
        );
    end component;

    component tabla_reglas is
        port (
            color : in std_logic_vector(1 downto 0);
            tamano : in std_logic;
            ruta : out std_logic_vector(3 downto 0);
            valida : out std_logic
        );
    end component;

    component decodificador_7segmentos is
        port (
            numero : in std_logic_vector(3 downto 0);
            segmentos : out std_logic_vector(6 downto 0)
        );
    end component;

    component registro_color is
        port (
            reloj, reinicio, HABILITAR : in std_logic;
            color_entrada : in std_logic_vector(1 downto 0);
            color_salida : out std_logic_vector(1 downto 0)
        );
    end component;

    component registro_tamano is
        port (
            reloj, reinicio, HABILITAR, tamano_entrada :
                in std_logic;
            tamano_salida : out std_logic
        );
    end component;

    signal reinicio_alto, nueva, guardar, limite :
        std_logic;

    signal color, color_historial, color_vista, color_guardado :
        std_logic_vector(1 downto 0);

    signal tamano, tamano_historial, tamano_vista, tamano_guardado :
        std_logic;

    signal total, identificador_nuevo,
           identificador_historial, identificador_vista :
        std_logic_vector(7 downto 0);

    signal segundos, tiempo_historial, tiempo_vista :
        std_logic_vector(7 downto 0);

    signal pulso_segundo, siguiente, avanzar,
           registro_historial_valido, hay_datos :
        std_logic;

    signal posicion_escritura, posicion_lectura :
        std_logic_vector(2 downto 0);

    signal modo_entrada, modo :
        std_logic_vector(0 downto 0);

    signal vista_valida, regla_valida : std_logic;
    signal ruta : std_logic_vector(3 downto 0);

    signal segmentos_identificador_bajo, segmentos_identificador_alto,
           segmentos_tiempo_bajo, segmentos_tiempo_alto :
        std_logic_vector(6 downto 0);

begin

    U_REINICIO : reinicio_seguro
        port map (
            reloj           => RELOJ,
            reinicio_bajo   => REINICIO_BAJO,
            reinicio_salida => reinicio_alto
        );

    U_CAPTURA : captura_pieza
        generic map (
            CICLOS_FILTRO => CICLOS_FILTRO
        )
        port map (
            reloj            => RELOJ,
            reinicio         => reinicio_alto,
            presencia_baja   => PRESENCIA,
            color_selector   => SELECTOR_COLOR,
            tamano_selector  => SELECTOR_TAMANO,
            nueva_pieza      => nueva,
            presencia_activa => open,
            color            => color,
            tamano           => tamano
        );

    -- Se permiten hasta 255 eventos por lote.
    limite <= '1' when total = x"FF" else '0';
    guardar <= nueva and not limite;

    identificador_nuevo <= std_logic_vector(unsigned(total) + 1);

    U_IDENTIFICADOR : contador_ascendente
        generic map (
            ANCHO_BITS => 8
        )
        port map (
            reloj     => RELOJ,
            reinicio  => reinicio_alto,
            habilitar => guardar,
            CUENTA    => total
        );

    U_ESCRITURA : contador_ascendente
        generic map (
            ANCHO_BITS => 3
        )
        port map (
            reloj     => RELOJ,
            reinicio  => reinicio_alto,
            habilitar => guardar,
            CUENTA    => posicion_escritura
        );

    U_PULSO_SEGUNDO : divisor_frecuencia
        generic map (
            FRECUENCIA_RELOJ_HZ => FRECUENCIA_RELOJ_HZ
        )
        port map (
            reloj       => RELOJ,
            reinicio    => reinicio_alto,
            nivel       => "01",
            pulso_linea => pulso_segundo
        );

    U_TIEMPO : contador_segundos
        port map (
            reloj         => RELOJ,
            reinicio      => reinicio_alto,
            pulso_segundo => pulso_segundo,
            segundos      => segundos
        );

    modo_entrada(0) <= VER_HISTORIAL;

    U_MODO : sincronizador
        generic map (
            ANCHO_BITS => 1
        )
        port map (
            reloj    => RELOJ,
            reinicio => reinicio_alto,
            entrada  => modo_entrada,
            salida   => modo
        );

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

    avanzar <= siguiente and modo(0);

    U_LECTURA : contador_ascendente
        generic map (
            ANCHO_BITS => 3
        )
        port map (
            reloj     => RELOJ,
            reinicio  => reinicio_alto,
            habilitar => avanzar,
            CUENTA    => posicion_lectura
        );

    U_MEMORIA : historial
        port map (
            reloj                 => RELOJ,
            reinicio              => reinicio_alto,
            escribir              => guardar,
            posicion_escritura    => posicion_escritura,
            posicion_lectura      => posicion_lectura,
            tiempo_entrada        => segundos,
            identificador_entrada => identificador_nuevo,
            color_entrada         => color,
            tamano_entrada        => tamano,
            tiempo_salida         => tiempo_historial,
            identificador_salida  => identificador_historial,
            color_salida          => color_historial,
            tamano_salida         => tamano_historial,
            registro_valido       => registro_historial_valido
        );

    U_COLOR_GUARDADO : registro_color
        port map (
            reloj         => RELOJ,
            reinicio      => reinicio_alto,
            HABILITAR     => guardar,
            color_entrada => color,
            color_salida  => color_guardado
        );

    U_TAMANO_GUARDADO : registro_tamano
        port map (
            reloj          => RELOJ,
            reinicio       => reinicio_alto,
            HABILITAR      => guardar,
            tamano_entrada => tamano,
            tamano_salida  => tamano_guardado
        );

    hay_datos <= '0' when total = x"00" else '1';

    vista_valida <= registro_historial_valido
        when modo(0) = '1' else hay_datos;

    identificador_vista <= identificador_historial
        when modo(0) = '1' else total;

    color_vista <= color_historial
        when modo(0) = '1' else color_guardado;

    tamano_vista <= tamano_historial
        when modo(0) = '1' else tamano_guardado;

    tiempo_vista <= tiempo_historial
        when modo(0) = '1' else segundos;

    U_REGLAS : tabla_reglas
        port map (
            color  => color_vista,
            tamano => tamano_vista,
            ruta   => ruta,
            valida => regla_valida
        );

    U_IDENTIFICADOR_BAJO : decodificador_7segmentos
        port map (
            numero    => identificador_vista(3 downto 0),
            segmentos => segmentos_identificador_bajo
        );

    U_IDENTIFICADOR_ALTO : decodificador_7segmentos
        port map (
            numero    => identificador_vista(7 downto 4),
            segmentos => segmentos_identificador_alto
        );

    U_TIEMPO_BAJO : decodificador_7segmentos
        port map (
            numero    => tiempo_vista(3 downto 0),
            segmentos => segmentos_tiempo_bajo
        );

    U_TIEMPO_ALTO : decodificador_7segmentos
        port map (
            numero    => tiempo_vista(7 downto 4),
            segmentos => segmentos_tiempo_alto
        );

    -- Las posiciones vacias se muestran con los visores apagados.
    VISOR_TOTAL <= "1111111"
        when modo(0) = '1' and registro_historial_valido = '0'
        else segmentos_identificador_bajo;

    VISOR_TOTAL_ALTO <= "1111111"
        when modo(0) = '1' and registro_historial_valido = '0'
        else segmentos_identificador_alto;

    TIEMPO_HISTORIAL_BAJO <= "1111111"
        when modo(0) = '1' and registro_historial_valido = '0'
        else segmentos_tiempo_bajo;

    TIEMPO_HISTORIAL_ALTO <= "1111111"
        when modo(0) = '1' and registro_historial_valido = '0'
        else segmentos_tiempo_alto;

    LED_COLOR <= color_vista
        when vista_valida = '1' else "00";

    LED_TAMANO <= tamano_vista and vista_valida;
    LED_REGISTRO_VALIDO <= vista_valida;
    LED_REGLA_VALIDA <= regla_valida and vista_valida;

    RUTA_REGLA <= ruta
        when vista_valida = '1' else "0000";

    LED_LIMITE <= limite;

end architecture estructural;