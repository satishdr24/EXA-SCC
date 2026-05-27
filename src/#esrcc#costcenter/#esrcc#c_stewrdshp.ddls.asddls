@EndUserText.label: 'Stewardship - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_Stewrdshp
  as projection on /ESRCC/I_Stewrdshp
{
  key StewardshipUuid,
      Validto,
      Stewardship,
      CostObjectUuid,
      ChainId,
      ChainSequence,
      WorkflowId,
      @ObjectModel.text.element: ['WorkflowStatusDescription']
      WorkflowStatus,
      CommentId,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/CL_CONFIG_VE_HANDLER'
      Comments,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @ObjectModel.text.element: ['SysidDescription']
      Sysid,

      @ObjectModel.text.element: ['LegalEntityDescription']
      LegalEntity,

      @ObjectModel.text.element: ['CompanyCodeDescription']
      CompanyCode,

      @ObjectModel.text.element: ['CostObjectDescription']
      CostObject,

      @ObjectModel.text.element: ['CostCenterDescription']
      CostCenter,
      ValidFrom,
      WorkflowStatusCriticality,

      //    Additional fields
      @ObjectModel.text.element: ['FunctionalAreaDescription']
      _CostObject.FunctionalArea,
      @ObjectModel.text.element: ['ProfitCenterDescription']
      _CostObject.ProfitCenter,
      @ObjectModel.text.element: ['BusinessDivisionDescription']
      _CostObject.BusinessDivision,
      @ObjectModel.text.element: ['Hierarchy1Description']
      _CostObject.Hierarchy1,
      @ObjectModel.text.element: ['Hierarchy2Description']
      _CostObject.Hierarchy2,
      @ObjectModel.text.element: ['Hierarchy3Description']
      _CostObject.Hierarchy3,
      @ObjectModel.text.element: ['Hierarchy4Description']
      _CostObject.Hierarchy4,
      @ObjectModel.text.element: ['BillingFreqDescription']
      _CostObject.BillingFrequency,

      @Semantics.text: true
      _CostObject._CcodeText.SysidDescription               as SysidDescription,
      @Semantics.text: true
      _CostObject._CcodeText.LegalentityDescription         as LegalEntityDescription,
      @Semantics.text: true
      _CostObject._CcodeText.ccodedescription               as CompanyCodeDescription,
      @Semantics.text: true
      _CostObject._CostObjTypeText.text                     as CostObjectDescription,
      @Semantics.text: true
      _CostObjectText.Description                           as CostCenterDescription,
      @Semantics.text: true
      _WorkflowStatusText.text                              as WorkflowStatusDescription,
      @Semantics.text: true
      _CostObject._FunctionalAreaText.Description           as FunctionalAreaDescription,
      @Semantics.text: true
      _CostObject._ProfitCenterText.profitcenterdescription as ProfitCenterDescription,
      @Semantics.text: true
      _CostObject._BusinessDivisionText.Description         as BusinessDivisionDescription,
      @Semantics.text: true
      _CostObject._Hierarchy1Text.description               as Hierarchy1Description,
      @Semantics.text: true
      _CostObject._Hierarchy2Text.description               as Hierarchy2Description,
      @Semantics.text: true
      _CostObject._Hierarchy3Text.description               as Hierarchy3Description,
      @Semantics.text: true
      _CostObject._Hierarchy4Text.description               as Hierarchy4Description,
      @Semantics.text: true
      _CostObject._BillingFreqText.text                     as BillingFreqDescription,

      _StewardshipAll : redirected to parent /ESRCC/C_Stewrdshp_S,
      _ServiceProduct : redirected to composition child /ESRCC/C_StwdSp
}
