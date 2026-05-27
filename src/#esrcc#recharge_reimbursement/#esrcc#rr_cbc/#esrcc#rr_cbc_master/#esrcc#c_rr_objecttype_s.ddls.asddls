@EndUserText.label: 'Maintain RR  Source Object Types Singlet'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_RR_ObjectType_S
  provider contract transactional_query
  as projection on /ESRCC/I_RR_ObjectType_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _ObjectType : redirected to composition child /ESRCC/C_RR_ObjectType
  
}
