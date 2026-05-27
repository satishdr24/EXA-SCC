@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Indirect Allocation Key: Year F4 Help'
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
@UI.presentationVariant: [{ sortOrder: [{direction: #DESC, by: 'Ryear'}] }]
define view entity /ESRCC/I_RyearAllocation
  as select distinct from /esrcc/indtalloc
{
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
  key ryear as Ryear
}
