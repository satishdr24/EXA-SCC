@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RR Accounting Type'
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity /ESRCC/I_RR_Accounting_Type_F4
  as select from /esrcc/rr_acctyp

  association [0..1] to /esrcc/rr_acctyt as _AccTypeText on  _AccTypeText.accounting_type = $projection.AccountingType
                                                         and _AccTypeText.spras           = $session.system_language

{
      @ObjectModel.text.element: [ 'AcctDescription' ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @UI.textArrangement: #TEXT_LAST
  key accounting_type          as AccountingType,

      @Consumption.filter.hidden: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.9
      @Semantics.text: true
      _AccTypeText.description as AcctDescription
}
