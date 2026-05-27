@EndUserText.label: 'Copy Recharge/Reimbursement Object'
define root abstract entity /ESRCC/D_RR_CopyObjctP
{
  @Consumption.valueHelpDefinition: [{ entity: {  name: '/ESRCC/I_SystemInformation_F4', element: 'SystemId' },
                                       useForValidation: true }]
  Sysid         : /esrcc/sysid;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_LegalEntityAll_F4', element: 'Legalentity' },
                                       useForValidation: true }]
  LegalEntity   : /esrcc/legalentity;

  @Consumption.valueHelpDefinition: [{ entity: {  name: '/ESRCC/I_COMPANYCODES_F4', element: 'Ccode' },
                                       additionalBinding: [{ element: 'Sysid', localElement: 'Sysid' },
                                                           { element: 'Legalentity', localElement: 'LegalEntity'}],
                                       useForValidation: true }]
  CompanyCode   : /esrcc/ccode_de;

  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_RROBJECTS', element: 'Sourceobject' },
                                       useForValidation: true }]
  object_type   : /esrcc/rr_object_type;
  object_number : /esrcc/rr_object_number;


}
