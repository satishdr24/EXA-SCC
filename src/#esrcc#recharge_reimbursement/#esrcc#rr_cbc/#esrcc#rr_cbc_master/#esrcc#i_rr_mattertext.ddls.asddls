@EndUserText.label: 'Recharge/Reimbursement Matter Text'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_RR_MatterText
  as select from /esrcc/rrmattert
  association [1..1] to /ESRCC/I_RR_Matter_S as _RRMatterAll on $projection.SingletonID = _RRMatterAll.SingletonID
  association to parent /ESRCC/I_RR_Matter as _RRMatter on $projection.RrMatter = _RRMatter.RrMatter
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key spras as Spras,
  key rr_matter as RrMatter,
  @Semantics.text: true
  description as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  1 as SingletonID,
  _RRMatterAll,
  _RRMatter,
  _LanguageText
  
}
