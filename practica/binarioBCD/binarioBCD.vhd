library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binarioBCD is
    port
    (
        suma : in bit_vector(3 downto 0);
        cout : in bit;

        unidades : out std_logic_vector(3 downto 0);
        decenas  : out std_logic_vector(3 downto 0)
    );
end binarioBCD;

architecture arch_binarioBCD of binarioBCD is
begin

    process(suma, cout)

        variable resultado : bit_vector(4 downto 0);

        variable numero : integer range 0 to 31;
        variable contador_decenas : integer range 0 to 3;

    begin

        -- Formamos el resultado completo de cinco bits.
        resultado := cout & suma;

        numero := to_integer(
            unsigned(to_stdlogicvector(resultado))
        );

        contador_decenas := 0;

        -- Para valores de 0 a 31 bastan tres restas.
        for i in 1 to 3 loop

            if numero >= 10 then

                numero := numero - 10;

                contador_decenas := contador_decenas + 1;

            end if;

        end loop;

        -- El numero restante corresponde a las unidades.
        unidades <= std_logic_vector(
            to_unsigned(numero, 4)
        );

        -- La cantidad de restas corresponde a las decenas.
        decenas <= std_logic_vector(
            to_unsigned(contador_decenas, 4)
        );

    end process;

end arch_binarioBCD;