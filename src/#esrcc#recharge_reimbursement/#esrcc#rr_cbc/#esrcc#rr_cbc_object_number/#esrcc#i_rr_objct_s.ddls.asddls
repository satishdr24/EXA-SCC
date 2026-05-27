@EndUserText.label: 'Recharge/Reimbursement Objects Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_RR_Objct_S
  as select from I_Language
    left outer join /esrcc/rr_objct on 0 = 0
  composition [0..*] of /ESRCC/I_RR_Objct as _Objct
{
  key 1 as SingletonID,
  _Objct,
  max( /esrcc/rr_objct.last_changed_at ) as LastChangedAtMax,
  cast( '' as sxco_transport) as TransportRequestID,
  cast( 'X' as abap_boolean preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
