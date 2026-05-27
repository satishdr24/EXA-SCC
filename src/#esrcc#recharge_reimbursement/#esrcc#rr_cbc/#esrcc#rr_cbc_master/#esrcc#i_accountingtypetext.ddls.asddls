@EndUserText.label: 'Recharge/Reimbursement Accounting Type T'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_AccountingTypeText
  as select from /esrcc/rr_acctyt
  association [1..1] to /ESRCC/I_AccountingType_S as _AccountingTypeAll on $projection.SingletonID = _AccountingTypeAll.SingletonID
  association to parent /ESRCC/I_RR_Accounting_Type as _AccountingType on $projection.AccountingType = _AccountingType.AccountingType
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key spras as Spras,
  key accounting_type as AccountingType,
  @Semantics.text: true
  description as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  1 as SingletonID,
  _AccountingTypeAll,
  _AccountingType,
  _LanguageText
  
}
