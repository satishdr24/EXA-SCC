@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@EndUserText.label: 'RR Source Object Types'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
define view entity /ESRCC/I_RR_ObjectType_F4
  as select from /esrcc/rr_objtyp
  association [0..1] to /ESRCC/I_RR_ObjectTypeText as _ObjectTypeText on  _ObjectTypeText.ObjectType = $projection.ObjectType
                                                                      and _ObjectTypeText.Spras      = $session.system_language
{
      @ObjectModel.text.element: ['ObjectDescription']
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
  key object_type                 as ObjectType,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      accounting_type             as AccountingType,
      
      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @Consumption.filter.hidden: true
      _ObjectTypeText.Description as ObjectDescription

}
