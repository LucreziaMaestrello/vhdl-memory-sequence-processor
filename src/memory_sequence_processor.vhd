
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
     port(
       i_clk : in std_logic;
       i_rst : in std_logic;
       i_start : in std_logic;
       i_add : in std_logic_vector(15 downto 0);
       i_k : in std_logic_vector(9 downto 0);
       
       o_done : out std_logic;
       
       o_mem_addr : out std_logic_vector(15 downto 0);
       i_mem_data : in std_logic_vector(7 downto 0);
       o_mem_data : out std_logic_vector(7 downto 0);
       o_mem_we : out std_logic;
       o_mem_en : out std_logic
      );

end project_reti_logiche;

architecture prj_RL_arch of project_reti_logiche is
signal o_mux_sel : STD_LOGIC;
signal mux_data_sel : STD_LOGIC;
signal o_mem_data_datapath : STD_LOGIC_VECTOR(7 downto 0);
signal o_mem_data_cred : STD_LOGIC_VECTOR(7 downto 0);
signal r1_load : STD_LOGIC;
signal r2_load : STD_LOGIC;
signal r3_load : STD_LOGIC;
signal r4_load : STD_LOGIC;
signal r5_load : STD_LOGIC;
signal r6_load : STD_LOGIC;
signal r1_eq0 : STD_LOGIC;
signal r2_eq0 : STD_LOGIC;
signal r3_eq0 : STD_LOGIC;
signal r4_eq0 : STD_LOGIC;
signal mux_reg3_sel : STD_LOGIC_VECTOR(1 downto 0);
signal mux_reg4_sel : STD_LOGIC;
signal mux_reg5_sel : STD_LOGIC;

component data_path is
port(
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_data : in STD_LOGIC_VECTOR(7 downto 0);
        o_data : out STD_LOGIC_VECTOR(7 downto 0);
        r1_load : in STD_LOGIC;
        r1_eq0: out STD_LOGIC;
        r2_load : in STD_LOGIC;
        r2_eq0 : out STD_LOGIC;
        mux_data_output_sel : in STD_LOGIC
    );    
end component data_path;


component credibility_counter is
Port (
       i_clk : in STD_LOGIC;
       i_rst : in STD_LOGIC;
       mux3_set : in STD_LOGIC_VECTOR(1 downto 0);
       r3_load : in STD_LOGIC;
       r3_eq0 : out STD_LOGIC;
       o_data3: out STD_LOGIC_VECTOR(7 downto 0)
   );
end component credibility_counter;

component address_counter is
port(
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_add : in STD_LOGIC_VECTOR(15 downto 0);
        add_sel : in STD_LOGIC;
        r5_load : in STD_LOGIC;
        o_data5: out STD_LOGIC_VECTOR(15 downto 0)
    );
end component address_counter;

component K_counter is
port(
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_k : in STD_LOGIC_VECTOR(9 downto 0);
        k_sel : in STD_LOGIC;
        r4_load : in STD_LOGIC;
        r4_eq0 : out STD_LOGIC
    );
end component K_counter;

component Fsm is
port(
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_start : in STD_LOGIC;
        o_done : out STD_LOGIC;
        o_en : out STD_LOGIC;
        o_we : out STD_LOGIC;
        r1_load : out STD_LOGIC;
        r2_load : out STD_LOGIC;
        r3_load : out STD_LOGIC;
        r4_load : out STD_LOGIC;
        r5_load : out STD_LOGIC;
        r1_eq0 : in STD_LOGIC;
        r2_eq0 : in STD_LOGIC;
        r3_eq0 : in STD_LOGIC;
        r4_eq0 : in STD_LOGIC;
        o_mux_sel : out STD_LOGIC;
        mux_reg3_sel : out STD_LOGIC_VECTOR(1 downto 0);
        mux_reg4_sel : out STD_LOGIC;
        mux_reg5_sel : out STD_LOGIC;
        mux_data_sel : out STD_LOGIC
    );
end component Fsm;

begin
    DATAPATH: data_path port map(
        i_clk,
        i_rst,
        i_data => i_mem_data,  
        o_data => o_mem_data_datapath,
        r1_load => r1_load, 
        r1_eq0 => r1_eq0,
        r2_load => r2_load,
        r2_eq0 => r2_eq0,
        mux_data_output_sel => mux_data_sel
    );
    CREDIBILITY : credibility_counter port map(
        i_clk,
        i_rst,
        mux3_set => mux_reg3_sel,
        r3_load => r3_load,
        r3_eq0 => r3_eq0,
        o_data3 => o_mem_data_cred
    );
    ADD : address_counter port map(
        i_clk,
        i_rst,
        i_add => i_add,
        add_sel => mux_reg5_sel,
        r5_load => r5_load,
        o_data5 => o_mem_addr
    );
    K : K_counter port map(
        i_clk ,
        i_rst ,
        i_k => i_k,
        k_sel => mux_reg4_sel, 
        r4_load => r4_load,
        r4_eq0 => r4_eq0
    );
    FineStateMachine : Fsm port map(
        i_clk,
        i_rst,
        i_start,
        o_done,
        o_en => o_mem_en,
        o_we => o_mem_we,
        r1_load => r1_load,
        r2_load => r2_load,
        r3_load => r3_load,
        r4_load => r4_load,
        r5_load => r5_load,
        r1_eq0 => r1_eq0,
        r2_eq0 => r2_eq0,
        r3_eq0 => r3_eq0,
        r4_eq0 => r4_eq0,
        o_mux_sel => o_mux_sel,
        mux_reg3_sel => mux_reg3_sel,
        mux_reg4_sel => mux_reg4_sel,
        mux_reg5_sel => mux_reg5_sel,
        mux_data_sel => mux_data_sel
    );

    with o_mux_sel select
        o_mem_data <=  o_mem_data_cred when '1',
                       o_mem_data_datapath when '0',
                       "XXXXXXXX" when others;    

end prj_RL_arch;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity data_path is
    port(
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_data : in STD_LOGIC_VECTOR(7 downto 0);
        o_data : out STD_LOGIC_VECTOR(7 downto 0);
        r1_load : in STD_LOGIC;
        r1_eq0: out STD_LOGIC;
        r2_load : in STD_LOGIC;
        r2_eq0 : out STD_LOGIC;
        mux_data_output_sel : in STD_LOGIC
    );    
end data_path;

architecture data_path_arch of data_path is
signal data_reg1 : STD_LOGIC_VECTOR(7 downto 0);
signal data_reg2 : STD_LOGIC_VECTOR(7 downto 0);
signal o_mux2 : STD_LOGIC_VECTOR(7 downto 0);
signal internal_i_data : STD_LOGIC_VECTOR(7 downto 0);
signal o_mux_data : STD_LOGIC_VECTOR(7 downto 0);
begin

     o_data <= o_mux_data; --in out metto ciò che c'è nel registro d'uscita
     
     internal_i_data <= i_data;

    process(i_clk, i_rst)  --registro 1
    begin
        if i_rst = '1' then
            data_reg1 <= "00000000";
        elsif falling_edge(i_clk) then
            if r1_load = '1' then
                data_reg1 <= i_data;
            end if;
        end if;
     end process;
     
     process(i_clk, i_rst) --registro 2
     begin
         if(i_rst = '1') then
             data_reg2 <= "00000000";
         elsif falling_edge(i_clk) then
             if(r2_load = '1') then
                 data_reg2 <= data_reg1;
             end if;
         end if;
      end process;
      
      r1_eq0 <= '1' when (data_reg1 = "00000000") else '0';
      
      r2_eq0 <= '1' when (data_reg2 = "00000000") else '0';
      
          
      with mux_data_output_sel select --mux per registro d'uscita
        o_mux_data <= data_reg1 when '0',
                      data_reg2 when '1',
                      "XXXXXXXX" when others;

end data_path_arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity credibility_counter is
    Port (
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        mux3_set : in STD_LOGIC_VECTOR(1 downto 0);
        r3_load : in STD_LOGIC;
        r3_eq0 : out STD_LOGIC;
        o_data3: out STD_LOGIC_VECTOR(7 downto 0)
    );
end credibility_counter;

architecture credibility_counter_arch of credibility_counter is
signal data_reg3 : STD_LOGIC_VECTOR(7 downto 0);
signal o_mux3 : STD_LOGIC_VECTOR(7 downto 0);
signal sub : STD_LOGIC_VECTOR(7 downto 0);
signal r3_eq0_internal : STD_LOGIC;
begin

     o_data3 <= data_reg3;

     process(i_clk, i_rst)  --registro 3
     begin
         if(i_rst = '1') then
             data_reg3 <= "00000000";
         elsif falling_edge(i_clk) then
              if r3_load = '1' then
                 data_reg3 <= o_mux3;
              end if;
         end if;
      end process;
      
      sub <= std_logic_vector(unsigned(data_reg3) - "00000001");
      
      with mux3_set select --multiplexer 
              o_mux3 <= "00011111" when "00",
                        sub when "01",
                        "00000000" when "10",
                        "XXXXXXXX" when others;
                        
      r3_eq0_internal <= '1' when (unsigned(data_reg3) = "00000000") else '0'; --segnale per sapere se da 31 sono arrivato a 0

      r3_eq0 <= r3_eq0_internal;

end credibility_counter_arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Address_counter is
    port(
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_add : in STD_LOGIC_VECTOR(15 downto 0);
        add_sel : in STD_LOGIC;
        r5_load : in STD_LOGIC;
        o_data5 : out std_logic_vector(15 downto 0)
    );
end Address_counter;

architecture Address_counter_arch of Address_counter is
signal mux_reg5 : std_logic_vector(15 downto 0);
signal sum1 : std_logic_vector(15 downto 0);
signal data_reg5 : std_logic_vector(15 downto 0);

begin
    
    o_data5 <= data_reg5;

    with add_sel select
        mux_reg5 <= i_add when '0',
                    sum1 when '1',
                    "XXXXXXXXXXXXXXXX" when others;
                    
    process(i_clk, i_rst)  --registro 5
         begin
             if(i_rst = '1') then
                 data_reg5 <= "0000000000000000";
                 elsif falling_edge(i_clk) then
                      if(r5_load = '1') then
                         data_reg5 <= mux_reg5;
                      end if;
                 end if;
             end process;
     
    sum1 <= std_logic_vector(unsigned(data_reg5) + 1);

end Address_counter_arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity K_counter is
    port(
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_k : in STD_LOGIC_VECTOR(9 downto 0);
        k_sel : in STD_LOGIC;
        r4_load : in STD_LOGIC;
        r4_eq0 : out STD_LOGIC
    );
end K_counter;

architecture K_counter_arch of K_counter is
signal mux_reg4 : std_logic_vector(9 downto 0);
signal sub : std_logic_vector(9 downto 0);
signal data_reg4 : std_logic_vector(9 downto 0);
begin    
    
    with k_sel select
            mux_reg4 <= i_k when '0',
                        sub when '1',
                        "XXXXXXXXXX" when others;
                        
    process(i_clk, i_rst)
        begin
            if i_rst = '1' then
                data_reg4 <= "0000000000";
            elsif falling_edge(i_clk) then
                if r4_load = '1' then        
                    data_reg4 <= mux_reg4;
                    sub <= std_logic_vector(unsigned(mux_reg4) - 1);
                end if;
            end if;
        end process;       
    
    r4_eq0 <= '1' when (data_reg4 = "0000000000") else '0';
         

end K_counter_arch;




library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Fsm is
    Port(
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_start : in STD_LOGIC;
        o_done : out STD_LOGIC;
        o_en : out STD_LOGIC;
        o_we : out STD_LOGIC;
        r1_load : out STD_LOGIC;
        r2_load : out STD_LOGIC;
        r3_load : out STD_LOGIC;
        r4_load : out STD_LOGIC;
        r5_load : out STD_LOGIC;
        r1_eq0 : in STD_LOGIC;
        r2_eq0 : in STD_LOGIC;
        r3_eq0 : in STD_LOGIC;
        r4_eq0 : in STD_LOGIC;
        o_mux_sel : out STD_LOGIC;
        mux_reg3_sel : out STD_LOGIC_VECTOR(1 downto 0);
        mux_reg4_sel : out STD_LOGIC;
        mux_reg5_sel : out STD_LOGIC;
        mux_data_sel : out STD_LOGIC
    );
end Fsm;

architecture Fsm_arch of Fsm is

type S is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14);
signal cur_state, next_state : S;
begin
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= S0;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;
      
    
    process(i_rst, i_clk, i_start, r1_eq0, r2_eq0, r3_eq0, r4_eq0, cur_state)
        begin
            next_state <= cur_state;
            case cur_state is
                when S0 =>
                    if i_start = '1' then
                        next_state <= S1;
                    end if;
                when S1 =>       
                    if r4_eq0 = '1' then             
                        next_state <= S14;
                    else
                        next_state <= S2;
                    end if;
                when S2 =>
                    next_state <= S3;
                when S3 => 
                    if r4_eq0 = '1' then
                        next_state <= S14;
                    elsif r1_eq0 = '1' then 
                        next_state <= S4;
                    else 
                        next_state <= S6;
                    end if;
                when S4 =>
                    if r2_eq0 = '1' then
                        next_state <= S6;
                    else 
                        next_state <= S5;
                    end if;
                when S5 =>
                    if r3_eq0 = '1' then
                        next_state <= S9;
                    else
                        next_state <= S8;
                    end if;
                when S6 =>
                    if r1_eq0 = '0' then
                        next_state <= S7;
                    else 
                        next_state <= S10;
                    end if;
                when S7 =>
                    next_state <= S10;
                when S8 =>
                    next_state <= S10;
                when S9 =>
                    next_state <= S10;
                when S10 =>
                    next_state <= S11;
                when S11 =>
                    next_state <= S12;
                when S12 =>
                    next_state <= S13;
                when S13 =>
                    next_state <= S3;
                when S14 =>
                    if i_start = '0' then
                        next_state <= S0;
                    else
                        next_state <= cur_state;
                    end if;                  
            end case;
        end process;
        
        process(cur_state)
        begin
        o_done <= '0';
        o_en <= '0';
        o_we <= '0';
        r1_load <= '0';
        r2_load <= '0';
        r3_load <= '0';
        r4_load <= '0';
        r5_load <= '0';
        mux_reg3_sel <= "10";
        mux_reg4_sel <= '1';
        mux_reg5_sel <= '0';
        o_mux_sel <= '0';
        mux_data_sel <= '0';
            case cur_state is
                when S0 =>
                report "s0";
                when S1 =>
                report "s1";
                    o_en <= '1';
                    r4_load <= '1';
                    r5_load <= '1';
                    mux_reg4_sel <= '0';
                    mux_reg5_sel <= '0';
                when S2 =>
                report "s2";
                    r1_load <= '1';
                    r2_load <= '1';
                    mux_reg3_sel <= "10";
                    r3_load <= '1';
                when S3 =>
                report "s3";
                when S4 =>
                report "s4";
                when S5 =>
                report "s5";
                    o_we <= '1';
                    o_en <= '1';
                    o_mux_sel <= '0';
                    mux_data_sel <= '1';
                when S6 =>
                report "s6";
                     o_en <= '1';
                     o_we <= '1';
                     o_mux_sel <= '0';
                     mux_data_sel <= '0';
                when S7 =>
                report "s7";
                    r2_load <= '1';
                    r3_load <= '1';
                    mux_reg3_sel <= "00";   
                when S8 =>
                report "s8";
                    r3_load <= '1';
                    mux_reg3_sel <= "01";
                when S9 =>
                report "s9";
                    r3_load <= '1';
                    mux_reg3_sel <= "10";
                when S10 =>
                report "s10";
                    r5_load <= '1';
                    mux_reg5_sel <= '1';
                when S11 =>
                report "s11";
                    o_we <= '1';
                    o_en <= '1';
                    o_mux_sel <= '1';
                when S12 =>
                report "s12";
                    o_en <= '1';
                    r5_load <= '1';
                    mux_reg5_sel <= '1';
                when S13 =>
                report "s13";
                    r4_load <= '1';
                    mux_reg4_sel <= '1';
                    r1_load <= '1';
                when S14 =>
                report "s14";
                    o_done <= '1';
               end case;
        end process;
end Fsm_arch;

