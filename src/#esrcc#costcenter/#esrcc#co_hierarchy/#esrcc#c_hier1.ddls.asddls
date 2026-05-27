@EndUserText.label: 'Maintain Hierarchy'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_Hier1
  as projection on /ESRCC/I_Hier1
{
  key Hierarchy,
      WorkflowId,
      @ObjectModel.text.element: ['WorkflowStatusDescription']
      WorkflowStatus,
      CommentId,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/CL_CONFIG_VE_HANDLER'
      Comments,
      WorkflowStatusCriticality,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      _WorkflowStatusText.text as WorkflowStatusDescription,

      _HierarchyAll  : redirected to parent /ESRCC/C_Hier1_S,
      _HierarchyText : redirected to composition child /ESRCC/C_Hier1Text,
      _HierarchyText.Description : localized

}
