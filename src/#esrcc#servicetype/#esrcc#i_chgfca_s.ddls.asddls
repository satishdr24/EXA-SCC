@EndUserText.label: 'Forecast Rule'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_Chgfca_S
  as select from I_Language
    left outer join /ESRCC/CHGFCA on 0 = 0
  composition [0..*] of /ESRCC/I_Chgfca as _Rule
{
  key 1 as SingletonID,
  _Rule,
  max( /ESRCC/CHGFCA.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
