@EndUserText.label: 'Service Product Forecast Rule'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_Chgfca
  as select from /esrcc/chgfca
  association        to parent /ESRCC/I_Chgfca_S   as _RuleAll     on $projection.SingletonID = _RuleAll.SingletonID
  association [0..1] to /ESRCC/I_SERVICEPRODUCT_F4 as _ProductText on _ProductText.ServiceProduct = $projection.Serviceproduct
  association [1..1] to /ESRCC/C_CoRule            as _Rule        on _Rule.RuleId = $projection.ChargeoutRuleId
{
  key uuid                  as Uuid,
      serviceproduct        as Serviceproduct,
      validfrom             as Validfrom,
      validto               as Validto,
      chargeout_rule_id     as ChargeoutRuleId,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      1                     as SingletonID,
      _RuleAll,
      _ProductText,
      _Rule
}
