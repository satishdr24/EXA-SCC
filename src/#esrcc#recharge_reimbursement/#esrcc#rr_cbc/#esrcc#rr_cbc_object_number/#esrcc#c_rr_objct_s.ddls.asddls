@EndUserText.label: 'Maintain Recharge/Reimbursement Objects '
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_RR_Objct_S
  provider contract transactional_query
  as projection on /ESRCC/I_RR_Objct_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _Objct : redirected to composition child /ESRCC/C_RR_Objct
  
}
