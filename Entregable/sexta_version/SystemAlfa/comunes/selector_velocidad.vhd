library ieee;
use ieee.std_logic_1164.all;

entity selector_velocidad is
    generic (
        FRECUENCIA_RELOJ_HZ : positive := 50000000;
        CICLOS_FILTRO : positive := 500000
    );
    port (
        reloj, reinicio, boton_bajo : in std_logic;
        nivel_salida : out std_logic_vector(1 downto 0);
        pulso_linea : out std_logic;
        segmentos : out std_logic_vector(6 downto 0)
    );
end entity selector_velocidad;

architecture estructural of selector_velocidad is

    component filtro_boton is
        generic (
            CICLOS_ESTABLES : positive := 500000
        );
        port (
            reloj, reinicio, boton_entrada : in std_logic;
            pulso_salida, estado_salida : out std_logic
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

    component decodificador_7segmentos is
        port (
            numero : in std_logic_vector(3 downto 0);
            segmentos : out std_logic_vector(6 downto 0)
        );
    end component;

    signal boton, cambio : std_logic;
    signal nivel : std_logic_vector(1 downto 0);
    signal numero : std_logic_vector(3 downto 0);

begin

    boton <= not boton_bajo;

    U_BOTON : filtro_boton
        generic map (
            CICLOS_ESTABLES => CICLOS_FILTRO
        )
        port map (
            reloj         => reloj,
            reinicio      => reinicio,
            boton_entrada => boton,
            pulso_salida  => cambio,
            estado_salida => open
        );

    U_NIVEL : contador_ascendente
        generic map (
            ANCHO_BITS => 2
        )
        port map (
            reloj     => reloj,
            reinicio  => reinicio,
            habilitar => cambio,
            CUENTA    => nivel
        );

    U_DIVISOR : divisor_frecuencia
        generic map (
            FRECUENCIA_RELOJ_HZ => FRECUENCIA_RELOJ_HZ
        )
        port map (
            reloj       => reloj,
            reinicio    => reinicio,
            nivel       => nivel,
            pulso_linea => pulso_linea
        );

    numero <= "00" & nivel;

    U_VISOR : decodificador_7segmentos
        port map (
            numero    => numero,
            segmentos => segmentos
        );

    nivel_salida <= nivel;

end architecture estructural;