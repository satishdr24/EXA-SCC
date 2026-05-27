@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RR Objects(Partner)'
@Search.searchable: true
@Metadata.allowExtensions: true

define view entity /ESRCC/I_RR_ObjctRec_F4
  as select from /ESRCC/I_RR_Objct_F4 as objct

  association [0..1] to /ESRCC/I_RECEIVINGENTITY_F4 as _LegalEntity on _LegalEntity.Receivingentity = objct.LegalEntity

{
      @Consumption.filter.hidden: true
      @UI.hidden: true
  key objct.Uuid        as Uuid,

      objct.Sysid       as Sysid,

      @Consumption.valueHelpDefinition: [ { entity: { name: '/ESRCC/I_RECEIVINGENTITY_F4', element: 'Receivingentity' } } ]
      @ObjectModel.text.element: [ 'LegalEntityDescription' ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @UI.textArrangement: #TEXT_LAST
      objct.LegalEntity as LegalEntity,

      @Consumption.valueHelpDefinition: [ { entity: { name: '/ESRCC/I_COMPANYCODES_REC_F4', element: 'Ccode' } } ]
      @ObjectModel.text.element: [ 'CompanyCodeDescription' ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @UI.textArrangement: #TEXT_LAST
      objct.CompanyCode as CompanyCode,
      objct.ObjectType,
      objct.ObjectNumber,
      objct.ActiveFlag,
      objct.FunctionalArea,
      objct.ProfitCenter,
      objct.BusinessDivision,
      objct.ObjectDescription,
      objct.CompanyCodeDescription,
      objct.LegalEntityDescription,
      objct.SysidDescription,
      objct.FunctionalAreaDescription,
      objct.ProfitCenterDescription,
      objct.BusinessDivisionDescription
}

where
  _LegalEntity.Receivingentity is not null
