@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST, #UNION]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RR Source Object Types'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity /ESRCC/I_RROBJECTS 
as select from /esrcc/rr_objtyp
association [0..1] to /esrcc/rr_obtypt as _SourceObjecTypeText on  _SourceObjecTypeText.object_type = $projection.Sourceobject
                                                               and _SourceObjecTypeText.spras       = $session.system_language
{
      @ObjectModel.text.element: ['text']
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
  key object_type                    as Sourceobject,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
     _SourceObjecTypeText.description as text
}
