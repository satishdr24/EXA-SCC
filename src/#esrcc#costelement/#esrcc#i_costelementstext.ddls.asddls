@EndUserText.label: 'Cost elements Text'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_CostElementsText
  as select from /esrcc/cstelemtt
  association [1..1] to /ESRCC/I_CostElements_S as _CostElementsAll on $projection.SingletonID = _CostElementsAll.SingletonID
  association to parent /ESRCC/I_CostElements as _CostElements on $projection.SysId       = _CostElements.Sysid
                                                              and $projection.CostElement = _CostElements.CostElement
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key spras as Spras,
  key sysid as SysId,
  key cost_element as CostElement,
//  key COST_ELEMENT_UUID as CostElementUuid,
  @Semantics.text: true
  description as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  1 as SingletonID,
  _CostElementsAll,
  _CostElements,
  _LanguageText
  
}
