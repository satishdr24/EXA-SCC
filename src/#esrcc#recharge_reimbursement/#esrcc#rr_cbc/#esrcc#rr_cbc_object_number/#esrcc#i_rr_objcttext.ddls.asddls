@AccessControl.authorizationCheck: #CHECK
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@EndUserText.label: 'Recharge/Reimbursement Objects Text'
@ObjectModel.dataCategory: #TEXT

define view entity /ESRCC/I_RR_ObjctText
  as select from /esrcc/rr_objctt

  association [1..1] to /ESRCC/I_RR_Objct_S      as _ObjctAll     on $projection.SingletonID = _ObjctAll.SingletonID
  association        to parent /ESRCC/I_RR_Objct as _Objct        on $projection.Uuid = _Objct.Uuid
  association [0..*] to I_LanguageText           as _LanguageText on $projection.Spras = _LanguageText.LanguageCode

{
      @Semantics.language: true
  key spras                 as Spras,

  key uuid                  as Uuid,

      @Semantics.text: true
      description           as Description,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      1                     as SingletonID,

      _ObjctAll,
      _Objct,
      _LanguageText
}
