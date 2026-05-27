@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]

@AccessControl.authorizationCheck: #CHECK

@EndUserText.label: 'Projection View for /ESRCC/R_RR_LI'

@Metadata.allowExtensions: true

define root view entity /ESRCC/C_RR_LI
  provider contract transactional_query
  as projection on /ESRCC/I_RR_LI

{
  key Ryear,
  key Period,

      @ObjectModel.text.element: [ 'DatasetDescription' ]
  key Fplv,

      @ObjectModel.text.element: [ 'SysidDescription' ]
  key SystemID,

      @ObjectModel.text.element: [ 'LegalEntityDescription' ]
  key LegalEntity,

      @ObjectModel.text.element: [ 'CompanyCodeDescription' ]
  key CompanyCode,

      @ObjectModel.text.element: [ 'ObjectDescription' ]
  key ObjectType,

      @ObjectModel.text.element: [ 'ObjectNumDescription' ]
  key ObjectNumber,

  key Ledger,
  key Belnr,
  key Buzei,

      @ObjectModel.text.element: [ 'RRMatterDescription' ]
  key RRMatter,

  key Material,

      ReferenceBelnr,
      BelnrText,

      @ObjectModel.text.element: [ 'DatasourceDescription' ]
      DataSource,

      @DefaultAggregation: #SUM
      @ObjectModel.filter.enabled: false
      @Semantics.amount.currencyCode: 'LocalCurrency'
      LocalValue,

      @ObjectModel.filter.enabled: false
      LocalCurrency,

      @DefaultAggregation: #SUM
      @ObjectModel.filter.enabled: false
      @Semantics.amount.currencyCode: 'GroupCurrency'
      Ksl,

      @ObjectModel.filter.enabled: false
      GroupCurrency,

      @DefaultAggregation: #SUM
      @ObjectModel.filter.enabled: false
      @Semantics.quantity.unitOfMeasure: 'Meins'
      Quantity,

      @ObjectModel.filter.enabled: false
      Meins,

      @ObjectModel.text.element: [ 'VendorDescription' ]
      Vendor,

      PostingKey,
      Budat,

      @ObjectModel.text.element: [ 'ProfitcenterDescription' ]
      ProfitCenter,

      @ObjectModel.text.element: [ 'BusinessdivisonDescription' ]
      Businessdivision,

      @ObjectModel.text.element: [ 'FunctionalAreaDescription' ]
      Functionalarea,

      DocumentDate,
      Assignment,
      ItemText,
      SoItem,
      SalesOrg,
      DistributionChannel,
      Division,
      ServiceMaterial,

      SalesorderNumber,
      SalesorderReference,

      @Semantics.user.createdBy: true
      CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      CreatedAt,

      @Semantics.user.lastChangedBy: true
      LastChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,

      @ObjectModel.text.element: [ 'RecSysidDescription' ]
      RecSystemId,

      @ObjectModel.text.element: [ 'RecLegalEntityDescription' ]
      RecLegalentity,

      @ObjectModel.text.element: [ 'RecCompanyCodeDescription' ]
      RecCompanyCode,

      @ObjectModel.text.element: [ 'RecObjectTypeDescription' ]
      RecObjectType,

      @ObjectModel.text.element: [ 'RecObjectNumDescription' ]
      RecObjectNumber,

      @ObjectModel.text.element: [ 'AccountingTypeMeaning' ]
      RecAccountingType,

      @ObjectModel.text.element: [ 'RecBusinessdivisonDescription' ]
      RecBusinessDivision,

      @ObjectModel.text.element: [ 'RecProfitcenterDescription' ]
      RecProfitCenter,

      @ObjectModel.text.element: [ 'RecFunctionalAreaDescription' ]
      RecFunctionalArea,

      @ObjectModel.text.element: [ 'SalesorderCreatedDescription' ]
      RecSalesorderCreated,

      @ObjectModel.text.element: [ 'StatusDescription' ]
      RRStatus,

      Criticality,

      @ObjectModel.filter.enabled: false
      @ObjectModel.text.element: [ 'legalentitycountryname' ]
      country,

      @ObjectModel.filter.enabled: false
      @ObjectModel.text.element: [ 'Receivingcountryname' ]
      recelegalentity.country                  as ReceivingCountry,

      @Semantics.text: true
      SysidDescription,

      @Semantics.text: true
      LegalentityDescription,

      @Semantics.text: true
      CompanyCodeDescription,

      @Semantics.text: true
      ObjectDescription,

      @Semantics.text: true
      ObjectNumDescription,

      @Semantics.text: true
      VendorDescription,

      @Semantics.text: true
      ProfitcenterDescription,

      @Semantics.text: true
      RRMatterDescription,

      @Semantics.text: true
      DatasourceDescription,

      @Semantics.text: true
      DatasetDescription,

      @Semantics.text: true
      BusinessdivisonDescription,

      @Semantics.text: true
      FunctionalAreaDescription,

      @Semantics.text: true
      SalesorderCreatedDescription,

      @Semantics.text: true
      AccountingTypeMeaning,

      @Semantics.text: true
      _status.text                             as StatusDescription,

      @Semantics.text: true
      _legalCountryText.CountryName            as legalentitycountryname,

      @Semantics.text: true
      _recccodeText.SysidDescription           as RecSysidDescription,

      @Semantics.text: true
      _recccodeText.LegalentityDescription     as RecLegalentityDescription,

      @Semantics.text: true
      _recccodeText.ccodedescription           as RecCompanyCodeDescription,

      @Semantics.text: true
      _recObjType.ObjectDescription            as RecObjectTypeDescription,

      @Semantics.text: true
      _recObjNumber.Description                as RecObjectNumDescription,

      @Semantics.text: true
      _recProfitCenter.profitcenterdescription as RecProfitcenterDescription,

      @Semantics.text: true
      _recbusinessdiv.Description              as RecBusinessdivisonDescription,

      @Semantics.text: true
      _recFunctionalArea.Description           as RecFunctionalAreaDescription,

      @Semantics.text: true
      _reclegalCountryText.CountryName         as Receivingcountryname
      
}
