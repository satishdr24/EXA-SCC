@EndUserText.label: 'Cost elements - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_CostElements
  as projection on /ESRCC/I_CostElements
{
      @ObjectModel.text.element: [ 'SysidDescription' ]
  key Sysid,
  key CostElement,
      @ObjectModel.text.element: [ 'CostElemTypeDescription' ]
      CostElemType,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      _SysidText.description            as SysidDescription,
      @Semantics.text: true
      _CostElemTypeText.text            as CostElemTypeDescription,

      _CostElementsAll  : redirected to parent /ESRCC/C_CostElements_S,
      _CostElementsText : redirected to composition child /ESRCC/C_CostElementsText,
      _CostElementsText.Description : localized

}
