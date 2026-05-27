@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'Projection View for /ESRCC/R_RR_LI'
@AbapCatalog.extensibility.extensible: true
@Metadata.allowExtensions: true
define root view entity /ESRCC/C_RR_LI_SO
  provider contract transactional_query
  as projection on /ESRCC/I_RR_LI_SO

{
         @UI.lineItem: [{ position: 10, type: #FOR_ACTION, dataAction: 'AcknowledgeSO' },
         { position: 20, type: #FOR_ACTION, dataAction: 'CreateSO' }]
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
