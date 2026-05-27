@EndUserText.label: 'Maintain Recharge/Reimbursement Rules Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_RR_Rule_S
  provider contract transactional_query
  as projection on /ESRCC/I_RR_Rule_S
{
  key SingletonID,
      LastChangedAtMax,
      TransportRequestID,
      HideTransport,
      _Rule : redirected to composition child /ESRCC/C_RR_Rule

}
