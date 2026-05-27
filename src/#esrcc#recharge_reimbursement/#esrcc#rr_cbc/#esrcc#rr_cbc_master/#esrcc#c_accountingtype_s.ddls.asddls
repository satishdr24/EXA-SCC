@EndUserText.label: 'Maintain Recharge/Reimbursement Accounting Type'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_AccountingType_S
  provider contract transactional_query
  as projection on /ESRCC/I_AccountingType_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _AccountingType : redirected to composition child /ESRCC/C_RR_Accounting_Type
  
}
