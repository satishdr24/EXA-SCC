@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Hierarchy'
@Search.searchable: true

define view entity /ESRCC/I_Hierarchy1F_F4
  as select from /ESRCC/I_Hierarchy1_F4
{
  key Hierarchy,
      Description
}
where
  WorkflowStatus = 'F'
