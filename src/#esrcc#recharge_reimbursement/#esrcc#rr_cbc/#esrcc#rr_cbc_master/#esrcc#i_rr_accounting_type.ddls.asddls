@EndUserText.label: 'Recharge/Reimbursement Accounting Type'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_RR_Accounting_Type
  as select from /esrcc/rr_acctyp
  association to parent /ESRCC/I_AccountingType_S   as _AccountingTypeAll on $projection.SingletonID = _AccountingTypeAll.SingletonID
  composition [0..*] of /ESRCC/I_AccountingTypeText as _AccountingTypeText
{
  key accounting_type        as AccountingType,
      acc_meaning_with_plus  as AccMeaningWithPlus,
      acc_meaning_with_minus as AccMeaningWithMinus,
      @Semantics.user.createdBy: true
      created_by             as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at             as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by        as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at        as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at  as LocalLastChangedAt,
      1                      as SingletonID,
      _AccountingTypeAll,
      _AccountingTypeText

}
