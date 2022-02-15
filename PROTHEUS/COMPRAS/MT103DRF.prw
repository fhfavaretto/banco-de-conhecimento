#Include 'Protheus.ch'

User Function MT103DRF


Local nCombo  := PARAMIXB[1]
Local cCodRet := PARAMIXB[2]
Local aImpRet := {}

//Pos1 : Caracter com o c�digo do imposto a ser considerado nas condi��es.
//Pos2 : nCombo - Se o combo ser� selecionado como sim (1) ou n�o (2)
//Pos3 : cCodRet - C�digo da reten��o

Alert("ponto de entrada MT103DRF executado")

nCombo  := 1
cCodRet := "1700"
aadd(aImpRet,{"IRR",nCombo,cCodRet})

nCombo  := 1
//cCodRet := "1708"
cCodRet := "0297"
aadd(aImpRet,{"ISS",nCombo,cCodRet})

nCombo  := 1
//cCodRet := "2008"
cCodRet := "0297"
aadd(aImpRet,{"PIS",nCombo,cCodRet})

nCombo  := 1
//cCodRet := "2010"
cCodRet := "0297"
aadd(aImpRet,{"COF",nCombo,cCodRet})

nCombo  := 1
//cCodRet := "2050"
cCodRet := "0481"
aadd(aImpRet,{"CSL",nCombo,cCodRet})

varinfo("AIMPRET",aImpRet)

Return aImpRet
