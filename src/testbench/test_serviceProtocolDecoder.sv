`timescale 10 ns/ 1 ns

module test_serviceProtocolDecoder();
  import ServiceProtocol::*;
	bit rst, clk;

	//debug spi transmitter
	ISpi spiBus();
	IPush spiPush();
	IPushHelper 		spiHelper(clk, spiPush);
	DebugSpiTransmitter 	spiTrans(rst, clk, spiPush, spiBus);
	
	//receiver and unpacker
	IPush spiOut();
	IPush spiIn();
	ISpiReceiverControl spiControl();
	
	SpiReceiver spiR(rst, clk, 
						  spiOut.slave, 
						  spiIn.master, 
						  spiControl.slave,
						  spiBus.slave);	
				  
	IPush unpackerOut();
	IServiceProtocolDControl unpackerControl();
				  
	ServiceProtocolDecoder serviceUnpacker(rst, clk, 
															spiIn.slave,
															unpackerOut.master,
															unpackerControl.slave);
	
	//testbench
	initial begin
    clk = 0; rst = 1;
    #2 rst = 0; 
	
    fork
      begin
				$display("TransmitOverSpi Start");	
			
				spiHelper.doPush(16'hAB00);	
				spiHelper.doPush(16'h02A2); 
				spiHelper.doPush(16'hEFAB); 
				spiHelper.doPush(16'h0001); 
				spiHelper.doPush(16'h9D4E); 
				spiHelper.doPush(16'h0000);
			
				$display("TransmitOverSpi End");	
			end

      begin
        @(unpackerControl.packetStart);
        assert( unpackerControl.moduleAddr == 8'hAB ); 
        assert( unpackerControl.cmdCode == TCC_SEND_DATA ); //A2
      end
      
      begin
        @(posedge unpackerOut.request);
        assert( unpackerOut.data == 16'hEFAB ); 
        @(posedge unpackerOut.request);
        assert( unpackerOut.data == 16'h0001 );
      end
      
      #4000 $stop;
    
    join
  end
	
	always #1  clk =  ! clk;

endmodule
