CLASS /esrcc/cl_badiimp_amdp_cockpit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /esrcc/if_amdp_cockpit .
    INTERFACES if_amdp_marker_hdb .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /esrcc/cl_badiimp_amdp_cockpit IMPLEMENTATION.


  METHOD /esrcc/if_amdp_cockpit~get_cockpit_tree
                              BY DATABASE PROCEDURE
                              FOR HDB
                              LANGUAGE SQLSCRIPT
                              OPTIONS  READ-ONLY
                              USING /esrcc/cst_objct
                                    /esrcc/le
                                    /esrcc/le_t
                                    /esrcc/le_ccode
                                    /esrcc/ccodet
                                    /esrcc/cst_objtt
                                    /esrcc/cstbjtypt
                                    /esrcc/cb_li
                                    /esrcc/fc_li
                                    /esrcc/exec_st
                                    /esrcc/execst_t
                                    /esrcc/stwd_sp
                                    /esrcc/srvpro
                                    /esrcc/srvprot
                                    /esrcc/procctrl.


**Read line items for cost base status
    lt_li_approved = select DISTINCT
                  cbli.sysid,
                  cbli.legalentity,
                  cbli.ccode,
                  cbli.costobject,
                  cbli.costcenter
                  from "/ESRCC/CB_LI" AS cbli
                  where ryear = :year
                    and poper = :poper
                    and status = 'A'
                    and  (
                    not exists ( select 1 from :legalentity )
                    or cbli.legalentity in (
                      select low from :legalentity ) )
                    and  (
                    not exists ( select 1 from :companycode )
                    or cbli.ccode in (
                      select low from :companycode ) )
                    and  (
                    not exists ( select 1 from :costobject )
                    or cbli.costobject in (
                      select low from :costobject ) )
                    and  (
                    not exists ( select 1 from :costcenter )
                    or cbli.costcenter in (
                      select low from :costcenter ) )
                        and client   = session_context('CLIENT');

  lt_fcli_approved = select DISTINCT
                  cbli.sysid,
                  cbli.legalentity,
                  cbli.ccode,
                  cbli.costobject,
                  cbli.costcenter
                  from "/ESRCC/FC_LI" AS cbli
                  where ryear = :year
                    and poper = :poper
                    and status = 'A'
                    and  (
                    not exists ( select 1 from :legalentity )
                    or cbli.legalentity in (
                      select low from :legalentity ) )
                    and  (
                    not exists ( select 1 from :companycode )
                    or cbli.ccode in (
                      select low from :companycode ) )
                    and  (
                    not exists ( select 1 from :costobject )
                    or cbli.costobject in (
                      select low from :costobject ) )
                    and  (
                    not exists ( select 1 from :costcenter )
                    or cbli.costcenter in (
                      select low from :costcenter ) )
                        and client   = session_context('CLIENT');


  lt_incomplete_trueup = SELECT DISTINCT
                         sysid,
                         legalentity,
                         ccode,
                         costobject,
                         costcenter,
                         'X' as incompletetrueup
                         from "/ESRCC/PROCCTRL" as procctrl
                         where ryear   = :year
                         and   poper   < :poper
                         and   process = 'TRU'
                         and   status  <> '06'
                         and   client  = session_context('CLIENT');

  lt_trueupperformed  = SELECT DISTINCT
                         sysid,
                         legalentity,
                         ccode,
                         costobject,
                         costcenter,
                         'X' as trueupperformed
                         from "/ESRCC/PROCCTRL" as procctrl
                         where ryear   = :year
                         and   poper   > :poper
                         and   process = 'TRU'
                         and   ( status  = '01' or
                                 status  = '02' or
                                 status  = '03' or
                                 status  = '04' or
                                 status  = '05' or
                                 status  = '06' or
                                 status  = '07' or
                                 status  = '08' )
                         and   client  = session_context('CLIENT');

  lt_hier2_res =  SELECT DISTINCT
                   cstobjct.sysid,
                   :year as ryear,
                   :poper as poper,
                   concat( concat( concat( concat( cstobjct.legal_entity, cstobjct.company_code ), cstobjct.cost_object ), cstobjct.cost_center ), srvpro.serviceproduct ) as nodeid,
                   cstobjct.legal_entity as legalentity,
                   cstobjct.company_code as ccode,
                   cstobjct.cost_object as costobject,
                   cstobjct.cost_center as costcenter,
                   srvpro.serviceproduct,
                   '' as StdChargeout_Status,
                   '' as Recalculation_Status,
                   '' as Forecast_Status,
                   let.description         as legalentitydescription,
                   ccodet.description      as ccodedescription,
                   costobjtypt.description as costobjectdescription,
                   cstobjctt.description   as costcenterdescription,
                   srvprot.description     as serviceproductdescr,
                   '' as stdchargeoutstatusdescr,
                   '' as recalculationstatusdescr,
                   '' as forecaststatusdescr,
                   le.country as legalcountry,
                   '' as stdchargeoutcriticallity,
                   '' as recalculationcriticallity,
                   '' as forecastcriticallity,
                   concat( concat( concat( cstobjct.legal_entity, cstobjct.company_code ), cstobjct.cost_object ), cstobjct.cost_center ) as parentnodeid,
                   2 as hierarchylevel,
                   '' as selectionallowed,
                   :action as action,
                   srv.chain_id,
                   srv.chain_sequence,
                   '' as logid,
                   '' as logapp,
                   '' as stdchargeoutfplv,
                   '' as Recalculationfplv,
                   '' as Forecastfplv,
                   '' as stdmsgno,
                   '' as trumsgno,
                   '' as fcamsgno,
                   '' as messagestdchargeout,
                   '' as messagerecalculation,
                   '' as messageforecast,
                   '' as messagetypestdchargeout,
                   '' as messagetyperecalculation,
                   '' as messagetypeforecast

*            from "/ESRCC/I_STEWRDSHP" as srv
            from :filtervalues as srv
                inner join "/ESRCC/CST_OBJCT" as cstobjct
                on srv.costobjectuuid   = cstobjct.cost_object_uuid
                and cstobjct.client     = session_context('CLIENT')

                INNER JOIN "/ESRCC/LE" AS le
                ON  le.legalentity = cstobjct.legal_entity
                and le.client      = session_context('CLIENT')

                INNER JOIN "/ESRCC/LE_CCODE" AS leccode
                ON leccode.active       = 'X'
                AND leccode.legalentity = cstobjct.legal_entity
                and leccode.ccode       = cstobjct.company_code
                and leccode.client      = session_context('CLIENT')

                INNER JOIN "/ESRCC/STWD_SP" AS stwdsp
                ON stwdsp.stewardship_uuid = srv.stewardshipuuid
                and stwdsp.valid_from  <= :validon
                and stwdsp.valid_to    >= :validon

                INNER JOIN "/ESRCC/SRVPRO" AS srvpro
                ON srvpro.Serviceproduct = stwdsp.service_product
                and srvpro.client        = session_context('CLIENT')

                LEFT OUTER JOIN "/ESRCC/SRVPROT" AS srvprot
                ON  srvprot.serviceproduct = srvpro.Serviceproduct
                and srvprot.spras          = session_context('LOCALE_SAP')
                AND srvprot.client         = session_context('CLIENT')

                LEFT OUTER JOIN "/ESRCC/LE_T" AS let
                ON  let.legalentity = cstobjct.legal_entity
                and let.spras       = session_context('LOCALE_SAP')
                AND let.client      = session_context('CLIENT')

                LEFT OUTER JOIN "/ESRCC/CCODET" AS ccodet
                ON  ccodet.sysid       = leccode.sysid
                and ccodet.ccode       = leccode.ccode
                and ccodet.spras       = session_context('LOCALE_SAP')
                AND ccodet.client      = session_context('CLIENT')

                LEFT OUTER JOIN "/ESRCC/CST_OBJTT" AS cstobjctt
                ON  cstobjctt.cost_object_uuid  = cstobjct.cost_object_uuid
                and cstobjctt.spras             = session_context('LOCALE_SAP')
                AND cstobjctt.client            = session_context('CLIENT')

                LEFT OUTER JOIN "/ESRCC/CSTBJTYPT" AS costobjtypt
                ON  costobjtypt.cost_object  = cstobjct.cost_object
                and costobjtypt.spras        = session_context('LOCALE_SAP')
                AND costobjtypt.client       = session_context('CLIENT');

  lt_hier1_status =  SELECT DISTINCT
                   cstobjct.sysid,
                   :year as ryear,
                   :poper as poper,
                   concat( concat( concat( cstobjct.legal_entity, cstobjct.company_code ), cstobjct.cost_object ), cstobjct.cost_center ) as nodeid,
                   cstobjct.legal_entity as legalentity,
                   cstobjct.company_code as ccode,
                   cstobjct.cost_object as costobject,
                   cstobjct.cost_center as costcenter,
                   cstobjct.profit_center as profitcenter,
                   cstobjct.functional_area as functionalarea,
                   cstobjct.business_division as businessdivision,
                   case when procctrl.status is not null then
                   procctrl.status
                   else
                   case when lia.costcenter is not null then
                   '04'
                   else
                   '01'
                   end
                   end as StdChargeout_Status,

                   case when procctrltru.status is not null then
                   procctrltru.status
                   else
                   case when procctrl.status is not null and procctrl.status <> '09' THEN
                   '00'
                   ELSE
                   '01'
                   END
                   END AS Recalculation_Status,

                   CASE when procctrlfca.status is not null then
                   procctrlfca.status
                   else
                   case when fclia.costcenter is not null then
                   case when :poper = '012' then
                   '00'
                   else
                   '01'
                   end
                   else
                   '10'
                   end
                   end as Forecast_Status,

                   case when procctrltru.status = '02' OR
                             procctrltru.status = '03' OR
                             procctrltru.status = '05' OR
                             procctrltru.status = '07' THEN
                   'X'
                   ELSE
                   ''
                   END AS trueupinprogress,
                   CASE when incomtru.incompletetrueup is not null
                   then 'X' else '' end as incompletetrueup,
                   case when truperf.trueupperformed is not null
                   then 'X' else '' end as trueupperformed,

                   let.description         as legalentitydescription,
                   ccodet.description      as ccodedescription,
                   costobjtypt.description as costobjectdescription,
                   cstobjctt.description   as costcenterdescription,
                   le.country as legalcountry,
                   concat( cstobjct.legal_entity, cstobjct.company_code ) as parentnodeid,
                   1 as hierarchylevel,
                   '' as selectionallowed,
                   :action as action,
                   srv.chain_id,
                   srv.chain_sequence,
                   procctrl.errorflag as stderrorflag,
                   procctrltru.errorflag as truerrorflag,
                   procctrlfca.errorflag as fcaerrorflag,
                   case when procctrltru.log_header_uuid <> '' then
                   procctrltru.log_header_uuid
                   else
                   case when procctrlfca.log_header_uuid <> '' then
                   procctrlfca.log_header_uuid
                   else
                   procctrl.log_header_uuid
                   end
                   end as logid,

                   case when procctrltru.log_header_uuid <> '' then
                   'TRU'
                   else
                   case when procctrlfca.log_header_uuid <> '' then
                   'FCA'
                   else
                   'STD'
                   end
                   end as logapp,
                   procctrl.fplv    as stdchargeoutfplv,
                   procctrltru.fplv as Recalculationfplv,
                   procctrlfca.fplv as Forecastfplv

            from :filtervalues as srv
                inner join "/ESRCC/CST_OBJCT" as cstobjct
                on srv.costobjectuuid   = cstobjct.cost_object_uuid
                and cstobjct.client     = session_context('CLIENT')

                INNER JOIN "/ESRCC/LE" AS le
                ON  le.legalentity = cstobjct.legal_entity
                and le.client      = session_context('CLIENT')

                INNER JOIN "/ESRCC/LE_CCODE" AS leccode
                ON leccode.active       = 'X'
                AND leccode.legalentity = cstobjct.legal_entity
                and leccode.ccode       = cstobjct.company_code
                and leccode.client      = session_context('CLIENT')

                INNER JOIN "/ESRCC/STWD_SP" AS stwdsp
                ON stwdsp.stewardship_uuid = srv.stewardshipuuid
                and stwdsp.valid_from  <= :validon
                and stwdsp.valid_to    >= :validon

                INNER JOIN "/ESRCC/SRVPRO" AS srvpro
                ON srvpro.Serviceproduct = stwdsp.service_product
                and srvpro.client        = session_context('CLIENT')

                LEFT OUTER JOIN "/ESRCC/LE_T" AS let
                ON  let.legalentity = cstobjct.legal_entity
                and let.spras       = session_context('LOCALE_SAP')
                AND let.client      = session_context('CLIENT')

                LEFT OUTER JOIN "/ESRCC/CCODET" AS ccodet
                ON  ccodet.sysid       = leccode.sysid
                and ccodet.ccode       = leccode.ccode
                and ccodet.spras       = session_context('LOCALE_SAP')
                AND ccodet.client      = session_context('CLIENT')

                LEFT OUTER JOIN "/ESRCC/CST_OBJTT" AS cstobjctt
                ON  cstobjctt.cost_object_uuid  = cstobjct.cost_object_uuid
                and cstobjctt.spras             = session_context('LOCALE_SAP')
                AND cstobjctt.client            = session_context('CLIENT')

                LEFT OUTER JOIN "/ESRCC/CSTBJTYPT" AS costobjtypt
                ON  costobjtypt.cost_object  = cstobjct.cost_object
                and costobjtypt.spras        = session_context('LOCALE_SAP')
                AND costobjtypt.client       = session_context('CLIENT')

                LEFT OUTER JOIN "/ESRCC/PROCCTRL" AS procctrl
                ON  procctrl.sysid       = cstobjct.sysid
                and procctrl.ryear       = :year
                AND procctrl.legalentity = cstobjct.legal_entity
                and procctrl.ccode       = cstobjct.company_code
                and procctrl.costobject  = cstobjct.cost_object
                and procctrl.costcenter  = cstobjct.cost_center
                and procctrl.poper       = :poper
                AND procctrl.process     = 'STD'
                AND procctrl.client      = session_context('CLIENT')

                LEFT OUTER JOIN "/ESRCC/PROCCTRL" AS procctrltru
                ON  procctrltru.sysid       = cstobjct.sysid
                and procctrltru.ryear       = :year
                AND procctrltru.legalentity = cstobjct.legal_entity
                and procctrltru.ccode       = cstobjct.company_code
                and procctrltru.costobject  = cstobjct.cost_object
                and procctrltru.costcenter  = cstobjct.cost_center
                and procctrltru.poper       = :poper
                AND procctrltru.process     = 'TRU'
                AND procctrltru.client      = session_context('CLIENT')

                LEFT OUTER JOIN "/ESRCC/PROCCTRL" AS procctrlfca
                ON  procctrlfca.sysid       = cstobjct.sysid
                and procctrlfca.ryear       = :year
                AND procctrlfca.legalentity = cstobjct.legal_entity
                and procctrlfca.ccode       = cstobjct.company_code
                and procctrlfca.costobject  = cstobjct.cost_object
                and procctrlfca.costcenter  = cstobjct.cost_center
                and procctrlfca.poper       = :poper
                AND procctrlfca.process     = 'FCA'
                AND procctrlfca.client      = session_context('CLIENT')

                LEFT OUTER JOIN :lt_li_approved as lia
                 ON lia.sysid       = cstobjct.sysid
                and lia.legalentity = cstobjct.legal_entity
                and lia.ccode       = cstobjct.company_code
                and lia.costobject  = cstobjct.cost_object
                and lia.costcenter  = cstobjct.cost_center

                LEFT OUTER JOIN :lt_fcli_approved as fclia
                 ON fclia.sysid       = cstobjct.sysid
                and fclia.legalentity = cstobjct.legal_entity
                and fclia.ccode       = cstobjct.company_code
                and fclia.costobject  = cstobjct.cost_object
                and fclia.costcenter  = cstobjct.cost_center

                left outer join :lt_incomplete_trueup as incomtru
                 on incomtru.sysid       = cstobjct.sysid
                and incomtru.legalentity = cstobjct.legal_entity
                and incomtru.ccode       = cstobjct.company_code
                and incomtru.costobject  = cstobjct.cost_object
                and incomtru.costcenter  = cstobjct.cost_center

                left outer join :lt_trueupperformed as truperf
                 on truperf.sysid       = cstobjct.sysid
                and truperf.legalentity = cstobjct.legal_entity
                and truperf.ccode       = cstobjct.company_code
                and truperf.costobject  = cstobjct.cost_object
                and truperf.costcenter  = cstobjct.cost_center;

    lt_hier1_res = SELECT
                   sysid,
                   ryear,
                   poper,
                   nodeid,
                   legalentity,
                   ccode,
                   costobject,
                   costcenter,
                   '' as serviceproduct,
                   StdChargeout_Status,
                   Recalculation_Status,
                   Forecast_Status,
                   legalentitydescription,
                   ccodedescription,
                   costobjectdescription,
                   costcenterdescription,
                   '' as serviceproductdescr,
                   stdst_t.description as StdChargeoutstatusdescr,
                   trust_t.description as Recalculationstatusdescr,
                   fca_t.description   as Forecaststatusdescr,
                   legalcountry,
                   std_st.color        as StdChargeoutcriticallity,
                   tru_st.color        as Recalculationcriticallity,
                   fca_st.color        as Forecastcriticallity,
                   parentnodeid,
                   hierarchylevel,
                   case action
                   when '01' then
                   case when ( StdChargeout_Status = '04' or
                               StdChargeout_Status = '07' or
                               StdChargeout_Status = '12' or
                               StdChargeout_Status = '13' or
                               StdChargeout_Status = '01' )
                             and trueupperformed = ''
                             and ( Recalculation_Status = '01' or
                                   Recalculation_Status = '00' )
                             and trueupinprogress = ''
                               and ( chain_id = ''
                                     or ( chain_id <> '' and
                                          chain_sequence = 1 ) ) then
                   'X'
                   else
                   ''
                   end
                   when '02' then
                   case when StdChargeout_Status = '07'
                             and stderrorflag = ''
                             and trueupinprogress = ''
                             and trueupperformed = ''
                               and ( chain_id = ''
                                     or ( chain_id <> '' and
                                          chain_sequence = 1 ) ) then
                   'X'
                   else
                   ''
                   end
                   when '03' then
                   case when StdChargeout_Status = '09'
                               and trueupinprogress = ''
                               and trueupperformed = ''
                               and ( chain_id = ''
                                     or ( chain_id <> '' and
                                          chain_sequence = 1 ) ) then
                   'X'
                   else
                   ''
                   end

                   when '07' then
                   case when ( Recalculation_Status = '01' or
                               Recalculation_Status = '04' or
                               Recalculation_Status = '08' or
                               Recalculation_Status = '09' or
                               Recalculation_Status = '10')
                               and ( StdChargeout_Status = '04' or
                                   StdChargeout_Status = '09' )
                               and incompletetrueup = ''
                               and trueupperformed = ''
                               and ( chain_id = ''
                                     or ( chain_id <> '' and
                                          chain_sequence = 1 ) ) then
                   'X'
                   else
                   ''
                   end

                   when '08' then
                   case when Recalculation_Status = '04'
                             and truerrorflag = ''
                             and trueupperformed = ''
                               and ( chain_id = ''
                                     or ( chain_id <> '' and
                                          chain_sequence = 1 ) ) then
                   'X'
                   else
                   ''
                   end

                   when '09' then
                   case when Recalculation_Status = '06'
                               and trueupperformed = ''
                               and ( chain_id = ''
                                     or ( chain_id <> '' and
                                          chain_sequence = 1 ) ) then
                   'X'
                   else
                   ''
                   end
                   when '10' then
                   case when ( Forecast_Status = '01' or
                               Forecast_Status = '04' or
                               Forecast_Status = '08' or
                               Forecast_Status = '09' or
                               Forecast_Status = '10')
                               and ( chain_id = ''
                                     or ( chain_id <> '' and
                                          chain_sequence = 1 ) ) then
                   'X'
                   else
                   ''
                   end
                   when '11' then
                   case when Forecast_Status = '04'
                               and ( chain_id = ''
                                     or ( chain_id <> '' and
                                          chain_sequence = 1 ) ) then
                   'X'
                   else
                   ''
                   end
                   when '12' then
                   case when Forecast_Status = '06'
                               and ( chain_id = ''
                                     or ( chain_id <> '' and
                                          chain_sequence = 1 ) ) then
                   'X'
                   else
                   ''
                   end
                   end as selectionallowed,
                   action,
                   chain_id,
                   chain_sequence,
                   logid,
                   logapp,
                   stdchargeoutfplv,
                   Recalculationfplv,
                   Forecastfplv,
                   case when StdChargeout_Status = '13' then
                   '026'
                   else
                   case when stderrorflag = 'X' and action = '02'  then
                   '036'
                   else
                   case when StdChargeout_Status <> '09' and StdChargeout_Status <> '01'
                         and Recalculation_Status <> '01' and Recalculation_Status <> '00' and action = '01' then
                   '038'
                   else
                   ''
                   end
                   end
                   end as stdmsgno,

                   case when Recalculation_Status = '09' then
                   '026'
                   else
                   case when incompletetrueup = 'X' then
                   '034'
                   else
                   case when trueupperformed = 'X' then
                   '032'
                   else
                   case when res.truerrorflag = 'X' and action = '05'  then
                   '036'
                   ELSE
                   case when StdChargeout_Status <> '04' and StdChargeout_Status <> '09' and action = '07' then
                   '037'
                   else
                   ''
                   END
                   END
                   END
                   END
                   END as trumsgno,

                   CASE when Forecast_Status = '09' then
                   '026'
                   ELSE
                   '' END as fcamsgno,
                   '' as messagestdchargeout,
                   '' as messagerecalculation,
                   '' as messageforecast,
                   '' as messagetypestdchargeout,
                   '' as messagetyperecalculation,
                   '' as messagetypeforecast
                   FROM :lt_hier1_status as res

                   LEFT OUTER JOIN "/ESRCC/EXEC_ST" as std_st
                   ON  std_st.application = 'STD'
                   AND std_st.status      = res.StdChargeout_Status
                   and std_st.client      = session_context('CLIENT')

                   LEFT OUTER JOIN "/ESRCC/EXEC_ST" as tru_st
                   ON  tru_st.application = 'TRU'
                   AND tru_st.status      = res.Recalculation_Status
                   and tru_st.client      = session_context('CLIENT')

                   LEFT OUTER JOIN "/ESRCC/EXEC_ST" as fca_st
                   ON  fca_st.application = 'FCA'
                   AND fca_st.status      = res.Forecast_Status
                   and fca_st.client      = session_context('CLIENT')

                   LEFT OUTER JOIN "/ESRCC/EXECST_T" as stdst_t
                   ON  stdst_t.application = 'STD'
                   AND stdst_t.status      = res.StdChargeout_Status
                   and stdst_t.spras       = session_context('LOCALE_SAP')
                   AND stdst_t.client       = session_context('CLIENT')

                   LEFT OUTER JOIN "/ESRCC/EXECST_T" as trust_t
                   ON  trust_t.application = 'TRU'
                   AND trust_t.status      = res.Recalculation_Status
                   and trust_t.spras       = session_context('LOCALE_SAP')
                   AND trust_t.client      = session_context('CLIENT')

                   LEFT OUTER JOIN "/ESRCC/EXECST_T" as fca_t
                   ON  fca_t.application = 'FCA'
                   AND fca_t.status      = res.Forecast_Status
                   and fca_t.spras       = session_context('LOCALE_SAP')
                   AND fca_t.client      = session_context('CLIENT');

     lt_totalcostcenters = SELECT DISTINCT
                           legalentity,
                           sysid,
                           ccode,
                           cast( COUNT( costcenter ) AS char ) AS totalcostcenter
                           FROM  :lt_hier1_status AS result
                           GROUP BY legalentity,
                                  sysid,
                                  ccode;

     lt_finstd_costcenters = SELECT DISTINCT
                             legalentity,
                             sysid,
                             ccode,
                             cast( count( costcenter ) AS char ) AS totalcostcenter
                             FROM  :lt_hier1_status AS result
                             WHERE result.StdChargeout_Status = '09'
                             GROUP BY
                             legalentity,
                             sysid,
                             ccode;

     lt_fintru_costcenters = SELECT DISTINCT
                             legalentity,
                             sysid,
                             ccode,
                             cast( COUNT( costcenter ) AS char ) AS totalcostcenter
                             FROM  :lt_hier1_status AS result
                             WHERE result.Recalculation_Status = '06'
                             GROUP BY
                             legalentity,
                             sysid,
                             ccode;

    lt_finfca_costcenters = SELECT DISTINCT
                             legalentity,
                             sysid,
                             ccode,
                             cast( COUNT( costcenter ) AS char ) AS totalcostcenter
                             FROM  :lt_hier1_status AS result
                             WHERE result.Forecast_Status = '06'
                             GROUP BY
                             legalentity,
                             sysid,
                             ccode;

    lt_select_allowed = SELECT DISTINCT
                        sysid,
                        legalentity,
                        ccode,
                        selectionallowed
                        FROM :lt_hier1_res
                        WHERE selectionallowed = 'X';


    lt_hier0_res =  SELECT DISTINCT
                   srv.sysid,
                   :year as ryear,
                   :poper as poper,
                   concat( srv.legalentity, srv.ccode ) as nodeid,
                   srv.legalentity,
                   srv.ccode,
                   '' as costobject,
                   '' as costcenter,
                   '' as serviceproduct,
                   '09' as StdChargeout_Status,
                   '06' as Recalculation_Status,
                   '06' as Forecast_Status,
                   srv.legalentitydescription,
                   srv.ccodedescription,
                   '' as costobjectdescription,
                   '' as costcenterdescription,
                   '' as serviceproductdescr,
                   cast(
                   case when stdtotal.totalcostcenter is null and total.totalcostcenter is not null then
                   concat( concat( concat ( concat( concat( stdst_t.description, ' (' ), 0 ),  '/' ), total.totalcostcenter), ' )' )
                   ELSE
                   CASE when stdtotal.totalcostcenter is not null and total.totalcostcenter is not null then
                   concat( concat( concat ( concat( concat( stdst_t.description, ' (' ), stdtotal.totalcostcenter ),  '/' ), total.totalcostcenter), ' )' )
                   ELSE
                   concat( concat( concat ( concat( concat( stdst_t.description, ' (' ), 0 ),  '/' ), 0), ' )' )
                   END
                   END AS char( 80 ) ) AS StdChargeoutstatusdescr,

                   cast(
                   case WHEN trutotal.totalcostcenter is null and total.totalcostcenter is not null then
                   concat( concat( concat ( concat( concat( trust_t.description, ' (' ), 0 ),  '/' ), total.totalcostcenter), ' )' )
                   ELSE
                   CASE when trutotal.totalcostcenter is not null and total.totalcostcenter is not null then
                   concat( concat( concat ( concat( concat( trust_t.description, ' (' ), trutotal.totalcostcenter ),  '/' ), total.totalcostcenter), ' )' )
                   ELSE
                   concat( concat( concat ( concat( concat( trust_t.description, ' (' ), 0 ),  '/' ), 0), ' )' )
                   END
                   END AS char( 80 ) ) AS Recalculationstatusdescr,

                   cast(
                   case WHEN fcatotal.totalcostcenter is null and total.totalcostcenter is not null then
                   concat( concat( concat ( concat( concat( fca_t.description, ' (' ), 0 ),  '/' ), total.totalcostcenter), ' )' )
                   ELSE
                   CASE when fcatotal.totalcostcenter is not null and total.totalcostcenter is not null then
                   concat( concat( concat ( concat( concat( fca_t.description, ' (' ), fcatotal.totalcostcenter ),  '/' ), total.totalcostcenter), ' )' )
                   ELSE
                   concat( concat( concat ( concat( concat( fca_t.description, ' (' ), 0 ),  '/' ), 0), ' )' )
                   END
                   END AS char( 80 ) ) AS Forecaststatusdescr,

                   srv.legalcountry,

                   case when stdtotal.totalcostcenter is null or stdtotal.totalcostcenter = 0 THEN
                   '0'
                   ELSE
                   CASE when stdtotal.totalcostcenter <  total.totalcostcenter then
                   '2'
                   else
                   case when stdtotal.totalcostcenter = total.totalcostcenter then
                   '3'
                   else
                   '0'
                   end
                   end
                   end as StdChargeoutcriticallity,

                   case when trutotal.totalcostcenter is null or trutotal.totalcostcenter = 0 THEN
                   '0'
                   ELSE
                   CASE when trutotal.totalcostcenter <  total.totalcostcenter then
                   '2'
                   else
                   case when trutotal.totalcostcenter =  total.totalcostcenter then
                   '3'
                   else
                   '0'
                   end
                   end
                   end as Recalculationcriticallity,

                   case when fcatotal.totalcostcenter is null or fcatotal.totalcostcenter = 0 THEN
                   '0'
                   ELSE
                   CASE when fcatotal.totalcostcenter <  total.totalcostcenter then
                   '2'
                   else
                   case when fcatotal.totalcostcenter =  total.totalcostcenter then
                   '3'
                   else
                   '0'
                   end
                   end
                   end as Forecastcriticallity,

                   '' as parentnodeid,
                   0 as hierarchylevel,
                   allow.selectionallowed,
                   action,
                   '' as chain_id,
                   0  as chain_sequence,
                   '' as logid,
                   '' as logapp,
                   '' as stdchargeoutfplv,
                   '' as Recalculationfplv,
                   '' as Forecastfplv,
                   '' as stdmsgno,
                   '' as trumsgno,
                   '' as fcamsgno,
                   '' as messagestdchargeout,
                   '' as messagerecalculation,
                   '' as messageforecast,
                   '' as messagetypestdchargeout,
                   '' as messagetyperecalculation,
                   '' as messagetypeforecast
                from :lt_hier1_res as srv

                left outer join "/ESRCC/EXECST_T" as stdst_t
                on  stdst_t.application = 'STD'
                AND stdst_t.status      = '09'
                AND stdst_t.spras       = session_context('LOCALE_SAP')
                AND stdst_t.client      = session_context('CLIENT')

                LEFT OUTER JOIN "/ESRCC/EXECST_T" as trust_t
                ON  trust_t.application = 'TRU'
                AND trust_t.status      = '06'
                AND trust_t.spras       = session_context('LOCALE_SAP')
                AND trust_t.client      = session_context('CLIENT')

                LEFT OUTER JOIN "/ESRCC/EXECST_T" as fca_t
                ON  fca_t.application   = 'FCA'
                AND fca_t.status        = '06'
                AND fca_t.spras         = session_context('LOCALE_SAP')
                AND fca_t.client        = session_context('CLIENT')

                LEFT OUTER JOIN :lt_totalcostcenters as total
                 ON total.sysid       = srv.sysid
                and total.legalentity = srv.legalentity
                and total.ccode       = srv.ccode

                left outer join :lt_finstd_costcenters as stdtotal
                 on stdtotal.sysid       = srv.sysid
                and stdtotal.legalentity = srv.legalentity
                and stdtotal.ccode       = srv.ccode

                left outer join :lt_fintru_costcenters as trutotal
                 on trutotal.sysid       = srv.sysid
                and trutotal.legalentity = srv.legalentity
                and trutotal.ccode       = srv.ccode

                left outer join :lt_finfca_costcenters as fcatotal
                 on fcatotal.sysid       = srv.sysid
                and fcatotal.legalentity = srv.legalentity
                and fcatotal.ccode       = srv.ccode

                left outer join :lt_select_allowed as allow
                 on allow.sysid          = srv.sysid
                and allow.legalentity    = srv.legalentity
                and allow.ccode          = srv.ccode;

       results = select * from :lt_hier0_res
                 union
                 select * from :lt_hier1_res
                 union
                 select * from :lt_hier2_res;

  endmethod.
ENDCLASS.
