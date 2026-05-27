@AbapCatalog.viewEnhancementCategory: [ #NONE ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Hierarchy interface for Invalid Records'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: { serviceQuality: #X, sizeCategory: #S, dataClass: #MIXED }

define view entity /ESRCC/I_InvalidRecordsCount
  as select from /esrcc/inv_rcrds

{
  key log_uuid                            as parent_hid,

      count(distinct invalid_record_uuid) as LineCount
}

group by
  log_uuid;
