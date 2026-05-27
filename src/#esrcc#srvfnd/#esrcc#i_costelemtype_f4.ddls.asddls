@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Element Type'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS
@Metadata.allowExtensions: true

@UI.presentationVariant: [{
    sortOrder: [{
        by: 'CostElemType',
        direction: #ASC
    }]
}]
define view entity /ESRCC/I_COSTELEMTYPE_F4
 as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: '/ESRCC/COSTELEM_TYPE')
{
      @ObjectModel.text.element: ['text']
      @UI.textArrangement: #TEXT_ONLY
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
  key value_low as CostElemType,
      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @UI.hidden: true
      text
}
where
  language = $session.system_language
