@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]

@AccessControl.authorizationCheck: #CHECK

@EndUserText.label: 'Maintain RR SO Group by Configuration'

@Metadata.allowExtensions: true

define view entity /ESRCC/C_RR_Sales_Config
  as projection on /ESRCC/I_RR_Sales_Config

{
  key     GroupByKey,

          GroupBy,
          
          GroupByItem,
          
          ItemCount,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/RR_SO_GROUPBY_DESC'
  virtual GroupByDescription     : abap.char(200),

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/RR_SO_GROUPBY_DESC'
  virtual GroupByItemDescription : abap.char(200),

          CreatedBy,
          CreatedAt,
          LastChangedBy,
          LastChangedAt,

          @Consumption.hidden: true
          LocalLastChangedAt,

          @Consumption.hidden: true
          SingletonID,

          _RR_Sales_ConfigAll : redirected to parent /ESRCC/C_RR_Sales_Config_S
}
