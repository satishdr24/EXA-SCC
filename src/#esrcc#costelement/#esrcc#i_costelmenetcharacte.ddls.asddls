@EndUserText.label: 'Cost element characteristics'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@AbapCatalog.extensibility.extensible: true
define view entity /ESRCC/I_CostElmenetCharacte
  as select from /esrcc/cstelmtch
  association        to parent /ESRCC/I_CostElmenetCharacte_S as _CostElementCharAll on  $projection.SingletonID = _CostElementCharAll.SingletonID
  association [0..1] to /ESRCC/I_SystemInformationText        as _SystemInfoText     on  _SystemInfoText.SystemId = $projection.Sysid
                                                                                     and _SystemInfoText.Spras    = $session.system_language
  association [0..1] to /ESRCC/I_LegalEntityAll_F4            as _LegalEntityText    on  _LegalEntityText.Legalentity = $projection.LegalEntity
  association [0..1] to /ESRCC/I_COMPANYCODES_F4              as _CcodeText          on  _CcodeText.Sysid       = $projection.Sysid
                                                                                     and _CcodeText.Ccode       = $projection.CompanyCode
                                                                                     and _CcodeText.Legalentity = $projection.LegalEntity
  association [0..1] to /esrcc/cstbjtypt                      as _CostObjTypeText    on  _CostObjTypeText.cost_object = $projection.CostObject
                                                                                     and _CostObjTypeText.spras       = $session.system_language
  association [0..1] to /ESRCC/I_COSCEN_F4                    as _CostObjectText     on  _CostObjectText.Sysid       = $projection.Sysid
                                                                                     and _CostObjectText.LegalEntity = $projection.LegalEntity
                                                                                     and _CostObjectText.CompanyCode = $projection.CompanyCode
                                                                                     and _CostObjectText.Costobject  = $projection.CostObject
                                                                                     and _CostObjectText.Costcenter  = $projection.CostCenter
  association [0..1] to /ESRCC/I_COSTTYPE                     as _CostTypeText       on  _CostTypeText.Costtype = $projection.CostType
  association [0..1] to /ESRCC/I_POSTINGTYPE                  as _PostingTypeText    on  _PostingTypeText.Postingtype = $projection.PostingType
  association [0..1] to /ESRCC/I_COSTIND                      as _CostIndText        on  _CostIndText.costind = $projection.CostIndicator
  association [0..1] to /ESRCC/I_USAGECALCULATION             as _UsageTypeText      on  _UsageTypeText.usagecal = $projection.UsageType
  association [0..1] to /ESRCC/I_REASON_F4                    as _ReasonText         on  _ReasonText.Reasonid = $projection.ReasonId
  association [0..1] to /ESRCC/I_VALUESOURCE                  as _ValueSourceText    on  _ValueSourceText.ValueSource = $projection.ValueSource
  association [0..1] to /esrcc/cstelemtt                      as _CostElementText    on  _CostElementText.sysid        = $projection.Sysid
                                                                                     and _CostElementText.cost_element = $projection.CostElementFrom
                                                                                     and _CostElementText.spras        = $session.system_language
  association [0..1] to /esrcc/cstelemtt                      as _CostElementToText  on  _CostElementToText.sysid        = $projection.Sysid
                                                                                     and _CostElementToText.cost_element = $projection.CostElementTo
                                                                                     and _CostElementToText.spras        = $session.system_language
  association [1..1] to /ESRCC/I_STATUS                       as _WorkflowStatusText on  _WorkflowStatusText.Status = $projection.WorkflowStatus
{

  key cst_elmnt_char_uuid         as CstElmntCharUuid,
      sysid                       as Sysid,
      legal_entity                as LegalEntity,
      company_code                as CompanyCode,
      cost_object                 as CostObject,
      cost_center                 as CostCenter,
      costelement_from            as CostElementFrom,
      costelement_to              as CostElementTo,
      valid_from                  as ValidFrom,
      valid_to                    as ValidTo,
      active                      as Active,
      cost_type                   as CostType,
      posting_type                as PostingType,
      cost_indicator              as CostIndicator,
      usage_type                  as UsageType,
      reason_id                   as ReasonId,
      value_source                as ValueSource,
      workflow_id                 as WorkflowId,
      workflow_status             as WorkflowStatus,
      comment_id                  as CommentId,
      case workflow_status
      -- Red
        when 'R' then 1
        when 'E' then 1

      -- Yellow
        when 'D' then 2
        when 'W' then 2
        when 'P' then 2
        when 'J' then 2
        when 'L' then 2

      -- Green
        when 'A' then 3
        when 'F' then 3
        else 0
      end                         as WorkflowStatusCriticality,
      ''                          as WorkflowInternalStatus,
      cast('' as /esrcc/comment ) as Comments,
      @Semantics.user.createdBy: true
      created_by                  as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                  as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by             as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at             as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at       as LocalLastChangedAt,
      1                           as SingletonID,

      _CostElementCharAll,
      _SystemInfoText,
      _LegalEntityText,
      _CcodeText,
      _CostObjTypeText,
      _CostObjectText,
      _CostTypeText,
      _PostingTypeText,
      _CostIndText,
      _UsageTypeText,
      _ReasonText,
      _ValueSourceText,
      _CostElementText,
      _CostElementToText,
      _WorkflowStatusText

}
