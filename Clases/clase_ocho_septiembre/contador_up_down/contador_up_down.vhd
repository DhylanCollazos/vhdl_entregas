LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY contador_up_down IS
    PORT (
        clk     : IN STD_LOGIC;
        reset   : IN STD_LOGIC;
        up_down : IN STD_LOGIC;
        Q       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END contador_up_down;


ARCHITECTURE synth OF contador_up_down IS

    SIGNAL contador : UNSIGNED(3 DOWNTO 0);

BEGIN

    PROCESS(clk, reset)
    BEGIN

        -- Reset
        IF reset = '1' THEN
            contador <= "0000";

        -- Conteo
        ELSIF rising_edge(clk) THEN

            -- UP/DOWN = 0: cuenta ascendente
            IF up_down = '0' THEN
                contador <= contador + 1;

            -- UP/DOWN = 1: cuenta descendente
            ELSE
                contador <= contador - 1;

            END IF;

        END IF;

    END PROCESS;

    Q <= STD_LOGIC_VECTOR(contador);

END synth;