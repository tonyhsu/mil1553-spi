`timescale 10 ns/ 1 ns

module ServiceProtocolUnpackerTest();
	bit rst, clk, ioClk; 
	logic[15:0] tData1, rData1, tData2, rData2;
	logic requestInsertToTQueue1, doneInsertToTQueue1, requestReceivedToRQueue1, doneSavedFromRQueue1, 
			overflowInTQueue1, overflowInRQueue1;
	logic requestInsertToTQueue2, doneInsertToTQueue2, requestReceivedToRQueue2, doneSavedFromRQueue2, 
			overflowInTQueue2, overflowInRQueue2, isBusy;
	logic oPin, iPin, nCS, sck;

	spiMaster spiM(rst, clk, ioClk, 
						tData1, requestInsertToTQueue1, doneInsertToTQueue1, 
						rData1, requestReceivedToRQueue1, doneSavedFromRQueue1, 
						overflowInTQueue1, overflowInRQueue1, 
						iPin, oPin, nCS, sck);

	IPush spiSlaveOut();
	IPush spiSlaveIn();
	ISpiReceiverControl spiReceiverControl();
	ISpi spiBus();

	assign spiBus.master.nCS = nCS;
	assign spiBus.master.mosi = oPin;
	assign spiBus.master.sck = sck;
	assign iPin = spiBus.master.miso;
	
	spiReceiver spiR(rst, clk, 
						  spiSlaveOut.slave, 
						  spiSlaveIn.master, 
						  spiReceiverControl.slave,
						  spiBus.slave);	
				  
	IPush milBusDecoded();
	IServiceProtocolUControl servProtoControl();
	
	
				  
	ServiceProtocolUnpacker serviceUnpacker(rst, clk, 
															spiSlaveIn.slave,
															milBusDecoded.master,
															servProtoControl.slave);
						 
	logic[15:0] debdata [0:5] = '{16'hAB00, 16'h02A1, 16'hEFAB, 16'h0001, 16'h9D4D, 16'h0};
	bit[2:0] cntr = 0;
	
	assign tData1 = debdata[cntr];

	
initial begin
	{clk, ioClk} = '0;
	rst = 1; requestInsertToTQueue1 = 0;
	
#2 rst = 0; 
#2	requestInsertToTQueue1 = 1;
#2 requestInsertToTQueue1 = 0;

end
	
always @ (posedge doneInsertToTQueue1) begin
	if(cntr != 5) begin
		cntr = cntr + 1'b1;
#2		requestInsertToTQueue1 = 1'b1;
#2		requestInsertToTQueue1 = 1'b0;
	end
end
	
always begin
	#1  clk =  ! clk;
end

always
	#8 ioClk = !ioClk;

endmodule


module ServiceProtocolDecoderTest();
	bit rst, clk, ioClk; 
	logic[15:0] tData1, rData1, tData2, rData2;
	logic requestInsertToTQueue1, doneInsertToTQueue1, requestReceivedToRQueue1, doneSavedFromRQueue1, 
			overflowInTQueue1, overflowInRQueue1;
	logic requestInsertToTQueue2, doneInsertToTQueue2, requestReceivedToRQueue2, doneSavedFromRQueue2, 
			overflowInTQueue2, overflowInRQueue2, isBusy;
	logic oPin, iPin, nCS, sck;

	spiMaster spiM(rst, clk, ioClk, 
						tData1, requestInsertToTQueue1, doneInsertToTQueue1, 
						rData1, requestReceivedToRQueue1, doneSavedFromRQueue1, 
						overflowInTQueue1, overflowInRQueue1, 
						iPin, oPin, nCS, sck);

	IPush spiSlaveOut();
	IPush spiSlaveIn();
	ISpiReceiverControl spiReceiverControl();
	ISpi spiBus();

	assign spiBus.master.nCS = nCS;
	assign spiBus.master.mosi = oPin;
	assign spiBus.master.sck = sck;
	assign iPin = spiBus.master.miso;
	
	spiReceiver spiR(rst, clk, 
						  spiSlaveOut.slave, 
						  spiSlaveIn.master, 
						  spiReceiverControl.slave,
						  spiBus.slave);	
				  
	IPush unpackBus();
	IServiceProtocolUControl servUnpackerControl();
				  
	ServiceProtocolUnpacker serviceUnpacker(rst, clk, 
														 spiSlaveIn.slave,
														 unpackBus.master,
														 servUnpackerControl.slave);
															
	IPushMil decodeBus();
	IServiceProtocolDControl servDecoderControl();
	
	ServiceProtocolDecoder serviceDecoder(	rst, clk, 
														unpackBus.slave,
														decodeBus.master,
														servDecoderControl.slave);
	
	assign servDecoderControl.master.cmdCode = servUnpackerControl.master.cmdCode;
	assign servDecoderControl.master.dataWordNum = servUnpackerControl.master.dataWordNum;
	
	
						 
	logic[15:0] debdata [0:5] = '{16'hAB00, 16'h02A1, 16'hEFAB, 16'h0001, 16'h9D4D, 16'h0};
	bit[2:0] cntr = 0;
	
	assign tData1 = debdata[cntr];

	
initial begin
	{clk, ioClk} = '0;
	rst = 1; requestInsertToTQueue1 = 0;
	
#2 rst = 0; 
#2	requestInsertToTQueue1 = 1;
#2 requestInsertToTQueue1 = 0;

end
	
always @ (posedge doneInsertToTQueue1) begin
	if(cntr != 5) begin
		cntr = cntr + 1'b1;
#2		requestInsertToTQueue1 = 1'b1;
#2		requestInsertToTQueue1 = 1'b0;
	end
end
	
always begin
	#1  clk =  ! clk;
end

always
	#8 ioClk = !ioClk;

endmodule

