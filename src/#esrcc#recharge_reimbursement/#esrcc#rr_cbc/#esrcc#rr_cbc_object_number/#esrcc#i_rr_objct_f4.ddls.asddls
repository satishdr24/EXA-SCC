@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RR Objects'
@Search.searchable: true

define view entity /ESRCC/I_RR_Objct_F4
  as select from /esrcc/rr_objct

  association [0..1] to /ESRCC/I_RR_ObjctText          as _ObjctText            on  _ObjctText.Uuid  = $projection.Uuid
                                                                                and _ObjctText.Spras = $session.system_language

  association [0..1] to /ESRCC/I_COMPANYCODES_F4       as _CcodeText            on  _CcodeText.Sysid       = $projection.Sysid
                                                                                and _CcodeText.Ccode       = $projection.CompanyCode
                                                                                and _CcodeText.Legalentity = $projection.LegalEntity

  association [0..1] to /ESRCC/I_SystemInformationText as _SystemInfoText       on  _SystemInfoText.SystemId = $projection.Sysid
                                                                                and _SystemInfoText.Spras    = $session.system_language

  association [0..1] to /ESRCC/I_PROFITCENTER_F4       as _ProfitCenterText     on  _ProfitCenterText.ProfitCenter = $projection.ProfitCenter

  association [0..1] to /ESRCC/I_FunctionalArea_F4     as _FunctionalAreaText   on  _FunctionalAreaText.FunctionalArea = $projection.FunctionalArea

  association [0..1] to /ESRCC/I_BUSINESSDIV_F4        as _BusinessDivisionText on  _BusinessDivisionText.BusinessDivision = $projection.BusinessDivision

{
      @Consumption.filter.hidden: true
      @UI.hidden: true
  key uuid                                      as Uuid,


      @Consumption.valueHelpDefinition: [ { entity: { name: '/ESRCC/I_SystemInformation_F4', element: 'Sysid' } } ]
      @ObjectModel.text.element: [ 'SysidDescription' ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @UI.textArrangement: #TEXT_LAST
      system_id                                 as Sysid,

      @Consumption.valueHelpDefinition: [ { entity: { name: '/ESRCC/I_LegalEntityAll_F4', element: 'Legalentity' } } ]
      @ObjectModel.text.element: [ 'LegalEntityDescription' ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @UI.textArrangement: #TEXT_LAST
      legal_entity                              as LegalEntity,

      @Consumption.valueHelpDefinition: [ { entity: { name: '/ESRCC/I_COMPANYCODES_F4', element: 'Ccode' } } ]
      @ObjectModel.text.element: [ 'CompanyCodeDescription' ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @UI.textArrangement: #TEXT_LAST
      company_code                              as CompanyCode,

      @Consumption.valueHelpDefinition: [ { entity: { name: '/ESRCC/I_RR_ObjectType_F4', element: 'ObjectType' } } ]
      @ObjectModel.text.element: [ 'ObjectDescription' ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @UI.textArrangement: #TEXT_LAST
      object_type                               as ObjectType,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      object_number                             as ObjectNumber,
      active_flag                               as ActiveFlag,

      @Consumption.valueHelpDefinition: [ { entity: { name: '/ESRCC/I_FunctionalArea_F4', element: 'FunctionalArea' } } ]
      @ObjectModel.text.element: [ 'FunctionalAreaDescription' ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @UI.textArrangement: #TEXT_LAST
      functional_area                           as FunctionalArea,

      @Consumption.valueHelpDefinition: [ { entity: { name: '/ESRCC/I_PROFITCENTER_F4', element: 'ProfitCenter' } } ]
      @ObjectModel.text.element: [ 'ProfitCenterDescription' ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @UI.textArrangement: #TEXT_LAST
      profit_center                             as ProfitCenter,

      @Consumption.valueHelpDefinition: [ { entity: { name: '/ESRCC/I_BUSINESSDIV_F4', element: 'BusinessDivision' } } ]
      @ObjectModel.text.element: [ 'BusinessDivisionDescription' ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @UI.textArrangement: #TEXT_LAST
      business_division                         as BusinessDivision,

      @Consumption.filter.hidden: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @Semantics.text: true
      _ObjctText.Description                    as ObjectDescription,

      @Consumption.filter.hidden: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @Semantics.text: true
      _CcodeText.ccodedescription               as CompanyCodeDescription,

      @Consumption.filter.hidden: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @Semantics.text: true
      _CcodeText.LegalentityDescription         as LegalEntityDescription,

      @Consumption.filter.hidden: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @Semantics.text: true
      _SystemInfoText.Description               as SysidDescription,

      @Consumption.filter.hidden: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @Semantics.text: true
      _FunctionalAreaText.Description           as FunctionalAreaDescription,

      @Consumption.filter.hidden: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @Semantics.text: true
      _ProfitCenterText.profitcenterdescription as ProfitCenterDescription,

      @Consumption.filter.hidden: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @Semantics.text: true
      _BusinessDivisionText.Description         as BusinessDivisionDescription
}
