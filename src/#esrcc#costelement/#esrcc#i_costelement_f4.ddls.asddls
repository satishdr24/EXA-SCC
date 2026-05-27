@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Element'

@Search.searchable: true
define view entity /ESRCC/I_COSTELEMENT_F4
  as select from /esrcc/cstelemnt
  association [0..1] to /esrcc/cstelemtt               as _CostelementText on  _CostelementText.sysid = $projection.Sysid
                                                                           and _CostelementText.cost_element = $projection.Costelement 
                                                                           and _CostelementText.spras             = $session.system_language

  association [0..1] to /ESRCC/I_SystemInformationText as _SystemInfoText  on  _SystemInfoText.SystemId = $projection.Sysid
                                                                           and _SystemInfoText.Spras    = $session.system_language
{
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: [ 'SysidDescription' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_F4', element: 'Sysid' },
                                       useForValidation: true }]
   key sysid                             as Sysid,

      @ObjectModel.text.element: ['costelementdescription']
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
   key cost_element                      as Costelement,
   
      costelemtype                       as CostElementType,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @Consumption.filter.hidden: true
      _CostelementText.description      as costelementdescription,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.9 }
      @Consumption.filter.hidden: true
      _SystemInfoText.Description       as SysidDescription,

      _SystemInfoText
}
