@AccessControl.authorizationCheck: #CHECK
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@EndUserText.label: 'Maintain Recharge/Reimbursement Objects '
@Metadata.allowExtensions: true
define view entity /ESRCC/C_RR_ObjctText
  as projection on /ESRCC/I_RR_ObjctText

{
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Language', element: 'Language' } } ]
      @ObjectModel.text.element: [ 'LanguageName' ]
  key Spras,

  key Uuid,

      Description,

      @Consumption.hidden: true
      LocalLastChangedAt,

      @Consumption.hidden: true
      SingletonID,

      _LanguageText.LanguageName : localized,
      _Objct    : redirected to parent /ESRCC/C_RR_Objct,
      _ObjctAll : redirected to /ESRCC/C_RR_Objct_S
}
