@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@EndUserText.label: 'Allocation Key - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_AllocationKey
  as projection on /ESRCC/I_AllocationKey
{
  key Allocationkey,
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

      _AllocationKeyAll  : redirected to parent /ESRCC/C_AllocationKey_S,
      _AllocationKeyText : redirected to composition child /ESRCC/C_AllocationKeyText,
      _AllocationKeyText.Description : localized

}
