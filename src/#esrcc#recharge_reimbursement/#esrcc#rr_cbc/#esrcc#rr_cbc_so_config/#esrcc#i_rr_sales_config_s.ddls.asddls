@EndUserText.label: 'Recharge/Reimbursement SO Configuration'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_RR_Sales_Config_S
  as select from I_Language
    left outer join /ESRCC/RR_SOCONF on 0 = 0
  composition [0..*] of /ESRCC/I_RR_Sales_Config as _RR_Sales_Config
{
  key 1 as SingletonID,
  _RR_Sales_Config,
  max( /ESRCC/RR_SOCONF.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
