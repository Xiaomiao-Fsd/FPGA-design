// Version 1.0

/*
This is the LED matrix controller module
Including Single led, row led, water led, PWM four mode

10ms = 100 Hz

*/

// Version 1.1 For convinience reason, this file use key on board from 1 - 2 - 3 - 4 to choose the mode, instead of the w_instruction which need to decode

`include "./LED_defines.vh"

module LED_Matrix_Test#(

    parameter integer p_frequency           = 50_000_000                                            ,   // System clk frequency
    parameter integer p_pwm_bits            = 8                                                     ,   // PWM resolution bits
    parameter integer p_row_num             = 8                                                     ,   // Matrix row num  
    parameter integer p_column_num          = 8                                                     ,   // Matrix column num
    parameter integer p_control_num         = 3                                                     ,   // Controlling pin num for each led

    parameter integer LED_NUM               = p_row_num * p_column_num                              ,   // Total LED num
    parameter integer p_brightness_step_ms  = 10                                                    ,   // Each brightness level duration in ms
    parameter integer PWM_BRIGHTNESS_PERIOD = (p_frequency * p_brightness_step_ms) / 1000               // PWM timing: ensure p_brightness_step_ms duration per step

)

(
    input   wire    clk                                                                             ,
    input   wire    rst_n                                                                           ,
    input   wire    start                                                                           ,

    // input   wire    [8 + p_row_num + p_column_num - 1 : 0]  w_instruction                           ,
    input   wire                                            w_key_2                                 ,
    input   wire                                            w_key_3                                 ,
    input   wire                                            w_key_4                                 ,

    output  wire    [p_row_num - 1 : 0]                     w_row_anode                             ,
    output  wire    [p_control_num - 1 : 0]                 w_column_cell   [0 : p_column_num - 1]  ,

    output  wire                                            w_done                      
    
);



/*--------------------------------register-------------------------------------------*/


// Instruction decode reg

// reg     [7 : 0]                                 r_instruction_mode                      ;
// reg     [p_column_num - 1 : 0]                  r_instruction_data_column               ;
// reg     [p_row_num - 1 : 0]                     r_instruction_data_row                  ;
reg                                             r_key_2                                 ;
reg                                             r_key_3                                 ;
reg                                             r_key_4                                 ;


// Matrix output temp reg
reg     [p_row_num - 1 : 0]                     r_row_anode                             ;
reg     [p_control_num - 1 : 0]                 r_column_cell   [0 : p_column_num - 1]  ;
reg     [3 : 0]                                 r_mode                                  ;
reg                                             r_done                                  ;


// State Machine

typedef enum logic [3 : 0] { 

    ST_IDLE                                                                             ,
    ST_SL                                                                               ,
    ST_RL                                                                               ,
    ST_WL                                                                               ,
    ST_PWM                                                                              ,
    ST_DONE

} STATE                                                                                 ;

STATE                                           CURRENT_STATE, NEXT_STATE               ;

reg                                             FLAG_Single_Light_Done                  ;
reg                                             FLAG_Row_Light_Done                     ;
reg                                             FLAG_Water_Light_Done                   ;
reg                                             FLAG_PWM_Done                           ;


// Water LED

reg     [$clog2(LED_NUM) - 1 : 0]               r_WL_count                              ;
reg     [31 : 0]                                r_WL_timer_cnt                          ;

// PWM Controller
reg     [p_pwm_bits - 1 : 0]                    PWM_counter                             ; // PWM counter
reg     [p_pwm_bits - 1 : 0]                    PWM_duty_cycle                          ; // Duty cycle value (0-255)
reg     [$clog2(p_frequency)-1:0]               PWM_brightness_timer                    ; // Timer for brightness changes (dynamic width)
reg                                             PWM_led_state                           ; // Current PWM LED state
reg                                             PWM_direction                           ; // PWM brightness direction: 1=increasing, 0=decreasing




/*--------------------------------register-------------------------------------------*/


/*--------------------------------assign---------------------------------------------*/

// Matrix output wire connect
assign  w_row_anode                             = r_row_anode                           ;
assign  w_column_cell                           = r_column_cell                         ;
assign  w_mode                                  = r_mode                                ;
assign  w_done                                  = r_done                                ;


// Instruction storage
// assign  r_instruction_data_column               = w_instruction [p_column_num - 1 : 0]  ;
// assign  r_instruction_data_row                  = w_instruction [p_row_num + p_column_num - 1 -: p_row_num]  ;
// assign  r_instruction_mode                      = w_instruction [$high(w_instruction) -: 8] ;

assign  r_key_2                                 = w_key_2                               ;
assign  r_key_3                                 = w_key_3                               ;
assign  r_key_4                                 = w_key_4                               ;

/*--------------------------------assign---------------------------------------------*/


// Done logic

always @(posedge clk) begin
    
    if(~rst_n) begin
        
        r_done <= 'd0; 
    end

    else begin
        
        if(FLAG_Single_Light_Done || FLAG_Row_Light_Done || FLAG_Water_Light_Done || FLAG_PWM_Done) begin
            
            r_done <= 'd1;
        end

        else if(r_done == 'd1) begin
            
            r_done <= 'd0;
        end

        else begin
            
            r_done <= r_done; 
        end
    end

end



// State Machine


// State Machine Running logic

always @(posedge clk) begin
    
    if(~rst_n) begin
        
        CURRENT_STATE <= ST_IDLE; 
    end

    else begin
        
        CURRENT_STATE <= NEXT_STATE; 
    end
end



// State Machine Next State controller

always @(*) begin

    NEXT_STATE = ST_IDLE;

    case(CURRENT_STATE)

        // IDLE
        ST_IDLE: begin

            if(rst_n && start) begin

                case({r_key_2,r_key_3,r_key_4})


                    3'b111  :   NEXT_STATE = ST_IDLE   ;
                    3'b011  :   NEXT_STATE = ST_SL     ;
                    3'b101  :   NEXT_STATE = ST_RL     ;
                    3'b110  :   NEXT_STATE = ST_WL     ;
                    3'b001  :   NEXT_STATE = ST_PWM    ;

                    default:    NEXT_STATE = ST_IDLE   ;

                endcase

            end

            else begin
                
                NEXT_STATE = ST_IDLE; 
            end
        end


        // Single LED
        ST_SL: begin

            if(~FLAG_Single_Light_Done) begin

                NEXT_STATE = ST_SL; 
            end

            else if(FLAG_Single_Light_Done) begin

                NEXT_STATE = ST_DONE; 
            end
        end


        // Row LED
        ST_RL: begin

            if(~FLAG_Row_Light_Done) begin

                NEXT_STATE = ST_RL; 
            end

            else if(FLAG_Row_Light_Done) begin

                NEXT_STATE = ST_DONE; 
            end
        end


        // Water LED
        ST_WL: begin

            if(~FLAG_Water_Light_Done) begin

                NEXT_STATE = ST_WL; 
            end 

            else if(FLAG_Water_Light_Done) begin

                NEXT_STATE = ST_DONE; 
            end
        end


        // PWM
        ST_PWM: begin

            if(~FLAG_PWM_Done) begin

                NEXT_STATE = ST_PWM;
            end

            else if(FLAG_PWM_Done) begin

                NEXT_STATE = ST_DONE;

            end
        end


        // Done
        ST_DONE: begin
            
            NEXT_STATE = ST_IDLE;
        end

        default: NEXT_STATE = ST_IDLE;


    endcase

end



// State Machine Definition


// Main Logic

always @(posedge clk) begin
    
    case(CURRENT_STATE)

        // IDLE: Doing nothing
        ST_IDLE: begin

            if(~rst_n) begin

                PWM_counter             <= {p_pwm_bits{1'b0}}               ;
                PWM_duty_cycle          <= {p_pwm_bits{1'b0}}               ;
                PWM_brightness_timer    <= {$clog2(p_frequency){1'b0}}      ;
                PWM_led_state           <= 1'b0                             ;
                PWM_direction           <= 1'b1                             ;
                r_WL_count              <= 'd0                              ;
                r_WL_timer_cnt          <= 'd0                              ;
                FLAG_PWM_Done           <= 1'b0                             ;
                FLAG_Row_Light_Done     <= 1'b0                             ;
                FLAG_Single_Light_Done  <= 1'b0                             ;
                FLAG_Water_Light_Done   <= 1'b0                             ;

                r_row_anode             <= 8'b0000_0000                     ;

                for(int i=0; i<p_column_num; i=i+1) begin

                    r_column_cell[i] <= `COLOR_OFF                          ;
                end
            end
        end


        // Turn on a Single Led
        ST_SL: begin

            if(~FLAG_Single_Light_Done) begin

                r_row_anode             <= 8'b0000_1000                     ;

                    
                r_column_cell[2]        <= `COLOR_BLUE                      ;

                FLAG_Single_Light_Done  <= 'd1                              ;
            end
        end


        // Turn on all the led of a Row
        ST_RL: begin

            if(~FLAG_Row_Light_Done) begin
                
                r_row_anode             <= 8'b0010_0000                     ;

                for(int i=0; i<p_column_num; i++) begin
                    
                    r_column_cell[i]    <= `COLOR_RED;
                end

                FLAG_Row_Light_Done     <= 'd1;
            end
        end


        // Water Light Mode
        ST_WL: begin

            if(~FLAG_Water_Light_Done && r_WL_count <= 7) begin

                if(r_WL_timer_cnt >= (p_frequency/5) - 1) begin

                    for(int i=0; i<p_column_num; i++) begin
                        r_column_cell[i] <= `COLOR_OFF;
                    end
                    
                    r_column_cell[2] <= `COLOR_GREEN;
                    r_row_anode <= (r_WL_count == 0) ? 8'b0000_0001 : r_row_anode << 1;
                    r_WL_count <= r_WL_count + 1;

                    if(r_WL_count == 7) begin
                        FLAG_Water_Light_Done <= 1'b1;
                    end
                    
                    r_WL_timer_cnt <= 'd0;
                end

                else begin
                    
                    r_WL_timer_cnt <= r_WL_timer_cnt + 'd1; 
                end

            end

        end


        // PWM controller 
        ST_PWM: begin

            if(~FLAG_PWM_Done) begin

                r_row_anode <= 8'b0000_1000             ;   
                
                PWM_counter <= PWM_counter + 1'b1;
                

                if(PWM_counter < PWM_duty_cycle) begin
                    PWM_led_state <= 1'b1;      
                end
                else begin
                    PWM_led_state <= 1'b0;     
                end
                

                // PWM On / Off Switch

                if(PWM_led_state) begin

                    r_column_cell[2]        <= `COLOR_BLUE                      ; 
                end

                else begin

                    r_column_cell[2]        <= `COLOR_OFF                       ;
                end
                

                PWM_brightness_timer <= PWM_brightness_timer + 1'b1;
                

                if(PWM_brightness_timer >= PWM_BRIGHTNESS_PERIOD) begin 
                    
                    PWM_brightness_timer <= {$clog2(p_frequency){1'b0}};
                    
                    // Change to decreasing direction
                    if(PWM_duty_cycle == {p_pwm_bits{1'b1}} && PWM_direction) begin

                        PWM_direction   <= 1'b0; 
                        PWM_duty_cycle  <= PWM_duty_cycle - 1'b1;
                    end

                    // change to increasing direction
                    else if(PWM_duty_cycle == {p_pwm_bits{1'b0}} && !PWM_direction) begin

                        PWM_direction   <= 1'b1;  
                        PWM_duty_cycle  <= PWM_duty_cycle + 1'b1;
                    end

                    // increasing
                    else if(PWM_direction) begin  

                        PWM_duty_cycle  <= PWM_duty_cycle + 1'b1;
                    end

                    // decreasing
                    else begin  

                        PWM_duty_cycle  <= PWM_duty_cycle - 1'b1;
                    end
                end
                
                
                // if(r_instruction_data[7] && PWM_brightness_timer >= PWM_BRIGHTNESS_PERIOD) begin
                    // FLAG_PWM_Done <= 1'b1;
                // end
            end
        end

        
        ST_DONE: begin
            
            FLAG_PWM_Done           <= 'd0  ;
            FLAG_Row_Light_Done     <= 'd0  ;
            FLAG_Single_Light_Done  <= 'd0  ;
            FLAG_Water_Light_Done   <= 'd0  ;

        end

    endcase

end



endmodule
