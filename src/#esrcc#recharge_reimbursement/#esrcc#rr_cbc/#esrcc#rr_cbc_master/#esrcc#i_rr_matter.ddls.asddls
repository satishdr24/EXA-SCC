@EndUserText.label: 'Recharge/Reimbursement Matter'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_RR_Matter
  as select from /esrcc/rrmatter
  association to parent /ESRCC/I_RR_Matter_S as _RRMatterAll on $projection.SingletonID = _RRMatterAll.SingletonID
  composition [0..*] of /ESRCC/I_RR_MatterText as _RRMatterText
{
  key rr_matter as RrMatter,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  1 as SingletonID,
  _RRMatterAll,
  _RRMatterText
  
}
