@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Royalty Base: Year F4 Help'
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
@UI.presentationVariant: [{ sortOrder: [{direction: #DESC, by: 'Ryear'}] }]
define view entity /ESRCC/I_RyearRoyaltyBase
  as select distinct from /esrcc/roybasval
{
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
  key ryear as Ryear
}
