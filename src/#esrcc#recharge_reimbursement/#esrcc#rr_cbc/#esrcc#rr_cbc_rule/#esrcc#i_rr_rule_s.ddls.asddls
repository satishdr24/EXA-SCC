@EndUserText.label: 'Recharge/Reimbursement Rules Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_RR_Rule_S
  as select from    I_Language
    left outer join /esrcc/rr_rule on 0 = 0
  composition [0..*] of /ESRCC/I_RR_Rule as _Rule
{
  key 1                                          as SingletonID,
      _Rule,
      max( /esrcc/rr_rule.last_changed_at )      as LastChangedAtMax,
      cast( '' as sxco_transport)                as TransportRequestID,
      cast( 'X' as abap_boolean preserving type) as HideTransport

}
where
  I_Language.Language = $session.system_language
