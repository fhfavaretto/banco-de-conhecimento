#INCLUDE 'TOTVS.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "FS_BUTTON_CSS.CH"

#define LAYOUT_ALIGN_LEFT		1
#define LAYOUT_ALIGN_RIGHT		2
#define LAYOUT_ALIGN_HCENTER	4
#define LAYOUT_ALIGN_TOP		32
#define LAYOUT_ALIGN_BOTTON		64
#define LAYOUT_ALIGN_VCENTER	128

#define LAYOUT_LINEAR_L2R		0
#define LAYOUT_LINEAR_R2L		1
#define LAYOUT_LINEAR_T2B		2
#define LAYOUT_LINEAR_B2T		3

#define ENTER CHR(13) + CHR(10)

User Function FRESA002()

	Local oWnd
	Local n_Linha	:= 4
	Local n_Coluna	:= 85
	Local n_SeqBut	:= 1

	Local c_Style	:= f_MontaStyle()

	//Local oBtn1
	//Local oBtn2
	//Local oBtn3

	BEGIN SEQUENCE

		MsAguarde( {|| f_CarregaDic() }, "Aguarde!!!", "Aguarde enquanto preparamos seu ambiente...")

		oFont1     := TFont():New( "Arial",0,-13,,.F.,0,,400,.F.,.F.,,,,,, )

		//oWnd:= TWindow():New(010, 010, 010,010, "Restaurante", NIL, NIL, NIL, NIL, NIL, NIL, NIL,CLR_BLUE, CLR_BLACK, NIL, NIL, NIL, NIL, NIL, NIL, .T. )
		//oWnd:Center(.T.)

		oWnd	:= MSDialog():New( 092,232,650,809,"Mesas",,,.F.,,,,,,.T.,,,.T. )

		oBtnA	:= TButton():New( 004,004,"Atendente",oWnd,{|| oBtnB:Hide(.T.) },039,030,,,,.T.,,"",,,,.F. )
		oBtnB	:= TButton():New( 004,045,"Mesa",oWnd,{|| f_Operacao( "01" ) },039,030,,,,.T.,,"",,,,.F. )


		For i:=1 To 3 Step 1
			j:=Alltrim(Str(i))
			oBtn&j		:= TButton():New( n_Linha, n_Coluna, "CAFE C/ LEITE" + chr(10) + "145ML " + Alltrim(Str(i)) + chr(10),oWnd,,040,040,,oFont1,,.T.,,"",,,,.F. )
			oBtn&j:bAction := {|| f_Func2( oBtn&j, oWnd ) }
			oBtn&j:SetCss( STYLE0000 )
			n_Coluna	+= 40
		Next i

		//oBtn3      := TButton():New( 004,329,"oBtn1",oWnd,,039,030,,,,.T.,,"",,,,.F. )
		//oBtn4      := TButton():New( 004,126,"oBtn1",oWnd,,039,030,,,,.T.,,"",,,,.F. )
		//oBtn5      := TButton():New( 004,085,"oBtn1",oWnd,,039,030,,,,.T.,,"",,,,.F. )
		//oBtn6      := TButton():New( 004,288,"oBtn1",oWnd,,039,030,,,,.T.,,"",,,,.F. )
		//oBtn7      := TButton():New( 004,167,"oBtn1",oWnd,,039,030,,,,.T.,,"",,,,.F. )
		//oBtn8      := TButton():New( 004,207,"oBtn1",oWnd,,039,030,,,,.T.,,"",,,,.F. )
		//oBtn9      := TButton():New( 004,248,"oBtn1",oWnd,,039,030,,,,.T.,,"",,,,.F. )

		oWnd:Activate()


	END SEQUENCE

Return()

Static Function f_Funcao( i )

	conout( i )

Return

Static Function f_Func2( o_Botao, oWnd )

	conout( ownd:octlfocus:ccaption )

Return

Static Function f_MontaStyle()

	Local c_CSS	:= "QPushButton {" +;
	" background-color: #000000;" +;
	" background-repeat: none; margin: 2px;"  +;
	" border-style: outset;" +;
	" border-width: 2px;" +;
	" border: 1px solid #C0C0C0;" +;
	" border-radius: 5px;" +;
	" border-color: #C0C0C0;" +;
	" font: bold 12px Arial;" +;
	" padding: 6px;" +;
	"}" +;
	"QPushButton:pressed {background-color: #e6e6f9;border-style: inset;}"

Return

Static Function f_CarregaDic()

	PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "FAT" TABLES "SB1"

Return()

Static Function f_Operacao( c_Mesa )

	Local c_Pesq		:= Space(200)

	Private c_Cupom		:= ""
	Private n_Quant		:= 1
	Private aBrowse		:= {}
	Private n_Total		:= 0
	Private n_Servico	:= 0.1
	Private c_HrIni		:= TIME()
	Private n_Item		:= 0

	// 12345678901234567890123456789012345678901234
	//"--------------------------------------------"
	//"             PARCIAL DA MESA 01             "
	//"--------------------------------------------"
	c_Cupom += "-----------------------------------------" + ENTER
	c_Cupom += "             PARCIAL DA MESA " + c_Mesa + ENTER
	c_Cupom += "-----------------------------------------" + ENTER
	c_Cupom += "DATA: " + DTOC( Date() ) + ENTER
	c_Cupom += "HORA: " + c_HrIni + ENTER
	c_Cupom += "-----------------------------------------" + ENTER
	c_Cupom += "It  Produto                Qt   Prc   Tot" + ENTER
	c_Cupom += "-----------------------------------------" + ENTER

	f_CarregaGrid( c_Pesq, .F. )

	oFont1     := TFont():New( "Arial",0,-21,,.T.,0,,700,.F.,.F.,,,,,, )
	oFont2     := TFont():New( "Arial",0,-29,,.T.,0,,700,.F.,.F.,,,,,, )
	oFont3     := TFont():New( "Arial Narrow",0,-19,,.F.,0,,400,.F.,.F.,,,,,, )
	oFont4     := TFont():New( "Courier",0,-9,,.F.,0,,400,.F.,.F.,,,,,, )

	oDlg1      := MSDialog():New( 092,232,594,1114,"Comandas",,,.F.,,,,,,.T.,,,.T. )

	oBtn5      := TButton():New( 004,005,"TRANSFERIR MESA",oDlg1,{|| f_Transferencia( @c_Mesa ) },075,017,,,,.T.,,"",,,,.F. )
	oBtn7      := TButton():New( 004,082,"ESTORNAR ITEM",oDlg1,{|| f_EstornaIt( c_Mesa ) },075,017,,,,.T.,,"",,,,.F. )
	oBtn6      := TButton():New( 004,158,"FECHAR MESA",oDlg1,{|| f_FecharMesa( c_Mesa ) },075,017,,,,.T.,,"",,,,.F. )
	oBtn6      := TButton():New( 004,235,"SAIR",oDlg1,{|| oDlg1:End() },075,017,,,,.T.,,"",,,,.F. )
	oSay1      := TSay():New( 006,350,{|| "MESA: " + c_Mesa },oDlg1,,oFont2,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,112,016)

	oGet2      := TGet():New( 032,005,{|u| If(PCount()>0,c_Pesq:=u,c_Pesq)},oDlg1,187,015,'@!',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	oBtn4      := TButton():New( 032,193,"PESQUISAR",oDlg1,{ || f_CarregaGrid( c_Pesq, .T. ) },038,017,,,,.T.,,"",,,,.F. )

	oBtn2      := TButton():New( 031,257,"-",oDlg1,{|| f_Subrai1() },038,017,,,,.T.,,"",,,,.F. )
	oGet1      := TGet():New( 031,296,{|u| If(PCount()>0,n_Quant:=u,n_Quant)},oDlg1,032,015,'@e 99',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.T.,.F.,,.F.,.F.,"","",,)
	oBtn1      := TButton():New( 031,329,"+",oDlg1,{|| f_Soma1() },038,017,,,,.T.,,"",,,,.F. )
	oBtn3      := TButton():New( 031,372,"CONFIRMAR",oDlg1,{|| f_GravaItem() },038,017,,,,.T.,,"",,,,.F. )

	oBrowse := TSBrowse():New(056,04,250,192,oDlg1,,16,oFont3,3)
	oBrowse:AddColumn( TCColumn():New('',,,{|| },{|| }) )
	oBrowse:AddColumn( TCColumn():New('Produto',,,{|| },{|| }) )
	oBrowse:AddColumn( TCColumn():New('Preco',,,{|| },{|| }) )
	oBrowse:AddColumn( TCColumn():New('Codigo',,,{|| },{|| }) )
	oBrowse:SetArray(aBrowse)

	oMGet1     := TMultiGet():New( 056,258,{| u | if( pCount() > 0, c_Cupom := u, c_Cupom ) },oDlg1,180,192,oFont4,,CLR_WHITE,CLR_GRAY,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
	oMGet1:EnableVScroll( .T. )
	oMGet1:Disable()

	oDlg1:Activate(,,,.T.)

Return()

Static Function f_FecharMesa( c_Mesa )

	Local c_HrSai	:= Time()
	Local n_Conta	:= 0
	Local n_VlrSV	:= 0

	If MsgYesNo("Deseja encerrar a MESA " + c_Mesa + "?")

		n_VlrSV	:= n_Servico * n_Total
		n_Conta := ( n_Servico * n_Total ) + n_Total

		c_Cupom += "-----------------------------------------" + ENTER
		c_Cupom += "PRODUTOS                    " + Transform( n_Total, "@e 999.99") + ENTER
		c_Cupom += "SERVICO                     " + Transform( n_VlrSV, "@e 999.99") + ENTER
		c_Cupom += "TOTAL                       " + Transform( n_Conta, "@e 999.99") + ENTER
		c_Cupom += "-----------------------------------------" + ENTER
		c_Cupom += "DATA: " + DTOC( Date() ) + ENTER
		c_Cupom += "HORA: " + TIME() + ENTER
		c_Cupom += "PERMAN�NCIA: " + ELAPTIME( c_HrIni, c_HrSai ) + ENTER
		c_Cupom += "-----------------------------------------" + ENTER

	EndIf

Return()

Static Function f_GravaItem()

	Local c_Produto	:= aBrowse[oBrowse:nAt][4]
	Local c_Descric	:= aBrowse[oBrowse:nAt][2]
	Local n_QtdVend	:= Alltrim( Transform(n_Quant, "@e 99") )
	Local n_Preco	:= Alltrim( Transform(val(replace(aBrowse[oBrowse:nAt][3],",",".")), "@e 999.99") )
	Local n_TotPrd	:= Alltrim( Transform(n_Quant * val(replace(aBrowse[oBrowse:nAt][3],",",".")), "@e 999.99") )

	n_Item++
	n_Total += n_Quant * val( Replace( aBrowse[oBrowse:nAt][3],",",".") )
	c_Cupom += 	Strzero( n_Item, 2) + " " + PADR( c_Descric, 24 ) + " " + PADR( n_QtdVend, 2 ) + " " + PADR( n_Preco, 5 ) + " " + PADR( n_TotPrd, 5 ) + ENTER

	n_Quant := 1
	oMGet1:GoEnd()
	oGet1:Refresh()

Return()

Static Function f_CarregaGrid( c_Pesq, l_Comp )

	Local c_Alias	:= GetNextAlias()
	Local c_Where	:= ""

	IF Empty( c_Pesq )
		c_Where := " 1=1 "
		c_Where	:= "%"+ c_Where + "%"
	Else
		c_Where := " B1_DESC LIKE '%" + Upper( Alltrim( c_Pesq ) ) + "%' "
		c_Where	:= "%"+ c_Where + "%"
	EndiF

	BeginSQL Alias c_Alias

		SELECT
		B1_DESC, B1_UPRC, B1_COD
		FROM
		%TABLE:SB1% (NOLOCK)
		WHERE
		%NOTDEL%
		AND %EXP:c_Where%
		ORDER BY
		%Order:SB1,3%

	EndSQL
	dbSelectArea( c_Alias )
	( c_Alias )->( dbGoTop() )
	aBrowse := {}
	While ( c_Alias )->( !EOF())

		AADD( aBrowse, { .T., Alltrim( ( c_Alias )->B1_DESC ), Transform( ( c_Alias )->B1_UPRC, "@E 999.99" ), Alltrim( ( c_Alias )->B1_COD ) } )

		( c_Alias )->( dbSkip() )

	EndDo
	( c_Alias )->( dbCloseArea() )

	If l_Comp
		oBrowse:SetArray(aBrowse)
		oBrowse:Refresh()
		oGet2:SetFocus()
	EndIf

Return()

Static Function f_Soma1()

	n_Quant++
	oGet1:Refresh()

Return()

Static Function f_Subrai1()

	n_Quant--
	If n_Quant < 1
		n_Quant := 1
	EndIf
	oGet1:Refresh()

Return()

Static Function f_Transferencia( c_Mesa )

	Local n_Opca		:= 0
	Local c_MesaDest	:= Space(2)

	/*������������������������������������������������������������������������ٱ�
	�� Declara��o de Variaveis Private dos Objetos                             ��
	ٱ�������������������������������������������������������������������������*/
	SetPrvt("oFont1","oDlg2","oBmp1","oGrp1","oGet1","oGrp2","oGet2","oBtn2","oBtn3")

	/*������������������������������������������������������������������������ٱ�
	�� Definicao do Dialog e todos os seus componentes.                        ��
	ٱ�������������������������������������������������������������������������*/
	oFont1     := TFont():New( "Arial",0,-19,,.T.,0,,700,.F.,.F.,,,,,, )
	oDlg2      := MSDialog():New( 092,232,282,604,"Transferencia de Mesa",,,.F.,,,,,,.T.,,oFont1,.T. )

	oBmp1      := TBitmap():New( 020,072,024,020,,"",.F.,oDlg2,,,.F.,.T.,,"",.T.,,.T.,,.F. )
	oGrp1      := TGroup():New( 004,004,052,064,"Mesa Atual",oDlg2,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oGet1      := TGet():New( 023,020,{|u| If(PCount()>0,c_Mesa:=u,c_Mesa)},oDlg2,020,015,'',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	oGet1:Disable()

	oGrp2      := TGroup():New( 005,101,052,172,"Mesa Destino",oDlg2,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oGet2      := TGet():New( 024,125,{|u| If(PCount()>0,c_MesaDest:=u,c_MesaDest)},oDlg2,020,013,'',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)

	oBtn2      := TButton():New( 056,056,"Cancelar",oDlg2,{ || n_Opca := 0, oDlg2:End() },052,024,,oFont1,,.T.,,"",,,,.F. )
	oBtn3      := TButton():New( 056,120,"Confirmar",oDlg2,{ || n_Opca := 1, oDlg2:End() },052,024,,oFont1,,.T.,,"",,,,.F. )

	oDlg2:Activate(,,,.T.)

	If n_Opca == 1

		c_Mesa := c_MesaDest

	EndIf

Return()

Static Function f_EstornaIt( c_Mesa )

	Alert("Em Desenvolvimento!")

Return