@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@EndUserText.label: 'Workflow Controller - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_WfSwitch
  as projection on /ESRCC/I_WfSwitch
{
      @ObjectModel.text.element: ['ApplicationDescription']
  key Application,
      Workflowactive,
      @ObjectModel.text.element: ['WorkflowGroupByText']
      WorkflowGroupBy,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      @Semantics.text: true
      _ApplicationTypeText.text as ApplicationDescription,
      @Semantics.text: true
      _WorkflowgroupbyText.text as WorkflowGroupByText,
      _WorkflowSwitchAll : redirected to parent /ESRCC/C_WfSwitch_S

}
