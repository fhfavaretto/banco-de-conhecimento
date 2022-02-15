#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA120BUT  � Autor � Cassio Loureiro    � Data �  12/07/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Adciona o botao de consulta dos saldos das filiais por     ���
���          � Produto                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MA120BUT


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

aBtuser := {}

AAdd(aBtuser,{"CLIPS",{|| execblock("MCOME999", .F., .F.) },"Conhec." }) // Inserido por Emerson - 05.02.2010


Return(aBtuser)

User Function MCOME999(_nRegSC7)

Local nPosPrd     := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_PRODUTO'})
Local nPosItem    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_ITEM'})   

dbSelectArea('SC7')
dbSetOrder(4)
If MsSeek(xFilial('SC7')+aCols[n][nPosPrd]+cA120Num+aCols[n][nPosItem])
     _nRegSc7:=SC7->( RecNo() )
EndIf 

nOld := n
n    := 1

MsDocument("SC7",_nRegSC7,2,,1) 

n:=nOld

Return()
