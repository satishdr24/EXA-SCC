@AccessControl.authorizationCheck: #CHECK
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@EndUserText.label: 'RR Source Object Types'

define view entity /ESRCC/I_RR_ObjectType
  as select from /esrcc/rr_objtyp

  association to parent /ESRCC/I_RR_ObjectType_S   as _ObjectTypeAll on $projection.SingletonID = _ObjectTypeAll.SingletonID
  composition [0..*] of /ESRCC/I_RR_ObjectTypeText as _ObjectTypeText

  association [1..1] to /ESRCC/I_AccountingTypeText as _AccountingTypeDescription on $projection.AccountingType = _AccountingTypeDescription.AccountingType
                                                                                 and _AccountingTypeDescription.Spras = $session.system_language                                          
{
  key object_type           as ObjectType,

      accounting_type       as AccountingType,

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

      _ObjectTypeAll,
      _ObjectTypeText,
      _AccountingTypeDescription
}
