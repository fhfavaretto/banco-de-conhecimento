user function AfterLogin()

	Local aInfo := GetUserInfoArray() // Resultado: (Informa��es dos processos)
	Local c_user	:= paramixb[2]

	if substr(ainfo[1][11],20,15) <> c_user
		final("mensagem 1","mensagem 2")
	EndIf


Return