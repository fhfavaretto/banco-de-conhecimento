User Function GrvFI2()

	/*
	���          �    aItemsFI2[x][1]: Ocorrencia                             ���
	���          �    aItemsFI2[x][2]: Titulo do campo (nao utilizado)        ���
	���          �    aItemsFI2[x][3]: Valor anterior                         ���
	���          �    aItemsFI2[x][4]: Novo valor                             ���
	���          �    aItemsFI2[x][5]: Nome do campo                          ���
	���          �    aItemsFI2[x][6]: Tipo do campo                          ���
	*/
	Private aItemsFI2	:= {{"02","","01","02","E1_SITUAC","C"}} //CarregaFI2(aCpos,aDados, lAbatim, lProtesto, lCancProt) //

	dbSelectArea("SE1")
	dbSetOrder(1)
	If dbSeek( "01BA0001" + "TST" +  "000031313" + "1  " + "NF " )
		Alert("Entrei")
		//Fa040AltOk({Space(10)}, {""},,.F., .F., .T.)
		//Fa040AltOk(,,.T.)
		F040GrvFI2()
	EndIf

Return()