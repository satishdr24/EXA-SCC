@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST, #UNION]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RR Sales Order Creation by'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS

define view entity /ESRCC/I_Salesorder_created as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: '/ESRCC/SO_CREATED')
{
      @ObjectModel.text.element: ['text']
      @UI.textArrangement: #TEXT_LAST
  key value_low as Salesorder_created,

      @Semantics.text: true
      text

}
where
  language = $session.system_language
