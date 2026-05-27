@EndUserText.label: 'Maintain RR SO Group by Configuration'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_RR_Sales_Config_S
  provider contract transactional_query
  as projection on /ESRCC/I_RR_Sales_Config_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _RR_Sales_Config : redirected to composition child /ESRCC/C_RR_Sales_Config
  
}
