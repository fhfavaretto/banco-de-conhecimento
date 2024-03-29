#INCLUDE "FileIO.CH"
#INCLUDE "PROTHEUS.CH"                                              
#INCLUDE "fwschedule.ch"
#INCLUDE "CTBXLOG.CH"
    
STATIC __cIdCV8   	:= ""
STATIC __SubProc	:= ""
STATIC __BatchProc	:= ""
STATIC __lLogCTB			
STATIC __MvConOutR
STATIC __PEConOutR
STATIC aTxt	

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBShowFLG�Autor  �Marcos S. Lobo      � Data �  01/28/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTBShowFLG(cArqTRB)

Local aAreaTRB	:= GetArea()
Local aCampos	:= {}
Local aRotOri	:= aClone(aRotina)

DEFAULT cArqTRB	:= "LOGCTB"+cEmpAnt+".FLG"

If Select("TRBFLAG") <= 0
	If !File(cArqTRB)
		MsgInfo(STR0001+cArqTRB+STR0002)//"Arquivo de log "#" nao encontrado ou vazio."
		RestArea(aAreaTRB)
		Return
	Else
		dbUseArea(.T.,,cArqTRB,"TRBFLAG",.T.,.F.)		
		If Select("TRBFLAG") <= 0
			MsgInfo(STR0003+cArqTRB+STR0004)//"Nao foi possivel abrir log "#"com flags remarcados."
			RestArea(aAreaTRB)
			Return
		EndIf		
	EndIf
	//NAO FECHAR ALIAS DURANTE GRAVA��O///// TRBFLAG->(DbCloseArea())
Endif

dbSelectArea("TRBFLAG")

//P/ BROWSE	   //CAMPO		//PICTURE	//TITULO		//TAMANHO
aadd(aCampos ,{"TIPOREG" 	,"9"				,STR0005	,01}) //"Tipo Reg."
aadd(aCampos ,{"USUARIO" 	,"" 				,STR0006	,10}) //"Usuario"
aadd(aCampos ,{"DATAEXC" 	,"99/99/99" 		,STR0007	,10}) //"Data Exc."
aadd(aCampos ,{"HORAEXC" 	,""					,STR0008	,10}) //"Hora Exc."
aadd(aCampos ,{"CV3_TABORI"	,""					,STR0009	,03}) //"Tab.Origem"
aadd(aCampos ,{"CV3_RECORI" ,"99999999999999999",STR0010	,17}) //"Reg.Origem"
aadd(aCampos ,{"CT2_FILIAL" ,""					,STR0011	,02}) //"Filial"
aadd(aCampos ,{"CT2_DATA"	,"99/99/99"			,STR0012	,10}) //"Data Lcto."
aadd(aCampos ,{"CT2_LOTE" 	,""					,STR0013	,06}) //"Lote"
aadd(aCampos ,{"CT2_SBLOTE" ,""					,STR0014	,03}) //"Sub-Lote"
aadd(aCampos ,{"CT2_DOC" 	,""					,STR0015	,06}) //"Documento"	
aadd(aCampos ,{"CT2_LINHA"	,""					,STR0016	,03}) //"Linha"	
aadd(aCampos ,{"CV3_LP" 	,""					,STR0017	,03}) //"Lanc.Pad."
aadd(aCampos ,{"CV3_LPSEQ"  ,""					,STR0018	,03}) //"Seq.LP."
aadd(aCampos ,{"CT2_VALOR"  ,"99,999,999,999.99",STR0019	,20}) //"Valor.Lancto."     
aadd(aCampos ,{"CV3_VALOR"  ,"99,999,999,999.99",STR0020	,20}) //"Valor Rastro"
aadd(aCampos ,{"CT2_HIST"	,""					,STR0021	,40}) //"Historico"	
aadd(aCampos ,{"CT2_RECNO"	,"99999999999999999",STR0022	,17}) //"Reg.Lancto."
aadd(aCampos ,{"CV3_RECNO"	,"99999999999999999",STR0023	,17}) //"Reg.Rastro"

aRotina :=	{	{ STR0024	, "LogVisOri", 0, 1 },;	//"Ver Origem"
				{ STR0025	, "LogVisCV3", 0, 2 },; //"Ver Rastro"
				{ STR0026	, "LogVisCT2", 0, 3 },; //"Ver Lancto"
				{ STR0027	, "LogVisLeg", 0, 4 } }	//"Imprimir Log"
				
//MsgInfo("Veja o arquivo: "+cArqTRB+" ! no diretorio: "+GetSrvProfString("Startpath",""), "Log Gerado.")
//MaWndBrowse(nLin1,nCol1,nLin2,nCol2,cTitle									  ,uAlias	 ,aCampos,aRotina,cFun,cTopFun,cBotFun,lCentered,aResource,nModelo,aPesqui,cSeek,lDic,lSavOrd,lParPad,lPesq,bViewReg,oBrowse)
MaWndBrowse(0	   ,0	 ,400	,600 ,STR0028+" - "+cArqTRB,"TRBFLAG",aCampos ,aRotina,    , 	  , 	  ,.T.		,		  ,  	  ,    	  ,	 	,.F. ,		 ,.F.  	,.F.   ,		,)//"Log de Limpeza de Flags de Contabiliza��o"

aRotina := aClone(aRotOri)
RestArea(aAreaTRB)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LogVisOri �Autor  �Marcos S. Lobo      � Data �  01/28/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Visualiza��o do registro de origem a partir do Browse do LOG���
���          �arquivo .FLG                   	                          ���
�������������������������������������������������������������������������͹��
���Uso       � AP - 						                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LogVisOri()

Local aAreaVis := GetArea()
Local nRecOri
Local cCadOri	:= cCadastro

If Empty(TRBFLAG->CV3_TABORI) .or. Empty(TRBFLAG->CV3_RECORI)
	Return
EndIf

nRecOri := int(val(TRBFLAG->CV3_RECORI))

dbSelectArea(TRBFLAG->CV3_TABORI)
dbGoTo(nRecOri)
If (TRBFLAG->CV3_TABORI)->(Eof()) .or. (TRBFLAG->CV3_TABORI)->(Recno()) <> nRecOri
	RestArea(aAreaVis)
	Return
EndIf
dbSetOrder(1)

dbSelectArea("SX2")
dbSeek(TRBFLAG->CV3_TABORI)
#IFDEF ENGLISH
	cCadastro := SX2->X2_NOMEENG
	cCadastro := alltrim(cCadastro)+" - Record "+TRBFLAG->CV3_RECORI
#ELSE
	#IFDEF SPANISH
		cCadastro := SX2->X2_NOMESPA
		cCadastro := alltrim(cCadastro)+" - Registro "+TRBFLAG->CV3_RECORI
	#ELSE
		cCadastro := SX2->X2_NOME	
		cCadastro := alltrim(cCadastro)+" - Registro "+TRBFLAG->CV3_RECORI
	#ENDIF
#ENDIF

dbSelectArea(TRBFLAG->CV3_TABORI)
AxVisual(Alias(),(TRBFLAG->CV3_TABORI)->(Recno()),2)

cCadastro := cCadOri
RestArea(aAreaVis)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBXFUN   �Autor  �Microsiga           � Data �  01/29/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LogVisCV3

Local aAreaVis := GetArea()
Local nRecOri
Local cCadOri	:= cCadastro

If Empty(TRBFLAG->CV3_RECNO) 
	Return
EndIf

nRecOri := int(val(TRBFLAG->CV3_RECNO))

dbSelectArea("CV3")
dbGoTo(nRecOri)
If CV3->(Eof()) .or. CV3->(Recno()) <> nRecOri
	RestArea(aAreaVis)
	Return
EndIf
dbSetOrder(1)

dbSelectArea("SX2")
dbSeek("CV3")
#IFDEF ENGLISH
	cCadastro := SX2->X2_NOMEENG
	cCadastro := alltrim(cCadastro)+" - Record "+TRBFLAG->CV3_RECNO
#ELSE
	#IFDEF SPANISH
		cCadastro := SX2->X2_NOMESPA
		cCadastro := alltrim(cCadastro)+" - Registro "+TRBFLAG->CV3_RECNO
	#ELSE
		cCadastro := SX2->X2_NOME	
		cCadastro := alltrim(cCadastro)+" - Registro "+TRBFLAG->CV3_RECNO
	#ENDIF
#ENDIF

dbSelectArea("CV3")
AxVisual("CV3",CV3->(Recno()),2)

cCadastro := cCadOri
RestArea(aAreaVis)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LogVisCT2 �Autor  �Marcos S. Lobo      � Data �  01/28/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Visualiza��o do registro de LANCTO a partir do Browse do LOG���
���          �arquivo .FLG                   	                          ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LogVisCT2()

Local aAreaVis := GetArea()
Local nRecCT2
Local cCadOri	:= cCadastro

nRecCT2 := int(val(TRBFLAG->CT2_RECNO))

dbSelectArea("CT2")
dbGoTo(nRecCT2)
If CT2->(Eof()) .or. CT2->(Recno()) <> nRecCT2
	RestArea(aAreaVis)
	Return
EndIf
dbSetOrder(1)

dbSelectArea("SX2")
dbSeek("CT2")
#IFDEF ENGLISH
	cCadastro := SX2->X2_NOMEENG
	cCadastro := alltrim(cCadastro) + " - Record " + TRBFLAG->CT2_RECNO
#ELSE
	#IFDEF SPANISH
		cCadastro := SX2->X2_NOMESPA
		cCadastro := alltrim(cCadastro) + " - Registro " + TRBFLAG->CT2_RECNO
	#ELSE
		cCadastro := SX2->X2_NOME	
		cCadastro := alltrim(cCadastro) + " - Registro " + TRBFLAG->CT2_RECNO
	#ENDIF
#ENDIF

dbSelectArea("CT2")
If CT2->(Deleted())
	cCadastro += " j� exclu�do."
EndIf

AxVisual("CT2",Recno(),2)

cCadastro := cCadOri
RestArea(aAreaVis)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBXFUN   �Autor  �Microsiga           � Data �  01/29/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LogVisLeg

Aviso(	STR0029+" - "+STR0030,;  		//"Tipos de registro"#"Log de Limpeza de Flags de Contabiliza��o"
					STR0031+CRLF+;		//"0 = Log - Exclusao Lan�amento efetuada, remarcacao flags OK"
					STR0032+CRLF+;		//"1 = Erro - Tabela ou Registro de origem no rastreamento em branco."
					STR0033+CRLF+;		//"2 = Erro - Registro n�o encontrado na tabela de origem."
					STR0034+CRLF+;		//"3 = Erro - Registro n�o encontrado na tabela rastreamento (CV3)."
					STR0035+CRLF+;		//"4 = Log - Exclusao Documento, usuario optou por n�o remarcar flags."
					STR0036,{},3,"")	//"5 = Log - Excluso de Linha Lancamento, usuario optou por n�o remarcar flags."

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �BatchLog� Autor � Edson Maricate          � Data � 31.01.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria uma FormBatch com utilizacao de Log.                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � BatchLog(cTitle,aSays,aButtons,bValid,nAltura,nLargura)    ���
�������������������������������������������������������������������������Ĵ��
���Par�metros� cTitle = Titulo da janela											  ���
���			 � aSays  = Array com Says 											  ���
���			 � aButtons = Array com bottoes										  ���
���			 � aButtons[i,1] = Tipo de botao 									  ���
���			 � aButtons[i,2] = Tipo de enabled									  ���
���			 � aButtons[i,3] = bAction 											  ���
���			 � bValid = Bloco de validacao do Form 							  ���
���			 � nAltura= Altura do Form em Pixel (Default 250)				  ���
���			 � nLargura = Largura do Form em Pixel (Default 520)			  ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ProcLogIni( aButtons,cProcess,cSubProcess,cIdCV8)
Local aAreaAnt := GetArea()
Default cProcess := ProcName(1)
Default cSubProcess  := ""
Default aButtons     := {}

If Empty(__BatchProc)
	__BatchProc := cProcess
Else
	__SubProc := cProcess
EndIf

If !Empty(cProcess)
	__BatchProc := cProcess 
EndIf

If !Empty(cSubProcess)
	__SubProc := cSubProcess 
EndIf

If CV8->(FieldPos("CV8_IDMOV")) > 0 .And. !Empty(CV8->(IndexKey(5))) 
	__cIdCV8:= GetSXENum("CV8","CV8_IDMOV",,5)	
	cIdCV8 	:= __cIdCV8
	ConfirmSX8()
EndIf



aadd(aButtons, { 15,.T.,{|| ProcLogView()  } } )

RestArea(aAreaAnt)
Return 


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �BatchLog� Autor � Edson Maricate          � Data � 31.01.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria uma FormBatch com utilizacao de Log.                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � BatchLog(cTitle,aSays,aButtons,bValid,nAltura,nLargura)    ���
�������������������������������������������������������������������������Ĵ��
���Par�metros� cTitle = Titulo da janela											  ���
���			 � aSays  = Array com Says 											  ���
���			 � aButtons = Array com bottoes										  ���
���			 � aButtons[i,1] = Tipo de botao 									  ���
���			 � aButtons[i,2] = Tipo de enabled									  ���
���			 � aButtons[i,3] = bAction 											  ���
���			 � bValid = Bloco de validacao do Form 							  ���
���			 � nAltura= Altura do Form em Pixel (Default 250)				  ���
���			 � nLargura = Largura do Form em Pixel (Default 520)			  ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ProcLogView(cFilProc,cProc,cSubProc,cIdCV8)
Local aAreaAnt  := GetArea()
Local cFilterIni:= ""
Local cFilterFin:= ""   
Local cChave	:= "" 

Private aRotina 	:= {}
Default cProc 		:= __BatchProc  
Default cSubProc 	:= ""
Default cFilProc 	:= cFilAnt

If Type("cCadastro") != "C"
	cCadastro := ""
EndIf


__BatchProc := cProc

aRotina := MenuDef()

//Criado parametro para filtro
dbSelectArea("CV8")

If !Empty(cIdCV8) .And. CV8->(FieldPos("CV8_IDMOV")) > 0
	dbSetOrder(5) //CV8_FILIAL+CV8_IDMOV
	cFilterIni := 'xFilial("CV8","'+cFilProc+'")+"'+cIdCV8+'"'
	cFilterFin := 'xFilial("CV8","'+cFilProc+'")+"'+cIdCV8+'"'
	cChave := xFilial("CV8")+cIdCV8
ElseIf !Empty(cSubProc) .And. CV8->(FieldPos("CV8_SBPROC")) > 0
	dbSetOrder(4) //CV8_FILIAL+CV8_PROC+CV8_SBPROC+CV8_USER+DTOS(CV8_DATA)+CV8_HORA
	cProc := Padr( cProc,TamSx3("CV8_PROC")[1])
	cFilterIni := 'xFilial("CV8","'+cFilProc+'")+"'+cProc+cSubProc+'"'
	cFilterFin := 'xFilial("CV8","'+cFilProc+'")+"'+cProc+cSubProc+'"' 
	cChave := xFilial("CV8")+cProc+cSubProc
Else
	dbSetOrder(1) //CV8_FILIAL+CV8_PROC+DTOS(CV8_DATA)+CV8_HORA
	cProc := Padr( cProc,TamSx3("CV8_PROC")[1])
	cFilterIni :='xFilial("CV8")+"'+cProc+'"'
	cFilterFin :='xFilial("CV8")+"'+cProc+'zzzzzzzzzzz"'                    
	cChave := xFilial("CV8")+cProc
EndIf 

MaWndBrowse(0,0,500,780,STR0037+" - "+cCadastro,"CV8",,aRotina,"CV8->CV8_INFO=='4'",;
cFilterIni,;
cFilterFin,;
.T.,{{"OK",STR0038},{"CANCEL",STR0039}},2,{{STR0040,1},{STR0041,2}}, cChave ,,,,,,,,,,,,,,,, ".F." )  //"Avisos"##"Erro de processamento"##"Data+Hora"##"Usuario+Data+Hora"

RestArea(aAreaAnt)
Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �ProcLogDet� Autor � Renato / Davi		    � Data � 14.11.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe o detalhamento dos logs 			                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ProcLogDet()												  ���
�������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ProcLogDet()
Local aAreaAnt  := GetArea()
Local aRotina   := {}

dbSelectArea( "CV8" )

nRecno := CV8->( Recno() )

dbSetOrder(1)
If DbSeek( xFilial( 'CV8' ) + ALLTRIM( __BatchProc ) )
	aRotina := {{ STR0042,"AxVisual", Recno() , 2}}  //"Detalhes"
ENDIF


CV8->( DBGOTO( nRecno ) )

RestArea(aAreaAnt)
RETURN  aRotina


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �BatchLog� Autor � Edson Maricate          � Data � 31.01.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria uma FormBatch com utilizacao de Log.                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � BatchLog(cTitle,aSays,aButtons,bValid,nAltura,nLargura)    ���
�������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ProcLogAtu(cType,cMsg,cDetalhes,cBatchProc,lCabec)
Local nx
Local aAreaAnt		:= GetArea()
Local cMsgSubProc	:= ""

Default cDetalhes   := ""
Default cMsg		:= ""
Default cType		:= "INICIO"
Default lCabec		:= Nil

If  cBatchProc <> Nil
	__BatchProc  := cBatchProc
Endif

If !Empty(__BatchProc)
	Do Case
		Case cType == "INICIO" // Inicio do Processamento
			cMsg := STR0043+cMsg    //"Processamento iniciado. "
			cType := "1"
   		For nx := 1 to 30
				If Type('mv_par'+StrZero(nx,2)) <> "U"
					If !Empty(ToXlsFormat(&('mv_par'+StrZero(nx,2))))
						cDetalhes += STR0044+StrZero(nx,2)+" : "+ToXlsFormat(&('mv_par'+StrZero(nx,2)))+CHR(13)+CHR(10)   //"Parametro "
					EndIf
				EndIf
			Next
		Case cType == "FIM" // Final do Processamento
			cMsg := STR0045+cMsg  //"Processamento encerrado. "
			cType := "2"
		Case cType == "ALERTA" // Alerta
			cMsg := STR0046+cMsg  //"Alerta! "
			cType := "3"
		Case cType == "ERRO" // Erro 
			cMsg := STR0047+cMsg  //"Erro de Processamento. "
			cType := "4"
		Case cType == "CANCEL" // Cancelado pelo usuario
			cMsg := STR0048+cMsg  //"Processamento cancelado pelo usuario. "
			cType := "5"
		Case cType == "MENSAGEM" // Mensagem
			cMsg := STR0049+cMsg  //"Mensagem : "
			cType := "6"
	EndCase	

	cMsgSubProc	:= cMsg+STR0050+__BatchProc 								//" Executado por :"
	cMsg		:= If(!Empty(__SubProc),STR0051+__SubProc+" - ","")+cMsg	//"Sub-Processo : "

	GravaCV8(cType, __BatchProc, cMsg, cDetalhes, __SubProc, cMsgSubProc, lCabec, __cIdCV8)

	If cType == "2" // Final do Processamento
		__BatchProc := ""
		__SubProc	:= ""
	EndIf

EndIf	

RestArea(aAreaAnt)
Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �06/12/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()                  
		Local aRotina := ProcLogDet()
Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBXFUNA  �Autor  �Marcos S. Lobo      � Data �  01/17/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Log de processamento com impressao em relatorio.            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ConOutR(cTexto,lFim,cProcesso)

If __MvConOutR == Nil
	__MvConOutR := GetNewPar("MV_CONOUTR",0)
EndIf

DEFAULT cTexto		:= ""
DEFAULT lFim		:= .F.
DEFAULT cProcesso	:= "CTBA105"

If __lLogCTB == Nil
	__lLogCTB := If(__MvConOutR >= 1,.T.,.F.)
EndIf

If !__lLogCTB
	Return
EndIf

cTxtLog := cProcesso+"|"+cUserName+"|"+STR(THREADID())+"|"+Dtoc(Date())+"|"+Time()+"|"+ALLTRIM(STR(SECONDS()))+"|"
cTxtLog += cTexto

If __MvConOutR >= 2
	CONOUT(cTxtLog)
EndIf

If __PEConOutR == Nil
	__PEConOutR := ExistBlock("CONOUTR")
EndIf
If __PEConOutR
	ExecBlock("CONOUTR",.F.,.F.)
EndIf

If ValType(aTxt) == "U"
	aTxt := {}
Endif

aAdd(aTxt,cTxtLog)

If !lFim .or. IsBlind() .or. __MvConOutR >= 3
	Return
EndIf

If !MsgYesNo(STR0052+cProcesso+" ?","MV_CONOUTR "+STR0053)//"Imprime Log do processo "//"TraceLog de Processamento"
	If MsgYesNo(STR0054+STR0055+" MV_CONOUTR."+CRLF+STR0056,STR0053)//"Importante, o uso de Trace/Log de processo pode interferir na performance do sistema."//" Avalie com o Administrador a configura��o do Log atrav�s do par�metro
																	//"Cancelar a execu��o deste Log ?"//"TraceLog de Processamento"
		__lLogCTB := .F.
	EndIf
	Return
EndIf

CtRConOut(aTxt)

aTxt := {}

If MsgYesNo(STR0054+STR0055+" MV_CONOUTR."+CRLF+STR0056,STR0053)//"Importante, o uso de Trace/Log de processo pode interferir na performance do sistema."//" Avalie com o Administrador a configura��o do Log atrav�s do par�metro
																	//"Cancelar a execu��o deste Log ?"//"TraceLog de Processamento"
	__lLogCTB := .F.
EndIf

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBXFUNA  �Autor  �Microsiga           � Data �  01/17/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CtRConOut(aTxt)
Local cPict          := ""
Local imprime        := .T.

Private cDesc1       := STR0058 //"Este programa tem como objetivo imprimir relatorio "
Private cDesc2       := STR0059 //"com o Trace/Log de Processamento."
Private cDesc3       := STR0053 //"Trace/Log Processamento"
Private titulo       := STR0053 //"Trace/Log Processamento"
Private nLin         := 80

Private Cabec1       := "Trace/Log Processamento"
Private Cabec2       := ""
Private aOrd         := {}
Private lEnd         := .F.
Private limite       := 220
Private tamanho      := "M"
Private nomeprog     := "CTBXFUN" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 10
Private aReturn      := { "Zebrado", 1, STR0061, 2, 2, 1, "", 1}///"Administracao"
Private nLastKey     := 0
Private cPerg        := "CONOUTR"
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 1
Private wnrel        := "CONOUTR"//+ALLTRIM(cUserName)//Coloque aqui o nome do arquivo usado para impressao em disco
Private nOrdem       := 1
Private cString      := "CT1"

dbSelectArea( "CT1" )

//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������
wnrel := SetPrint(cString,wnrel,,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

  SetDefault( aReturn , cString ,,,"M" , 2 ) 

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,10,15)


//���������������������������������������������������������������������Ŀ
//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
//�����������������������������������������������������������������������
RptStatus({|lEnd| RunCtROut(lEnd,WnRel,cString,nOrdem,aTxt)},Titulo)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RunCtROut � Autor � AP6 IDE            � Data �  17/01/07   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function RunCtROut(lEnd,WnRel,cString,nOrdem,aTxt)

Local nTxt

dbSelectArea(cString)
dbSetOrder(1)
SetRegua(RecCount())

Pergunte("CTRFCONT", .F.)

For nTxt := 1 to Len(aTxt)

   //���������������������������������������������������������������������Ŀ
   //� Verifica o cancelamento pelo usuario...                             �
   //�����������������������������������������������������������������������

	If lEnd
      @nLin,00 PSAY STR0060  //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //���������������������������������������������������������������������Ŀ
   //� Impressao do cabecalho do relatorio. . .                            �
   //�����������������������������������������������������������������������
	If nLin > 59 // Salto de P�gina. Neste caso o formulario tem 59 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif

    @nLin,00 PSAY aTxt[nTxt]

   nLin := nLin + 1 // Avanca a linha de impressao
Next
              
//���������������������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                                 �
//�����������������������������������������������������������������������

SET DEVICE TO SCREEN

//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return
