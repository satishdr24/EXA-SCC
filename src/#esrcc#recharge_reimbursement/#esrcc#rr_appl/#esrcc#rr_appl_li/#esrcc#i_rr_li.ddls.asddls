@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'RR Line Items'
@Metadata.allowExtensions: true
@ObjectModel.usageType: { serviceQuality: #X, sizeCategory: #M, dataClass: #MIXED }
define root view entity /ESRCC/I_RR_LI
  as select from    /esrcc/rr_li              as LineItem
    left outer join /ESRCC/I_RR_ObjectType_F4 as ObjectType on LineItem.object_type = ObjectType.ObjectType
  //    left outer join /ESRCC/I_RR_ObjectType_F4 as ObjectType on LineItem.p_object_type = ObjectType.ObjectType

  association [0..1] to /ESRCC/I_RR_OBJECT_NUMBER_F4   as _ObjNumber             on  _ObjNumber.Sysid        = $projection.SystemID
                                                                                 and _ObjNumber.CompanyCode  = $projection.CompanyCode
                                                                                 and _ObjNumber.LegalEntity  = $projection.LegalEntity
                                                                                 and _ObjNumber.ObjectType   = $projection.ObjectType
                                                                                 and _ObjNumber.ObjectNumber = $projection.ObjectNumber

  association [0..1] to /esrcc/le                      as legalentity            on  legalentity.legalentity = $projection.LegalEntity

  association [0..1] to /ESRCC/I_RR_ObjectType_F4      as _ObjType               on  _ObjType.ObjectType = $projection.ObjectType

  association [0..1] to /ESRCC/I_COMPANYCODES_F4       as _CcodeText             on  _CcodeText.Sysid       = $projection.SystemID
                                                                                 and _CcodeText.Ccode       = $projection.CompanyCode
                                                                                 and _CcodeText.Legalentity = $projection.LegalEntity

  association [0..1] to /ESRCC/I_RRMATTER_F4           as _RR_MatterText         on  _RR_MatterText.Matter = $projection.RRMatter

  association [0..1] to /ESRCC/I_RR_DATASOURCE         as _valuesource           on  _valuesource.ValueSource = $projection.DataSource

  association [0..1] to /ESRCC/I_COSTDATASET           as _dataset               on  _dataset.costdataset = $projection.Fplv

  association [0..1] to /ESRCC/I_PROFITCENTER_F4       as _ProfitCenter          on  _ProfitCenter.ProfitCenter = $projection.ProfitCenter

  association [0..1] to /ESRCC/I_BUSINESSDIV_F4        as _businessdiv           on  _businessdiv.BusinessDivision = $projection.Businessdivision

  association [0..1] to /ESRCC/I_FunctionalArea_F4     as _FunctionalArea        on  _FunctionalArea.FunctionalArea = $projection.Functionalarea

  association [0..1] to /ESRCC/I_Salesorder_created    as _SalesOrderCreated     on  _SalesOrderCreated.Salesorder_created = $projection.RecSalesorderCreated

  association [0..1] to /ESRCC/I_VENDOR_F4             as _vendor                on  _vendor.vendor = $projection.Vendor

  association [0..1] to /ESRCC/I_RR_STATUS             as _status                on  _status.Status = $projection.RRStatus

  association [0..1] to I_CountryText                  as _legalCountryText      on  _legalCountryText.Country  = $projection.country
                                                                                 and _legalCountryText.Language = $session.system_language

  //  Receiver association
  association [0..1] to /ESRCC/I_COMPANYCODES_F4       as _recccodeText          on  _recccodeText.Sysid       = $projection.RecSystemId
                                                                                 and _recccodeText.Ccode       = $projection.RecCompanyCode
                                                                                 and _recccodeText.Legalentity = $projection.RecLegalentity

  association [0..1] to /ESRCC/I_RR_ObjectType_F4      as _recObjType            on  _recObjType.ObjectType = LineItem.p_object_type

  association [0..1] to /ESRCC/I_RR_OBJECT_NUMBER_F4   as _recObjNumber          on  _recObjNumber.Sysid        = $projection.RecSystemId
                                                                                 and _recObjNumber.CompanyCode  = $projection.RecCompanyCode
                                                                                 and _recObjNumber.LegalEntity  = $projection.RecLegalentity
                                                                                 and _recObjNumber.ObjectType   = $projection.RecObjectType
                                                                                 and _recObjNumber.ObjectNumber = $projection.RecObjectNumber

  association [0..1] to /ESRCC/I_RR_AccountingTypeMean as _AccountingTypeMeaning on  _AccountingTypeMeaning.AccountingType = ObjectType.AccountingType

  association [0..1] to /ESRCC/I_PROFITCENTER_F4       as _recProfitCenter       on  _recProfitCenter.ProfitCenter = $projection.RecProfitCenter

  association [0..1] to /ESRCC/I_BUSINESSDIV_F4        as _recbusinessdiv        on  _recbusinessdiv.BusinessDivision = $projection.RecBusinessDivision

  association [0..1] to /ESRCC/I_FunctionalArea_F4     as _recFunctionalArea     on  _recFunctionalArea.FunctionalArea = $projection.RecFunctionalArea

  association [0..1] to /esrcc/le                      as recelegalentity        on  recelegalentity.legalentity = $projection.RecLegalentity

  association [0..1] to I_CountryText                  as _reclegalCountryText   on  _reclegalCountryText.Country  = $projection.ReceivingCountry
                                                                                 and _reclegalCountryText.Language = $session.system_language

{
  key LineItem.ryear                                  as Ryear,
  key LineItem.poper                                  as Period,
  key LineItem.fplv                                   as Fplv,
  key LineItem.sysid                                  as SystemID,
  key LineItem.legalentity                            as LegalEntity,
  key LineItem.ccode                                  as CompanyCode,
  key LineItem.object_type                            as ObjectType,
  key LineItem.object_number                          as ObjectNumber,
  key LineItem.ledger                                 as Ledger,
  key LineItem.belnr                                  as Belnr,
  key LineItem.buzei                                  as Buzei,
  key LineItem.rr_matter                              as RRMatter,
  key LineItem.material                               as Material,

      LineItem.reference_belnr                        as ReferenceBelnr,
      LineItem.belnr_text                             as BelnrText,
      LineItem.data_source                            as DataSource,

      @Semantics.amount.currencyCode: 'LocalCurrency'
      LineItem.hsl                                    as LocalValue,

      LineItem.localcurr                              as LocalCurrency,

      @Semantics.amount.currencyCode: 'GroupCurrency'
      LineItem.ksl                                    as Ksl,

      LineItem.groupcurr                              as GroupCurrency,

      @Semantics.quantity.unitOfMeasure: 'Meins'
      LineItem.quantity                               as Quantity,

      LineItem.meins                                  as Meins,
      LineItem.vendor                                 as Vendor,
      LineItem.bschl                                  as PostingKey,
      LineItem.budat                                  as Budat,

      LineItem.profitcenter                           as ProfitCenter,
      LineItem.businessdivision                       as Businessdivision,
      LineItem.functionalarea                         as Functionalarea,
      
      LineItem.document_date                          as DocumentDate,
      LineItem.assignment                             as Assignment,
      LineItem.item_text                              as ItemText,
      LineItem.so_item                                as SoItem,
      LineItem.sales_org                              as SalesOrg,
      LineItem.distribution_channel                   as DistributionChannel,
      LineItem.division                               as Division,
      LineItem.service_material                       as ServiceMaterial,

      LineItem.salesorder_number                      as SalesorderNumber,
      LineItem.salesorder_reference                   as SalesorderReference,

      LineItem.p_system_id                            as RecSystemId,
      LineItem.p_legalentity                          as RecLegalentity,
      LineItem.p_company_code                         as RecCompanyCode,
      LineItem.p_object_type                          as RecObjectType,
      LineItem.p_object_number                        as RecObjectNumber,
      LineItem.p_accounting_type                      as RecAccountingType,
      LineItem.p_businessdivision                     as RecBusinessDivision,
      LineItem.p_profit_center                        as RecProfitCenter,
      LineItem.p_functionalarea                       as RecFunctionalArea,
      LineItem.p_salesorder_created                   as RecSalesorderCreated,

      LineItem.status                                 as RRStatus,
      case
      when LineItem.status  = 'S'  then '2'
      when LineItem.status  = 'F'  then '3'
      else '0' end                                    as Criticality,

      @Semantics.user.createdBy: true
      LineItem.created_by                             as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      LineItem.created_at                             as CreatedAt,

      @Semantics.user.lastChangedBy: true
      LineItem.last_changed_by                        as LastChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      LineItem.last_changed_at                        as LastChangedAt,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LineItem.local_last_changed_at                  as LocalLastChangedAt,


      legalentity.country                             as country,
      recelegalentity.country                         as ReceivingCountry,
      _CcodeText.ccodedescription                     as CompanyCodeDescription,
      _CcodeText.SysidDescription                     as SysidDescription,
      _CcodeText.LegalentityDescription               as LegalentityDescription,
      _ObjType.AccountingType                         as AccountingType,
      _ObjType.ObjectDescription                      as ObjectDescription,
      _ObjNumber.Description                          as ObjectNumDescription,
      _ProfitCenter.profitcenterdescription           as ProfitcenterDescription,
      _RR_MatterText.RRMatterDescription              as RRMatterDescription,
      _valuesource.text                               as DatasourceDescription,
      _dataset.text                                   as DatasetDescription,
      _businessdiv.Description                        as BusinessdivisonDescription,
      _FunctionalArea.Description                     as FunctionalAreaDescription,
      _SalesOrderCreated.text                         as SalesorderCreatedDescription,

      ObjectType.AccountingType                       as PartnerAccType,
      _recObjType.AccountingType                      as PartnerAcctType,

      case when LineItem.hsl > 0
      then _AccountingTypeMeaning.AccMeaningPlus
      else _AccountingTypeMeaning.AccMeaningMinus end as AccountingTypeMeaning,
      _AccountingTypeMeaning,

      _vendor.Description                             as VendorDescription,
      _status,
      _legalCountryText,
      _recccodeText,
      _recObjType,
      _recObjNumber,
      _recProfitCenter,
      _recbusinessdiv,
      _recFunctionalArea,
      recelegalentity,

      _reclegalCountryText
}
