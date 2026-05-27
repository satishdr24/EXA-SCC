@EndUserText.label: 'Copy'
define root abstract entity /ESRCC/D_CopyHierDefP
{
  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_Hierarchy1F_F4', element: 'Hierarchy' }}]
  Hierarchy1 : /esrcc/hierarchy1;
  
  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_Hierarchy2_F4', element: 'Hierarchy' }}]
  Hierarchy2 : /esrcc/hierarchy2;
  
  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_Hierarchy3_F4', element: 'Hierarchy' }}]
  Hierarchy3 : /esrcc/hierarchy3;
  
  @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_Hierarchy4_F4', element: 'Hierarchy' }}]
  Hierarchy4 : /esrcc/hierarchy4;
  
  ValidFrom  : /esrcc/validfrom;

}
