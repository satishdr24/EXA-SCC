@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST, #UNION]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RR Related Material'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity /ESRCC/I_RR_Related_Mat_F4
  as select distinct from /esrcc/rr_li
  association [0..1] to /ESRCC/I_COMPANYCODES_F4     as _CcodeText           on  _CcodeText.Sysid       = $projection.SystemID
                                                                             and _CcodeText.Ccode       = $projection.CompanyCode
                                                                             and _CcodeText.Legalentity = $projection.LegalEntity
  association [0..1] to /ESRCC/I_RROBJECTS           as _SourceObjecTypeText on  _SourceObjecTypeText.Sourceobject = $projection.ObjectType
  association [0..1] to /ESRCC/I_RR_OBJECT_NUMBER_F4 as _ObjNumber           on  _ObjNumber.Sysid        = $projection.SystemID
                                                                             and _ObjNumber.CompanyCode  = $projection.CompanyCode
                                                                             and _ObjNumber.LegalEntity  = $projection.LegalEntity
                                                                             and _ObjNumber.ObjectType   = $projection.ObjectType
                                                                             and _ObjNumber.ObjectNumber = $projection.ObjectNumber
    association [0..1] to /ESRCC/I_RRMATTER_F4         as _RR_MatterText       on  _RR_MatterText.Matter = $projection.RRMatter
{
         @UI.hidden: true
  key    ryear                              as Reportyear,
         @UI.hidden: true
  key    poper                              as Period,
         @UI.hidden: true
  key    fplv                               as Datasource,
         @UI.hidden: true
  key    ledger                             as Ledger,
         @UI.hidden: true
  key    reference_belnr                    as ReferenceBelnr,
         @ObjectModel.text.element: [ 'SysidDescription' ]
         @UI.lineItem: [{ position: 1 }]
         @UI.textArrangement: #TEXT_LAST
  key    sysid                              as SystemID,
         @ObjectModel.text.element: [ 'LegalEntityDescription' ]
         @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
         @UI.lineItem: [{ position: 2 }]
         @UI.textArrangement: #TEXT_LAST
  key    legalentity                        as LegalEntity,
         @ObjectModel.text.element: [ 'CompanyCodeDescription' ]
         @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
         @UI.lineItem: [{ position: 3 }]
         @UI.textArrangement: #TEXT_LAST
  key    ccode                              as CompanyCode,
         @ObjectModel.text.element: [ 'SourceObjectDescription' ]
         @UI.lineItem: [{ position: 4 }]
         @UI.textArrangement: #TEXT_LAST
         @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
  key    object_type                        as ObjectType,
         @ObjectModel.text.element: [ 'ObjectNumDescription' ]
         @UI.lineItem: [{ position: 5 }]
         @UI.textArrangement: #TEXT_LAST
         @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
  key    object_number                      as ObjectNumber,
         @UI.lineItem: [{ position: 6 }]
  key    belnr                              as DocumentNumber,
         @UI.lineItem: [{ position: 7 }]
  key    buzei                              as NumberOfItems,
         //         @ObjectModel.text.element: [ 'RRMatterDescription' ]
         @UI.lineItem: [{ position: 8 }]
         @UI.textArrangement: #TEXT_LAST
         @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
  key    rr_matter                          as RRMatter,
         @UI.lineItem: [{ position: 9 }]
         @UI.textArrangement: #TEXT_LAST
         @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
  key    material                           as RRRelatedMaterial,

         @Semantics.text: true
         @Consumption.filter.hidden: true
         _CcodeText._SystemText.Description as SysidDescription,

         @Semantics.text: true
         @Consumption.filter.hidden: true
         _CcodeText.ccodedescription        as CompanyCodeDescription,

         @Semantics.text: true
         _CcodeText.LegalentityDescription  as LegalEntityDescription,

         @Semantics.text: true
         @Consumption.filter.hidden: true
         _SourceObjecTypeText.text          as SourceObjectDescription,

         @Semantics.text: true
         @Consumption.filter.hidden: true
         _ObjNumber.Description             as ObjectNumDescription,

         @Semantics.text: true
         @Consumption.filter.hidden: true
         _RR_MatterText.RRMatterDescription as RRMatterDescription

}
