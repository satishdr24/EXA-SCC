@EndUserText.label: 'Maintain Recharge/Reimbursement Matter S'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_RR_Matter_S
  provider contract transactional_query
  as projection on /ESRCC/I_RR_Matter_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _RRMatter : redirected to composition child /ESRCC/C_RR_Matter
  
}
