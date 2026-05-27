@EndUserText.label: 'RR Accounting Type Meaning'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity /ESRCC/I_RR_AccountingTypeMean
  as select from /esrcc/rr_acctyp
{

  key    accounting_type       as AccountingType,
         acc_meaning_with_plus as AccMeaningPlus,
         acc_meaning_with_minus as AccMeaningMinus
}

