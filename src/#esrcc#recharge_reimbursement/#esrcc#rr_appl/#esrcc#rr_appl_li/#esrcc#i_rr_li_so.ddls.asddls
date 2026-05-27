@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST, #UNION]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RR Line item for SO Creation'
@AbapCatalog.extensibility.extensible: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity /ESRCC/I_RR_LI_SO
  as select from /ESRCC/I_RR_LI
{
  key    Ryear,
  key    Period,
  key    Fplv,
  key    SystemID,
  key    LegalEntity,
  key    CompanyCode,
  key    ObjectType,
  key    ObjectNumber,
  key    Ledger,
  key    Belnr,
  key    Buzei,
  key    RRMatter,
  key    Material
}
