@EndUserText.label: 'Maintain RR  Source Object Types Text'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_RR_ObjectTypeText
  as projection on /ESRCC/I_RR_ObjectTypeText
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Spras,
  key ObjectType,
  Description,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _ObjectType : redirected to parent /ESRCC/C_RR_ObjectType,
  _ObjectTypeAll : redirected to /ESRCC/C_RR_ObjectType_S
  
}
