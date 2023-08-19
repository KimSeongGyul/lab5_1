`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/15 18:08:01
// Design Name: 
// Module Name: i2c_master
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module i2c_master(
   input clk,
   input sysclk,
   input rst_n,
   output logic scl,
   input sda,
   output logic oe,
   output logic sda_o
);


localparam logic [7:0] wdata [2] = {8'h42, 8'h0A};
localparam logic [7:0] rdata = {8'h43};


logic [1:0] idx_byte;
logic [3:0] idx_bit;
logic [1:0] idx_div4;

logic ack;
logic flag_read;

logic test;

enum logic [3:0] {
   RESET, 
   START_W,
   WRITE,
   STOP_W,
   STOP_W_D1,
   STOP_W_D2,
   START_R,
   READ_1,
   READ_2,
   STOP_R,
   DONE,
   ERROR
} state, next_state;



task reset();
   idx_byte<= 0;
   idx_bit <= 0;
   oe       <= 0;
   sda_o    <= 0;
   scl    <= 1;
   idx_div4<= 0;
   ack    <= 0;
   flag_read <= 0;
   test <= 0;
endtask



/* 
   RESET      : 모든 레지스터 초기화
   START_W    : SDA를 먼저 내리고 SCL을 내려준다
   WRITE      : 1바이트 쓰고 ACK 기다리고, 같은작업 다시 한번 반복  
   STOP_W     : SCL을 먼저 올려주고 SDA를 나중에 올린다
   STOP_W_D1  : SDA가 1로 올라가 있는 상태를 조금 더 유지한다.
   STOP_W_D2  : SDA가 1로 올라가 있는 상태를 조금 더 유지한다.
   START_R    : SDA를 먼저 내리고 SCL을 내려준다
   READ_1     : 1바이트 쓰고 ACK 기다린다
   READ_2     : 1바이트를 읽고 NACK signal을 0으로 설정해준다. 
   STOP_R     : SCL을 먼저 올려주고 SDA를 나중에 올린다
   DONE       : 영원히 정지 상태 
*/




// 상태 레지스터링
always_ff @(posedge clk or negedge rst_n) begin
   if(~rst_n)    state <= RESET;
   else        state <= next_state;
end


// 상태계산
always_comb begin

   next_state = state;

   case (state)
      RESET:
         // 바로 START로 넘어감
         next_state = START_W;

      START_W:
         // SCL이 LOW면 WRITE로 
         if (~scl) next_state = WRITE;

      WRITE:
         //  2번의 WRITE (데이터 8비트 + ACK 1비트)가 끝나면 STOP
         if (idx_byte == 2) next_state = STOP_W;

      STOP_W:
         // SDA가 HIGH면 DONE으로
         if (sda) next_state = STOP_W_D1;

      STOP_W_D1:
         // SDA가 HIGH인 상태를 유지
         if (sda) next_state = STOP_W_D2;
 
      STOP_W_D2:
         // SDA가 HIGH인 상태를 유지
         if (sda) next_state = START_R;

      START_R:
         // SCL이 LOW면 READ로 
         if (~scl) next_state = READ_1;

      READ_1:
         //  1번의 WRITE (데이터 8비트 + ACK 1비트)
         if (idx_byte == 1) next_state = READ_2;

      READ_2:
         //  데이터 8비트 읽기 + Nack 1비트설정)
         if (flag_read == 1) next_state = STOP_R;

      STOP_R:
         // SDA가 HIGH면 DONE으로
         if (sda) next_state = DONE;

      DONE:
         // 그대로 stay
         next_state = state;

      ERROR:
         // 그대로 stay
         next_state = state;

      default:
         next_state = ERROR;
   endcase
end


// 출력 로직
always_ff @(posedge clk or negedge rst_n) begin
   if(~rst_n) begin
      reset();
   end else begin

      case (next_state)
         RESET: 
            reset();

         START_W: begin
            //SDA 내리고 SCL 내리기
            if (sda) begin
               oe      <= 1;
               sda_o <= 0;
            end else begin
               scl   <= 0;
            end
         end

         WRITE: begin

            case (idx_div4)
               2'b00: begin
                  if (idx_bit < 8) begin
                     oe    <= 1;
                     sda_o    <= wdata[idx_byte][idx_bit];
                  end else begin
                     oe    <= 0;
                  end
               end

               2'b01:
                  scl <= 1;

               2'b11: begin
                  scl <= 0;

                  if (idx_bit == 8) begin
                     ack <= sda;
                     idx_bit <= 0;
                     idx_byte <= idx_byte + 1;
                  end else begin
                     idx_bit <= idx_bit + 1;
                  end
               end

            endcase

            idx_div4 <= idx_div4 + 1;
         end


         STOP_W: begin
            // SCL 올리고 SDA 올리기
            if (state != next_state) begin
               scl    <= 0;
               sda_o    <= 0;
               oe       <= 1;
               idx_byte <= 0;
            end else begin
               if (~scl) begin 
                  scl <= 1;
               end
               else if (~sda)
                  sda_o<= 1;
                  test <= 1;              
            end
         end

         START_R: begin
            //SDA 내리고 SCL 내리기
            if (sda) begin
//               oe      <= 1;
               sda_o <= 0;
            end else begin
               scl   <= 0;
            end
         end

         READ_1 : begin

            case (idx_div4)
               2'b00: begin
                  if (idx_bit < 8) begin
                     oe    <= 1;
                     sda_o    <= rdata[idx_bit];
                  end else begin
                     oe    <= 0;
                  end
               end

               2'b01:
                  scl <= 1;

               2'b11: begin
                  scl <= 0;

                  if (idx_bit == 8) begin
                     ack <= sda;
                     idx_bit <= 0;
                     idx_byte <= idx_byte + 1;
                  end else begin
                     idx_bit <= idx_bit + 1;
                  end
               end
            endcase
            idx_div4 <= idx_div4 + 1;
         end

         READ_2 : begin

            case (idx_div4)
               2'b00: begin
                  if (idx_bit < 8) begin
                     oe    <= 0;
                  end else begin
                     oe    <= 1;
                     sda_o <= 1'b0; // Nack bit, set 0 is right?
                  end
               end

               2'b01:
                  scl <= 1;

               2'b11: begin
                  scl <= 0;

                  if (idx_bit == 8) begin
                     idx_bit <= 0;
                     flag_read <= 1;
                  end else begin
                     idx_bit <= idx_bit + 1;
                  end
               end
            endcase
            idx_div4 <= idx_div4 + 1;
         end

         STOP_R: begin
            // SCL 올리고 SDA 올리기
            if (state != next_state) begin
               scl    <= 0;
               sda_o    <= 0;
               oe       <= 1;
            end else begin
               if (~scl)
                  scl <= 1;
               else if (~sda)
                  oe <= 0;
            end
         end

      endcase

   end
end

ila T1(
    .clk(sysclk),
   .probe0(rst_n),
   .probe1(scl),
   .probe2(sda),
   .probe3(state),
   .probe4(next_state),
   .probe5(oe),
   .probe6(idx_byte),
   .probe7(test)
);    


endmodule