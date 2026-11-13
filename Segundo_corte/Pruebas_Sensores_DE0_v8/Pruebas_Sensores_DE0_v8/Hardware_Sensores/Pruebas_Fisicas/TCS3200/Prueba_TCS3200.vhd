library ieee;
use ieee.std_logic_1164.all;

entity Prueba_TCS3200 is
    port (
        CLOCK_50 : in  std_logic;
        BUTTON   : in  std_logic_vector(2 downto 0);
        SW       : in  std_logic_vector(9 downto 0);

        TCS_OUT : in  std_logic;
        TCS_S0  : out std_logic;
        TCS_S1  : out std_logic;
        TCS_S2  : out std_logic;
        TCS_S3  : out std_logic;

        LEDG : out std_logic_vector(9 downto 0);
        HEX0, HEX1, HEX2, HEX3 : out std_logic_vector(6 downto 0)
    );
end entity Prueba_TCS3200;

architecture estructural of Prueba_TCS3200 is

    signal reinicio       : std_logic;
    signal boton_inicio   : std_logic;
    signal pulso_inicio   : std_logic;

    signal color          : std_logic_vector(1 downto 0);
    signal rojo           : std_logic_vector(15 downto 0);
    signal verde          : std_logic_vector(15 downto 0);
    signal azul           : std_logic_vector(15 downto 0);
    signal valor_mostrado : std_logic_vector(15 downto 0);

    signal seleccion_1, seleccion_2 : std_logic_vector(1 downto 0) := "00";
    signal lista          : std_logic;
    signal valida         : std_logic;
    signal ocupado        : std_logic;
    signal alternador_fin : std_logic := '0';

begin

    boton_inicio <= not BUTTON(0);

    with seleccion_2 select
        valor_mostrado <=
            rojo  when "00",
            verde when "01",
            azul  when "10",
            (others => '0') when others;

    U_REINICIO : entity work.reinicio_seguro
        port map (
            reloj => CLOCK_50,
            reinicio_bajo => BUTTON(1),
            reinicio_salida => reinicio
        );

    U_BOTON : entity work.filtro_boton
        generic map (
            CICLOS_ESTABLES => 250000
        )
        port map (
            reloj => CLOCK_50,
            reinicio => reinicio,
            boton_entrada => boton_inicio,
            pulso_salida => pulso_inicio,
            estado_salida => open
        );

    U_TCS3200 : entity work.lector_tcs3200
        generic map (
            VENTANA_CICLOS => 1500000,       -- 30 ms a 50 MHz
            ASENTAMIENTO_CICLOS => 25000,    -- 0.5 ms a 50 MHz
            CLASIFICACION_HABILITADA => true,
            BASE_NEGRA_ROJO => 26,
            BASE_NEGRA_VERDE => 26,
            BASE_NEGRA_AZUL => 34,
            GANANCIA_ROJO_Q5 => 85,
            GANANCIA_VERDE_Q5 => 109,
            GANANCIA_AZUL_Q5 => 115,
            SENAL_MINIMA => 10
        )
        port map (
            reloj => CLOCK_50,
            reinicio => reinicio,
            iniciar => pulso_inicio,
            tcs_out => TCS_OUT,
            tcs_s0 => TCS_S0,
            tcs_s1 => TCS_S1,
            tcs_s2 => TCS_S2,
            tcs_s3 => TCS_S3,
            color => color,
            valor_rojo => rojo,
            valor_verde => verde,
            valor_azul => azul,
            medicion_lista => lista,
            medicion_valida => valida,
            ocupado => ocupado
        );

    process(CLOCK_50, reinicio)
    begin
        if reinicio = '1' then
            alternador_fin <= '0';
            seleccion_1 <= "00"; seleccion_2 <= "00";
        elsif rising_edge(CLOCK_50) then
            seleccion_1 <= SW(1 downto 0); seleccion_2 <= seleccion_1;
            if lista = '1' then
                alternador_fin <= not alternador_fin;
            end if;
        end if;
    end process;

    U_HEX0 : entity work.decodificador_7segmentos
        port map (numero => valor_mostrado(3 downto 0), segmentos => HEX0);

    U_HEX1 : entity work.decodificador_7segmentos
        port map (numero => valor_mostrado(7 downto 4), segmentos => HEX1);

    U_HEX2 : entity work.decodificador_7segmentos
        port map (numero => valor_mostrado(11 downto 8), segmentos => HEX2);

    U_HEX3 : entity work.decodificador_7segmentos
        port map (numero => valor_mostrado(15 downto 12), segmentos => HEX3);

    LEDG(1 downto 0) <= color;
    LEDG(2) <= valida;
    LEDG(3) <= ocupado;
    LEDG(4) <= alternador_fin;
    LEDG(9 downto 5) <= (others => '0');

end architecture estructural;
