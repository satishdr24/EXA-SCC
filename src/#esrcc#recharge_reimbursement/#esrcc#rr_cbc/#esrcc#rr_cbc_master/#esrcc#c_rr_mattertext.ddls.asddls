@EndUserText.label: 'Maintain Recharge/Reimbursement Matter T'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_RR_MatterText
  as projection on /ESRCC/I_RR_MatterText
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Spras,
  key RrMatter,
  Description,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _RRMatter : redirected to parent /ESRCC/C_RR_Matter,
  _RRMatterAll : redirected to /ESRCC/C_RR_Matter_S
  
}
