@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST, #UNION]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer/Vendor'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity /ESRCC/I_VENDOR_F4 as select from /esrcc/le as le
association [0..1] to /esrcc/le_t as letext on  le.legalentity = letext.legalentity
                                            and letext.spras            = $session.system_language
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @ObjectModel.text.element: ['Description']
  key legalentity        as vendor,

      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      letext.description as Description
}
