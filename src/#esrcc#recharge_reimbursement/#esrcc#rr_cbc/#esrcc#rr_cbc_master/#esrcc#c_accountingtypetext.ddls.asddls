@EndUserText.label: 'Maintain Recharge/Reimbursement Accounting Type'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_AccountingTypeText
  as projection on /ESRCC/I_AccountingTypeText
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Spras,
  key AccountingType,
  Description,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _AccountingType : redirected to parent /ESRCC/C_RR_Accounting_Type,
  _AccountingTypeAll : redirected to /ESRCC/C_AccountingType_S
  
}
