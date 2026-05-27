@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]

@AccessControl.authorizationCheck: #CHECK

@EndUserText.label: 'Recharge/Reimbursement SO Configuration'

define view entity /ESRCC/I_RR_Sales_Config
  as select from /esrcc/rr_soconf

  association to parent /ESRCC/I_RR_Sales_Config_S as _RR_Sales_ConfigAll on $projection.SingletonID = _RR_Sales_ConfigAll.SingletonID

{
  key group_by_key          as GroupByKey,

      group_by              as GroupBy,

      group_by_item         as GroupByItem,
      item_count            as ItemCount,

      @Semantics.user.createdBy: true
      created_by            as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,

      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      1                     as SingletonID,

      _RR_Sales_ConfigAll
}
