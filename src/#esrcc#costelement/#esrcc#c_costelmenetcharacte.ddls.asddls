@EndUserText.label: 'Cost element characteristics - Maintain'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_CostElmenetCharacte
  as projection on /ESRCC/I_CostElmenetCharacte
{
  key CstElmntCharUuid,
      @ObjectModel.text.element: ['SysidDescription']
      Sysid,
      @ObjectModel.text.element: ['LegalEntityDescription']
      LegalEntity,
      @ObjectModel.text.element: ['CompanyCodeDescription']
      CompanyCode,
      //      @ObjectModel.text.element: ['CostElementDescription']
      //      CostElement,
      @ObjectModel.text.element: ['CostElementFromDescription']
      CostElementFrom,
      @ObjectModel.text.element: ['CostElementToDescription']
      CostElementTo,
      @ObjectModel.text.element: ['costobjecttypedescription']
      CostObject,
      //      @ObjectModel.text.element: ['CostCenterDescription']
      CostCenter,
      ValidFrom,
      ValidTo,
      Active,
      @ObjectModel.text.element: ['CostTypeDescription']
      CostType,
      @ObjectModel.text.element: ['PostingTypeDescription']
      PostingType,
      @ObjectModel.text.element: ['CostIndDescription']
      CostIndicator,
      @ObjectModel.text.element: ['UsageTypeDescription']
      UsageType,
      @ObjectModel.text.element: ['ReasonDescription']
      ReasonId,
      @ObjectModel.text.element: ['ValueSourceDescription']
      ValueSource,
      //      CostElementUuid,
      WorkflowId,
      @ObjectModel.text.element: ['WorkflowStatusDescription']
      WorkflowStatus,
      CommentId,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/CL_CONFIG_VE_HANDLER'
      Comments,
      WorkflowStatusCriticality,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      _CostTypeText.text             as CostTypeDescription,
      @Semantics.text: true
      _PostingTypeText.text          as PostingTypeDescription,
      @Semantics.text: true
      _CostIndText.text              as CostIndDescription,
      @Semantics.text: true
      _UsageTypeText.text            as UsageTypeDescription,
      @Semantics.text: true
      _ReasonText.reasondescription  as ReasonDescription,
      @Semantics.text: true
      _ValueSourceText.text          as ValueSourceDescription,
      @Semantics.text: true
      _SystemInfoText.Description    as SysidDescription,
      @Semantics.text: true
      _LegalEntityText.Description   as LegalentityDescription,
      @Semantics.text: true
      _CcodeText.ccodedescription    as CompanyCodeDescription,
      @Semantics.text: true
      _CostObjTypeText.description   as CostObjectTypeDescription,
      @Semantics.text: true
      _CostElementText.description   as CostElementFromDescription,
      @Semantics.text: true
      _CostElementToText.description as CostElementToDescription,
      @Semantics.text: true
      _CostObjectText.Description    as CostCenterDescription,
      @Semantics.text: true
      _WorkflowStatusText.text       as WorkflowStatusDescription,

      _CostElementCharAll : redirected to parent /ESRCC/C_CostElmenetCharacte_S

}
