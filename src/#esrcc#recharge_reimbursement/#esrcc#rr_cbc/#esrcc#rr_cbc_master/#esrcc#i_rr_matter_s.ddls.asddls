@EndUserText.label: 'Recharge/Reimbursement Matter Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_RR_Matter_S
  as select from I_Language
    left outer join /esrcc/rrmatter on 0 = 0
  composition [0..*] of /ESRCC/I_RR_Matter as _RRMatter
{
  key 1 as SingletonID,
  _RRMatter,
  max( /esrcc/rrmatter.last_changed_at ) as LastChangedAtMax,
  cast( '' as sxco_transport) as TransportRequestID,
  cast( 'X' as abap_boolean preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
