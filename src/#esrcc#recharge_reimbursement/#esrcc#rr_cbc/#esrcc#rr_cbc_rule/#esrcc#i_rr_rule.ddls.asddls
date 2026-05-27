@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Recharge/Reimbursement Rules'

define view entity /ESRCC/I_RR_Rule
  as select from /esrcc/rr_rule as rule

  association        to parent /ESRCC/I_RR_Rule_S   as _RuleAll                     on  $projection.SingletonID = _RuleAll.SingletonID

  composition [0..*] of /ESRCC/I_RR_RuleText        as _RuleText

  association [0..1] to /ESRCC/I_COMPANYCODES_F4 as _CcodeText                      on  _CcodeText.Sysid       = $projection.SystemId
                                                                                    and _CcodeText.Ccode       = $projection.CompanyCode
                                                                                    and _CcodeText.Legalentity = $projection.LegalEntity

  association [0..1] to /ESRCC/I_LegalEntityAll_F4  as _LegalEntity                 on  _LegalEntity.Legalentity = $projection.LegalEntity

  association [0..1] to /esrcc/sys_infot            as _SysidText                   on  _SysidText.system_id = $projection.SystemId
                                                                                    and _SysidText.spras     = $session.system_language

  association [0..1] to /ESRCC/I_RR_ObjectType_F4   as _ObjType                     on  _ObjType.ObjectType = $projection.ObjectType

  association [0..1] to /ESRCC/I_PROFITCENTER_F4    as _ProfitCenterText            on  _ProfitCenterText.ProfitCenter = $projection.ProfitCenter

  association [0..1] to /ESRCC/I_FunctionalArea_F4  as _FunctionalAreaText          on  _FunctionalAreaText.FunctionalArea = $projection.FunctionalArea

  association [0..1] to /ESRCC/I_BUSINESSDIV_F4     as _BusinessDivisionText        on  _BusinessDivisionText.BusinessDivision = $projection.BusinessDivision

//  association [0..1] to /ESRCC/I_RR_MatterText      as _sourcekeyText               on  _sourcekeyText.SourceKeyField = $projection.KeyField
//                                                                                    and _sourcekeyText.Spras          = $session.system_language

  association [0..1] to /ESRCC/I_Salesorder_created as _soCreation                  on  _soCreation.Salesorder_created = $projection.SalesOrderCreation

  // Partner Details
  association [0..1] to /ESRCC/I_RR_Objct           as _PartnerObjct                on  _PartnerObjct.Uuid = $projection.PartnerUuid

  association [0..1] to /ESRCC/I_COMPANYCODES_F4    as _PartnerCcodeText            on  _PartnerCcodeText.Sysid       = $projection.PartnerSystemId
                                                                                    and _PartnerCcodeText.Ccode       = $projection.PartnerCompanyCode
                                                                                    and _PartnerCcodeText.Legalentity = $projection.PartnerLegalEntity

  association [0..1] to /ESRCC/I_LegalEntityAll_F4  as _PartnerLegalEntity          on  _PartnerLegalEntity.Legalentity = $projection.PartnerLegalEntity

  association [0..1] to /esrcc/sys_infot            as _PartnerSysidText            on  _PartnerSysidText.system_id = $projection.PartnerSystemId
                                                                                    and _PartnerSysidText.spras     = $session.system_language

  association [0..1] to /ESRCC/I_RR_ObjectType_F4   as _PartnerObjType              on  _PartnerObjType.ObjectType = $projection.PartnerObjectType

  association [0..1] to /ESRCC/I_PROFITCENTER_F4    as _PartnerProfitCenterText     on  _PartnerProfitCenterText.ProfitCenter = $projection.PartnerProfitCenter

  association [0..1] to /ESRCC/I_FunctionalArea_F4  as _PartnerFunctionalAreaText   on  _PartnerFunctionalAreaText.FunctionalArea = $projection.PartnerFunctionalArea

  association [0..1] to /ESRCC/I_BUSINESSDIV_F4     as _PartnerBusinessDivisionText on  _PartnerBusinessDivisionText.BusinessDivision = $projection.PartnerBusinessDivision

{
  key rule_id                        as RuleId,

      system_id                      as SystemId,
      legal_entity                   as LegalEntity,
      company_code                   as CompanyCode,
      object_type                    as ObjectType,
      object_number                  as ObjectNumber,
      key_field                      as KeyField,
      functional_area                as FunctionalArea,
      profit_center                  as ProfitCenter,
      business_division              as BusinessDivision,
      related_material               as RelatedMaterial,
      validfrom                      as Validfrom,
      validto                        as Validto,
      active_flag                    as ActiveFlag,
      partner_uuid                   as PartnerUuid,
      sales_order_creation           as SalesOrderCreation,

      @Semantics.user.createdBy: true
      created_by                     as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at                     as CreatedAt,

      @Semantics.user.lastChangedBy: true
      last_changed_by                as LastChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                as LastChangedAt,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at          as LocalLastChangedAt,

      1                              as SingletonID,

      _PartnerObjct.SystemId         as PartnerSystemId,
      _PartnerObjct.LegalEntity      as PartnerLegalEntity,
      _PartnerObjct.CompanyCode      as PartnerCompanyCode,
      _PartnerObjct.ObjectType       as PartnerObjectType,
      _PartnerObjct.ObjectNumber     as PartnerObjectNumber,
      _PartnerObjct.FunctionalArea   as PartnerFunctionalArea,
      _PartnerObjct.ProfitCenter     as PartnerProfitCenter,
      _PartnerObjct.BusinessDivision as PartnerBusinessDivision,

      _RuleAll,
      _RuleText,
      _CcodeText,
      _LegalEntity,
      _SysidText,
      _soCreation,

      _ObjType,
      _ProfitCenterText,
      _FunctionalAreaText,
      _BusinessDivisionText,
//      _sourcekeyText,
      _PartnerCcodeText,

      _PartnerLegalEntity,
      _PartnerSysidText,
      _PartnerObjType,
      _PartnerProfitCenterText,
      _PartnerFunctionalAreaText,
      _PartnerBusinessDivisionText
}
