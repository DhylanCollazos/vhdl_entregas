library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Control del historial.
--
-- Este modulo ya NO contiene la memoria internamente.
-- La memoria RAM se encuentra en memoria_ram_historial.vhd.

entity historial_sesion is
    port (
        reloj, reinicio, guardar :
            in std_logic;

        consulta, siguiente, ir_ultimo :
            in std_logic;

        tiempo_entrada :
            in std_logic_vector(7 downto 0);

        color_entrada :
            in std_logic_vector(1 downto 0);

        tamano_entrada :
            in std_logic;

        identificador_salida :
            out std_logic_vector(9 downto 0);

        tiempo_salida :
            out std_logic_vector(7 downto 0);

        color_salida :
            out std_logic_vector(1 downto 0);

        tamano_salida,
        registro_valido,
        limite :
            out std_logic
    );
end entity historial_sesion;

architecture estructural of historial_sesion is

    ------------------------------------------------------------
    -- CONTADOR
    ------------------------------------------------------------

    component contador_ascendente is
        generic (
            ANCHO_BITS :
                positive := 4
        );

        port (
            reloj,
            reinicio,
            habilitar :
                in std_logic;

            CUENTA :
                out std_logic_vector(
                    ANCHO_BITS-1 downto 0
                )
        );
    end component;

    ------------------------------------------------------------
    -- RAM EXTERNA
    ------------------------------------------------------------

    component memoria_ram_historial is
        port (
            reloj :
                in std_logic;

            habilitar_escritura :
                in std_logic;

            direccion_escritura :
                in std_logic_vector(2 downto 0);

            direccion_lectura :
                in std_logic_vector(2 downto 0);

            dato_entrada :
                in std_logic_vector(20 downto 0);

            dato_salida :
                out std_logic_vector(20 downto 0)
        );
    end component;

    ------------------------------------------------------------
    -- VALIDEZ DE LAS OCHO POSICIONES
    ------------------------------------------------------------

    signal validos :
        std_logic_vector(7 downto 0) :=
        (others => '0');

    ------------------------------------------------------------
    -- DIRECCIONES
    ------------------------------------------------------------

    signal posicion_escritura :
        std_logic_vector(2 downto 0);

    signal posicion_lectura :
        unsigned(2 downto 0) :=
        (others => '0');

    signal ultima_posicion :
        unsigned(2 downto 0) :=
        (others => '0');

    ------------------------------------------------------------
    -- IDENTIFICADOR
    ------------------------------------------------------------

    signal cantidad_guardada :
        std_logic_vector(9 downto 0);

    signal nuevo_id :
        std_logic_vector(9 downto 0);

    ------------------------------------------------------------
    -- DATOS RAM
    ------------------------------------------------------------

    signal dato_entrada_ram :
        std_logic_vector(20 downto 0);

    signal dato_salida_ram :
        std_logic_vector(20 downto 0);

    signal ocupadas :
        integer range 0 to 8 := 0;

    signal escribir :
        std_logic;

    signal completa :
        std_logic;

    signal consulta_anterior :
        std_logic := '0';

begin

    ------------------------------------------------------------
    -- LIMITE DE SESION
    ------------------------------------------------------------

    completa <= '1'
        when unsigned(cantidad_guardada) >= 999
        else '0';

    escribir <=
        guardar and not completa and not reinicio;

    ------------------------------------------------------------
    -- NUEVO IDENTIFICADOR
    ------------------------------------------------------------

    nuevo_id <=
        std_logic_vector(
            unsigned(cantidad_guardada) + 1
        );

    ------------------------------------------------------------
    -- EMPAQUETAR LOS DATOS PARA LA RAM
    ------------------------------------------------------------

    dato_entrada_ram <=
        tiempo_entrada &
        nuevo_id &
        color_entrada &
        tamano_entrada;

    ------------------------------------------------------------
    -- CONTADOR DE IDENTIFICADORES
    ------------------------------------------------------------

    U_IDENTIFICADOR : contador_ascendente
        generic map (
            ANCHO_BITS => 10
        )
        port map (
            reloj     => reloj,
            reinicio  => reinicio,
            habilitar => escribir,
            CUENTA    => cantidad_guardada
        );

    ------------------------------------------------------------
    -- CONTADOR DE DIRECCION DE ESCRITURA
    ------------------------------------------------------------

    U_POSICION_ESCRITURA : contador_ascendente
        generic map (
            ANCHO_BITS => 3
        )
        port map (
            reloj     => reloj,
            reinicio  => reinicio,
            habilitar => escribir,
            CUENTA    => posicion_escritura
        );

    ------------------------------------------------------------
    -- INSTANCIA DE LA RAM
    ------------------------------------------------------------

    U_RAM : memoria_ram_historial
        port map (
            reloj =>
                reloj,

            habilitar_escritura =>
                escribir,

            direccion_escritura =>
                posicion_escritura,

            direccion_lectura =>
                std_logic_vector(
                    posicion_lectura
                ),

            dato_entrada =>
                dato_entrada_ram,

            dato_salida =>
                dato_salida_ram
        );

    ------------------------------------------------------------
    -- CONTROL DEL HISTORIAL
    ------------------------------------------------------------

    process(reloj, reinicio)
    begin

        if reinicio = '1' then

            validos <=
                (others => '0');

            posicion_lectura <=
                (others => '0');

            ultima_posicion <=
                (others => '0');

            ocupadas <= 0;

            consulta_anterior <= '0';

        elsif rising_edge(reloj) then

            consulta_anterior <= consulta;

            ----------------------------------------------------
            -- NUEVA ESCRITURA
            ----------------------------------------------------

            if escribir = '1' then

                validos(
                    to_integer(
                        unsigned(posicion_escritura)
                    )
                ) <= '1';

                ultima_posicion <=
                    unsigned(posicion_escritura);

                if ocupadas < 8 then

                    ocupadas <=
                        ocupadas + 1;

                end if;

            end if;

            ----------------------------------------------------
            -- CONSULTA
            ----------------------------------------------------

            if consulta = '1' then

                ------------------------------------------------
                -- ENTRAR AL HISTORIAL O VOLVER AL ULTIMO
                ------------------------------------------------

                if
                    consulta_anterior = '0'
                    or
                    ir_ultimo = '1'
                then

                    if escribir = '1' then

                        posicion_lectura <=
                            unsigned(posicion_escritura);

                    elsif ocupadas > 0 then

                        posicion_lectura <=
                            ultima_posicion;

                    end if;

                ------------------------------------------------
                -- SIGUIENTE REGISTRO
                ------------------------------------------------

                elsif
                    siguiente = '1'
                    and
                    ocupadas > 0
                then

                    if escribir = '1' then

                        posicion_lectura <=
                            unsigned(posicion_escritura);

                    elsif posicion_lectura =
                          ultima_posicion
                    then

                        if ocupadas = 8 then

                            posicion_lectura <=
                                unsigned(
                                    posicion_escritura
                                );

                        else

                            posicion_lectura <=
                                (others => '0');

                        end if;

                    else

                        posicion_lectura <=
                            posicion_lectura + 1;

                    end if;

                end if;

            end if;

        end if;

    end process;

    ------------------------------------------------------------
    -- DESEMPAQUETAR LA SALIDA DE LA RAM
    ------------------------------------------------------------

    tiempo_salida <=
        dato_salida_ram(20 downto 13);

    identificador_salida <=
        dato_salida_ram(12 downto 3);

    color_salida <=
        dato_salida_ram(2 downto 1);

    tamano_salida <=
        dato_salida_ram(0);

    ------------------------------------------------------------
    -- SALIDAS DE CONTROL
    ------------------------------------------------------------

    registro_valido <=
        validos(
            to_integer(
                posicion_lectura
            )
        );

    limite <= completa;

end architecture estructural;