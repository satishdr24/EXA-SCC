@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST, #UNION]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RR Object Number'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity /ESRCC/I_RR_OBJECT_NUMBER_F4 
as select from /esrcc/rr_objct
association [0..1] to /esrcc/rr_objctt           as _Text                 on  _Text.uuid = $projection.uuid
                                                                            and _Text.spras            = $session.system_language
association [0..1] to /ESRCC/I_COMPANYCODES_F4   as _CcodeText            on  _CcodeText.Sysid       = $projection.Sysid
                                                                            and _CcodeText.Ccode       = $projection.CompanyCode
                                                                            and _CcodeText.Legalentity = $projection.LegalEntity
association [0..1] to /ESRCC/I_RROBJECTS  as _SourceObjecTypeText on _SourceObjecTypeText.Sourceobject = $projection.Sourceobject 
association [0..1] to /ESRCC/I_FunctionalArea_F4 as _FunctionalAreaText   on  _FunctionalAreaText.FunctionalArea = $projection.FunctionalArea
association [0..1] to /ESRCC/I_PROFITCENTER_F4   as _ProfitCenterText     on  _ProfitCenterText.ProfitCenter = $projection.ProfitCenter
association [0..1] to /ESRCC/I_BUSINESSDIV_F4    as _BusinessDivisionText on  _BusinessDivisionText.BusinessDivision = $projection.BusinessDivision
{
        
      @UI.hidden: true
      key uuid as uuid, 
     
      @ObjectModel.text.element: [ 'SysidDescription' ]
      @UI.lineItem: [{ position: 1 }]
      @UI.textArrangement: #TEXT_LAST
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SystemInformation_F4', element: 'SystemId' }}]
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      system_id  as Sysid,
      
      @ObjectModel.text.element: [ 'LegalEntityDescription' ]
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @UI.lineItem: [{ position: 2 }]
      @UI.textArrangement: #TEXT_LAST
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_LegalEntityAll_F4', element: 'Legalentity' }}]
     legal_entity as LegalEntity,
      
      @ObjectModel.text.element: [ 'CompanyCodeDescription' ]
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @UI.lineItem: [{ position: 3 }]
      @UI.textArrangement: #TEXT_LAST
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_F4', element: 'Ccode' }}]
      company_code as CompanyCode,
      
      @ObjectModel.text.element: [ 'SourceObjectDescription' ]
      @UI.lineItem: [{ position: 4 }]
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_RROBJECTS', element: 'Sourceobject' }}]
      object_type   as ObjectType,
      
      @ObjectModel.text.element: [ 'Description' ]
      @UI.lineItem: [{ position: 5 }]
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      object_number as ObjectNumber,
      
      @ObjectModel.text.element: [ 'FunctionalAreaDescription' ]
      @UI.lineItem: [{ position: 6 }]
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_FunctionalArea_F4', element: 'FunctionalArea' }}]
      functional_area as FunctionalArea,
      
       @ObjectModel.text.element: [ 'ProfitCenterDescription' ]
      @UI.lineItem: [{ position: 7 }]
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_PROFITCENTER_F4', element: 'ProfitCenter' }}]
      profit_center as ProfitCenter,
      
      @ObjectModel.text.element: [ 'BusinessDivisionDescription' ]
      @UI.lineItem: [{ position: 8 }]
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_BUSINESSDIV_F4', element: 'BusinessDivision' }}]
      business_division as BusinessDivision,
      
      @Semantics.text: true
      @Consumption.filter.hidden: true
      _Text.description                         as Description,
      
      @UI.hidden: true
      object_type as Sourceobject,
      
      @Semantics.text: true
      @Consumption.filter.hidden: true
      _CcodeText._SystemText.Description        as SysidDescription,

      @Semantics.text: true
      @Consumption.filter.hidden: true
      _CcodeText.ccodedescription               as CompanyCodeDescription,

      @Semantics.text: true
      _CcodeText.LegalentityDescription         as LegalEntityDescription,
            
      @Semantics.text: true
      @Consumption.filter.hidden: true
     _SourceObjecTypeText.text as SourceObjectDescription,
     
     @Semantics.text: true
     _FunctionalAreaText.Description           as FunctionalAreaDescription,
     
     @Semantics.text: true
     _ProfitCenterText.profitcenterdescription as ProfitCenterDescription,
     
     @Semantics.text: true
     _BusinessDivisionText.Description as BusinessDivisionDescription
      
}
