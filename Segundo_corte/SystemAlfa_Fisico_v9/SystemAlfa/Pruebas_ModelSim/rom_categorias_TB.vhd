library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_categorias_TB is
end entity rom_categorias_TB;

architecture prueba of rom_categorias_TB is

    component rom_categorias is
        port (
            direccion :
                in std_logic_vector(2 downto 0);

            dato :
                out std_logic_vector(4 downto 0)
        );
    end component;

    signal DIRECCION_TB :
        std_logic_vector(2 downto 0) :=
        "000";

    signal DATO_TB :
        std_logic_vector(4 downto 0);

begin

    DUT1 : rom_categorias
        port map (
            direccion =>
                DIRECCION_TB,

            dato =>
                DATO_TB
        );

    STIMULUS : process

        type tipo_esperados is
            array (0 to 7)
            of std_logic_vector(4 downto 0);

        constant ESPERADOS :
            tipo_esperados := (

            "01000",
            "01000",
            "10001",
            "10010",
            "10011",
            "10100",
            "10101",
            "10110"

        );

    begin

        for i in 0 to 7 loop

            DIRECCION_TB <=
                std_logic_vector(
                    to_unsigned(i, 3)
                );

            wait for 10 ns;

            assert
                DATO_TB = ESPERADOS(i)

                report
                    "Dato incorrecto en ROM"

                severity failure;

        end loop;

        report
            "OK: rom_categorias_TB"
            severity note;

        wait;

    end process STIMULUS;

end architecture prueba;