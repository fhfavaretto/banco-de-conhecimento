User Function TSTCTBCUS()

	Local c_User		:= RetCodUsr()				//C�digo do Usu�rio logado
	Local c_NUser		:= UsrFullName( c_User )	//Nome do usu�rio logado
	Local c_Arquivo 	:= "SC7"					//Alias em execu��o
	Local n_Total   	:= 0						//Totaliza contabiliza��o
	Local l_Digita  	:= .T.						//Abre tela de contabiliza��o
	Local l_Aglutina	:= .F.						//Aglutina ou n�o o lan�amento
	Local c_Lote		:= "8840"					//Lote Cont�bil
	Local c_Padrao		:= "001" 					//Lan�amento padr�o customizado

	//Fun��o respons�vel por montar o cabe�alho da tela de contabiliza��o
	Local n_HdlPrv	:= HeadProva( c_Lote, "MATA097", Alltrim(c_NUser), @c_Arquivo )

	DbSelectArea("SC7")
	ProcRegua( RecCount() )

	SC7->(DbGoTop())
	Do While SC7->(!Eof())

		IncProc("Gerando Lan�amento Cont�bil...")

		//Fun��o respons�vel por detalhar (itens) os lan�amentos cont�beis
		n_Total += DetProva( n_HdlPrv, c_Padrao, "MATA097", c_Lote )

		SC7->(DbSkip())

	EndDo

	//Finaliza os totais da contabiliza��o
	RodaProva( n_HdlPrv, n_Total )

	//Fun��o respons�vel por gravar a contabiliza��o
	cA100Incl( c_Arquivo, n_HdlPrv, 3, c_Lote, l_Digita, l_Aglutina )

Return