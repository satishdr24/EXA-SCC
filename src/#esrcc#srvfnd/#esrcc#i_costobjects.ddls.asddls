@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Maintain Cost Object Types'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@Search.searchable: true
define view entity /ESRCC/I_COSTOBJECTS
  as select from /esrcc/cstobjtyp
  association [0..1] to /esrcc/cstbjtypt as _CostObjecTypeText on  _CostObjecTypeText.cost_object = $projection.Costobject
                                                               and _CostObjecTypeText.spras       = $session.system_language
{
      @ObjectModel.text.element: ['text']
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
  key cost_object                    as Costobject,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      _CostObjecTypeText.description as text
}
