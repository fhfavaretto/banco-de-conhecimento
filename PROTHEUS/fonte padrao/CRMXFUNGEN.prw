#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRMXFUN.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "CRMDEF.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWTABLEATTACH.CH"
#INCLUDE "FWCALENDARWIDGET.CH"

Static lFixSXB 		:= .F.
Static lCallGFSXB	:= .F.	

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXEnvMail 

Funcao generica para envio de e-mail utilizando as configuracoes de E-mail/Proxy
especificados atraves do Configurador.

@sample   CRMXEnvMail(cFrom, cTo, cCc, cBcc, cSubject, cBody, cAlias, cCodEnt, lAuto, cUserAut, cPassAut)

@param	  ExpC1 - Rementente
		  ExpC2 - Destinatario
		  ExpC3 - Copia
		  ExpC4 - Copia Oculta
		  ExpC5 - Assunto
		  ExpC6 - Mensagem / Texto
		  ExpC7 - Alias da Entidade que possuie Anexo 
		  ExpC8 - Codigo da entidade(Chave unica de relacionamento na AC9, para buscar o Registro que possue anexo).    
		  ExpL9 - Indica se a chamada � automatica, se for n�o mostra a telas de aviso.
		  ExpC10 - Usuario para Autenticacao SMTP.
		  ExpC11 - Senha para Autentica SMTP.

@return  lRet

@author  Thiago Tavares 
@since	  19/05/2013
@version 11.90
/*/
//------------------------------------------------------------------------------
Function CRMXEnvMail(cFrom, cTo, cCc, cBcc, cSubject, cBody, cAlias, cCodEnt, lAuto, cUserAut, cPassAut)

Local aArea      		:= GetArea()
Local oMailServer		:= Nil
Local lRetorno   		:= .F.
Local nSMTPPort  		:= SuperGetMV("MV_PORSMTP",.F.,25)  				// Porta SMTP.
Local cSMTPAddr  		:= AllTrim( SuperGetMV("MV_RELSERV",.F.,"") ) 	// Endereco SMTP.
Local cUser      		:= AllTrim( SuperGetMV("MV_RELACNT",.F.,"") )		// Conta a ser utilizada no envio de E-Mail para os relatorios.
Local cPass      		:= SuperGetMV("MV_RELPSW" ,.F.,"") 			 	// Senha da Conta de E-Mail para envio de relatorios. 
Local lAutentica		:= SuperGetMV("MV_RELAUTH",.F.,.F.) 				// Servidor de EMAIL necessita de Autenticacao? 
Local nSMTPTime			:= SuperGetMV("MV_RELTIME",.F.,120) 				// Timeout no Envio de EMAIL.
Local lSSL       		:= SuperGetMV("MV_RELSSL",.F.,.F.)  				// Define se o envio e recebimento de e-mails na rotina SPED utilizara conexao segura (SSL).  
Local lTLS       		:= SuperGetMV("MV_RELTLS",.F.,.F.)  				// Informe se o servidor de SMTP possui conexao do tipo segura ( SSL/TLS ).
Local nError     		:= 0  									 				// Controle de Erro.
Local nPortAddSrv		:= 0

Default cFrom     	:= AllTrim( SuperGetMV("MV_RELACNT",.F.,"") )		// E-mail utilizado no campo FROM no envio de relatorios por e-mail 
Default cTo       	:= ""
Default cCc       	:= ""
Default cBcc      	:= ""
Default cSubject  	:= ""
Default cBody     	:= ""
Default cAlias    	:= ""
Default cCodEnt   	:= ""
Default cUserAut	:= ""  // Usuario para Autenticacao no Servidor de E-mail    
Default cPassAut	:= ""  // Senha para autenticac�o no servidor de E-mail           

Default lAuto     := .F.

/*
 Se autenticacao estiver ligada priorizar os parametros da fun��o.
 Senao considerar do configurador.
*/
If lAutentica 
	If Empty( cUserAut ) 
		cFrom 	  := AllTrim( SuperGetMV("MV_RELACNT",.F.,"") )
		cUserAut := SuperGetMV("MV_RELAUSR",.F.,"") 
		cPassAut := SuperGetMV("MV_RELAPSW",.F.,"") 
	EndIf
	cUserAut := AllTrim( cUserAut )
	cUser 	  := cUserAut
	cPass 	  := cPassAut 
EndIf	

oMailServer := TMailManager():New()

// Usa SSL, TLS ou nenhum na inicializacao
If lSSL
	oMailServer:SetUseSSL(lSSL)
ElseIf lTLS
	oMailServer:SetUseTLS(lTLS)
Endif

// Inicializacao do objeto de Email
If nError == 0
	//Prioriza se a porta est� no endere�o
	nPortAddSrv := AT(":",cSMTPAddr)
	
	If nPortAddSrv > 0
		nSMTPPort := Val(Substr(cSMTPAddr, nPortAddSrv + 1,Len(cSMTPAddr)))
		cSMTPAddr := Substr(cSMTPAddr, 0, nPortAddSrv - 1)
	EndIf
	
	nError := oMailServer:Init("",cSMTPAddr,cUser,cPass,,nSMTPPort)
	If nError <> 0
		Conout(STR0013+ oMailServer:GetErrorString(nError)) // Falha ao conectar:"
	EndIf
Endif

// Define o Timeout SMTP
If ( nError == 0 .And. oMailServer:SetSMTPTimeout(nSMTPTime) <> 0 )
	nError := 1
	Conout(STR0014) // Falha ao definir timeout
EndIf

// Conecta ao servidor
If nError == 0
	nError := oMailServer:SmtpConnect()
	If nError <> 0
		Conout(STR0013 + oMailServer:GetErrorString(nError)) // Falha ao conectar:
		oMailServer:SMTPDisconnect()
	EndIf
EndIf

// Realiza autenticacao no servidor
If nError == 0 .And. lAutentica
	nError	:= oMailServer:SmtpAuth(cUserAut,cPassAut)
	If nError <> 0
		Conout(STR0015+ oMailServer:GetErrorString(nError)) // Falha ao autenticar:
		oMailServer:SMTPDisconnect()
	EndIf
EndIf

If nError == 0
	
	oMessage:= TMailMessage():New()
	oMessage:Clear()
	oMessage:cFrom    := cFrom
	oMessage:cTo      := cTo
	oMessage:cCc      := cCc
	oMessage:cBcc     := cBcc
	oMessage:cSubject := cSubject
	oMessage:cBody    := cBody
	
	If !Empty(cAlias) .And. !Empty(cCodEnt)  // verificando se existe Anexos, se existir anexar ao email
		BeginSql Alias "TMPALIAS"
			SELECT
			ACB.ACB_OBJETO
			FROM
			%Table:AC9% AC9 INNER JOIN %Table:ACB% ACB ON (ACB.ACB_CODOBJ = AC9_CODOBJ)
			WHERE
			AC9.AC9_FILIAL = %xFilial:AC9%          AND
			AC9.AC9_ENTIDA = %Exp:cAlias%           AND
			AC9.AC9_FILENT = %Exp:xFilial(cAlias)%  AND
			AC9.AC9_CODENT = %Exp:cCodEnt%          AND
			AC9.%NotDel%
		EndSql
		
		While TMPALIAS->(!Eof())
			oMessage:AttachFile(MsDocPath()+"\"+AllTrim(TMPALIAS->ACB_OBJETO))
			TMPALIAS->(DbSkip())
		EndDo
		
		TMPALIAS->(DbCloseArea())
	EndIf
	
	nError := oMessage:Send( oMailServer )
	
	If nError <> 0
		If !lAuto
			MsgAlert(STR0002 + oMailServer:GetErrorString(nError),STR0004)//"Falha no envio do Email - "   #Atencao
		Else
			Conout(STR0002 + oMailServer:GetErrorString(nError))
		EndIf
	Else
		lRetorno := .T.
		If !lAuto .And. !IsInCallStack("CRMA180")
			MsgAlert(STR0003,STR0004)//"Email enviado com sucesso."#Atencao
		Else
			Conout(STR0003)
		EndIf
	EndIf
	
	oMailServer:SmtpDisconnect()
	
EndIf

RestArea(aArea)

Return(lRetorno)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXRetVend

Retorna o codigo do vendedor do usu�rio logado no CRM.

@sample 	CRMXRetVend()

@param		Nenhum 

@Return   	ExpC - Codigo do vendedor 

@author		Thiago Tavares
@since		24/03/2014
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMXRetVend(cCodUsr) 

Local aArea	 	:= GetArea()
Local aAreaAO3	:= AO3->(GetArea()) 
Local cCodVend	:= ""
Local lPosVend	:= .T.

Default cCodUsr  := RetCodUsr() 

DbSelectArea("AO3")	// Usu�rios do CRM
DbSetOrder(1)      	// AO3_FILIAL + AO3_CODUSR 

If ( !Empty(cCodUsr) .AND. (AO3->AO3_CODUSR <> cCodUsr) )
	lPosVend := AO3->(DbSeek(xFilial("AO3")+cCodUsr))	  
EndIf  

If !Empty(cCodUsr) .AND. lPosVend 
	cCodVend := AO3->AO3_VEND
EndIf	            

RestArea(aAreaAO3)
RestArea(aArea) 

Return(cCodVend)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXIntVend

Inicializa os campos de vendedor para as entidades do CRM.

@sample 	CRMXIntVend()

@param		Nenhum

@Return   	ExpC C�digo do Vendedor

@author	Anderson Silva
@since		29/10/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Function CRMXIntVend()
 
Local aArea		:= GetArea()
Local cCodVend	:= ""

//Retorna o codigo do vendedor logado somente no SIGACRM.
If nModulo == 73
	cCodVend := CRMXRetVend()	
EndIf

RestArea(aArea)

Return(cCodVend)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXGetSX2

Obt�m o X2_UNICO, X2_DISPLAY, X2_SYSOBJ ou Chave Unica sem Funcao ADVPL.

@sample		CRMXGetSX2( cAliasEnt, lUnqNoFunc )

@param		ExpC1 - Alias atual
			ExpL2 - Monta a chave unica sem fun��es ADVPL. 

@Return		ExpA - Array com X2_UNICO, X2_DISPLAY e X2_SYSOBJ.

@author		Cristiane Nishizaka
@since		07/02/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMXGetSX2(cAliasEnt, lUnqNoFunc)

Local aArea			:= GetArea()
Local aAreaSX2 		:= SX2->(GetArea())
Local aAreaSX3 		:= SX3->(GetArea())
Local aCmpDisp		:= {}
Local aCampos		:= {}
Local aRet 			:= {}
Local cX3Cmp     	:= "X3_RELACAO"
Local cCpoNoFunc	:= ""
Local cUnqNoFunc	:= ""
Local cDisplay		:= ""
Local cExpress 		:= ""
Local cUnico		:= ""
Local nPosFunc		:= 0
Local nX			:= 0

Default lUnqNoFunc	:= .F.

If !Empty( cAliasEnt )
	
	DbSelectArea( "SX2" )
	DbSetOrder( 1 )
	
	If SX2->( DbSeek ( cAliasEnt ) ) .AND. !Empty( SX2->X2_UNICO )  
		
		If !Empty(SX2->X2_DISPLAY)

			DbSelectArea("SX3")
			SX3->(DbSetOrder(2))//X3_CAMPO

			aCmpDisp := StrTokArr(AllTrim(SX2->X2_DISPLAY),"+")// criando um array com os campos presentes no display
			
			For nX := 1 to Len(aCmpDisp) // Pegando somente campos reais do display para poder macro executar
				If SX3->(DbSeek(aCmpDisp[nX]))
				
					If SX3->X3_CONTEXT <> "V" //Diferente de campo virtual
						If SX3->X3_TIPO == "D" //  tratando campo do tipo data
							cExpress := "DTOC("+aCmpDisp[nX]+")"
						Else	
							cExpress := aCmpDisp[nX]
						EndIf
					Else
						cExpress := StrTran(AllTrim(GetSx3Cache(aCmpDisp[nX],cX3Cmp)),'"',"'",,)
					EndIf	

					If Empty(cDisplay) .AND. !Empty(cExpress)//montando a express�o para macro executar
						cDisplay += cExpress
					ElseIf !Empty(cExpress)
						cDisplay += "+' | '+"+ cExpress 
					EndIf

				EndIf
			Next nX
		EndIf
	
		cUnico	  	:= AllTrim( SubStr( SX2->X2_UNICO, At( "+", SX2->X2_UNICO ) + 1, Len( SX2->X2_UNICO ) ) )
		aRet := {cUnico,cDisplay,SX2->X2_SYSOBJ} 
		
		If lUnqNoFunc
			aCampos := StrTokArr(cUnico,"+")
			For nX := 1 To Len(aCampos)
				nPosFunc 	:= At("(",aCampos[nX])
				If nPosFunc == 0  
					If nX <> Len(aCampos)
						cUnqNoFunc += aCampos[nX]+"+"	
					Else
						cUnqNoFunc	+= aCampos[nX]
					EndIf
				Else
					cCpoNoFunc := SubStr(aCampos[nX],nPosFunc+1,(Len(aCampos[nX])-nPosFunc)-1)
					If nX <> Len(aCampos)
						cUnqNoFunc += cCpoNoFunc+"+"	
					Else
						cUnqNoFunc	+= cCpoNoFunc 
					EndIf
				EndIf 
			Next nX
			aAdd(aRet,cUnqNoFunc)
		EndIf
			
	EndIf

EndIf       

RestArea(aAreaSX2)
RestArea(aAreaSX3)
RestArea(aArea)

Return(aRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXGMnDef

Busca o menudef da rotina da entidade.
Abre o cadastro da entidade em modo de visualiza��o.

@sample		CRMXGMnDef( cEntidade, cUnico )

@param		ExpC1 - Alias Entidade
			ExpC2 - X2_UNICO posicionado

@Return		ExpL - Verdadeiro

@author		Cristiane Nishizaka
@since		07/02/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMXGMnDef(cAlias, cUnico) 			

Local aArea		:= GetArea()
Local aAreaEnt 	:= ( cAlias )->( GetArea() )
Local lRet		:=	.T.
Local aDadosSX2	:= CRMXGetSX2( cAlias )	
Local aRotina	:= {}
Local cFuncVisu	:= ""
Local cX2Obj	:= ""

//Vari�vel criada para possibilitar a chamada da fun��o AXVisual
Private cCadastro	:= STR0011		// "Visualizar" 
		 
DbSelectArea( cAlias )
DbSetOrder( 1 )

cX2Obj		:= AllTrim( aDadosSX2[3] )
aRotina 	:= &( "StaticCall( " + cX2Obj + ", MENUDEF )" )
cFuncVisu	:= aRotina[2][2]

If ( cAlias )->( DbSeek( cUnico ) )	
	// Se a fun��o estiver em MVC
	If Left( AllTrim( cFuncVisu ), 7 ) == "VIEWDEF"
		FWExecView( STR0011, AllTrim( cFuncVisu ), 1, /*oDlg*/, /*bCloseOnOk*/, /*bOk*/, /*nPercReducao*/ )		// "Visualizar"
	Else
		&( cFuncVisu + "( '" + cAlias + "', " + AllTrim( Str( ( cAlias )->( Recno() ) ) ) + ", 2 )" )
	EndIf
Else
	Help("",1, "HELP", ,STR0012, 1, )//"Problemas para visualizar este registro !"
	lRet := .F.
EndIf		
		
RestArea(aAreaEnt)
RestArea(aArea)
		
Return(lRet)

//----------------------------------------------------------
/*/{Protheus.doc} CRMXVldEnt()
 
Rotina para Validar o valor digitado no Campo AOF_ENTIDA

Exemplo :  cAlias = "SA3"
           nRotina = 2

a rotina ir� verificar se o alias SA3 est� disponivel para a rotina de atividades		    

@param	   ExpC1 - Alias Entidade
		   ExpN1 - Numero que representa a Rotina que dever� ser verificada a permiss�o do Alias
		            esse numero dever� ser passado pela variavel DEFINE que est� no fonte CRMDEF
		     		#DEFINE RESPECIFICACAO   1
			 		#DEFINE RATIVIDADE        2
			 		#DEFINE RCONEXAO          3
			 		#DEFINE RANOTACOES        4
			 		#DEFINE REMAIL            5
       			    #DEFINE RCEMAIL           6
@return   ExpL - Verdadeiro / Falso

@author   Victor Bitencourt
@since    26/02/2014
@version  12.0
/*/
//----------------------------------------------------------
Function CRMXVldEnt(cAlias, nRotina) 

Local lRet		:= .T.  
Local aAreaAO2 	:= {}

Default cAlias 	:= ""
Default nRotina	:= 0 

If Select("AO2") > 0
	aAreaAO2 := AO2->(GetArea())	
Else
	DbSelectArea("AO2")
EndIf	        

AO2->(DbSetOrder(1))//AO2_FILIAL+AO2_ENTID

If !Empty( cAlias ) .AND.  AO2->( DbSeek( xFilial( "AO2" ) + cAlias ) )
	Do Case
		Case nRotina == RESPECIFICACAO
			If AO2->AO2_ESPEC == "1"
				lRet   := .T.		
			Else
				lRet   := .F.
			EndIf		
		Case nRotina == RATIVIDADE
			If AO2->AO2_ATIV == "1"
				lRet   := .T.		
			Else
				lRet   := .F.
			EndIf		
		Case nRotina == RCONEXAO
			If AO2->AO2_CONEX == "1"
				lRet   := .T.		
			Else
				lRet   := .F.
			EndIf	
		Case nRotina == RANOTACOES
			If AO2->AO2_ANOTAC == "1"
				lRet   := .T.		
			Else
				lRet   := .F.
			EndIf				
		Case nRotina == REMAIL
			If AO2->AO2_MEMAIL == "1"
				lRet   := .T.		
			Else
				lRet   := .F.
			EndIf	
		Case nRotina == RCEMAIL
			If AO2->AO2_CEMAIL == "1"
				lRet   := .T.		
			Else
				lRet   := .F.
			EndIf						
	EndCase	
ElseIf Empty( cAlias )
	lRet   := .T.
Else
	lRet   := .F.
EndIf

If !Empty(aAreaAO2)
	RestArea(aAreaAO2)
EndIf		

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMInitFun

Fun��es a serem executadas na entrada do modulo CRM

@sample 	CRMInitFun() 

@param		Nenhum
	
@return		Nenhum

@author		Victor Bitencourt
@since		23/01/2014       
@version	12.0   
/*/
//---------------------------------------------------------------------
Function CRMInitFun()
	CRMXCRGAO2() 
	CRMLayMile() 
	CRMXP360()
	CRMXObserver()
Return( .T. ) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMLayMile

Fun��es a serem executadas na entrada do modulo CRM

@sample 	CRMLayMile()

@param		Nenhum
	
@Return		Nenhum

@author		Victor Bitencourt
@since		23/01/2014       
@version	12.0   
/*/
//---------------------------------------------------------------------
Function CRMLayMile()

	Local oFwMile 	:= FwMile():New() 
	Local lImpLayMl := SuperGetMv("MV_MLLYENT",,.T.) 
	
	//Apaga layout NeoWay descontinuado;
	If !lImpLayMl
		NwLayClear() 
	EndIf

	If  lImpLayMl       
										
		If !(TkxExtMile("ACHLAY01"))
			Tk341Mile("ACHLAY01")
		EndIf
		
		If !(TkxExtMile("SUSLAY01"))
			Tk260Mile("SUSLAY01")
		EndIf
		
		If !(TkxExtMile("SA1LAY01"))
			Ma030Mile("SA1LAY01")
		EndIf
		
		If !(TkxExtMile("TK700IMP"))
			Tk700Mile("TK700IMP")
		EndIf		
		
		DbSelectArea("SX6")
		DbSetOrder(1)
		
		PutMv("MV_MLLYENT",.F.)

	EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXNewOpo

Rotina que inclui uma nova oportuniadde conforme o registro posiciondo

@sample 	CRMXNewOpo() 

@param		ExpC1 - Alias Entidade que est� chamando
		    ExpC2 - Codigo do registro posicionado
		    ExpC3 - Loja do registro posicionado
	
@return		Nenhum

@author		Victor Bitencourt
@since		01/05/2014       
@version	12.0   
/*/
//---------------------------------------------------------------------
Function CRMXNewOpo(cEntidad, cCodEnt, cLojEnt)

Local oModel    := Nil
Local oFWMVCWin := Nil
Local aSize	 	:= FWGetDialogSize( oMainWnd )	// Coordenadas da Dialog Principal.
Local aError	:= {}

Default cEntidad	:= ""
Default cCodEnt		:= ""
Default cLojEnt		:= ""

oModel := FwLoadModel("FATA300")
oModel:SetOperation(3)
oModel:Activate()

If oModel:IsActive()   
	If !Empty(cEntidad) .AND. cEntidad == "SUS"
		oModel:GetModel("AD1MASTER"):SetValue("AD1_PROSPE",cCodEnt)
		oModel:GetModel("AD1MASTER"):SetValue("AD1_LOJPRO",cLojEnt)
	ElseIf !Empty(cEntidad) .AND. cEntidad == "SA1"
		oModel:GetModel("AD1MASTER"):SetValue("AD1_CODCLI",cCodEnt)
		oModel:GetModel("AD1MASTER"):SetValue("AD1_LOJCLI",cLojEnt)
	EndIf
	
	oView := FWLoadView("FATA300")
	oView:SetModel(oModel)
	oView:SetOperation(3) 
		  
	oFWMVCWin := FWMVCWindow():New()
	oFWMVCWin:SetUseControlBar(.T.)
		
	oFWMVCWin:SetView(oView)
	oFWMVCWin:SetCentered(.T.)
	oFWMVCWin:SetPos(aSize[1],aSize[2])
	oFWMVCWin:SetSize(aSize[3],aSize[4])
	oFWMVCWin:SetTitle(STR0021)//"Incluir"
	oFWMVCWin:oView:BCloseOnOk := {|| .T.  }
		
	oFWMVCWin:Activate()
Else
	aError := oModel:GetErrorMessage()
	If !Empty( aError )
		Help("",1,Alltrim(aError[5]),,aError[6],1)
	EndIf
EndIF 

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXNewApo

Rotina que inclui um novo apontamento conforme o registro posiciondo

@sample 	CRMXNewApo(cEntidad, cCodEnt, cLojEnt)

@param		ExpC1 - Alias Entidade que est� chamando
		    ExpC2 - Codigo do registro posicionado
		    ExpC3 - Loja do registro posicionado
	
@return	Nenhum

@author	Victor Bitencourt
@since		01/05/2014       
@version	12.0   
/*/
//---------------------------------------------------------------------
Function CRMXNewApo(cEntidad, cCodEnt, cLojEnt)

Local oModel    := Nil
Local oFWMVCWin := Nil
Local aSize	 	:= FWGetDialogSize( oMainWnd )	// Coordenadas da Dialog Principal.
Local aError	:= {} 

Default cEntidad	:= ""
Default cCodEnt		:= ""
Default cLojEnt		:= ""

oModel := FwLoadModel("FATA310")
oModel:SetOperation(3)
oModel:Activate()
  
If oModel:iSActive()   
	If !Empty(cEntidad) .AND. cEntidad == "SUS"
		oModel:GetModel("AD5MASTER"):SetValue("AD5_PROSPE",cCodEnt)
		oModel:GetModel("AD5MASTER"):SetValue("AD5_LOJPRO",cLojEnt)
	ElseIf !Empty(cEntidad) .AND. cEntidad == "SA1"
		oModel:GetModel("AD5MASTER"):SetValue("AD5_CODCLI",cCodEnt)
		oModel:GetModel("AD5MASTER"):SetValue("AD5_LOJA",cLojEnt)
	ElseIf !Empty(cEntidad) .AND. cEntidad == "AD1"
		oModel:GetModel("AD5MASTER"):SetValue("AD5_NROPOR",cCodEnt)	
	EndIf

	
	oView := FWLoadView("FATA310")
	oView:SetModel(oModel)
	oView:SetOperation(3) 
		  
	oFWMVCWin := FWMVCWindow():New()
	oFWMVCWin:SetUseControlBar(.T.)
		
	oFWMVCWin:SetView(oView)
	oFWMVCWin:SetCentered(.T.)
	oFWMVCWin:SetPos(aSize[1],aSize[2])
	oFWMVCWin:SetSize(aSize[3],aSize[4])
	oFWMVCWin:SetTitle(STR0021)//"Incluir"
	oFWMVCWin:oView:BCloseOnOk := {|| .T.  }
		
		oFWMVCWin:Activate()
Else
	aError := oModel:GetErrorMessage()
	If !Empty( aError )
		Help("",1,"CRMXNewApo",,aError[6],1)
	EndIf
EndIf

Return	Nil

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXVldAli

Fun��o que Valida se o Alias da tabela existe no SX2

@sample	CRMXVldAli(cAlias)

@param		ExpC1 - Alias  da Tabela

@return		ExpL - Indica se foi encontrada ou n�o a tabela no SX2

@author		Victor Bitencourt
@since		12/09/2014
@version	12.0
/*/
//---------------------------------------------------------------------------------------------------------------
Function CRMXVldAli(cAlias)

Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaSX2 := SX2->(GetArea())

Default cAlias := ""

If !Empty(cAlias)
	DbSelectArea("SX2")
	SX2->(DbSetOrder(1))
	
	If !SX2->(DbSeek(cAlias))
		Help("",1,"CRMXVLDALI")	// Este alias n�o existe !	
		lRet := .F.
	EndIf
EndIf

RestArea(aAreaSX2)
RestArea(aArea)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMXGeraExcel
Gera uma planilha excel com base nos dados recebidos em arrays ou tabelas.

@param nTipoDados      Tipo dos dados de origem (1=array;2=tabela)
@param aDados           dados de origem (array com arrays ou array com aliases)
@param aFieldsEx        cabecalhos das colunas (array com arrays de estrutura de campos)
@param aSheets          array com os nomes das WorkSheets
@param cNomeArq         Parte inicial do nome do arquivo gerado
@param cDirArq          Diret�rio da m�quina local para gera��o da planilha

@return lRetorno        Indica se a planilha foi gerada ou nao

@author  Norberto Frassi Jr
@since   06/08/2015
/*/
//-------------------------------------------------------------------
Function CRMXGeraExcel( nTipoDados, aDados, aFieldsEx, aSheets, cNomeArq, cDirArq )
	
	Local oExcel            := Nil
	Local aRow              := {}
	Local cFile             := ""
	Local nField            := 0
	Local nAlign            := 1
	Local nFormat           := 1
	Local cDirDest          := ""
	Local nWs               := 0
	Local nLinha            := 0
	Local lRetorno          := .T.

	Default nTipoDados      := 1
	Default aDados          := {}
	Default aFieldsEx       := {}
	Default cNomeArq        := FunName()+"_"
	Default aSheets         := {FunDesc()}
	Default cDirArq         := ""
	
	Do Case
		Case ( Empty( aDados ) .Or. Empty( aFieldsEx ) .Or. Empty( aSheets ) )
			MsgAlert(STR0109)	 //	"Par�metros inv�lidos para a gera��o de planilha."
			lRetorno := .F.
		Case ( Len( aDados ) <> Len( aFieldsEx ) .Or. Len( aDados ) <> Len( aSheets ) )
			MsgAlert(STR0112)	 //	"A quantidade de elementos de dados, cabe�alhos e WorkSheets n�o � a mesma."
			lRetorno := .F.
		Case !ApOleClient( 'MsExcel' ) 
			MsgAlert( STR0113 ) //"N�o ser� poss�vel exportar os dados, pois n�o existe Excel instalado."
			lRetorno := .F.
	EndCase
		
	If lRetorno 
		
		If ( Empty( cDirArq ) .Or. !File( cDirArq ) )
			cDirDest := GetTempPath(.T.) //	Se Diret�rio n�o recebido ou n�o existir, gera no tempor�rio local do usu�rio
		Else
			cDirDest := cDirArq	//Diret�rio recebido
		Endif
	
		If ( !Empty( cDirArq ) .And. !File( cDirArq ) )
			MsgAlert(STR0110 + cDirArq + STR0111 + cDirDest + ".")		//	"O diret�rio informado "###" n�o existe. A planilha ser� gerada no diret�rio "
		Endif
	
		//-------------------------------------------------------------------
		// Define o nome da planilha.
		//-------------------------------------------------------------------
		cFile := AllTrim( cNomeArq ) + DTos( Date() ) + "_" + StrTran( Time(), ":", "" ) + ".xml"
	
		oExcel := FWMsExcelEx():New()
		
		//-------------------------------------------------------------------
		// Define o t�tulo da planilha e das WorkSheets
		//-------------------------------------------------------------------
		For nWs := 1 to Len( aSheets )
			
			oExcel:AddworkSheet( aSheets[nWs] )              //  Nome da planilha
			oExcel:AddTable( aSheets[nWs], aSheets[nWs] )     //  Nome da planilha
	
			//-------------------------------------------------------------------
			// Monta as colunas da planilha.
			//-------------------------------------------------------------------
			For nField := 1 To Len( aFieldsEx[nWs]	)
			
				If ( aFieldsEx[nWs][nField][2] == "C" )
					nAlign	:= 1
					nFormat	:= 1
				ElseIf( aFieldsEx[nWs][nField][2] == "N" )
					nAlign	:= 3
					nFormat	:= 2
				ElseIf( aFieldsEx[nWs][nField][2] == "D" )
					nAlign	:= 2
					nFormat	:= 4
				Else
					nAlign	:= 1
					nFormat	:= 1
				EndIf
	
				oExcel:AddColumn( aSheets[nWs], aSheets[nWs], aFieldsEx[nWs][nField][5], nAlign, nFormat, .F.) //   Nome da planilha###Nome da planilha
	
			Next nField
				
			If nTipoDados == 1		//	array
			
				For nLinha := 1 to Len(aDados[nWs])
					
					//-------------------------------------------------------------------
					// Monta as linhas da planilha.
					//-------------------------------------------------------------------
					aRow := {}
					//-------------------------------------------------------------------
					// Recupera o conte�do do arquivo tempor�rio.
					//-------------------------------------------------------------------
					For nField := 1 To Len( aFieldsEx[nWs]	)
						aAdd( aRow, ( aDados[nWs][nLinha][nField] ) )
					Next nField
	
					//-------------------------------------------------------------------
					// Adiciona uma nova linha na planilha.
					//-------------------------------------------------------------------
					oExcel:AddRow( aSheets[nWs], aSheets[nWs], aRow )  //   Nome da planilha###Nome da planilha
		
				Next nLinha
			Else	//	tabela
				
				(aDados[nWs])->( DBGoTop() )
				
				//-------------------------------------------------------------------
				// Monta as linhas da planilha.
				//-------------------------------------------------------------------
				While (aDados[nWs])->( ! Eof() )
					aRow := {}
					//-------------------------------------------------------------------
					// Recupera o conte�do do arquivo tempor�rio.
					//-------------------------------------------------------------------
					For nField := 1 To Len( aFieldsEx[nWs]	)
						aAdd( aRow, (aDados[nWs])->&( aFieldsEx[nWs][nField][1] ) )
					Next nField
	
					//-------------------------------------------------------------------
					// Adiciona uma nova linha na planilha.
					//-------------------------------------------------------------------
					oExcel:AddRow( aSheets[nWs], aSheets[nWs], aRow )  //   Nome da planilha###Nome da planilha
	
					(aDados[nWs])->(DbSkip())
				EndDo
			Endif
	
		Next nWs
		
		oExcel:Activate()
	
		//-------------------------------------------------------------------
		// Gera a planilha no servidor.
		//-------------------------------------------------------------------
		If oExcel:nRows > 0 
			oExcel:GetXMLFile( cFile )
			//-------------------------------------------------------------------
			// Copia a planilha para m�quina local e executa.
			//-------------------------------------------------------------------
			If ( CpyS2T ( cFile, cDirDest, .T. ) )
				If ( MsgYesNo( STR0114 + cFile + STR0115 + cDirDest + " ? ") ) //"Deseja abrir a planilha "###" gerada no diret�rio "###cDirArq###" ? "
					ShellExecute( "OPEN", "EXCEL", cDirDest + "\" + cFile, "", SW_SHOWMAXIMIZED )
				EndIf
			EndIf
		EndIf
		
		//-------------------------------------------------------------------
		// Apaga o arquivo do servidor.
		//-------------------------------------------------------------------
		If ( File( cFile ) )
			FErase( cFile )
		EndIf
		
		oExcel:DeActivate()
		
		FreeObj( oExcel )
		oExcel := Nil
	
	Endif
	
Return (lRetorno)

//------------------------------------------------------------------------------
/*/{Protheus.doc} DlgMsgCRM
Exibe log de processamento na tela
@param cMsg, caracter: (LOG a ser exibido)
@param cTitle, caracter: T�tulo da tela de LOG de processamento
@param lVScroll, l�gico: habilita ou n�o a barra de scroll vertical
@param lHScroll, l�gico: habilita ou n�o a barra de scroll horizontal
@param lWrdWrap, l�gico: habilita a quebra de linha autom�tica ou n�o, obedecendo ao tamanho da caixa de texto do log
@return lRet, Indica confirma��o ou cancelamento
@author     William Pianheri
@since 22/06/2017
@version 1.0
/*/
//------------------------------------------------------------------------------
Function DlgMsgCRM(cMsg,cTitle,lVScroll,lHScroll,lWrdWrap)
Local lRet			:= .F.
Local oFont		:= TFont():New("Courier New",07,15)
Local oMemo		:= Nil
Local oDlgEsc		:= Nil
Default cMsg		:= ""
Default cTitle	:= ""
Default lVScroll	:= .T.
Default lHScroll	:= .F.
Default lWrdWrap	:= .T.
Default lCancel	:= .T.

If !Empty(cMsg)
    Define Dialog oDlgEsc Title AllTrim(cTitle) From 0,0 to 425, 600 Pixel
    @ 000, 000 MsPanel oDlg Of oDlgEsc Size 000,250    // Coordenada para o panel
    oDlg:Align := CONTROL_ALIGN_TOP //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
    @ 005,005 Get oMemo Var cMsg Memo FONT oFont Size 292,186 READONLY Of oDlg Pixel
    oMemo:EnableVScroll(lVScroll)
    oMemo:EnableHScroll(lHScroll)
    oMemo:lWordWrap := lWrdWrap
    oMemo:bRClicked := {|| AllwaysTrue()}
    Define SButton From 196, 270 Type  1 Action (lRet := .T., oDlgEsc:End()) Enable Of oDlg Pixel // OK

    If lCancel
        Define SButton From 196, 240 Type  2 Action (lRet := .F., oDlgEsc:End()) Enable Of oDlg Pixel // Cancelar
    Endif

    Activate Dialog oDlgEsc Centered
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMXPicTel 
Fun��o gen�rica para ajuste da m�scara dos campos de Telefone.
@sample	CRMXPicTel(cTipTel)
@param		cTipTel, caracter, Tipo de Telefone (Conforme tipos definidos na tabela AGB)
      		1=Comercial
      		2=Residencial
      		3=Fax comercial
      		4=Fax residencial
      		5=Celular
@return	cPict
@author	CRM/Faturamento
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Function CRMXPicTel(cTipTel)

Local	cCpo		:= ''
Local	cConteudo	:= ''
Local	nDigitos	:= 0
Local	cPict		:= ""

Default	cTipTel	:= ''

If	cTipTel == "5"	.And. cPaisLoc == "BRA"//5=Celular
	cCpo		:= StrTran(AllTrim(Upper(ReadVar())),"M->","")
	cConteudo	:= ( IIF( Type(cCpo) <> "U", AllTrim(&cCpo), "" ) )
	nDigitos	:= Len(cConteudo)
	If	nDigitos == 9
		cPict := "@R 99999-9999"
	Else
		cPict := "@R 9999-9999"
	EndIf
Else
	cPict := "@R 9999-9999"
EndIf

cPict := cPict + "%C"

Return cPict

//------------------------------------------------------------------------------
/*/{Protheus.doc}CRMXGFSXB

Retorna se o fix do SXB foi carregado.

@sample 	CRMXGFSXB

@param		Nenhum

@Return   	Nenhum

@author	SQUAD FAT / CRM
@since		23/05/2017
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Function CRMXGFSXB()

Local aAreaSXB	:= {}
Local nTamSXB 	:= 0

If !lCallGFSXB
	aAreaSXB := SXB->( GetArea() )
	SXB->( DBSetOrder( 1 ) )
	nTamSXB := Len(SXB->XB_ALIAS)
	If SXB->( DBSeek(PadR("SA1", nTamSXB)+'601  ') .And. (RTrim(SXB->XB_CONTEM) == 'CRMXFilSXB("SA1")') )
		lFixSXB := .F.		
	Else
		lFixSXB := .T.
	EndIf
	lCallGFSXB := .T.
	RestArea( aAreaSXB )
EndIf

Return( lFixSXB )

//------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXGetJFields
Retorna uma lista de campos no formato JSON de uma determinada 
tabela do SX2 ou de uma tabela temporaria com estrutura de campos. 

@param		cAlias	    , caracter	, Alias da tabela
			cLanguage	, caracter	, Linguagem do nome do campo. 
			aFields	    , array		, Lista de campos para retornar.
            lContent    , logico    , Traz o conteudo do campo na tag value do registro posicionado.
			lListDetail , logico    , Indica se objeto JSON ser� utilizado numa lista de um outro objeto.
@return	    cJFiedls 	, caracter  , Lista os campos no formato JSON as Tags {identifier, label, type, value}.      

@author 	Squad CRM / FAT
@version	12.1.20 / Superior
@since		31/01/2018 
/*/
//-------------------------------------------------------------------------------------------------------------------------
Function CRMXGetJFields(cAlias, cLanguage, aFields, lContent, lListDetail)     
    Local aJFields      := {}
    Local aStruct       := {}
    Local jFields       := JsonObject():New()   
    Local jField        := Nil      
    Local nI            := 0
    Local lAliasInDic   := .F.
    Local lFields       := .F. 
    Local cJFiedls      := ""
    Local cOptions      := ""

    Default cAlias      := ""
    Default cLanguage   := "pt"
    Default aFields     := {} 
    Default lContent    := .F.
    Default lListDetail := .F.

    jFields := JsonObject():New()

    lFields := !Empty( aFields )

    If !Empty( cAlias )

        lAliasInDic := AliasInDic( cAlias )
        aStruct 	:= (cAlias)->( DBStruct() ) 

        For nI := 1 To Len( aStruct )
            
            If ( lFields .And. aScan( aFields, { | x | AllTrim( Upper( x ) ) == aStruct[nI][1]   } ) == 0 )
                Loop
            EndIf

            jField := JsonObject():New()

            jField["identifier"] := aStruct[nI][1]     
            jField["type"      ] := aStruct[nI][2]
                 
            If lAliasInDic
                jField["label"] := CRMXGetTitle( aStruct[nI][1], cLanguage )
				cOptions 		:= CRMXGetBox(aStruct[nI][1], cLanguage)
				If !Empty(cOptions)
                	jField["options"] := AllTrim(cOptions)
           		EndIf
			EndIf

            If ( lContent .And. (cAlias)->( !Eof() ) )
                jField["value"] := (cAlias)->( FieldGet( FieldPos( aStruct[nI][1] ) ) )                  
            EndIf

            AAdd(aJFields, jField)  

        Next nI

    EndIf

    If !lListDetail
        jFields["fields"] := aJFields
        cJFiedls := FwJsonSerialize(jFields) 
    Else
        cJFiedls := FwJsonSerialize(aJFields) 
        cJFiedls := Substr(cJFiedls,2,Len(cJFiedls)-2)   
    EndIf 

Return cJFiedls 

//------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXGetTitle
Retorna o nome do campo. 

@param		cField	    , caracter	, Nome da campo no SX3
			cLanguage	, caracter	, Linguagem do nome do campo. 
			
@return	    cTitle      , caracter  , T�tulo do campo.     

@author 	Squad CRM / FAT
@version	12.1.20 / Superior
@since		31/01/2018 
/*/
//-------------------------------------------------------------------------------------------------------------------------
Static Function CRMXGetTitle(cField, cLanguage)
    Local cTitle    := ""
    Local cSX3Field := ""

    Default cField      := ""
    Default cLanguage   := "pt"

    cLanguage := Lower( cLanguage )

    Do Case
        Case cLanguage == "en"
            cSX3Field := "X3_TITENG"
        Case cLanguage == "es"
            cSX3Field := "X3_TITSPA"
        Otherwise
            cSX3Field := "X3_TITULO"
    EndCase

    If !Empty( cField )
        cTitle := GetSx3Cache( cField, cSX3Field )
    EndIf

Return EncodeUtf8( AllTrim( cTitle ) )

//------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXGetBox
Retorna o conteudo do combobox. 

@param		cField	    , caracter	, Nome da campo no SX3
			cLanguage	, caracter	, Linguagem do conte�do do Combobox. 
			
@return	    cOptBox     , caracter  , Conte�do do Combobox.     

@author 	Squad CRM / FAT
@version	12.1.20 / Superior
@since		31/01/2018 
/*/
//-------------------------------------------------------------------------------------------------------------------------
Static Function CRMXGetBox(cField, cLanguage)
    Local cOptBox   := ""
    Local cSX3Field := ""

    Default cField      := ""
    Default cLanguage   := "pt"

    cLanguage := Lower( cLanguage )

    Do Case
        Case cLanguage == "en"
            cSX3Field := "X3_CBOXENG"
        Case cLanguage == "es"
            cSX3Field := "X3_CBOXSPA"
        Otherwise
            cSX3Field := "X3_CBOX"
    EndCase

    If !Empty( cField )
        cOptBox := GetSx3Cache( cField, cSX3Field )
    EndIf

Return EncodeUtf8( AllTrim( cOptBox ) )

//----------------------------------------------------------------------------
/*/{Protheus.doc} CRMMText
Prepara texto para Json mobile

@param		cString	    , caracter	, String a ser formatada
			lIsUpper	, L�gico	, Caixa alta. 
			lIsTrim     , L�gico    , Retira espa�os em branco.
@return	    cString     , caracter  , String formatada.     

@author 	Renato da Cunha
@version	12.1.17
@since		27/03/2018 
/*/
//----------------------------------------------------------------------------
Function CRMMText(cString, lIsUpper, lIsTrim)
	Default	cString	:= ''
	Default lIsUpper	:= .F.
	Default lIsTrim	:= .F.
	
	If !Empty(cString)
		cString := StrTran( cString,","," "   )
		cString := StrTran( cString,"."," "   )
		cString := StrTran( cString,'"',''    )
		cString := StrTran( cString,'\','\\'  )
	EndIf

	If lIsUpper
		cString := Upper(cString)
	EndIf

	If lIsTrim
		cString := Alltrim(cString)
	EndIf
Return FwNoAccent(cString)