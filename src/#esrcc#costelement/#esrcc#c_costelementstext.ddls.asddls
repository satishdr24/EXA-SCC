@EndUserText.label: 'Cost elements Text - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_CostElementsText
  as projection on /ESRCC/I_CostElementsText
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Spras,
  key SysId,
  key CostElement,
  Description,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _CostElements : redirected to parent /ESRCC/C_CostElements,
  _CostElementsAll : redirected to /ESRCC/C_CostElements_S
  
}
