@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Capacity: Year F4 Help'
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
@UI.presentationVariant: [{ sortOrder: [{direction: #DESC, by: 'Ryear'}] }]
define view entity /ESRCC/I_RyearCapacity
  as select distinct from /esrcc/srv_cpcty
{
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
  key ryear as Ryear
}
