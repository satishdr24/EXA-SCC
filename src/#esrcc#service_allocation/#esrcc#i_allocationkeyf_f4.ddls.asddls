@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Allocation Key'
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity /ESRCC/I_AllocationKeyF_F4
  as select from /ESRCC/I_ALLOCATION_KEY_F4
{
  key Allocationkey,
      AllocationKeyDescription
}
where
  WorkflowStatus = 'F'
