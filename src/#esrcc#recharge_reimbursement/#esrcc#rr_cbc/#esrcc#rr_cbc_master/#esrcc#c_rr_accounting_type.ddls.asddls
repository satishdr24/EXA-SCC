@EndUserText.label: 'Maintain Recharge/Reimbursement Accounting Type'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_RR_Accounting_Type
  as projection on /ESRCC/I_RR_Accounting_Type
{
  key AccountingType,
  AccMeaningWithPlus,
  AccMeaningWithMinus,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _AccountingTypeAll : redirected to parent /ESRCC/C_AccountingType_S,
  _AccountingTypeText : redirected to composition child /ESRCC/C_AccountingTypeText,
  _AccountingTypeText.Description : localized
  
}
