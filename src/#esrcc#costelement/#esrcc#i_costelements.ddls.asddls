@EndUserText.label: 'Cost elements'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK

define view entity /ESRCC/I_CostElements
  as select from /esrcc/cstelemnt
  association        to parent /ESRCC/I_CostElements_S as _CostElementsAll on  $projection.SingletonID = _CostElementsAll.SingletonID
  composition [0..*] of /ESRCC/I_CostElementsText      as _CostElementsText
  association [0..1] to /esrcc/sys_infot               as _SysidText       on  _SysidText.system_id = $projection.Sysid
                                                                           and _SysidText.spras     = $session.system_language
  association [0..1] to /ESRCC/I_COSTELEMTYPE_F4       as _CostElemTypeText  on  _CostElemTypeText.costelemtype = $projection.CostElemType
                                                                                                                                                 
{
  key sysid                 as Sysid,      
  key cost_element          as CostElement,
      costelemtype          as CostElemType,
//      active                as Active,
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
      _CostElementsAll,
      _CostElementsText,
      _CostElemTypeText,
      _SysidText

}
