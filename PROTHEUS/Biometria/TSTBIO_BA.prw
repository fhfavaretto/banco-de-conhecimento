function u_TSTBIO_BA()

	Local nHdl	:= 0
	Local cName	:= "C:\Totvs\EasyInstallation_v3.12\EasyInstallation_v3.12\FDU\HamsterII_III\Drivers\x86\NGStar.dll"

	nHdl := ExecInDLLOpen( cName )

	If nHdl = -1

		If File( cName, 2 )
			Alert( "Falha ao carregar DLL. Verifique atualiza��o da DLL:" + cName )	//"Falha ao carregar DLL. Verifique atualiza��o da DLL"
		Else
			Alert( "ERRO - DLL n�o encontrada:" + cName )	//"ERRO - DLL n�o encontrada"
		EndIf
		
	EndIf

Return()
