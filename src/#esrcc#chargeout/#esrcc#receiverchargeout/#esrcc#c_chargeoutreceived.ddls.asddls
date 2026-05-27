@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@EndUserText.label: 'Receivers Chargeout Cost'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity /ESRCC/C_CHARGEOUTRECEIVED
  provider contract transactional_query
  as projection on /ESRCC/I_CHARGEOUTRECEIVED
{
  key UUID,
  key ParentUUID,
  key RootUUID,
      @ObjectModel.text.element: [ 'currenytext' ]
  key Currencytype,
      @ObjectModel.text.element: [ 'costdatasetdescription' ]
      Fplv,
      Ryear,
      RefPoper,      
      Poper,
      Sysid,
      @ObjectModel.text.element: [ 'legalentitydescription' ]
      Legalentity,
      @ObjectModel.text.element: [ 'ccodedescription' ]
      Ccode,
      @ObjectModel.text.element: [ 'costobjectdescription' ]
      Costobject,
      @ObjectModel.text.element: [ 'costcenterdescription' ]
      Costcenter,
      @ObjectModel.text.element: [ 'ProcessTypedescription' ]
      ProcessType,
      @ObjectModel.text.element: [ 'profitcenterdescription' ]
      Profitcenter,
      @ObjectModel.text.element: [ 'businessdescription' ]
      Businessdivision,
      @ObjectModel.text.element: [ 'functionalareadescription' ]
      FunctionalArea,
      @ObjectModel.text.element: [ 'serviceproductdescription' ]
      Serviceproduct,
      ReceiverSysId,
      @ObjectModel.text.element: [ 'RecCcodedescription' ]
      ReceiverCompanyCode,
      @ObjectModel.text.element: [ 'receivingentitydescription' ]
      Receivingentity,
      @ObjectModel.text.element: [ 'RecCostObjectdescription' ]
      ReceiverCostObject,
      @ObjectModel.text.element: [ 'RecCostCenterdescription' ]
      ReceiverCostCenter,
      @ObjectModel.text.element: [ 'chargeoutdescription' ]
      _ServiceCost.Chargeout,
      @ObjectModel.text.element: [ 'servicetypedescription' ]
      _ServiceCost.Servicetype,
      @ObjectModel.text.element: [ 'transactiongroupdescription' ]
      _ServiceCost.Transactiongroup,
      ContractId,
      ErpSalesOrder,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      TotalMarkup,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      TotalCostbase,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      TotalValueAdd,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      TotalPassthrough,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      ChargeoutAmount,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      TotalChargeoutAmount,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      TotalTrueupAmount,      
      Currency,
      @ObjectModel.text.element: [ 'oecdDescription' ]
      _ServiceCost.OECD,
//      @Semantics.text: true
//      _ServiceCost._CostCenterCost.billingfrequencydescription,
//      @Semantics.text: true
//      _ServiceCost._CostCenterCost.billingperioddescription,
      @Semantics.text: true
      costdatasetdescription,
      @Semantics.text: true
      ccodedescription,
      @Semantics.text: true
      legalentitydescription,
      @Semantics.text: true
      costobjectdescription,
      @Semantics.text: true
      costcenterdescription,
      @Semantics.text: true
      Serviceproductdescription,
      @Semantics.text: true
      Transactiongroupdescription,
      @Semantics.text: true
      Servicetypedescription,      
      @Semantics.text: true
      oecdDescription,      
      @Semantics.text: true
      RecCcodedescription,
      @Semantics.text: true
      receivingentitydescription,
      @Semantics.text: true
      RecCostCenterdescription,
      @Semantics.text: true
      RecCostObjectdescription,
      @Semantics.text: true
      chargeoutdescription,
      @Semantics.text: true
      ProcessTypedescription,
      @Semantics.text: true
      profitcenterdescription,
      @Semantics.text: true
      businessdescription,
      @Semantics.text: true
      functionalareadescription,
      _CurrencyTypeText.text                        as currenytext,
      @ObjectModel.text.element: [ 'legalentitycountryname' ]
      LECountry,
      @ObjectModel.text.element: [ 'receivingcountryname' ]
      RecCountry,
      _ServiceCost._CostCenterCost._legalCountryText.CountryName                 as legalentitycountryname,
      _ReceivingCountryText.CountryName             as receivingcountryname
}
where ( ProcessType = 'A'
       or ProcessType = 'S' 
       or ProcessType = 'F' ) 
and TotalChargeoutAmount <> 0


