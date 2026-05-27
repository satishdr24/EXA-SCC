@EndUserText.label: 'Create Sales Order'
define abstract entity /ESRCC/D_RR_CreateSO
{
  @Consumption.valueHelpDefinition: [ { entity: { name: '/ESRCC/I_RR_SO_Config_F4', element: 'GroupByKey' },
                                        useForValidation: true } ]
    group_by_key : /esrcc/rr_group_by_key;
}
