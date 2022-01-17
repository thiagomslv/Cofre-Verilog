module cofre(controleSistema, clk_27, botaoPassarNumero, botaoPassarDisplay, botaoConfirmar, 
				 display1, display2, display3, display4, aceitoID, falhaID);

input clk_27, botaoPassarNumero, botaoPassarDisplay, botaoConfirmar;
input [3:0]controleSistema;

output reg [6:0]display1, display2, display3, display4;
output reg aceitoID, falhaID;

reg [3:0]estado_atual, estado_anterior;
reg [3:0]displaySelecionado, contadorDisplay1, contadorDisplay2, contadorDisplay3, contadorDisplay4;

reg [2:0]usuariosNoSistema; //conferirId; -> Variavel comentada (substitui por conferir)
reg [3:0]conferir; //Modificado
reg [3:0]usuario1_id1, usuario1_id2, usuario1_id3, usuario1_id4;
reg [3:0]usuario1_sn1, usuario1_sn2, usuario1_sn3, usuario1_sn4; //Modificado
reg [3:0]auxIdConferir1, auxIdConferir2, auxIdConferir3, auxIdConferir4;
reg [3:0]auxSnConferir1, auxSnConferir2, auxSnConferir3, auxSnConferir4; //Modificado

parameter espera = 4'd0, cadastroID = 4'd1, registraID = 4'd2, zerarApagarDisplay = 4'd3,
			 apagarDisplay = 4'd4, cadastroSenha = 4'd5, registraSenha = 4'd6, 
			 digitarIdParaConferir = 4'd7, registrarIdConferir = 4'd8,
			 digitarSenhaParaConferir = 4'd9, registraSenhaConferir = 4'd10, confID = 4'd11; //Modificado

initial begin
	
	estado_atual = 4'b0000;
	estado_anterior = 4'b0000; //Modificado
	usuariosNoSistema = 3'b000;
	displaySelecionado = 4'b0000;
	//conferirId = 3'b000;
	conferir = 4'b0000;
	aceitoID = 1'b0;
	falhaID = 1'b0;
	
	contadorDisplay1 = 3'b000;
	contadorDisplay2 = 3'b000;
	contadorDisplay3 = 3'b000;
	contadorDisplay4 = 3'b000;
	
	display1 = 7'b1111111;
	display2 = 7'b1111111;
	display3 = 7'b1111111;
	display4 = 7'b1111111;
	
	usuario1_id1 = 4'b0000;
	usuario1_id2 = 4'b0000;
	usuario1_id3 = 4'b0000;
	usuario1_id4 = 4'b0000;
	
	auxIdConferir1 = 4'b0000;
	auxIdConferir2 = 4'b0000;
	auxIdConferir3 = 4'b0000;
	auxIdConferir4 = 4'b0000;
	
	usuario1_sn1 = 4'b0000; //Modificado
	usuario1_sn2 = 4'b0000; //Modificado
	usuario1_sn3 = 4'b0000; //Modificado
	usuario1_sn4 = 4'b0000; //Modificado
	
	auxSnConferir1 = 4'b0000; //Modificado
	auxSnConferir2 = 4'b0000; //Modificado
	auxSnConferir3 = 4'b0000; //Modificado
	auxSnConferir4 = 4'b0000; //Modificado
end

/*---------------------------------------------------------*/

function [6:0]segmentosDisplay;

	input [3:0]numeroDoDisplay;
	reg [6:0]segmentosSelecionados;

	begin

		case(numeroDoDisplay)
		
			4'b0000: segmentosSelecionados = 7'b1000000;
			4'b0001: segmentosSelecionados = 7'b1111001;
			4'b0010: segmentosSelecionados = 7'b0100100;
			4'b0011: segmentosSelecionados = 7'b0110000;
			4'b0100: segmentosSelecionados = 7'b0011001;	
			4'b0101: segmentosSelecionados = 7'b0010010;
			4'b0110: segmentosSelecionados = 7'b0000010;
			4'b0111: segmentosSelecionados = 7'b1111000;
			4'b1000: segmentosSelecionados = 7'b0000000;
			4'b1001: segmentosSelecionados = 7'b0010000;
			4'b1111: segmentosSelecionados = 7'b1111111;
		endcase
		
		segmentosDisplay = segmentosSelecionados;
	end
endfunction

/*---------------------------------------------------------*/

always@(negedge clk_27) begin : ctrEstadosMaquina
	
	case(estado_atual) //Modificado
	
		espera: if(controleSistema == 4'b0001) estado_atual <= cadastroID;
		cadastroID: if(controleSistema == 4'b0010) estado_atual <= registraID;
		registraID: if(controleSistema == 4'b0011) begin 
			estado_atual <= zerarApagarDisplay;
			estado_anterior <= registraID; end
		zerarApagarDisplay: if(controleSistema == 4'b0100) estado_atual <= apagarDisplay;
		apagarDisplay: if(controleSistema == 4'b0101) begin
			if(estado_anterior == registraID) estado_atual <= cadastroSenha;
			if(estado_anterior == registraSenha) estado_atual <= digitarIdParaConferir; end
		cadastroSenha: if(controleSistema == 4'b0110) estado_atual <= registraSenha;
		registraSenha: if(controleSistema == 4'b0111) begin
			estado_atual <= zerarApagarDisplay;
			estado_anterior <= registraSenha; end
		digitarIdParaConferir: if(controleSistema == 4'b1000) estado_atual <= registrarIdConferir;
		registrarIdConferir: if(controleSistema == 4'b1001) estado_atual <= confID;
		digitarSenhaParaConferir: if(controleSistema == 4'b1010) estado_atual <= registrarIdConferir;
		registraSenhaConferir: if(controleSistema == 4'b1011) estado_atual <= confID;
		confID: if(controleSistema == 4'b1100) estado_atual <= espera;
	endcase	
end

always@(negedge botaoPassarNumero) begin : ctrDisplay //posedge

	if(estado_atual == cadastroID || estado_atual == digitarIdParaConferir 
	|| estado_atual == cadastroSenha || estado_atual == digitarSenhaParaConferir) begin //Modificado
	
		case(displaySelecionado)
				
			4'b0000: begin
			
				display1 = segmentosDisplay(contadorDisplay1);
				contadorDisplay1 = contadorDisplay1 + 4'b0001;
				if(contadorDisplay1 == 4'b1010) contadorDisplay1 = 4'b0000; //4'b1010
			end
			
			4'b0001: begin

				display2 = segmentosDisplay(contadorDisplay2);
				contadorDisplay2 = contadorDisplay2 + 4'b0001;
				if(contadorDisplay2 == 4'b1010) contadorDisplay2 = 4'b0000; //4'b1010
			end
			
			4'b0010: begin

				display3 = segmentosDisplay(contadorDisplay3);
				contadorDisplay3 = contadorDisplay3 + 4'b0001;
				if(contadorDisplay3 == 4'b1010) contadorDisplay3 = 4'b0000; //4'b1010
			end
			
			4'b0011: begin

				display4 = segmentosDisplay(contadorDisplay4);
				contadorDisplay4 = contadorDisplay4 + 4'b0001;
				if(contadorDisplay4 == 4'b1010) contadorDisplay4 = 4'b0000; //4'b1010
			end
		endcase
	end
	
	if(estado_atual == apagarDisplay) begin
	
		case(displaySelecionado)
			
			4'b0000: begin
				
				contadorDisplay1 = 4'b1111;
				display1 = segmentosDisplay(contadorDisplay1);
				contadorDisplay1 = 4'b0000;
			end
			
			4'b0001: begin
				
				contadorDisplay2 = 4'b1111;
				display2 = segmentosDisplay(contadorDisplay2);
				contadorDisplay2 = 4'b0000;
			end
			
			4'b0010: begin
				
				contadorDisplay3 = 4'b1111;
				display3 = segmentosDisplay(contadorDisplay3);
				contadorDisplay3 = 4'b0000;
			end
			
			4'b0011: begin
				
				contadorDisplay4 = 4'b1111;
				display4 = segmentosDisplay(contadorDisplay4);
				contadorDisplay4 = 4'b0000;
			end
		endcase
	end
end

always@(negedge botaoPassarDisplay) begin : passarDisplay
	
	if(estado_atual == zerarApagarDisplay) displaySelecionado = 4'b0000;
	
	if(estado_atual != cadastroID && estado_atual != apagarDisplay && estado_atual != digitarIdParaConferir
	&& estado_atual != cadastroSenha && estado_atual != digitarSenhaParaConferir) disable passarDisplay; //Modificado
	
	displaySelecionado = displaySelecionado + 4'b0001;
	if(displaySelecionado == 4'b0100) displaySelecionado = 4'b0000; //4'b0010
	
end

always@(negedge botaoConfirmar) begin : confNumeracaoDisplay
	
	if(estado_atual == registraID) begin
	
		case(usuariosNoSistema)
		
			4'b0000: begin
			
				usuario1_id1 = contadorDisplay1;
				usuario1_id2 = contadorDisplay2;
				usuario1_id3 = contadorDisplay3;
				usuario1_id4 = contadorDisplay4;
			end
		endcase
		
		//usuariosNoSistema = usuariosNoSistema + 3'b001;
	end
	
	if(estado_atual == registraSenha) begin
	
		case(usuariosNoSistema)
		
			4'b0000: begin
			
				usuario1_sn1 = contadorDisplay1;
				usuario1_sn2 = contadorDisplay2;
				usuario1_sn3 = contadorDisplay3;
				usuario1_sn4 = contadorDisplay4;
			end
		endcase
		
		usuariosNoSistema = usuariosNoSistema + 3'b001;
	end //Modificado
	
	if(estado_atual == registrarIdConferir) begin
	
		auxIdConferir1 = contadorDisplay1;
		auxIdConferir2 = contadorDisplay2;
		auxIdConferir3 = contadorDisplay3;
		auxIdConferir4 = contadorDisplay4;
	end
	
	if(estado_atual == registraSenhaConferir) begin
	
		auxSnConferir1 = contadorDisplay1;
		auxSnConferir2 = contadorDisplay2;
		auxSnConferir3 = contadorDisplay3;
		auxSnConferir4 = contadorDisplay4;
	end
	
	if(estado_atual == confID) begin
	
		if(usuario1_id1 == auxIdConferir1) conferir = conferir + 3'b001;
		if(usuario1_id2 == auxIdConferir2) conferir = conferir + 3'b001;
		if(usuario1_id3 == auxIdConferir3) conferir = conferir + 3'b001;
		if(usuario1_id4 == auxIdConferir4) conferir = conferir + 3'b001;
		
		if(usuario1_sn1 == auxSnConferir1) conferir = conferir + 3'b001;
		if(usuario1_sn2 == auxSnConferir2) conferir = conferir + 3'b001;
		if(usuario1_sn3 == auxSnConferir3) conferir = conferir + 3'b001;
		if(usuario1_sn4 == auxSnConferir4) conferir = conferir + 3'b001;
		
		if(conferir == 4'b1000) begin
	
			aceitoID = 1'b1;
			falhaID = 1'b0;
		end else begin
		
			aceitoID = 1'b0;
			falhaID = 1'b1;
		end
		
		auxIdConferir1 = 4'b0000;
		auxIdConferir2 = 4'b0000;
		auxIdConferir3 = 4'b0000; //Modificado
		auxIdConferir4 = 4'b0000; //Modificado
		auxSnConferir1 = 4'b0000; //Modificado
		auxSnConferir2 = 4'b0000; //Modificado
		auxSnConferir3 = 4'b0000; //Modificado
		auxSnConferir4 = 4'b0000; //Modificado
	end
	
	if(estado_atual == espera) begin
	
		aceitoID = 1'b0;
		falhaID = 1'b0;
	end
	
end

endmodule