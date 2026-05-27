@EndUserText.label: 'Recharge/Reimbursement Rules Text'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_RR_RuleText
  as select from /esrcc/rr_rulet
  association [1..1] to /ESRCC/I_RR_Rule_S      as _RuleAll      on $projection.SingletonID = _RuleAll.SingletonID
  association        to parent /ESRCC/I_RR_Rule as _Rule         on $projection.RuleId = _Rule.RuleId
  association [0..*] to I_LanguageText          as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
      @Semantics.language: true
  key spras                 as Spras,
  key rule_id               as RuleId,
      @Semantics.text: true
      description           as Description,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      1                     as SingletonID,
      _RuleAll,
      _Rule,
      _LanguageText

}
