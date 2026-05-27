@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RR Matter'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Search.searchable: true
define view entity /ESRCC/I_RRMATTER_F4
  as select from /esrcc/rrmatter
  association [0..1] to /esrcc/rrmattert as _RRMatterText on  _RRMatterText.rr_matter = $projection.Matter
                                                          and _RRMatterText.spras     = $session.system_language

{
        @ObjectModel.text.element: ['RRMatterDescription']
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
  key   rr_matter                 as Matter,

        @Semantics.text: true
        @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
        @Consumption.filter.hidden: true
        _RRMatterText.description as RRMatterDescription
}
