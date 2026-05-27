@EndUserText.label: 'Maintain RR Source Object Types'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_RR_ObjectType
  as projection on /ESRCC/I_RR_ObjectType
{
  key ObjectType,
      @ObjectModel.text.element: [ 'AccountingTypeDescription' ]
      AccountingType,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      _ObjectTypeAll  : redirected to parent /ESRCC/C_RR_ObjectType_S,
      _ObjectTypeText : redirected to composition child /ESRCC/C_RR_ObjectTypeText,
      _ObjectTypeText.Description : localized,
      @Semantics.text: true
      _AccountingTypeDescription.Description as AccountingTypeDescription
}
