@AccessControl.authorizationCheck: #CHECK
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@EndUserText.label: 'Maintain Recharge/Reimbursement Objects'
@Metadata.allowExtensions: true
define view entity /ESRCC/C_RR_Objct
  as projection on /ESRCC/I_RR_Objct

{
  key Uuid,

      @ObjectModel.text.element: [ 'SysidDescription' ]
      SystemId,

      @ObjectModel.text.element: [ 'LegalEntityDescription' ]
      LegalEntity,

      @ObjectModel.text.element: [ 'CompanyCodeDescription' ]
      CompanyCode,


      @ObjectModel.text.element: [ 'ObjectDescription' ]
      ObjectType,

      ObjectNumber,
      ActiveFlag,

      @ObjectModel.text.element: [ 'FunctionalAreaDescription' ]
      FunctionalArea,

      @ObjectModel.text.element: [ 'ProfitCenterDescription' ]
      ProfitCenter,

      @ObjectModel.text.element: [ 'BusinessDivisionDescription' ]
      BusinessDivision,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,

      @Consumption.hidden: true
      LocalLastChangedAt,

      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      _SysidText.description                    as SysidDescription,

      @Semantics.text: true
      _CcodeText.ccodedescription               as CompanyCodeDescription,

      @Semantics.text: true
      _CcodeText.LegalentityDescription         as LegalEntityDescription,

      @Semantics.text: true
      _FunctionalAreaText.Description           as FunctionalAreaDescription,

      @Semantics.text: true
      _ProfitCenterText.profitcenterdescription as ProfitCenterDescription,

      @Semantics.text: true
      _BusinessDivisionText.Description         as BusinessDivisionDescription,

      @Semantics.text: true
      _ObjType.text                as ObjectDescription,

      _ObjctAll  : redirected to parent /ESRCC/C_RR_Objct_S,
      _ObjctText : redirected to composition child /ESRCC/C_RR_ObjctText,
      _ObjctText.Description : localized
}
