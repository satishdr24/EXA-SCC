@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'True-up Amounts'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_TRUEUP_YTD
  with parameters
    p_ryear    : /esrcc/ryear,
    p_refpoper : /esrcc/poper,
    p_currencytype : /esrcc/sendercurr
  as select from /esrcc/trueup
{
  key ryear               as Ryear,
  key sysid               as Sysid,
  key legalentity         as Legalentity,
  key ccode               as Ccode,
  key costobject          as Costobject,
  key costcenter          as Costcenter,
  key serviceproduct      as Serviceproduct,
  key receiversysid       as Receiversysid,
  key receivingentity     as Receivingentity,
  key receivercompanycode as Receivercompanycode,
  key receivercostobject  as Receivercostobject,
  key receivercostcenter  as Receivercostcenter,
      case when $parameters.p_currencytype = 'L' then sum(amount_l)
           when $parameters.p_currencytype = 'G' then sum(amount_g)
           else 0
      end                  as Amount      
}
where
      ryear  = $parameters.p_ryear
  and poper <= $parameters.p_refpoper
group by
  ryear,
  sysid,
  legalentity,
  ccode,
  costobject,
  costcenter,
  serviceproduct,
  receiversysid,
  receivingentity,
  receivercompanycode,
  receivercostobject,
  receivercostcenter  
