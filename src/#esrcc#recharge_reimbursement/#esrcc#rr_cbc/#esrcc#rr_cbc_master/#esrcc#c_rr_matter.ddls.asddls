@EndUserText.label: 'Maintain Recharge/Reimbursement Matter'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_RR_Matter
  as projection on /ESRCC/I_RR_Matter
{
  key RrMatter,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _RRMatterAll : redirected to parent /ESRCC/C_RR_Matter_S,
  _RRMatterText : redirected to composition child /ESRCC/C_RR_MatterText,
  _RRMatterText.Description : localized
  
}
