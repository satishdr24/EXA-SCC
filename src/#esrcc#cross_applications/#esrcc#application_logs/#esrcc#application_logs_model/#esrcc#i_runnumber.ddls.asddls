@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Run Number'
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
@UI.presentationVariant: [{ sortOrder: [{direction: #DESC, by: 'RunNumber'}] }]
define root view entity /ESRCC/I_RunNumber
  as select distinct from /esrcc/log_hdr
{
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }  
  key run_number as RunNumber
}
