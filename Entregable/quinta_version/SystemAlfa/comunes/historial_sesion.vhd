library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity historial_sesion is
    port (
        reloj, reinicio, guardar : in std_logic;
        consulta, siguiente, ir_ultimo : in std_logic;

        tiempo_entrada : in std_logic_vector(7 downto 0);
        color_entrada : in std_logic_vector(1 downto 0);
        tamano_entrada : in std_logic;

        identificador_salida : out std_logic_vector(9 downto 0);
        tiempo_salida : out std_logic_vector(7 downto 0);
        color_salida : out std_logic_vector(1 downto 0);

        tamano_salida, registro_valido, limite : out std_logic
    );
end entity historial_sesion;

architecture estructural of historial_sesion is

    component contador_ascendente is
        generic (
            ANCHO_BITS : positive := 4
        );
        port (
            reloj, reinicio, habilitar : in std_logic;
            CUENTA : out std_logic_vector(ANCHO_BITS-1 downto 0)
        );
    end component;

    -- Cada registro tiene 21 bits.
    type tipo_memoria is array (0 to 7)
        of std_logic_vector(20 downto 0);

    signal memoria : tipo_memoria;
    signal validos : std_logic_vector(7 downto 0);

    signal posicion_escritura : std_logic_vector(2 downto 0);
    signal posicion_lectura, ultima_posicion : unsigned(2 downto 0);

    signal cantidad_guardada, nuevo_id :
        std_logic_vector(9 downto 0);

    signal dato : std_logic_vector(20 downto 0);

    signal ocupadas : integer range 0 to 8 := 0;

    signal escribir, completa, consulta_anterior : std_logic;

begin

    completa <= '1'
        when unsigned(cantidad_guardada) >= 999
        else '0';

    escribir <= guardar and not completa;

    nuevo_id <=
        std_logic_vector(unsigned(cantidad_guardada) + 1);

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

    U_ESCRITURA : contador_ascendente
        generic map (
            ANCHO_BITS => 3
        )
        port map (
            reloj     => reloj,
            reinicio  => reinicio,
            habilitar => escribir,
            CUENTA    => posicion_escritura
        );

    process(reloj, reinicio)
    begin

        if reinicio = '1' then
            memoria <= (others => (others => '0'));
            validos <= (others => '0');

            posicion_lectura <= (others => '0');
            ultima_posicion <= (others => '0');

            ocupadas <= 0;
            consulta_anterior <= '0';

        elsif rising_edge(reloj) then

            consulta_anterior <= consulta;

            -- Escritura del nuevo evento.
            if escribir = '1' then

                memoria(to_integer(unsigned(posicion_escritura))) <=
                    tiempo_entrada &
                    nuevo_id &
                    color_entrada &
                    tamano_entrada;

                validos(to_integer(unsigned(posicion_escritura))) <= '1';

                ultima_posicion <= unsigned(posicion_escritura);

                if ocupadas < 8 then
                    ocupadas <= ocupadas + 1;
                end if;

            end if;

            -- Navegacion por los registros.
            if consulta = '1' then

                -- Al entrar al historial se muestra el ultimo.
                if consulta_anterior = '0' or ir_ultimo = '1' then

                    if escribir = '1' then
                        posicion_lectura <= unsigned(posicion_escritura);

                    elsif ocupadas > 0 then
                        posicion_lectura <= ultima_posicion;
                    end if;

                elsif siguiente = '1' and ocupadas > 0 then

                    if escribir = '1' then
                        -- Si coinciden escritura y avance,
                        -- se muestra el registro recien escrito.
                        posicion_lectura <= unsigned(posicion_escritura);

                    elsif posicion_lectura = ultima_posicion then

                        -- Desde el ultimo se vuelve al mas antiguo.
                        if ocupadas = 8 then
                            posicion_lectura <= unsigned(posicion_escritura);
                        else
                            posicion_lectura <= (others => '0');
                        end if;

                    else
                        posicion_lectura <= posicion_lectura + 1;
                    end if;

                end if;

            end if;

        end if;

    end process;

    dato <= memoria(to_integer(posicion_lectura));

    tiempo_salida <= dato(20 downto 13);
    identificador_salida <= dato(12 downto 3);
    color_salida <= dato(2 downto 1);
    tamano_salida <= dato(0);

    registro_valido <= validos(to_integer(posicion_lectura));
    limite <= completa;

end architecture estructural;