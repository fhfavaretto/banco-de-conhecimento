function u_logconsoletst()

    nBegin := Seconds()
    aMessage := {}
    cMsg := ""
    nQtdMsg := 1
    nI := 1

   //Informa��es adicionais
    aAdd(aMessage, {"Date", Date()})
    aAdd(aMessage, {"Hour", Time()})
 
    if getRemoteType() != NO_REMOTE
        aAdd(aMessage, {"Computer", GetClientIP()})
        aAdd(aMessage, {"IP", GetClientIP()})
    endif
 
    //Quando enviado o par�metro de aMessage, o par�metro cMessage n�o � exibido no console
    //FWLogMsg("INFO", "LAST", "MeuGrupo", "MinhaCategoria", cValToChar(nI +1) , "MeuID", cMsg, nQtdMsg, Seconds() - nBegin, aMessage)
    FWLogMsg("INFO", /*cTransactionId*/, "CP114JOB", /*cCategory*/, /*cStep*/, /*cMsgId*/, "### CP114JOB: FIM "+DTOC(DATE())+" "+TIME(), /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

return()

