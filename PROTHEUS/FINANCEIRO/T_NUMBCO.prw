User Function T_NUMBCO()

	Local c_Linha	:=  "1040001301019T 030000008622440000000   14000000000016275810000007401     30092018000000000014730000000000A  000018712   BOL       092010426608000136BELLA VIDA EMPREENDIMENTO IMOBILIARIO SP          00000000000000048"

	conout( "banco - " + Substr( c_Linha , 1 , 3 ) )
	conout( "num bco - " + Substr( c_Linha, 40 , 18 ) )

Return()