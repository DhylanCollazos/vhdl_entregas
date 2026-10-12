LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY divisor_frecuencia IS
    PORT (
        clk        : IN STD_LOGIC;
        out1, out2 : BUFFER STD_LOGIC
    );
END divisor_frecuencia;


ARCHITECTURE example OF divisor_frecuencia IS

    SIGNAL count1 : INTEGER RANGE 0 TO 7;

BEGIN

    PROCESS(clk)

        VARIABLE count2 : INTEGER RANGE 0 TO 7;

    BEGIN

        IF (clk'EVENT AND clk='1') THEN

            count1 <= count1 + 1;
            count2 := count2 + 1;

            IF (count1 = 2) THEN
                out1 <= NOT out1;
                count1 <= 0;
            END IF;

            IF (count2 = 3) THEN
                out2 <= NOT out2;
                count2 := 0;
            END IF;
        END IF;
    END PROCESS;
END example;