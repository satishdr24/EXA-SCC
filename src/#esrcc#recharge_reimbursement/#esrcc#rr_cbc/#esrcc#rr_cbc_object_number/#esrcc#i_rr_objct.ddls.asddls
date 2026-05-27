@AccessControl.authorizationCheck: #CHECK
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@EndUserText.label: 'Recharge/Reimbursement Objects'

define view entity /ESRCC/I_RR_Objct
  as select from /esrcc/rr_objct as objects

  association        to parent /ESRCC/I_RR_Objct_S as _ObjctAll             on  $projection.SingletonID = _ObjctAll.SingletonID

  composition [0..*] of /ESRCC/I_RR_ObjctText      as _ObjctText

  association [0..1] to /ESRCC/I_COMPANYCODES_F4   as _CcodeText            on  _CcodeText.Sysid       = $projection.SystemId
                                                                            and _CcodeText.Ccode       = $projection.CompanyCode
                                                                            and _CcodeText.Legalentity = $projection.LegalEntity

  association [0..1] to /esrcc/sys_infot           as _SysidText            on  _SysidText.system_id = $projection.SystemId
                                                                            and _SysidText.spras     = $session.system_language

  association [0..1] to /ESRCC/I_RROBJECTS         as _ObjType              on  _ObjType.Sourceobject = $projection.ObjectType

  association [0..1] to /ESRCC/I_PROFITCENTER_F4   as _ProfitCenterText     on  _ProfitCenterText.ProfitCenter = $projection.ProfitCenter

  association [0..1] to /ESRCC/I_FunctionalArea_F4 as _FunctionalAreaText   on  _FunctionalAreaText.FunctionalArea = $projection.FunctionalArea

  association [0..1] to /ESRCC/I_BUSINESSDIV_F4    as _BusinessDivisionText on  _BusinessDivisionText.BusinessDivision = $projection.BusinessDivision
  
{
  key uuid                  as Uuid,
      system_id             as SystemId,
      legal_entity          as LegalEntity,
      company_code          as CompanyCode,
      object_type           as ObjectType,
      object_number         as ObjectNumber,
      active_flag           as ActiveFlag,
      functional_area       as FunctionalArea,
      profit_center         as ProfitCenter,
      business_division     as BusinessDivision,

      @Semantics.user.createdBy: true
      created_by            as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,

      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      1                     as SingletonID,

      _ObjctAll,
      _ObjctText,
      _CcodeText,
      _SysidText,
      _ObjType,
      _ProfitCenterText,
      _FunctionalAreaText,
      _BusinessDivisionText
}
