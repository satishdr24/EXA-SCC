@EndUserText.label: 'Recharge/Reimbursement Accounting Type S'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_AccountingType_S
  as select from I_Language
    left outer join /esrcc/rr_acctyp on 0 = 0
  composition [0..*] of /ESRCC/I_RR_Accounting_Type as _AccountingType
{
  key 1 as SingletonID,
  _AccountingType,
  max( /esrcc/rr_acctyp.last_changed_at ) as LastChangedAtMax,
  cast( '' as sxco_transport) as TransportRequestID,
  cast( 'X' as abap_boolean preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
