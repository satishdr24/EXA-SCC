@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Base Values for Year End'
@Metadata.ignorePropagatedAnnotations: true
define view entity /ESRCC/I_YEAREND_BASE
with parameters
    p_ryear    : /esrcc/ryear,
    p_refpoper : /esrcc/poper
as select from /ESRCC/I_ReceiverChargeout as ReceiverChargeout  

{
    key _ServiceCost._CostCenterCost._Currencytype.Currencytype,
    key _ServiceCost._CostCenterCost.Ryear as Ryear,    
    key _ServiceCost._CostCenterCost.Sysid as Sysid,      
    key _ServiceCost._CostCenterCost.Legalentity as Legalentity,      
    key _ServiceCost._CostCenterCost.Ccode as Ccode,      
    key _ServiceCost._CostCenterCost.Costobject as Costobject,      
    key _ServiceCost._CostCenterCost.Costcenter as Costcenter,  
    key _ServiceCost._CostCenterCost.Profitcenter,
    key _ServiceCost._CostCenterCost.Businessdivision,
    key _ServiceCost._CostCenterCost.FunctionalArea,    
    key _ServiceCost._CostCenterCost.ProcessType,      
    key _ServiceCost.Serviceproduct as Serviceproduct,
    key _ServiceCost.Servicetype,
    key _ServiceCost.OECD,
    key _ServiceCost.Transactiongroup,
    key ReceiverSysId,
    key ReceiverCompanyCode,
    key Receivingentity,
    key ReceiverCostObject,
    key ReceiverCostCenter,     
    $parameters.p_refpoper as ytdperiod, 
    
    _ServiceCost._CostCenterCost.Currency as Currency,
    @Semantics.amount.currencyCode: 'Currency'
    case when _ServiceCost._CostCenterCost.ProcessType = 'A' or 
              _ServiceCost._CostCenterCost.ProcessType = 'S' then
    sum(
      case Currencytype
      when 'L' then
      case when Currency <> _ServiceCost._CostCenterCost.Currency then
      currency_conversion( client => $session.client,
                           amount => cast(TotalChargeout as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => _ServiceCost._CostCenterCost.Currency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' ) 
      else cast(TotalChargeout  as abap.curr(23,2)) end
      else cast(TotalChargeout as abap.curr(23,2)) end       
      ) end as Ytdamount,
      
    @Semantics.amount.currencyCode: 'Currency'
    case when _ServiceCost._CostCenterCost.ProcessType = 'F' then
    sum(
      case Currencytype
      when 'L' then
      case when Currency <> _ServiceCost._CostCenterCost.Currency then
      currency_conversion( client => $session.client,
                           amount => cast(TotalChargeout as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => _ServiceCost._CostCenterCost.Currency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' ) 
      else cast(TotalChargeout  as abap.curr(23,2)) end
      else cast(TotalChargeout as abap.curr(23,2)) end       
      ) end as Forecastamount,
         
    @Semantics.amount.currencyCode: 'Currency' 
    case when _ServiceCost._CostCenterCost.ProcessType = 'A' or 
              _ServiceCost._CostCenterCost.ProcessType = 'S' or
              _ServiceCost._CostCenterCost.ProcessType = 'F' then
    sum(
      case Currencytype
      when 'L' then
      case when Currency <> _ServiceCost._CostCenterCost.Currency then
      currency_conversion( client => $session.client,
                           amount => cast(TotalChargeout as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => _ServiceCost._CostCenterCost.Currency,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' ) 
      else cast(TotalChargeout  as abap.curr(23,2)) end
      else cast(TotalChargeout as abap.curr(23,2)) end      
      ) end as Yearendamount,
      
      //Descriptions
      @Semantics.text: true
      _ServiceCost._CostCenterCost.ccodedescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.legalentitydescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.costobjectdescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.costcenterdescription,
      @Semantics.text: true
      _ServiceCost.Serviceproductdescription,
      @Semantics.text: true
      _ServiceCost.Transactiongroupdescription,
      @Semantics.text: true
      _ServiceCost.Servicetypedescription,      
      @Semantics.text: true
      _ServiceCost.oecdDescription,       
      @Semantics.text: true
      _ServiceCost._CostCenterCost.profitcenterdescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.businessdescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.functionalareadescription,
      @Semantics.text: true
      ccodedescription  as RecCcodedescription,
      @Semantics.text: true
      receivingentitydescription,
      @Semantics.text: true
      costcenterdescription as RecCostCenterdescription,      
      @Semantics.text: true
      costobjectdescription as RecCostObjectdescription,      
      Country as RecCountry,      
      _ServiceCost._CostCenterCost.Country as LECountry,  
      @Semantics.text: true    
      _ServiceCost._CostCenterCost._Currencytype.text as currencytypedescription
}
where $parameters.p_ryear = _ServiceCost._CostCenterCost.Ryear and 
      ( ( _ServiceCost._CostCenterCost.Poper <= $parameters.p_refpoper 
          and _ServiceCost._CostCenterCost.RefPoper is initial ) 
        or _ServiceCost._CostCenterCost.RefPoper = $parameters.p_refpoper )
      and ( _ServiceCost._CostCenterCost.ProcessType = 'A' or 
            _ServiceCost._CostCenterCost.ProcessType = 'S' or
            _ServiceCost._CostCenterCost.ProcessType = 'F' )
        
group by
 _ServiceCost._CostCenterCost._Currencytype.Currencytype,
 _ServiceCost._CostCenterCost.Ryear,    
 _ServiceCost._CostCenterCost.Sysid,      
 _ServiceCost._CostCenterCost.Legalentity,      
 _ServiceCost._CostCenterCost.Ccode,      
 _ServiceCost._CostCenterCost.Costobject,      
 _ServiceCost._CostCenterCost.Costcenter,  
 _ServiceCost._CostCenterCost.Profitcenter,
 _ServiceCost._CostCenterCost.Businessdivision,
 _ServiceCost._CostCenterCost.FunctionalArea,    
 _ServiceCost._CostCenterCost.ProcessType,      
 _ServiceCost.Serviceproduct,
 _ServiceCost.Servicetype,
 _ServiceCost.OECD,
 _ServiceCost.Transactiongroup,
 ReceiverSysId,
 ReceiverCompanyCode,
 Receivingentity,
 ReceiverCostObject,
 ReceiverCostCenter, 
 _ServiceCost._CostCenterCost.Currency,
 _ServiceCost._CostCenterCost.ccodedescription,  
 _ServiceCost._CostCenterCost.legalentitydescription,    
 _ServiceCost._CostCenterCost.costobjectdescription,    
 _ServiceCost._CostCenterCost.costcenterdescription,    
 _ServiceCost.Serviceproductdescription,     
 _ServiceCost.Transactiongroupdescription,     
 _ServiceCost.Servicetypedescription,           
 _ServiceCost.oecdDescription,            
 _ServiceCost._CostCenterCost.profitcenterdescription,     
 _ServiceCost._CostCenterCost.businessdescription,     
 _ServiceCost._CostCenterCost.functionalareadescription,     
 ccodedescription,     
 receivingentitydescription,     
 costcenterdescription,     
 costobjectdescription,      
 Country,      
 _ServiceCost._CostCenterCost.Country,
 _ServiceCost._CostCenterCost._Currencytype.text  
 
