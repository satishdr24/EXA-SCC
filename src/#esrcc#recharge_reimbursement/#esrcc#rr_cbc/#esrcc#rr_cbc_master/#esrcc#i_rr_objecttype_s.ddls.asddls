@EndUserText.label: 'RR  Source Object Types Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_RR_ObjectType_S
  as select from I_Language
    left outer join /esrcc/rr_objtyp on 0 = 0
  composition [0..*] of /ESRCC/I_RR_ObjectType as _ObjectType
{
  key 1 as SingletonID,
  _ObjectType,
  max( /esrcc/rr_objtyp.last_changed_at ) as LastChangedAtMax,
  cast( '' as sxco_transport) as TransportRequestID,
  cast( 'X' as abap_boolean preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
