@EndUserText.label: 'RR  Source Object Types Text'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_RR_ObjectTypeText
  as select from /esrcc/rr_obtypt
  association [1..1] to /ESRCC/I_RR_ObjectType_S as _ObjectTypeAll on $projection.SingletonID = _ObjectTypeAll.SingletonID
  association to parent /ESRCC/I_RR_ObjectType as _ObjectType on $projection.ObjectType = _ObjectType.ObjectType
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key spras as Spras,
  key object_type as ObjectType,
  @Semantics.text: true
  description as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  1 as SingletonID,
  _ObjectTypeAll,
  _ObjectType,
  _LanguageText
  
}
