@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Year End Review'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity /ESRCC/I_YEAREND 
with parameters
    p_ryear    : /esrcc/ryear,
    p_refpoper : /esrcc/poper
as select from /ESRCC/I_YEAREND_BASE( p_ryear : $parameters.p_ryear, p_refpoper: $parameters.p_refpoper )
//    association [0..1] to /ESRCC/I_TRUEUP_YTD( 
//                        p_ryear : $parameters.p_ryear, 
//                        p_refpoper: $parameters.p_refpoper ) as _trueup 
//                       on _trueup.Ryear              = $projection.ryear
//                     and _trueup.Sysid               = $projection.Sysid
//                     and _trueup.Ccode               = $projection.Ccode
//                     and _trueup.Legalentity         = $projection.Legalentity
//                     and _trueup.Costobject          = $projection.Costobject
//                     and _trueup.Costcenter          = $projection.Costcenter
//                     and _trueup.Serviceproduct      = $projection.Serviceproduct                
//                     and _trueup.Receiversysid       = $projection.ReceiverSysId
//                     and _trueup.Receivercompanycode = $projection.ReceiverCompanyCode
//                     and _trueup.Receivingentity     = $projection.Receivingentity
//                     and _trueup.Receivercostobject  = $projection.ReceiverCostObject
//                     and _trueup.Receivercostcenter  = $projection.ReceiverCostCenter  
{
    key Currencytype,    
    key Ryear,    
    key Sysid,
    @ObjectModel.text.element: [ 'legalentitydescription' ]
    key Legalentity,
    @ObjectModel.text.element: [ 'ccodedescription' ]
    key Ccode,
    @ObjectModel.text.element: [ 'costobjectdescription' ]
    key Costobject,
    @ObjectModel.text.element: [ 'costcenterdescription' ]
    key Costcenter,
    @ObjectModel.text.element: [ 'profitcenterdescription' ]
    key Profitcenter,
    @ObjectModel.text.element: [ 'businessdescription' ]
    key Businessdivision,
    @ObjectModel.text.element: [ 'functionalareadescription' ]
    key FunctionalArea,  
    @ObjectModel.text.element: [ 'Serviceproductdescription' ]  
    key Serviceproduct,
    @ObjectModel.text.element: [ 'Servicetypedescription' ]
    key Servicetype,
    @ObjectModel.text.element: [ 'oecdDescription' ]
    key OECD,
    @ObjectModel.text.element: [ 'Transactiongroupdescription' ]
    key Transactiongroup,    
    key ReceiverSysId,
    @ObjectModel.text.element: [ 'RecCcodedescription' ]
    key ReceiverCompanyCode,
    @ObjectModel.text.element: [ 'receivingentitydescription' ]
    key Receivingentity,
    @ObjectModel.text.element: [ 'RecCostObjectdescription' ]
    key ReceiverCostObject,
    @ObjectModel.text.element: [ 'RecCostCenterdescription' ]
    key ReceiverCostCenter,
    ytdperiod as Refpoper, 
    Currency,   
    
    @Semantics.amount.currencyCode: 'Currency'    
    sum(Ytdamount) as Ytdamount,
    
    @Semantics.amount.currencyCode: 'Currency'   
    sum(Forecastamount) as Forecastamount, 
    
    @Semantics.amount.currencyCode: 'Currency'    
    sum(Yearendamount) as Yearendamount,
    
    //Description
    @Semantics.text: true    
    ccodedescription,
    @Semantics.text: true
    legalentitydescription,
    @Semantics.text: true
    costobjectdescription,
    @Semantics.text: true
    costcenterdescription,
    @Semantics.text: true
    Serviceproductdescription,
    @Semantics.text: true
    Transactiongroupdescription,
    @Semantics.text: true
    Servicetypedescription,
    @Semantics.text: true
    oecdDescription,
    @Semantics.text: true
    profitcenterdescription,
    @Semantics.text: true
    businessdescription,
    @Semantics.text: true
    functionalareadescription,
    @Semantics.text: true
    RecCcodedescription,
    @Semantics.text: true
    receivingentitydescription,
    @Semantics.text: true
    RecCostCenterdescription,    
    @Semantics.text: true
    RecCostObjectdescription,    
    RecCountry,    
    LECountry,
    @Semantics.text: true    
    currencytypedescription    
}
group by
 Currencytype, 
 Ryear, 
 Sysid,
 Legalentity,
 Ccode,
 Costobject,
 Costcenter,
 Profitcenter,
 Businessdivision,
 FunctionalArea, 
 Serviceproduct,
 Servicetype,
 OECD,
 Transactiongroup,
 ReceiverSysId,
 ReceiverCompanyCode,
 Receivingentity,
 ReceiverCostObject,
 ReceiverCostCenter,
 ytdperiod,   
 Currency,
 ccodedescription,  
 legalentitydescription,   
 costobjectdescription,   
 costcenterdescription,
 Serviceproductdescription,
 Transactiongroupdescription,   
 Servicetypedescription,
 oecdDescription,
 profitcenterdescription,
 businessdescription,
 functionalareadescription,
 RecCcodedescription,
 receivingentitydescription,
 RecCostCenterdescription, 
 RecCostObjectdescription,    
 RecCountry,    
 LECountry,
 currencytypedescription         
