@EndUserText.label: 'Copy'
define root abstract entity /ESRCC/D_CopyCostElementCharP
{
  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SystemInformation_F4', element: 'SystemId' }, useForValidation: true }]
  Sysid           : /esrcc/sysid;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_LegalEntityAll_F4', element: 'Legalentity' }, useForValidation: true }]
  LegalEntity     : /esrcc/legalentity;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_F4', element: 'Ccode' },
                                       additionalBinding: [{ localElement: 'Sysid', element: 'Sysid' },
                                                           { localElement: 'LegalEntity', element: 'Legalentity' }],
                                       useForValidation: true }]
  CompanyCode     : /esrcc/ccode_de;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTOBJECTS', element: 'Costobject' }, useForValidation: true }]
  CostObject      : /esrcc/costobject_de;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSCEN_F4', element: 'Costcenter' },
                                       additionalBinding: [{ localElement: 'Sysid', element: 'Sysid' },
                                                           { localElement: 'LegalEntity', element: 'LegalEntity' },
                                                           { localElement: 'CompanyCode', element: 'CompanyCode' },
                                                           { localElement: 'CostObject', element: 'Costobject' }], useForValidation: true }]
  Costcenter      : /esrcc/costcenter;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTELEMENT_F4', element: 'Costelement' },
                                       useForValidation: true }]
  Costelementfrom : /esrcc/costelement_from;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTELEMENT_F4', element: 'Costelement' },
                                     useForValidation: true }]
  Costelementto   : /esrcc/costelement_to;
  ValidFrom       : /esrcc/validfrom;
  ValidTo         : /esrcc/validto;

  //  @UI.hidden      : true
  //  @EndUserText.label: 'Cost Element UUID'
  //  CostElementUuid : sysuuid_x16;
}
