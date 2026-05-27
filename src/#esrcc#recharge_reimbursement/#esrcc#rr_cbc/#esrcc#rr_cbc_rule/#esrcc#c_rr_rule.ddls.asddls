@AccessControl.authorizationCheck: #CHECK
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@EndUserText.label: 'Maintain Recharge/Reimbursement Rules'
@Metadata.allowExtensions: true
define view entity /ESRCC/C_RR_Rule
  as projection on /ESRCC/I_RR_Rule

{
  key RuleId,

      @ObjectModel.text.element: [ 'SysidDescription' ]
      SystemId,

      @ObjectModel.text.element: [ 'LegalEntityDescription' ]
      LegalEntity,

      @ObjectModel.text.element: [ 'CompanyCodeDescription' ]
      CompanyCode,

      @ObjectModel.text.element: [ 'ObjectDescription' ]
      ObjectType,

      ObjectNumber,

//      @ObjectModel.text.element: [ 'SourceDescription' ]
      KeyField,

      @ObjectModel.text.element: [ 'FunctionalAreaDescription' ]
      FunctionalArea,

      @ObjectModel.text.element: [ 'ProfitCenterDescription' ]
      ProfitCenter,

      @ObjectModel.text.element: [ 'BusinessDivisionDescription' ]
      BusinessDivision,

      RelatedMaterial,
      Validfrom,
      Validto,
      ActiveFlag,

      PartnerUuid,

      @ObjectModel.text.element: [ 'SOCreationDescription' ]
      SalesOrderCreation,

      @ObjectModel.text.element: [ 'PartnerSysidDescription' ]
      PartnerSystemId,

      @ObjectModel.text.element: [ 'PartnerLegalEntityDescription' ]
      PartnerLegalEntity,

      @ObjectModel.text.element: [ 'PartnerCompanyCodeDescription' ]
      PartnerCompanyCode,

      @ObjectModel.text.element: [ 'PartnerObjectDescription' ]
      PartnerObjectType,

      PartnerObjectNumber,

      @ObjectModel.text.element: [ 'PartnerFunctionalAreaDescr' ]
      PartnerFunctionalArea,

      @ObjectModel.text.element: [ 'PartnerProfitCenterDescription' ]
      PartnerProfitCenter,

      @ObjectModel.text.element: [ 'PartnerBusinessDivisionDescr' ]
      PartnerBusinessDivision,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,

      @Consumption.hidden: true
      LocalLastChangedAt,

      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      _SysidText.description                           as SysidDescription,

      @Semantics.text: true
      _CcodeText.ccodedescription                      as CompanyCodeDescription,

      @Semantics.text: true
      _CcodeText.LegalentityDescription                as LegalEntityDescription,

      @Semantics.text: true
      _FunctionalAreaText.Description                  as FunctionalAreaDescription,

      @Semantics.text: true
      _ProfitCenterText.profitcenterdescription        as ProfitCenterDescription,

      @Semantics.text: true
      _BusinessDivisionText.Description                as BusinessDivisionDescription,

      @Semantics.text: true
      _ObjType.ObjectDescription                       as ObjectDescription,

//      @Semantics.text: true
//      _sourcekeyText.Description                       as SourceDescription,

      @Semantics.text: true
      _soCreation.text                                 as SOCreationDescription,


      // Partner
      @Semantics.text: true
      _PartnerSysidText.description                    as PartnerSysidDescription,

      @Semantics.text: true
      _PartnerCcodeText.ccodedescription               as PartnerCompanyCodeDescription,

      @Semantics.text: true
      _PartnerCcodeText.LegalentityDescription         as PartnerLegalEntityDescription,

      @Semantics.text: true
      _PartnerFunctionalAreaText.Description           as PartnerFunctionalAreaDescr,

      @Semantics.text: true
      _PartnerProfitCenterText.profitcenterdescription as PartnerProfitCenterDescription,

      @Semantics.text: true
      _PartnerBusinessDivisionText.Description         as PartnerBusinessDivisionDescr,

      @Semantics.text: true
      _PartnerObjType.ObjectDescription                as PartnerObjectDescription,

      _RuleAll  : redirected to parent /ESRCC/C_RR_Rule_S,
      _RuleText : redirected to composition child /ESRCC/C_RR_RuleText,
      _RuleText.Description : localized
}
