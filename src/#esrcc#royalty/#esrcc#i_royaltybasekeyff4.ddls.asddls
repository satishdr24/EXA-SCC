@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Royalty Base Key'
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Search.searchable: true

define view entity /ESRCC/I_RoyaltyBaseKeyFF4
  as select from /ESRCC/I_RoyaltyBaseKeyF4
{
  key RoyaltyBaseKey,
      Description
}
where
  WorkflowStatus = 'F'
