@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@EndUserText.label: 'RR SO Configuration for Group by'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.resultSet.sizeCategory: #XS
@Metadata.ignorePropagatedAnnotations: true
@UI.presentationVariant: [{ sortOrder: [{direction: #ASC, by: 'GroupByKey'}] }]
@Search.searchable: true
define root view entity /ESRCC/I_RR_SO_Config_F4
  as select from /esrcc/rr_soconf
{

      @ObjectModel.text.element: ['GroupByFields']
      @UI.textArrangement: #TEXT_ONLY
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @EndUserText.label: 'Group By Key'
  key group_by_key                     as GroupByKey,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @EndUserText.label: 'Group By Fields'
      group_by                         as GroupBy,
      
       @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/RR_SO_GROUPBY_DESC'
      cast( '' as /esrcc/rr_group_by ) as GroupByFields

}
