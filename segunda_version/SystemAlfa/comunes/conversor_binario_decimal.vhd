library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity conversor_binario_decimal is
    port (
        numero_binario : in std_logic_vector(9 downto 0);

        centenas : out std_logic_vector(3 downto 0);
        decenas  : out std_logic_vector(3 downto 0);
        unidades : out std_logic_vector(3 downto 0)
    );
end entity conversor_binario_decimal;

architecture comportamiento of conversor_binario_decimal is
begin

    process(numero_binario)

        variable numero :
            integer range 0 to 1023;

        variable valor_centenas :
            integer range 0 to 9;

        variable valor_decenas :
            integer range 0 to 9;

        variable valor_unidades :
            integer range 0 to 9;

    begin

        numero := to_integer(unsigned(numero_binario));

        -- Tres digitos permiten mostrar de 000 a 999
        -- Se protege el conversor ante entradas mayores
        if numero > 999 then
            numero := 999;
        end if;

        valor_centenas := numero / 100;
        valor_decenas  := (numero / 10) mod 10;
        valor_unidades := numero mod 10;

        centenas <= std_logic_vector(
            to_unsigned(valor_centenas, 4)
        );

        decenas <= std_logic_vector(
            to_unsigned(valor_decenas, 4)
        );

        unidades <= std_logic_vector(
            to_unsigned(valor_unidades, 4)
        );

    end process;

end architecture comportamiento;