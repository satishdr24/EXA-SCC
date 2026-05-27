CLASS /esrcc/cl_calculate_trueup DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_keys,
             validon        TYPE /esrcc/validfrom,
             sysid          TYPE /esrcc/sysid,
             fplv           TYPE /esrcc/costdataset_de,
             ryear          TYPE /esrcc/ryear,
             poper          TYPE /esrcc/poper,
             legalentity    TYPE /esrcc/legalentity,
             ccode          TYPE /esrcc/ccode_de,
             costobject     TYPE /esrcc/costobject_de,
             costcenter     TYPE /esrcc/costcenter,
             chain_id       TYPE /esrcc/chain_id,
             chain_rootnode TYPE abap_boolean,
           END OF ty_keys.

    TYPES: tt_keys TYPE TABLE OF ty_keys.

    CLASS-METHODS: calculate_recalchargeout
      IMPORTING
        !it_keys   TYPE /esrcc/tt_keys
      EXPORTING
        !ev_failed TYPE abap_boolean.

    CLASS-METHODS: finalize_recalchargeout
      IMPORTING
        !it_keys   TYPE /esrcc/tt_keys
      EXPORTING
        !ev_failed TYPE abap_boolean.

    CLASS-METHODS: reopen_recalchargeout
      IMPORTING
        !it_keys          TYPE /esrcc/tt_keys
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL.

    CLASS-METHODS perform_trueup_nonseq
      IMPORTING
        !it_keys          TYPE /esrcc/tt_keys
        !it_keys_monthly  TYPE tt_keys
        !iv_workflow      TYPE abap_boolean DEFAULT abap_true
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL
      EXPORTING
        !ev_failed        TYPE abap_boolean .

    CLASS-METHODS perform_trueup_seq
      IMPORTING
        !it_keys          TYPE /esrcc/tt_keys
        !it_keys_monthly  TYPE tt_keys
        !iv_workflow      TYPE abap_boolean DEFAULT abap_true
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL
      EXPORTING
        !ev_failed        TYPE abap_boolean .

    CLASS-METHODS: determine_trueup
      IMPORTING
        !it_keys          TYPE /esrcc/tt_keys
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL
        !iv_workflow      TYPE abap_boolean DEFAULT abap_true.

  PROTECTED SECTION.

  PRIVATE SECTION.

    TYPES: BEGIN OF ty_srvshare,
             fplv                TYPE /esrcc/costdataset_de,
             ryear               TYPE /esrcc/ryear,
             poper               TYPE /esrcc/poper,
             sysid               TYPE /esrcc/sysid,
             legalentity         TYPE /esrcc/legalentity,
             CompanyCode         TYPE /esrcc/ccode_de,
             costobject          TYPE /esrcc/costobject_de,
             costcenter          TYPE /esrcc/costcenter,
             ServiceProduct      TYPE /esrcc/srvproduct,
             servicetype         TYPE /esrcc/srvtype_de,
             transactiongroup    TYPE /esrcc/tg,
             chargeout           TYPE /esrcc/chargout,
             costshare           TYPE /esrcc/costshare,
             consumption_version TYPE /esrcc/consumption_version,
             capacity_version    TYPE /esrcc/capacity_version,
             key_version         TYPE /esrcc/key_version,
             planning            TYPE /esrcc/planning,
             PlanningUoM         TYPE /esrcc/uom,
             validon             TYPE /esrcc/validfrom,
           END OF ty_srvshare.

    TYPES: tt_srvshare TYPE TABLE OF ty_srvshare.

    TYPES: BEGIN OF ty_rec_cost,
             fplv                TYPE /esrcc/costdataset_de,
             ryear               TYPE /esrcc/ryear,
             poper               TYPE /esrcc/poper,
             systemid            TYPE /esrcc/sysid,
             legalentity         TYPE /esrcc/legalentity,
             CompanyCode         TYPE /esrcc/ccode_de,
             costobject          TYPE /esrcc/costobject_de,
             costcenter          TYPE /esrcc/costcenter,
             ServiceProduct      TYPE /esrcc/srvproduct,
             ReceiverSysId       TYPE /esrcc/recsysid,
             ReceiverCompanyCode TYPE /esrcc/recccode_de,
             ReceivingEntity     TYPE /esrcc/receivingntity,
             ReceiverCostObject  TYPE /esrcc/reccostobject_de,
             ReceiverCostCenter  TYPE /esrcc/reccostcenter,
             FunctionalArea      TYPE /esrcc/functional_area,
             BusinessDivision    TYPE /esrcc/businessdivision,
             ProfitCenter        TYPE /esrcc/profit_center,
             ContractId          TYPE /esrcc/contractid,
             ErpSalesOrder       TYPE /esrcc/erpsalesorder,
             InvoicingCurrency   TYPE /esrcc/invcurr,
             valueaddmarkup      TYPE /esrcc/valueaddmarkup,
             passthrumarkup      TYPE /esrcc/passthrumarkup,
             consumptionuom      TYPE /esrcc/uom,
             planninguom         TYPE /esrcc/uom,
             reckpi              TYPE /esrcc/reckpi,
             chargeout           TYPE /esrcc/chargout,
             consumption_version TYPE /esrcc/consumption_version,
             initialreckpishare  TYPE /esrcc/reckpishare,
             reckpishare         TYPE /esrcc/reckpishare,
             validon             TYPE /esrcc/validfrom,
           END OF ty_rec_cost.

    TYPES: tt_rec_cost TYPE TABLE OF ty_rec_cost.

    TYPES: BEGIN OF ty_indallocshares,
             fplv                TYPE /esrcc/costdataset_de,
             ryear               TYPE /esrcc/ryear,
             poper               TYPE /esrcc/poper,
             systemid            TYPE /esrcc/sysid,
             legalentity         TYPE /esrcc/legalentity,
             CompanyCode         TYPE /esrcc/ccode_de,
             costobject          TYPE /esrcc/costobject_de,
             costcenter          TYPE /esrcc/costcenter,
             ServiceProduct      TYPE /esrcc/srvproduct,
             ReceiverSysId       TYPE /esrcc/recsysid,
             ReceiverCompanyCode TYPE /esrcc/recccode_de,
             ReceivingEntity     TYPE /esrcc/receivingntity,
             ReceiverCostObject  TYPE /esrcc/reccostobject_de,
             ReceiverCostCenter  TYPE /esrcc/reccostcenter,
             keyversion          TYPE /esrcc/key_version,
             allockey            TYPE /esrcc/allockey,
             allocationperiod    TYPE /esrcc/allocation_period,
             refperiod           TYPE /esrcc/reference_period,
             weightage           TYPE /esrcc/weightage,
             reckpivalue         TYPE /esrcc/reckpi,
             initialreckpishare  TYPE /esrcc/reckpishare,
             reckpishare         TYPE /esrcc/reckpishare,
           END OF ty_indallocshares.

    TYPES: tt_indallocshares     TYPE TABLE OF ty_indallocshares.

    TYPES: BEGIN OF ty_indallocvalues,
             fplv                TYPE /esrcc/costdataset_de,
             ryear               TYPE /esrcc/ryear,
             poper               TYPE /esrcc/poper,
             systemid            TYPE /esrcc/sysid,
             legalentity         TYPE /esrcc/legalentity,
             CompanyCode         TYPE /esrcc/ccode_de,
             costobject          TYPE /esrcc/costobject_de,
             costcenter          TYPE /esrcc/costcenter,
             ServiceProduct      TYPE /esrcc/srvproduct,
             ReceiverSysId       TYPE /esrcc/recsysid,
             ReceiverCompanyCode TYPE /esrcc/recccode_de,
             ReceivingEntity     TYPE /esrcc/receivingntity,
             ReceiverCostObject  TYPE /esrcc/reccostobject_de,
             ReceiverCostCenter  TYPE /esrcc/reccostcenter,
             keyversion          TYPE /esrcc/key_version,
             allockey            TYPE /esrcc/allockey,
             allocationperiod    TYPE /esrcc/allocation_period,
             refperiod           TYPE /esrcc/reference_period,
             weightage           TYPE /esrcc/weightage,
             refpoper            TYPE /esrcc/reference_period,
             reckpivalue         TYPE /esrcc/reckpi,
           END OF ty_indallocvalues.

    TYPES: tt_indallocvalues     TYPE TABLE OF ty_indallocvalues.

    TYPES: BEGIN OF ty_receiverchargeout,
             systemid         TYPE /esrcc/sysid,
             legalentity      TYPE /esrcc/legalentity,
             CompanyCode      TYPE /esrcc/ccode_de,
             costobject       TYPE /esrcc/costobject_de,
             costcenter       TYPE /esrcc/costcenter,
             ServiceProduct   TYPE /esrcc/srvproduct,
             totalkpi         TYPE /esrcc/reckpi,
             totalreckpishare TYPE /esrcc/reckpishare,
           END OF ty_receiverchargeout.

    TYPES: tt_receiverchargeout     TYPE TABLE OF ty_receiverchargeout.
    TYPES: tt_logitems TYPE STANDARD TABLE OF /esrcc/log_item WITH EMPTY KEY.

    TYPES: BEGIN OF ty_costelement,
             poper            TYPE /esrcc/poper,
             sysid            TYPE /esrcc/sysid,
             company_code     TYPE /esrcc/ccode_de,
             legal_entity     TYPE /esrcc/legalentity,
             cost_object      TYPE /esrcc/costobject_de,
             cost_center      TYPE /esrcc/costcenter,
             costelement_from TYPE /esrcc/costelement,
             costelement_to   TYPE /esrcc/costelement,
             local_curr       TYPE /esrcc/localcurr,
             cost_indicator   TYPE /esrcc/costind_de,
             cost_type        TYPE /esrcc/costtype_de,
             usage_type       TYPE /esrcc/usage,
             value_source     TYPE /esrcc/value_source,
             reason_id        TYPE /esrcc/reasonid,
             posting_type     TYPE /esrcc/postingtype_de,
             valid_from       TYPE /esrcc/validfrom,
             valid_to         TYPE /esrcc/validto,
           END OF ty_costelement.

    TYPES: tt_costelements TYPE TABLE OF ty_costelement.

    TYPES: BEGIN OF ty_stdchargeout,
             ryear                TYPE /esrcc/ryear,
             poper                TYPE /esrcc/poper,
             sysid                TYPE /esrcc/sysid,
             legalentity          TYPE /esrcc/legalentity,
             ccode                TYPE /esrcc/ccode_de,
             costobject           TYPE /esrcc/costobject_de,
             costcenter           TYPE /esrcc/costcenter,
             ServiceProduct       TYPE /esrcc/srvproduct,
             ReceiverSysId        TYPE /esrcc/recsysid,
             ReceiverCompanyCode  TYPE /esrcc/recccode_de,
             ReceivingEntity      TYPE /esrcc/receivingntity,
             ReceiverCostObject   TYPE /esrcc/reccostobject_de,
             ReceiverCostCenter   TYPE /esrcc/reccostcenter,
             currency             TYPE /esrcc/localcurr,
             RecValueadded        TYPE /esrcc/hsl,
             RecPassthrough       TYPE /esrcc/hsl,
             RecValueaddMarkup    TYPE /esrcc/hsl,
             RecPassthroughMarkup TYPE /esrcc/hsl,
             ChargeoutAmount      TYPE /esrcc/hsl,
           END OF ty_stdchargeout.

    TYPES: tt_stdchargeout TYPE TABLE OF ty_stdchargeout.

    TYPES: BEGIN OF ty_recalchargeout,
             ryear                TYPE /esrcc/ryear,
             poper                TYPE /esrcc/poper,
             Refpoper             TYPE /esrcc/poper,
             sysid                TYPE /esrcc/sysid,
             legalentity          TYPE /esrcc/legalentity,
             ccode                TYPE /esrcc/ccode_de,
             costobject           TYPE /esrcc/costobject_de,
             costcenter           TYPE /esrcc/costcenter,
             ServiceProduct       TYPE /esrcc/srvproduct,
             ReceiverSysId        TYPE /esrcc/recsysid,
             ReceiverCompanyCode  TYPE /esrcc/recccode_de,
             ReceivingEntity      TYPE /esrcc/receivingntity,
             ReceiverCostObject   TYPE /esrcc/reccostobject_de,
             ReceiverCostCenter   TYPE /esrcc/reccostcenter,
             currency             TYPE /esrcc/localcurr,
             RecValueadded        TYPE /esrcc/hsl,
             RecPassthrough       TYPE /esrcc/hsl,
             RecValueaddMarkup    TYPE /esrcc/hsl,
             RecPassthroughMarkup TYPE /esrcc/hsl,
             ChargeoutAmount      TYPE /esrcc/hsl,
           END OF ty_recalchargeout.

    TYPES: tt_recalchargeout TYPE TABLE OF ty_recalchargeout.
    TYPES: tt_virtualcostelem TYPE TABLE OF /esrcc/i_costelement_f4.

    CLASS-METHODS: read_lineitems
      IMPORTING
        !it_keys      TYPE tt_keys
      EXPORTING
        !et_lineitems TYPE /esrcc/tt_cbli.

    CLASS-METHODS: read_serviceproduct_data
      IMPORTING
        !it_keys     TYPE tt_keys
      EXPORTING
        !et_srvshare TYPE tt_srvshare.

    CLASS-METHODS: read_receiver_data
      IMPORTING
        !it_srvshare          TYPE tt_srvshare
      EXPORTING
        !et_reccost           TYPE tt_rec_cost
        !et_indalloc          TYPE tt_indallocshares
        !et_indallocvalues    TYPE tt_indallocvalues
        !et_receiverchargeout TYPE tt_receiverchargeout.

    CLASS-METHODS: read_virtual_posting_data
      IMPORTING
        !it_rec_cost       TYPE tt_rec_cost
        !it_keys           TYPE tt_keys
        !iv_recalrefpoper  TYPE /esrcc/poper
      EXPORTING
        !et_grpcostelement TYPE tt_costelements
        !et_le_costelement TYPE tt_costelements
        !et_co_costelement TYPE tt_costelements
        !et_cc_costelement TYPE tt_costelements
        !et_stdchargeout   TYPE tt_stdchargeout
        !et_recalchargeout TYPE tt_recalchargeout.

    CLASS-METHODS: read_processcontrol_data
      IMPORTING
        !it_keys          TYPE tt_keys
        !iv_recalrefpoper TYPE /esrcc/poper
      EXPORTING
        !et_procctrl      TYPE /esrcc/tt_keys
        !et_std_procctrl  TYPE /esrcc/tt_keys.

    CLASS-METHODS: perform_validations
      IMPORTING
        !key               TYPE ty_keys
        !it_lineitems      TYPE /esrcc/tt_cbli
        !it_cc_cost        TYPE /esrcc/tt_cbstw
        !it_srvshare       TYPE tt_srvshare
        !it_rec_cost       TYPE tt_rec_cost
        !activeccode       TYPE /esrcc/tt_le_ccode
        !receiverchargeout TYPE tt_receiverchargeout
        !it_stdprocctrl    TYPE /esrcc/tt_keys
        !iv_recalrefpoper  TYPE /esrcc/poper OPTIONAL
      EXPORTING
        !logitems          TYPE tt_logitems
        !ev_nolineitems    TYPE abap_boolean
        !ev_failed         TYPE abap_boolean.

    CLASS-METHODS: addnew_chargeout_data
      IMPORTING
        !it_cc_cost          TYPE /esrcc/tt_cbstw
        !it_srvshare         TYPE tt_srvshare
        !it_rec_cost         TYPE tt_rec_cost
        !it_indalloc         TYPE tt_indallocshares
        !it_indallocvalues   TYPE tt_indallocvalues
        !it_grpcostelement   TYPE tt_costelements
        !it_le_costelement   TYPE tt_costelements
        !it_co_costelement   TYPE tt_costelements
        !it_cc_costelement   TYPE tt_costelements
        !it_stdchargeout     TYPE tt_stdchargeout
        !it_recalchargeout   TYPE tt_recalchargeout
        !it_virtualcostelem  TYPE tt_virtualcostelem
        !groupcurrency       TYPE /esrcc/groupcurr
        !wf_active           TYPE abap_boolean
        !iv_recalrefpoper    TYPE /esrcc/poper
      EXPORTING
        !et_cbli             TYPE /esrcc/tt_cbli
        !et_cc_cost          TYPE /esrcc/tt_cbstw
        !et_srv_cost         TYPE /esrcc/tt_srvshare
        !et_rec_chg          TYPE /esrcc/tt_rec_cost
        !et_alocshares       TYPE /esrcc/tt_alocshares
        !et_alocvalues       TYPE /esrcc/tt_allocvalues
        !et_wf_leadingobject TYPE /esrcc/tt_wf_leadingobject.

    CLASS-METHODS: add_virtual_posting
      IMPORTING
        !docno             TYPE /esrcc/doc_no
        !itemno            TYPE /esrcc/buzei
        !it_grpcostelement TYPE tt_costelements
        !it_le_costelement TYPE tt_costelements
        !it_co_costelement TYPE tt_costelements
        !it_cc_costelement TYPE tt_costelements
        !costelemtype      TYPE /esrcc/costelem_type
        !costelement       TYPE /esrcc/costelement
        !it_stdchargeout   TYPE tt_stdchargeout
        !it_recalchargeout TYPE tt_recalchargeout
        !rec_cost          TYPE ty_rec_cost
        !groupcurrency     TYPE /esrcc/groupcurr
        !chargeoutamount   TYPE /esrcc/chgamount
        !Exchdate          TYPE /esrcc/validfrom
        !iv_recalrefpoper  TYPE /esrcc/poper
      EXPORTING
        !es_cbli           TYPE /esrcc/cb_li.

    CLASS-METHODS finalize_costbase
      IMPORTING
        !it_keys          TYPE /esrcc/tt_keys
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL .

    CLASS-METHODS reopen_costbase
      IMPORTING
        !it_keys          TYPE /esrcc/tt_keys
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL .

    CLASS-METHODS create_processlogs
      IMPORTING
        !iv_action      TYPE /esrcc/actions OPTIONAL
        !it_keys        TYPE /esrcc/tt_keys
      EXPORTING
        !et_processlogs TYPE /esrcc/tt_processlogs .

    CLASS-METHODS authority_check
      IMPORTING
        !keys   TYPE /esrcc/procctrl
        !action TYPE /esrcc/actions
      EXPORTING
        !failed TYPE abap_boolean .

    CLASS-METHODS set_process_control
      IMPORTING
        !keys    TYPE /esrcc/tt_keys
        !process TYPE /esrcc/application_type_de
        !status  TYPE /esrcc/process_status_de
        !update  TYPE abap_boolean
      EXPORTING
        !failed  TYPE abap_boolean .

    CLASS-METHODS set_prc_errorflag
      IMPORTING
        !keys   TYPE /esrcc/tt_keys
      EXPORTING
        !failed TYPE abap_boolean .

    CLASS-METHODS determine_delta_chargeout
      IMPORTING
        !it_keys     TYPE tt_keys
        !iv_workflow TYPE abap_boolean DEFAULT abap_true .

    CLASS-METHODS determine_last_day
      IMPORTING
        !iv_ryear    TYPE /esrcc/ryear
        !iv_poper    TYPE poper
      EXPORTING
        !ev_valid_on TYPE /esrcc/validfrom .

    CLASS-METHODS delete_virtual_postings
      IMPORTING
        !it_keys          TYPE /esrcc/tt_keys
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL .

    CLASS-METHODS trigger_workflow
      IMPORTING
        !it_leading_object TYPE /esrcc/tt_wf_leadingobject
        !iv_application    TYPE /esrcc/application_type_de .

    CLASS-METHODS delete_costbase
      IMPORTING
        !it_keys          TYPE /esrcc/tt_keys
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL .

    CLASS-METHODS delete_trueups
      IMPORTING
        !it_keys          TYPE /esrcc/tt_keys
        !iv_recalrefpoper TYPE /esrcc/poper OPTIONAL .

    CLASS-METHODS derive_poper
      IMPORTING
        !it_keys  TYPE /esrcc/tt_keys
      EXPORTING
        !et_poper TYPE /esrcc/tt_poper_range .

    CLASS-METHODS create_loginstance
      IMPORTING
        !key               TYPE /esrcc/procctrl
        !procctrl          TYPE /esrcc/tt_keys
        !process           TYPE /esrcc/process
      RETURNING
        VALUE(loginstance) TYPE REF TO /esrcc/if_application_logs .

    CLASS-METHODS add_logmessages
      IMPORTING
        !logitems    TYPE /esrcc/log_items
        !loginstance TYPE REF TO /esrcc/if_application_logs .

    CLASS-METHODS determine_validon
      IMPORTING
        !it_keys       TYPE /esrcc/tt_keys
        !it_poper      TYPE /esrcc/tt_poper_range
      RETURNING
        VALUE(validon) TYPE /esrcc/validfrom .

    CLASS-METHODS: get_sequential_keys
      IMPORTING
        !it_keys            TYPE /esrcc/tt_keys
      EXPORTING
        !et_seq_keys        TYPE /esrcc/tt_keys
        !et_nonseq_keys     TYPE /esrcc/tt_keys
        !et_seq_mon_keys    TYPE tt_keys
        !et_nonseq_mon_keys TYPE tt_keys.

ENDCLASS.



CLASS /ESRCC/CL_CALCULATE_TRUEUP IMPLEMENTATION.


  METHOD add_logmessages.


  ENDMETHOD.


  METHOD authority_check.

    CLEAR failed.

*    Authorisation Check
    IF action = /esrcc/if_calculate_chargeout=>calculate_recalchargeout. " OR
*       action = /esrcc/if_calculate_chargeout=>calculate_recalseqchargeout.

      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
          ID '/ESRCC/LE' FIELD keys-legalentity
          ID 'ACTVT'  FIELD '01'.
      IF sy-subrc <> 0.
        failed = abap_true.
      ELSE.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
            ID '/ESRCC/OBJ' FIELD keys-costobject
            ID '/ESRCC/CN'  FIELD keys-costcenter
            ID 'ACTVT'  FIELD '01'.
        IF sy-subrc <> 0.
          failed = abap_true.
        ENDIF.
      ENDIF.
    ELSEIF action = /esrcc/if_calculate_chargeout=>finalize_recalchargeout.
*           action = /esrcc/if_calculate_chargeout=>finalize_recalseqchargeout.

      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
          ID '/ESRCC/LE' FIELD keys-legalentity
          ID 'ACTVT'  FIELD '02'.
      IF sy-subrc <> 0.
        failed = abap_true.
      ELSE.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
            ID '/ESRCC/OBJ' FIELD keys-costobject
            ID '/ESRCC/CN'  FIELD keys-costcenter
            ID 'ACTVT'  FIELD '02'.
        IF sy-subrc <> 0.
          failed = abap_true.
        ENDIF.
      ENDIF.
    ELSEIF action = /esrcc/if_calculate_chargeout=>reopen_recalchargeout.
*           action = /esrcc/if_calculate_chargeout=>reopen_recalseqchargeout.

      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
          ID '/ESRCC/LE' FIELD keys-legalentity
          ID 'ACTVT'  FIELD '06'.
      IF sy-subrc <> 0.
        failed = abap_true.
      ELSE.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
            ID '/ESRCC/OBJ' FIELD keys-costobject
            ID '/ESRCC/CN'  FIELD keys-costcenter
            ID 'ACTVT'  FIELD '06'.
        IF sy-subrc <> 0.
          failed = abap_true.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD create_loginstance.

    DATA loghdr        TYPE /esrcc/log_hdr.
    DATA logitem       TYPE /esrcc/log_item.

    READ TABLE procctrl ASSIGNING FIELD-SYMBOL(<procctrl>) WITH KEY fplv           = key-fplv
                                                                      ryear         = key-ryear
                                                                      poper         = key-poper
                                                                      sysid         = key-sysid
                                                                      legalentity   = key-legalentity
                                                                      ccode         = key-ccode
                                                                      costobject    = key-costobject
                                                                      costcenter    = key-costcenter
                                                                      process       = process
                                                                      BINARY SEARCH.

    IF sy-subrc = 0 AND <procctrl>-log_header_uuid IS NOT INITIAL.
* check if logid is already available then call resue instance to get the existence instance
      /esrcc/cl_application_logs=>reuse_instance(
        EXPORTING
          log_header_id = <procctrl>-log_header_uuid
        RECEIVING
          instance      = loginstance
      ).

*    Clear old messages
      loginstance->clear_messages( ).

    ELSE.
*  create a new instance
      /esrcc/cl_application_logs=>create_instance(
        EXPORTING
          deter_save = abap_true
        RECEIVING
          instance   = loginstance
      ).

*    set log header info
      loghdr-application      = 'EXE'.
      loghdr-sub_application  = process.
      loghdr-company_code     = key-ccode.
      loghdr-legal_entity     = key-legalentity.
      loghdr-planning_version = key-fplv.
      loghdr-reporting_year   = key-ryear.
      loghdr-system_id        = key-sysid.
      loginstance->set_log_header_info( log_header = loghdr ).
    ENDIF.

*  set header message about the object
    CLEAR logitem.
    logitem-message_id = '/ESRCC/EXECCOCKPIT'.
    logitem-message_number = '022'.
    logitem-message_type = 'I'.
    CONCATENATE key-fplv key-ryear key-poper INTO DATA(perioddetials) SEPARATED BY '-'.
*      CONCATENATE 'Period:' perioddetials INTO logitem-message_v1 SEPARATED BY space.
    CONCATENATE key-sysid key-legalentity key-ccode INTO logitem-message_v2 SEPARATED BY '/'.
    CONCATENATE 'Entity:' logitem-message_v2 INTO logitem-message_v2 SEPARATED BY space.
    CONCATENATE key-costobject key-costcenter INTO logitem-message_v3 SEPARATED BY '/'.
    CONCATENATE 'Object:' logitem-message_v3 INTO logitem-message_v3 SEPARATED BY space.
    loginstance->add_message(
      EXPORTING
        log_message      = logitem
    ).

  ENDMETHOD.


  METHOD create_processlogs.

    DATA processlog TYPE /esrcc/proclogs.

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

    LOOP AT it_keys ASSIGNING FIELD-SYMBOL(<procctrl>).
      MOVE-CORRESPONDING <procctrl> TO processlog.
* Assign the 16 digit unique identifier
      IF lo_uuid IS BOUND.
        TRY.
            processlog-uuid = lo_uuid->create_uuid_x16( ).
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
      ENDIF.

      processlog-action = iv_action.

* Admin data
      processlog-created_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = processlog-created_at
      ).
      processlog-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = processlog-last_changed_at
      ).

      APPEND processlog TO et_processlogs.

    ENDLOOP.

    MODIFY /esrcc/proclogs FROM TABLE @et_processlogs.

  ENDMETHOD.


  METHOD delete_costbase.

    DATA lt_tmp_cost TYPE TABLE OF /esrcc/cb_stw.
    DATA lt_cb_li    TYPE TABLE OF /esrcc/cb_li.
    DATA lv_refguid  TYPE sysuuid_x16.
    DATA lv_recalpoper TYPE /esrcc/poper.
    DATA conditonlist  TYPE string.
    DATA fieldlist     TYPE string.
    DATA fieldname     TYPE string.

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = DATA(last_changed_at)
    ).

**Reopen Virtual posting in case done during finalizing chargeouts.
    delete_virtual_postings(
      it_keys  = it_keys
      iv_recalrefpoper = iv_recalrefpoper
    ).

    SELECT cb_stw~*
      FROM /esrcc/cb_stw AS cb_stw
      INNER JOIN @it_keys AS it_keys
        ON cb_stw~ryear        = it_keys~ryear
       AND cb_stw~sysid        = it_keys~sysid
       AND cb_stw~legalentity  = it_keys~legalentity
       AND cb_stw~ccode        = it_keys~ccode
       AND cb_stw~costobject   = it_keys~costobject
       AND cb_stw~costcenter   = it_keys~costcenter
*       AND cb_stw~poper        = it_keys~poper
       AND cb_stw~recalrefpoper = @iv_recalrefpoper
       AND cb_stw~processtype   = @/esrcc/if_calculate_chargeout=>recalprocesstype
    INTO TABLE @DATA(lt_cbstw).

    CHECK lt_cbstw IS NOT INITIAL.

    SELECT srv_share~*
      FROM /esrcc/srv_share AS srv_share
      INNER JOIN @lt_cbstw AS cbstw
        ON cbstw~cc_uuid = srv_share~cc_uuid
       INTO TABLE @DATA(lt_srvshare).

    SELECT rec_chg~*
       FROM /esrcc/rec_chg AS rec_chg
       INNER JOIN @lt_cbstw AS cbstw
         ON cbstw~cc_uuid = rec_chg~cc_uuid
        INTO TABLE @DATA(lt_recchg).

    IF lt_recchg IS NOT INITIAL.
*  Delete Service Allocation
      SELECT alocshare~*
        FROM /esrcc/alocshare AS alocshare
        INNER JOIN @lt_recchg AS recshare
          ON alocshare~parentuuid = recshare~rec_uuid
      INTO TABLE @DATA(lt_alocshare).
      IF lt_alocshare IS NOT INITIAL.
        SELECT *
          FROM /esrcc/alcvalues AS alcvalues
          INNER JOIN @lt_alocshare AS alocshare
            ON alcvalues~parentuuid = alocshare~uuid
        INTO TABLE @DATA(lt_alocvalues).
      ENDIF.
    ENDIF.

    CONCATENATE 'cb~refguid' iv_recalrefpoper INTO fieldname.
    CONCATENATE fieldname '= ik~cc_uuid' INTO conditonlist SEPARATED BY space.

    CONCATENATE 'refguid' iv_recalrefpoper INTO fieldname.
    CONCATENATE 'cb~*,'
                '@/esrcc/if_calculate_chargeout=>approved AS status,'
                '@sy-uname AS last_changed_by,'
                '@last_changed_at AS last_changed_at,'
                '@lv_refguid AS' fieldname
      INTO fieldlist SEPARATED BY space.

*reset cost base line items.
    LOOP AT lt_cbstw INTO DATA(ls_cbstw)
                       GROUP BY ( legalentity = ls_cbstw-legalentity )
                       INTO DATA(entitygroup).

      CLEAR lt_tmp_cost.
      LOOP AT GROUP entitygroup INTO DATA(cbstw).
        APPEND cbstw TO lt_tmp_cost.
      ENDLOOP.

*reset cost base line items.
      IF lt_tmp_cost IS NOT INITIAL.
        CLEAR lt_cb_li.
        SELECT (fieldlist)
*               cb~*,
*               @/esrcc/if_calculate_chargeout=>approved AS status,
*               @lv_refguid AS cc_guid,
*               @lv_recalpoper AS recalrefpoper,
*               @sy-uname AS last_changed_by,
*               @last_changed_at AS last_changed_at
          FROM /esrcc/cb_li AS cb
          INNER JOIN @lt_tmp_cost AS ik
            ON (conditonlist)
          WHERE cb~recalrefpoper = @iv_recalrefpoper
            AND cb~value_source <> 'SCC'
        INTO CORRESPONDING FIELDS OF TABLE @lt_cb_li.

        MODIFY /esrcc/cb_li FROM TABLE @lt_cb_li.
      ENDIF.

    ENDLOOP.

**Delete trueups
    delete_trueups(
      it_keys          = it_keys
      iv_recalrefpoper = iv_recalrefpoper
    ).

    DELETE /esrcc/cb_stw    FROM TABLE @lt_cbstw.
    DELETE /esrcc/srv_share FROM TABLE @lt_srvshare.
    DELETE /esrcc/rec_chg   FROM TABLE @lt_recchg.
    DELETE /esrcc/alocshare FROM TABLE @lt_alocshare.
    DELETE /esrcc/alcvalues FROM TABLE @lt_alocvalues.

    CLEAR: lt_cbstw,
           lt_srvshare,
           lt_recchg,
           lt_alocshare,
           lt_alocvalues,
           lt_tmp_cost,
           lt_cb_li.

  ENDMETHOD.


  METHOD delete_virtual_postings.


    SELECT *
      FROM /esrcc/cb_li AS cb
      INNER JOIN @it_keys AS ik
       ON  cb~ryear                = ik~ryear
       AND cb~posting_sysid        = ik~sysid
       AND cb~posting_legalentity  = ik~legalentity
       AND cb~posting_ccode        = ik~ccode
       AND cb~posting_costobject   = ik~costobject
       AND cb~posting_costcenter   = ik~costcenter
*       AND cb~poper                = ik~poper
       AND cb~value_source         = 'SCC'
       AND cb~recalrefpoper        = @iv_recalrefpoper
    INTO TABLE @DATA(lt_costbase).

    DELETE /esrcc/cb_li FROM TABLE @lt_costbase.

  ENDMETHOD.


  METHOD derive_poper.

    DATA poper TYPE /esrcc/poper.

*Derive poper from billing frequency customizing
    READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      WHILE ( poper < <key>-poper ).
        poper = poper + 1.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = poper high = '' ) TO et_poper.
      ENDWHILE.
      SORT et_poper BY low.
    ENDIF.



  ENDMETHOD.


  METHOD determine_delta_chargeout.

    DATA lt_recsharedelta TYPE TABLE OF /esrcc/rec_chg.

*Handling of delta for direct Scenario
*If there is cost base which is not allocated 100% due to difference between consumption & planning
* for a period then allocate that cost base and remaining comsumption to a dummy receiver

*get total share of allocated to all receivers
    SELECT DISTINCT
           rec_chg~cc_uuid,
           rec_chg~srv_uuid,
           rec_chg~rec_uuid,
           reckpi,
           valueaddmarkup,
           passthrumarkup
          FROM /esrcc/cb_stw AS cb_stw
          INNER JOIN /esrcc/srv_share AS srv_share
            ON cb_stw~cc_uuid = srv_share~cc_uuid
           AND srv_share~chargeout = 'D'
          INNER JOIN /esrcc/rec_chg AS rec_chg
            ON cb_stw~cc_uuid = rec_chg~cc_uuid
           AND srv_share~srv_uuid = rec_chg~srv_uuid
          INNER JOIN @it_keys AS ik
            ON cb_stw~fplv          = ik~fplv
           AND cb_stw~ryear         = ik~ryear
           AND cb_stw~poper         = ik~poper
           AND cb_stw~sysid         = ik~sysid
           AND cb_stw~legalentity   = ik~legalentity
           AND cb_stw~ccode         = ik~ccode
           AND cb_stw~costobject    = ik~costobject
           AND cb_stw~costcenter    = ik~costcenter
*           AND srv_share~serviceproduct = ik~serviceproduct
*        WHERE cb_stw~poper IN @it_poper
        ORDER BY rec_chg~cc_uuid,
                 rec_chg~srv_uuid,
                 rec_chg~rec_uuid
        INTO TABLE @DATA(lt_recshare).

*get total share assigned to service product
    SELECT DISTINCT
          cb_stw~ryear,
          cb_stw~poper,
          cb_stw~localcurr,
          srv_share~*
          FROM /esrcc/cb_stw AS cb_stw
          INNER JOIN /esrcc/srv_share AS srv_share
            ON cb_stw~cc_uuid = srv_share~cc_uuid
           AND srv_share~chargeout = 'D'
          INNER JOIN @it_keys AS ik
            ON cb_stw~fplv          = ik~fplv
           AND cb_stw~ryear         = ik~ryear
           AND cb_stw~poper         = ik~poper
           AND cb_stw~sysid         = ik~sysid
           AND cb_stw~legalentity   = ik~legalentity
           AND cb_stw~ccode         = ik~ccode
           AND cb_stw~costobject    = ik~costobject
           AND cb_stw~costcenter    = ik~costcenter
*           AND srv_share~serviceproduct = ik~serviceproduct
*        WHERE cb_stw~poper IN @it_poper
        INTO TABLE @DATA(lt_srvshare).


    SELECT DISTINCT
           cc_uuid,
           srv_uuid,
           SUM( reckpi ) AS totalconsumption
           FROM @lt_recshare AS recshare
           GROUP BY
           cc_uuid,
           srv_uuid
           ORDER BY cc_uuid,
                    srv_uuid
           INTO TABLE @DATA(lt_totalconsumption).

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

* get dummy cost object details
    SELECT SINGLE * FROM /esrcc/cst_objct WHERE legal_entity = 'REST'
                    INTO @DATA(dummyreceiver).


    LOOP AT lt_srvshare ASSIGNING FIELD-SYMBOL(<ls_srvshare>).
      READ TABLE lt_totalconsumption ASSIGNING FIELD-SYMBOL(<totalconsumption>)
                                     WITH KEY cc_uuid = <ls_srvshare>-srv_share-cc_uuid
                                              srv_uuid = <ls_srvshare>-srv_share-srv_uuid
                                              BINARY SEARCH.

      IF sy-subrc = 0 AND <ls_srvshare>-srv_share-planning <> <totalconsumption>-totalconsumption.
** add a dummy receiver
        APPEND INITIAL LINE TO lt_recsharedelta ASSIGNING FIELD-SYMBOL(<recshare>).
        <recshare>-cc_uuid = <ls_srvshare>-srv_share-cc_uuid.
        <recshare>-srv_uuid = <ls_srvshare>-srv_share-srv_uuid.
* Assign the 16 digit unique identifier
        IF lo_uuid IS BOUND.
          TRY.
              <recshare>-rec_uuid = lo_uuid->create_uuid_x16( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
        ENDIF.
        IF dummyreceiver IS NOT INITIAL.
          <recshare>-receivingentity = dummyreceiver-legal_entity.
          <recshare>-receiversysid = dummyreceiver-sysid.
          <recshare>-receivercompanycode = dummyreceiver-company_code.
          <recshare>-receivercostobject = dummyreceiver-cost_object.
          <recshare>-receivercostcenter = dummyreceiver-cost_center.
        ELSE.
          <recshare>-receivingentity = 'REST'.
          <recshare>-receiversysid = 'RS'.
          <recshare>-receivercompanycode = 'RS01'.
          <recshare>-receivercostobject = 'CC'.
          <recshare>-receivercostcenter = 'DUMMY'.
        ENDIF.
*   get the markups applied at service product level for each receiever and apply for delta node as well
        READ TABLE lt_recshare ASSIGNING FIELD-SYMBOL(<ls_recshare>) WITH KEY cc_uuid = <totalconsumption>-cc_uuid
                                                                              srv_uuid = <totalconsumption>-srv_uuid
                                                                              BINARY SEARCH.
        IF sy-subrc = 0.
          <recshare>-valueaddmarkup = <ls_recshare>-valueaddmarkup.
          <recshare>-passthrumarkup = <ls_recshare>-passthrumarkup.
        ENDIF.
*    Assign local currency of the provider as the invoicing currency for REST.
        <recshare>-invoicingcurrency = <ls_srvshare>-localcurr.
        IF iv_workflow = abap_true.
          <recshare>-status = /esrcc/if_calculate_chargeout=>approval_pending.
        ELSE.
          <recshare>-status = /esrcc/if_calculate_chargeout=>approved.
        ENDIF.
        <recshare>-invoicestatus = '01'.
        <recshare>-reckpi = <ls_srvshare>-srv_share-planning - <totalconsumption>-totalconsumption.
        <recshare>-consumptionuom = <ls_srvshare>-srv_share-planninguom.
        determine_last_day(
          EXPORTING
            iv_ryear    = <ls_srvshare>-ryear
            iv_poper    = <ls_srvshare>-poper
          IMPORTING
            ev_valid_on = <recshare>-exchdate
        ).
* Admin data
        <recshare>-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <recshare>-created_at
        ).
        <recshare>-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <recshare>-last_changed_at
        ).

      ENDIF.
    ENDLOOP.

    MODIFY /esrcc/rec_chg FROM TABLE @lt_recsharedelta.

    CLEAR: lt_recshare, lt_totalconsumption, lt_recsharedelta, lt_srvshare.

  ENDMETHOD.


  METHOD determine_last_day.

    DATA lv_valid_from TYPE /esrcc/validfrom.

    CONCATENATE iv_ryear iv_poper+1(2) '01' INTO lv_valid_from.

    CALL FUNCTION '/ESRCC/FM_LAST_DAY_OF_MONTH'
      EXPORTING
        day_in       = lv_valid_from
      IMPORTING
        end_of_month = ev_valid_on.

  ENDMETHOD.


  METHOD finalize_costbase.

    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl TYPE  /esrcc/procctrl.
    DATA lt_cbstw    TYPE TABLE OF /esrcc/cb_stw.
    DATA lt_srvshare TYPE TABLE OF /esrcc/srv_share.
    DATA lt_trueup   TYPE TABLE OF /esrcc/trueup.
    DATA lt_cb_li    TYPE TABLE OF /esrcc/cb_li.
    DATA lt_tmp_cost TYPE TABLE OF /esrcc/cb_stw.
    DATA number      TYPE /esrcc/doc_no.
    DATA lo_badi     TYPE REF TO /esrcc/badi_trueuprecal.
    DATA lt_recshare TYPE TABLE OF /esrcc/rec_chg.
    DATA lv_invoicestatus TYPE /esrcc/invoicestatus VALUE '01'.
    DATA conditonlist  TYPE string.
    DATA fieldlist     TYPE string.
    DATA fieldname     TYPE string.

    DATA(lt_keys) = it_keys.
    DELETE lt_keys WHERE costcenter IS INITIAL.

    CHECK lt_keys IS NOT INITIAL.

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
        time_stamp = DATA(last_changed_at)
    ).

*Finalize calculated Cost base & Stewardship
    SELECT  cb~*,
            @/esrcc/if_calculate_chargeout=>finalized AS status,
            @sy-uname AS last_changed_by,
            @last_changed_at AS last_changed_at
      FROM /esrcc/cb_stw AS cb
      INNER JOIN @lt_keys AS ik
       ON  cb~ryear       = ik~ryear
       AND cb~sysid       = ik~sysid
       AND cb~legalentity = ik~legalentity
       AND cb~ccode       = ik~ccode
       AND cb~costobject  = ik~costobject
       AND cb~costcenter  = ik~costcenter
      WHERE  cb~recalrefpoper = @iv_recalrefpoper
    INTO CORRESPONDING FIELDS OF TABLE @lt_cbstw.

*Finalize service product costing
    SELECT srv_share~*,
           @/esrcc/if_calculate_chargeout=>finalized AS status,
           @sy-uname AS last_changed_by,
           @last_changed_at AS last_changed_at
      FROM /esrcc/srv_share AS srv_share
       INNER JOIN @lt_cbstw AS cb_stw
        ON cb_stw~cc_uuid = srv_share~cc_uuid
    INTO CORRESPONDING FIELDS OF TABLE @lt_srvshare.

*Finalize calculated receiever
    SELECT rec_chg~*,
           @lv_invoicestatus AS invoicestatus,
           @/esrcc/if_calculate_chargeout=>finalized AS status,
           @sy-uname AS last_changed_by,
           @last_changed_at AS last_changed_at
          FROM /esrcc/rec_chg AS rec_chg
          INNER JOIN @lt_cbstw AS cbstw
            ON cbstw~cc_uuid = rec_chg~cc_uuid
        INTO CORRESPONDING FIELDS OF TABLE @lt_recshare.

    CONCATENATE 'cb~refguid' iv_recalrefpoper INTO fieldname.
    CONCATENATE fieldname '= ik~cc_uuid' INTO conditonlist SEPARATED BY space.

    CONCATENATE 'refguid' iv_recalrefpoper INTO fieldname.
    CONCATENATE 'cb~*,'
                '@/esrcc/if_calculate_chargeout=>finalized AS status,'
                '@sy-uname AS last_changed_by,'
                '@last_changed_at AS last_changed_at'
      INTO fieldlist SEPARATED BY space.

*Finalize cost base line items.
    LOOP AT lt_cbstw INTO DATA(ls_cbstw)
                       GROUP BY ( legalentity = ls_cbstw-legalentity )
                       INTO DATA(entitygroup).

      CLEAR lt_tmp_cost.
      LOOP AT GROUP entitygroup INTO DATA(cbstw).
        APPEND cbstw TO lt_tmp_cost.
      ENDLOOP.

*Finalize cost base line items.
      IF lt_tmp_cost IS NOT INITIAL.
        CLEAR lt_cb_li.
        SELECT (fieldlist)
          FROM /esrcc/cb_li AS cb
          INNER JOIN @lt_tmp_cost AS ik
            ON (conditonlist)
           WHERE cb~recalrefpoper = @iv_recalrefpoper
        INTO CORRESPONDING FIELDS OF TABLE @lt_cb_li.

        MODIFY /esrcc/cb_li FROM TABLE @lt_cb_li.
      ENDIF.
      FREE: lt_tmp_cost,
            lt_cb_li.
    ENDLOOP.

*finalize True-ups
    SELECT trueup~*,
           @/esrcc/if_calculate_chargeout=>finalized AS status,
           @sy-uname AS last_changed_by,
           @last_changed_at AS last_changed_at
        FROM /esrcc/trueup AS trueup
        INNER JOIN @lt_keys AS ik
       ON  trueup~ryear         = ik~ryear
       AND trueup~sysid         = ik~sysid
       AND trueup~legalentity   = ik~legalentity
       AND trueup~ccode         = ik~ccode
       AND trueup~costobject    = ik~costobject
       AND trueup~costcenter    = ik~costcenter
     WHERE trueup~recalrefpoper = @iv_recalrefpoper
    INTO CORRESPONDING FIELDS OF TABLE @lt_trueup.

*update execution process control
    set_process_control(
      EXPORTING
        keys    = lt_keys
        process = /esrcc/if_calculate_chargeout=>trueuprecal
        status  = /esrcc/if_calculate_chargeout=>recalculation_finalized
        update  = abap_true
    ).

*Add process logs for traceability
    create_processlogs(
      iv_action = /esrcc/if_calculate_chargeout=>finalize_recalchargeout
      it_keys   = lt_procctrl
    ).


    MODIFY /esrcc/srv_share FROM TABLE @lt_srvshare.
    MODIFY /esrcc/cb_stw    FROM TABLE @lt_cbstw.
    MODIFY /esrcc/rec_chg   FROM TABLE @lt_recshare.
    MODIFY /esrcc/trueup    FROM TABLE @lt_trueup.

    FREE: lt_cbstw,
          lt_tmp_cost,
          lt_procctrl,
          lt_trueup,
          lt_cb_li.

  ENDMETHOD.


  METHOD reopen_costbase.

    DATA lt_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl   TYPE  /esrcc/procctrl.
    DATA lt_alocshare  TYPE TABLE OF /esrcc/alocshare.
    DATA lt_alocvalues TYPE TABLE OF /esrcc/alcvalues.
    DATA lt_cb_li TYPE TABLE OF /esrcc/cb_li.

    DATA(lt_keys) = it_keys.
    DELETE lt_keys WHERE costcenter IS INITIAL.

    CHECK lt_keys IS NOT INITIAL.


*  Delete cost center cost
    delete_costbase(
      it_keys  = lt_keys
      iv_recalrefpoper = iv_recalrefpoper
    ).

*Update execution cockpit process control
    SELECT pc~*
      FROM /esrcc/procctrl AS pc
      INNER JOIN @lt_keys AS ik
       ON  pc~ryear         = ik~ryear
       AND pc~sysid         = ik~sysid
       AND pc~legalentity   = ik~legalentity
       AND pc~ccode         = ik~ccode
       AND pc~costobject    = ik~costobject
       AND pc~costcenter    = ik~costcenter
       AND pc~poper         = @iv_recalrefpoper
       AND pc~process       = @/esrcc/if_calculate_chargeout=>trueuprecal
    INTO TABLE @lt_procctrl.

*Add process logs for traceability
    create_processlogs(
      iv_action = /esrcc/if_calculate_chargeout=>reopen_recalchargeout
      it_keys   = lt_procctrl
    ).

    DELETE /esrcc/procctrl FROM TABLE @lt_procctrl.

    CLEAR: lt_procctrl.

  ENDMETHOD.


  METHOD trigger_workflow.

    CALL FUNCTION '/ESRCC/FM_WF_START'
      EXPORTING
        it_leading_object = it_leading_object
        iv_apptype        = iv_application.

  ENDMETHOD.


  METHOD set_process_control.

    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.

    IF update = abap_true.
      SELECT procctrl~*  FROM /esrcc/procctrl AS procctrl
         INNER JOIN @keys AS keys
         ON procctrl~ryear = keys~ryear
         AND procctrl~poper = keys~poper
         AND procctrl~sysid = keys~sysid
         AND procctrl~ccode = keys~ccode
         AND procctrl~legalentity = keys~legalentity
         AND procctrl~costobject = keys~costobject
         AND procctrl~costcenter = keys~costcenter
         AND procctrl~process = @process
         INTO CORRESPONDING FIELDS OF TABLE @lt_procctrl.

*update process control
      LOOP AT lt_procctrl ASSIGNING FIELD-SYMBOL(<procctrl>).

*      ls_procctrl = CORRESPONDING #( <procctrl> ).
        <procctrl>-process = process.    "Cost Base
        <procctrl>-status = status.

*Admin data
        <procctrl>-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <procctrl>-last_changed_at
        ).

      ENDLOOP.

    ELSE.

*update process control
      LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).

        ls_procctrl = CORRESPONDING #( <key> ).
        ls_procctrl-process = process.    "Cost Base
        ls_procctrl-status = status.     "Cost Base Approved

*Admin data
        IF update = abap_false.
          ls_procctrl-created_by = sy-uname.
          /esrcc/cl_utility_core=>get_utc_date_time_ts(
            IMPORTING
              time_stamp = ls_procctrl-created_at
          ).
        ENDIF.

        ls_procctrl-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_procctrl-last_changed_at
        ).

        APPEND ls_procctrl TO lt_procctrl.
      ENDLOOP.

    ENDIF.

    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.

  ENDMETHOD.


  METHOD determine_validon.

    LOOP AT it_keys ASSIGNING FIELD-SYMBOL(<keys>).
      LOOP AT it_poper ASSIGNING FIELD-SYMBOL(<poper>).
        CONCATENATE <keys>-ryear <poper>-low+1(2) '01' INTO validon.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  METHOD calculate_recalchargeout.

    IF it_keys IS NOT INITIAL.
      DATA(recalrefpoper) = it_keys[ 1 ]-poper.
    ENDIF.

    get_sequential_keys(
      EXPORTING
        it_keys            = it_keys
      IMPORTING
        et_seq_keys        = DATA(lt_seq_keys)
        et_nonseq_keys     = DATA(lt_nonseq_key)
        et_seq_mon_keys    = DATA(lt_seq_mon_keys)
        et_nonseq_mon_keys = DATA(lt_nonseq_mon_keys)
    ).


**********************************************************************
*  Perform Non sequential Charge outs
**********************************************************************
    IF lt_nonseq_key IS NOT INITIAL.
      perform_trueup_nonseq(
        EXPORTING
          it_keys          = lt_nonseq_key
          it_keys_monthly  = lt_nonseq_mon_keys
          iv_workflow      = abap_true
          iv_recalrefpoper = recalrefpoper
      ).
    ENDIF.
**********************************************************************
*  Perform Sequential Charge outs
**********************************************************************
    IF lt_seq_keys IS NOT INITIAL.
      perform_trueup_seq(
          EXPORTING
            it_keys          = lt_seq_keys
            it_keys_monthly  = lt_seq_mon_keys
            iv_workflow      = abap_false
            iv_recalrefpoper = recalrefpoper
          IMPORTING
            ev_failed        = DATA(failed)
        ).
    ENDIF.
  ENDMETHOD.


  METHOD finalize_recalchargeout.

    DATA lt_keys TYPE /esrcc/tt_keys.

    IF it_keys IS NOT INITIAL.
      DATA(recalrefpoper) = it_keys[ 1 ]-poper.
    ENDIF.

    CHECK it_keys IS NOT INITIAL.

*get the chain and sequence.
* each cost object could be providing multiple services
    get_sequential_keys(
      EXPORTING
        it_keys        = it_keys
      IMPORTING
        et_seq_keys    = DATA(lt_seq_keys)
        et_nonseq_keys = DATA(lt_nonseq_keys)
    ).

    APPEND LINES OF lt_seq_keys TO lt_keys.
    APPEND LINES OF lt_nonseq_keys TO lt_keys.

    finalize_costbase(
      it_keys  = lt_keys
      iv_recalrefpoper = recalrefpoper
    ).

  ENDMETHOD.


  METHOD reopen_recalchargeout.

    DATA lt_keys TYPE /esrcc/tt_keys.

    IF it_keys IS NOT INITIAL.
      DATA(recalrefpoper) = it_keys[ 1 ]-poper.
    ENDIF.

    CHECK it_keys IS NOT INITIAL.

*get the chain and sequence.
* each cost object could be providing multiple services
    get_sequential_keys(
      EXPORTING
        it_keys        = it_keys
      IMPORTING
        et_seq_keys    = DATA(lt_seq_keys)
        et_nonseq_keys = DATA(lt_nonseq_keys)
    ).

    APPEND LINES OF lt_seq_keys TO lt_keys.
    APPEND LINES OF lt_nonseq_keys TO lt_keys.

    reopen_costbase(
      it_keys  = lt_keys
      iv_recalrefpoper = recalrefpoper
*      it_poper =
    ).


  ENDMETHOD.


  METHOD determine_trueup.

    DATA trueupamount     TYPE /esrcc/amount.
    DATA lt_trueup        TYPE TABLE OF /esrcc/trueup.
    DATA ls_trueup        TYPE /esrcc/trueup.
    DATA ls_cbstw         TYPE /esrcc/cb_stw.
    DATA ls_srvshare      TYPE /esrcc/srv_share.
    DATA ls_receiver      TYPE /esrcc/rec_chg.
    DATA lt_cbstw         TYPE TABLE OF /esrcc/cb_stw.
    DATA lt_srvshare      TYPE TABLE OF /esrcc/srv_share.
    DATA lt_receiver      TYPE TABLE OF /esrcc/rec_chg.

*   Get the recalculated chargeouts
    SELECT trueup~* FROM /esrcc/i_trup_analysis AS trueup
       INNER JOIN @it_keys AS keys
         ON  trueup~ryear          = keys~ryear
        AND  trueup~Legalentity    = keys~Legalentity
        AND  trueup~ccode          = keys~ccode
        AND  trueup~Costobject     = keys~Costobject
        AND  trueup~Costcenter     = keys~costcenter
        AND  trueup~Sysid          = keys~sysid
       WHERE RefPoper              = @iv_recalrefpoper
        AND  ProcessType           = @/esrcc/if_calculate_chargeout=>recalprocesstype
        AND  Currencytype          = 'L'   "sender local currency
        INTO TABLE @DATA(lt_recalculated).

*   Get the standard chargeouts
    SELECT trueup~* FROM /esrcc/i_trup_analysis AS trueup
       INNER JOIN @it_keys AS keys
         ON  trueup~ryear          = keys~ryear
        AND  trueup~Legalentity    = keys~Legalentity
        AND  trueup~ccode          = keys~ccode
        AND  trueup~Costobject     = keys~Costobject
        AND  trueup~Costcenter     = keys~costcenter
        AND  trueup~Sysid          = keys~sysid
       WHERE trueup~poper          <= @iv_recalrefpoper
        AND  ProcessType           = @/esrcc/if_calculate_chargeout=>standardprocesstype
        AND  Currencytype          = 'L'   "sender local currency
        INTO TABLE @DATA(lt_standard).

*   Get the true up amounts
    SELECT trueup~* FROM /esrcc/trueup AS trueup
       INNER JOIN @it_keys AS keys
         ON  trueup~ryear          = keys~ryear
        AND  trueup~Legalentity    = keys~Legalentity
        AND  trueup~ccode          = keys~ccode
        AND  trueup~Costobject     = keys~Costobject
        AND  trueup~Costcenter     = keys~costcenter
        AND  trueup~Sysid          = keys~sysid
       WHERE recalrefpoper         < @iv_recalrefpoper
        INTO TABLE @DATA(lt_trueups).

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

    SELECT SINGLE group_currency FROM /esrcc/group INTO @DATA(groupcurrency).

    LOOP AT lt_recalculated ASSIGNING FIELD-SYMBOL(<recalculated>).
      READ TABLE lt_standard ASSIGNING FIELD-SYMBOL(<standard>)
                               WITH KEY ryear          = <recalculated>-ryear
                                        poper          = <recalculated>-poper
                                        sysid          = <recalculated>-sysid
                                        Legalentity    = <recalculated>-Legalentity
                                        ccode          = <recalculated>-ccode
                                        costobject     = <recalculated>-costobject
                                        costcenter     = <recalculated>-Costcenter
                                        ServiceProduct = <recalculated>-ServiceProduct
                                        ReceiverSysId = <recalculated>-ReceiverSysId
                                        ReceiverCompanyCode = <recalculated>-ReceiverCompanyCode
                                        Receivingentity = <recalculated>-Receivingentity
                                        ReceiverCostObject = <recalculated>-ReceiverCostObject
                                        ReceiverCostCenter = <recalculated>-ReceiverCostCenter.
      IF sy-subrc = 0.
        CLEAR trueupamount.
        LOOP AT lt_trueups INTO DATA(trueup)
                             WHERE ryear               = <recalculated>-ryear
                               AND poper               = <recalculated>-poper
                               AND sysid               = <recalculated>-sysid
                               AND Legalentity         = <recalculated>-Legalentity
                               AND ccode               = <recalculated>-ccode
                               AND costobject          = <recalculated>-costobject
                               AND costcenter          = <recalculated>-Costcenter
                               AND ServiceProduct      = <recalculated>-ServiceProduct
                               AND ReceiverSysId       = <recalculated>-ReceiverSysId
                               AND ReceiverCompanyCode = <recalculated>-ReceiverCompanyCode
                               AND Receivingentity     = <recalculated>-Receivingentity
                               AND ReceiverCostObject  = <recalculated>-ReceiverCostObject
                               AND ReceiverCostCenter  = <recalculated>-ReceiverCostCenter.

          trueupamount = trueup-amount_l + trueupamount.
        ENDLOOP.

        CLEAR ls_trueup.
        MOVE-CORRESPONDING <recalculated> TO ls_trueup.
        ls_trueup-recalrefpoper = <recalculated>-RefPoper.
        ls_trueup-localcurr = <recalculated>-Currency.
        ls_trueup-exchdate  = <recalculated>-Exchdate.
        ls_trueup-invoicestatus = '01'.
*        ls_trueup-invoicingcurrency = <recalculated>-InvoicingCurrency.
*        ls_trueup-erpsalesorder = <recalculated>-ErpSalesOrder.
*        ls_trueup-contractid    = <recalculated>-contractid.
        IF iv_workflow = abap_true.
          ls_trueup-status = /esrcc/if_calculate_chargeout=>inprocess.
        ELSE.
          ls_trueup-status = /esrcc/if_calculate_chargeout=>approved.
        ENDIF.

        ls_trueup-groupcurr = groupcurrency.
        ls_trueup-amount_l = <recalculated>-TotalChargeoutAmount - ( <standard>-TotalChargeoutAmount + trueupamount ).
        /esrcc/cl_utility_core=>currency_conversion(
          EXPORTING
            amount          = ls_trueup-amount_l
            source_curr     = ls_trueup-localcurr
            target_curr     = ls_trueup-groupcurr
            validon         = <recalculated>-Exchdate
          IMPORTING
            convertedamount = ls_trueup-amount_g
        ).

* Assign the 16 digit unique identifier
        IF lo_uuid IS BOUND.
          TRY.
              ls_trueup-uuid = lo_uuid->create_uuid_x16( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
        ENDIF.
        ls_trueup-cc_uuid = <standard>-RootUUID.
        ls_trueup-srv_uuid = <standard>-ParentUUID.

* Admin data
        ls_trueup-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_trueup-created_at
        ).
        ls_trueup-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_trueup-last_changed_at
        ).
        IF ls_trueup-amount_l <> 0.
          APPEND ls_trueup TO lt_trueup.
        ENDIF.

        DELETE lt_standard WHERE ryear       = <recalculated>-ryear
                                 AND poper       = <recalculated>-poper
                                 AND sysid       = <recalculated>-sysid
                                 AND Legalentity = <recalculated>-Legalentity
                                 AND ccode       = <recalculated>-ccode
                                 AND costobject  = <recalculated>-costobject
                                 AND costcenter  = <recalculated>-Costcenter
                                 AND ServiceProduct = <recalculated>-ServiceProduct
                                 AND ReceiverSysId = <recalculated>-ReceiverSysId
                                 AND ReceiverCompanyCode = <recalculated>-ReceiverCompanyCode
                                 AND Receivingentity = <recalculated>-Receivingentity
                                 AND ReceiverCostObject = <recalculated>-ReceiverCostObject
                                 AND ReceiverCostCenter = <recalculated>-ReceiverCostCenter.
      ELSE.

* if there is no standard chargeout for the receiever than create a dummy standard chargeout
        CLEAR: ls_cbstw, ls_srvshare, ls_receiver.

        READ TABLE lt_cbstw INTO ls_cbstw
                            WITH KEY ryear          = <recalculated>-ryear
                                     poper          = <recalculated>-poper
                                     sysid          = <recalculated>-sysid
                                     Legalentity    = <recalculated>-Legalentity
                                     ccode          = <recalculated>-ccode
                                     costobject     = <recalculated>-costobject
                                     costcenter     = <recalculated>-Costcenter.
        IF sy-subrc <> 0.

          ls_cbstw-fplv        = <recalculated>-fplv.
          ls_cbstw-ryear       = <recalculated>-ryear.
          ls_cbstw-poper       = <recalculated>-poper.
          ls_cbstw-recalrefpoper = iv_recalrefpoper.
          ls_cbstw-sysid       = <recalculated>-sysid.
          ls_cbstw-Legalentity = <recalculated>-Legalentity.
          ls_cbstw-ccode       = <recalculated>-ccode.
          ls_cbstw-costobject  = <recalculated>-costobject.
          ls_cbstw-costcenter  = <recalculated>-Costcenter.
          ls_cbstw-processtype = /esrcc/if_calculate_chargeout=>standardprocesstype.
          ls_cbstw-businessdivision = <recalculated>-Businessdivision.
          ls_cbstw-functionalarea   = <recalculated>-functionalarea.
          ls_cbstw-profitcenter     = <recalculated>-profitcenter.
          ls_cbstw-localcurr        = <recalculated>-Currency.
          ls_cbstw-groupcurr        = groupcurrency.
          ls_cbstw-validon          = <recalculated>-Exchdate.
          IF iv_workflow = abap_true.
            ls_cbstw-status = /esrcc/if_calculate_chargeout=>inprocess.
          ELSE.
            ls_cbstw-status = /esrcc/if_calculate_chargeout=>approved.
          ENDIF.

* Assign the 16 digit unique identifier
          IF lo_uuid IS BOUND.
            TRY.
                ls_cbstw-cc_uuid = lo_uuid->create_uuid_x16( ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.
          ENDIF.
        ENDIF.
* Admin data
        ls_cbstw-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_cbstw-created_at
        ).
        ls_cbstw-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_cbstw-last_changed_at
        ).


        READ TABLE lt_srvshare INTO ls_srvshare
                           WITH KEY cc_uuid        = ls_cbstw-cc_uuid
                                    serviceproduct = <recalculated>-ServiceProduct.
        IF sy-subrc <> 0.

          ls_srvshare-ServiceProduct      = <recalculated>-ServiceProduct.
          ls_srvshare-servicetype         = <recalculated>-servicetype.
          ls_srvshare-transactiongroup    = <recalculated>-transactiongroup.
          ls_srvshare-chargeout           = <recalculated>-Chargeout.
          ls_srvshare-validon             = <recalculated>-Exchdate.
          IF iv_workflow = abap_true.
            ls_srvshare-status = /esrcc/if_calculate_chargeout=>inprocess.
          ELSE.
            ls_srvshare-status = /esrcc/if_calculate_chargeout=>approved.
          ENDIF.
*        ls_srvshare-oecd                = <recalculated>-oecd.
          ls_srvshare-cc_uuid             = ls_cbstw-cc_uuid.
* Assign the 16 digit unique identifier
          IF lo_uuid IS BOUND.
            TRY.
                ls_srvshare-srv_uuid = lo_uuid->create_uuid_x16( ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.
          ENDIF.
        ENDIF.

* Admin data
        ls_srvshare-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_srvshare-created_at
        ).
        ls_srvshare-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_srvshare-last_changed_at
        ).

        READ TABLE lt_receiver INTO ls_receiver
                           WITH KEY cc_uuid             = ls_srvshare-cc_uuid
                                    srv_uuid            = ls_srvshare-srv_uuid
                                    ReceiverSysId       = <recalculated>-ReceiverSysId
                                    ReceiverCompanyCode = <recalculated>-ReceiverCompanyCode
                                    Receivingentity     = <recalculated>-Receivingentity
                                    ReceiverCostObject  = <recalculated>-ReceiverCostObject
                                    ReceiverCostCenter  = <recalculated>-ReceiverCostCenter.
        IF sy-subrc <> 0.

          ls_receiver-ReceiverSysId       = <recalculated>-ReceiverSysId.
          ls_receiver-ReceiverCompanyCode = <recalculated>-ReceiverCompanyCode.
          ls_receiver-Receivingentity     = <recalculated>-Receivingentity.
          ls_receiver-ReceiverCostObject  = <recalculated>-ReceiverCostObject.
          ls_receiver-ReceiverCostCenter  = <recalculated>-ReceiverCostCenter.
          ls_receiver-invoicingcurrency   = <recalculated>-invoicingcurrency.
          ls_receiver-exchdate            = <recalculated>-Exchdate.
          ls_receiver-invoicestatus       = '01'.
          ls_receiver-cc_uuid             = ls_srvshare-cc_uuid.
          ls_receiver-srv_uuid            = ls_srvshare-srv_uuid.
          IF iv_workflow = abap_true.
            ls_receiver-status = /esrcc/if_calculate_chargeout=>inprocess.
          ELSE.
            ls_receiver-status = /esrcc/if_calculate_chargeout=>approved.
          ENDIF.
* Assign the 16 digit unique identifier
          IF lo_uuid IS BOUND.
            TRY.
                ls_receiver-rec_uuid = lo_uuid->create_uuid_x16( ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.
          ENDIF.
        ENDIF.

* Admin data
        ls_receiver-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_receiver-created_at
        ).
        ls_receiver-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_receiver-last_changed_at
        ).

        APPEND ls_cbstw TO lt_cbstw.
        APPEND ls_srvshare TO lt_srvshare.
        APPEND ls_receiver TO lt_receiver.

        CLEAR trueupamount.
        LOOP AT lt_trueups INTO trueup
                             WHERE ryear               = <recalculated>-ryear
                               AND poper               = <recalculated>-poper
                               AND sysid               = <recalculated>-sysid
                               AND Legalentity         = <recalculated>-Legalentity
                               AND ccode               = <recalculated>-ccode
                               AND costobject          = <recalculated>-costobject
                               AND costcenter          = <recalculated>-Costcenter
                               AND ServiceProduct      = <recalculated>-ServiceProduct
                               AND ReceiverSysId       = <recalculated>-ReceiverSysId
                               AND ReceiverCompanyCode = <recalculated>-ReceiverCompanyCode
                               AND Receivingentity     = <recalculated>-Receivingentity
                               AND ReceiverCostObject  = <recalculated>-ReceiverCostObject
                               AND ReceiverCostCenter  = <recalculated>-ReceiverCostCenter.

          trueupamount = trueup-amount_l + trueupamount.
        ENDLOOP.

        CLEAR ls_trueup.
        MOVE-CORRESPONDING <recalculated> TO ls_trueup.
        ls_trueup-recalrefpoper = <recalculated>-RefPoper.
        ls_trueup-localcurr = <recalculated>-Currency.
        ls_trueup-exchdate  = <recalculated>-Exchdate.
        ls_trueup-invoicestatus = '01'.
*        ls_trueup-invoicingcurrency = <recalculated>-InvoicingCurrency.
*        ls_trueup-erpsalesorder = <recalculated>-ErpSalesOrder.
*        ls_trueup-contractid    = <recalculated>-contractid.
        IF iv_workflow = abap_true.
          ls_trueup-status = /esrcc/if_calculate_chargeout=>inprocess.
        ELSE.
          ls_trueup-status = /esrcc/if_calculate_chargeout=>approved.
        ENDIF.

        ls_trueup-groupcurr = groupcurrency.
        ls_trueup-amount_l = <recalculated>-TotalChargeoutAmount - trueupamount .
        /esrcc/cl_utility_core=>currency_conversion(
          EXPORTING
            amount          = ls_trueup-amount_l
            source_curr     = ls_trueup-localcurr
            target_curr     = ls_trueup-groupcurr
            validon         = <recalculated>-Exchdate
          IMPORTING
            convertedamount = ls_trueup-amount_g
        ).

* Assign the 16 digit unique identifier
        IF lo_uuid IS BOUND.
          TRY.
              ls_trueup-uuid = lo_uuid->create_uuid_x16( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
        ENDIF.
        ls_trueup-cc_uuid = ls_receiver-cc_uuid.
        ls_trueup-srv_uuid = ls_receiver-srv_uuid.

* Admin data
        ls_trueup-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_trueup-created_at
        ).
        ls_trueup-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_trueup-last_changed_at
        ).
        IF ls_trueup-amount_l <> 0.
          APPEND ls_trueup TO lt_trueup.
        ENDIF.


      ENDIF.

    ENDLOOP.

*  For the scenario where receivers not found in recalculation
    LOOP AT lt_standard ASSIGNING <standard>.

      CLEAR trueupamount.
      LOOP AT lt_trueups INTO trueup
                           WHERE ryear               = <standard>-ryear
                             AND poper               = <standard>-poper
                             AND sysid               = <standard>-sysid
                             AND Legalentity         = <standard>-Legalentity
                             AND ccode               = <standard>-ccode
                             AND costobject          = <standard>-costobject
                             AND costcenter          = <standard>-Costcenter
                             AND ServiceProduct      = <standard>-ServiceProduct
                             AND ReceiverSysId       = <standard>-ReceiverSysId
                             AND ReceiverCompanyCode = <standard>-ReceiverCompanyCode
                             AND Receivingentity     = <standard>-Receivingentity
                             AND ReceiverCostObject  = <standard>-ReceiverCostObject
                             AND ReceiverCostCenter  = <standard>-ReceiverCostCenter.

        trueupamount = trueup-amount_l + trueupamount.
      ENDLOOP.

      CLEAR ls_trueup.
      MOVE-CORRESPONDING <standard> TO ls_trueup.
      ls_trueup-recalrefpoper = iv_recalrefpoper.
      ls_trueup-localcurr = <standard>-Currency.
      ls_trueup-exchdate  = <standard>-Exchdate.
      ls_trueup-invoicestatus = '01'.
*      ls_trueup-invoicingcurrency = <standard>-InvoicingCurrency.
*      ls_trueup-erpsalesorder = <standard>-ErpSalesOrder.
*      ls_trueup-contractid    = <standard>-contractid.
      IF iv_workflow = abap_true.
        ls_trueup-status = /esrcc/if_calculate_chargeout=>inprocess.
      ELSE.
        ls_trueup-status = /esrcc/if_calculate_chargeout=>approved.
      ENDIF.

      ls_trueup-groupcurr = groupcurrency.
      ls_trueup-amount_l = -1 * ( <standard>-TotalChargeoutAmount + trueupamount ).
      /esrcc/cl_utility_core=>currency_conversion(
        EXPORTING
          amount          = ls_trueup-amount_l
          source_curr     = ls_trueup-localcurr
          target_curr     = ls_trueup-groupcurr
          validon         = <standard>-Exchdate
        IMPORTING
          convertedamount = ls_trueup-amount_g
      ).

* Assign the 16 digit unique identifier
      IF lo_uuid IS BOUND.
        TRY.
            ls_trueup-uuid = lo_uuid->create_uuid_x16( ).
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
      ENDIF.
      ls_trueup-cc_uuid = <standard>-RootUUID.
      ls_trueup-srv_uuid = <standard>-ParentUUID.

* Admin data
      ls_trueup-created_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_trueup-created_at
      ).
      ls_trueup-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_trueup-last_changed_at
      ).
      IF ls_trueup-amount_l <> 0.
        APPEND ls_trueup TO lt_trueup.
      ENDIF.

    ENDLOOP.


    MODIFY /esrcc/cb_stw    FROM TABLE @lt_cbstw.
    MODIFY /esrcc/srv_share FROM TABLE @lt_srvshare.
    MODIFY /esrcc/rec_chg   FROM TABLE @lt_receiver.
    MODIFY /esrcc/trueup    FROM TABLE @lt_trueup.

  ENDMETHOD.


  METHOD delete_trueups.

*   Get the true ups
    SELECT trueup~* FROM /esrcc/trueup AS trueup
       INNER JOIN @it_keys AS keys
         ON  trueup~ryear          = keys~ryear
        AND  trueup~Legalentity    = keys~Legalentity
        AND  trueup~ccode          = keys~ccode
        AND  trueup~Costobject     = keys~Costobject
        AND  trueup~Costcenter     = keys~costcenter
        AND  trueup~Sysid          = keys~sysid
       WHERE recalrefpoper         = @iv_recalrefpoper
        INTO TABLE @DATA(lt_trueups).

    DELETE /esrcc/trueup FROM TABLE @lt_trueups.

  ENDMETHOD.


  METHOD set_prc_errorflag.

    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.

    SELECT procctrl~*  FROM /esrcc/procctrl AS procctrl
       INNER JOIN @keys AS keys
       ON procctrl~ryear = keys~ryear
       AND procctrl~poper = keys~poper
       AND procctrl~sysid = keys~sysid
       AND procctrl~ccode = keys~ccode
       AND procctrl~legalentity = keys~legalentity
       AND procctrl~costobject = keys~costobject
       AND procctrl~costcenter = keys~costcenter
       AND procctrl~process = @/esrcc/if_calculate_chargeout=>trueuprecal
       INTO CORRESPONDING FIELDS OF TABLE @lt_procctrl.

*update process control
    LOOP AT lt_procctrl ASSIGNING FIELD-SYMBOL(<procctrl>).

      <procctrl>-errorflag = abap_true.     "Cost Base Approved

*Admin data
      <procctrl>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <procctrl>-last_changed_at
      ).

    ENDLOOP.

    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.


  ENDMETHOD.


  METHOD perform_trueup_nonseq.

    DATA lt_cc_cost      TYPE TABLE OF /esrcc/cb_stw.
    DATA procctrl        TYPE /esrcc/tt_keys.
    DATA lt_procctrl     TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl     TYPE  /esrcc/procctrl.
    DATA lo_badi         TYPE REF TO /esrcc/badi_trueuprecal.
    DATA activeccode     TYPE /esrcc/tt_le_ccode.
    DATA lt_succ_keys    TYPE /esrcc/tt_keys.
    DATA ls_key          TYPE /esrcc/procctrl.
    DATA prockeys        TYPE /esrcc/procctrl.

    SELECT SINGLE group_currency FROM /esrcc/group INTO @DATA(groupcurrency).

*check if workflow is on
    IF iv_workflow = abap_true.
      /esrcc/cl_wf_utility=>is_wf_on(
        EXPORTING
          iv_apptype   = /esrcc/if_calculate_chargeout=>trueuprecal
        IMPORTING
          ev_wf_active = DATA(wf_active)
      ).

    ENDIF.

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = DATA(last_changed_at)
      ).

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).


*Check if company code and legal entity is still active for charge-out in configuration
    SELECT DISTINCT cc~sysid,
                    cc~ccode,
                    cc~legalentity
        FROM /esrcc/le_ccode AS cc
        INNER JOIN @it_keys AS keys
         ON cc~sysid       = keys~Sysid
        AND cc~ccode       = keys~Ccode
        AND cc~legalentity = keys~legalentity
        AND cc~active = @abap_false
        ORDER BY cc~sysid,
                 cc~ccode,
                 cc~legalentity
        INTO CORRESPONDING FIELDS OF TABLE @activeccode.

********************************************************************
*   Read cost base line items
********************************************************************
    SELECT coststw~*
           FROM /esrcc/i_cb_stewardship_trueup AS coststw
                 INNER JOIN @it_keys_monthly AS keys
                    ON coststw~fplv        = keys~fplv
                   AND coststw~ryear       = keys~ryear
                   AND coststw~poper       = keys~poper
                   AND coststw~sysid       = keys~sysid
                   AND coststw~legalentity = keys~legalentity
                   AND coststw~ccode       = keys~ccode
                   AND coststw~costobject  = keys~costobject
                   AND coststw~costcenter  = keys~costcenter
                   ORDER BY
                   coststw~fplv,
                   coststw~ryear,
                   coststw~poper,
                   coststw~sysid,
                   coststw~legalentity,
                   coststw~ccode,
                   coststw~CostObject,
                   coststw~costcenter
                   INTO CORRESPONDING FIELDS OF TABLE @lt_cc_cost.

********************************************************************
*   Read cost base line items
********************************************************************
    read_lineitems(
      EXPORTING
        it_keys      = it_keys_monthly
      IMPORTING
        et_lineitems = DATA(lineitems)
    ).

********************************************************************
*   Read service product information
********************************************************************
    read_serviceproduct_data(
      EXPORTING
        it_keys     = it_keys_monthly
      IMPORTING
        et_srvshare = DATA(lt_srvshare)
    ).

********************************************************************
*   Read and derive charge-out allocation data
********************************************************************
    read_receiver_data(
      EXPORTING
        it_srvshare       = lt_srvshare
      IMPORTING
        et_reccost        = DATA(lt_rec_cost)
        et_indalloc       = DATA(indalloc)
        et_indallocvalues = DATA(indallocvalues)
        et_receiverchargeout = DATA(receiverchargeout)
    ).

********************************************************************
*   Read and derive charge-out allocation data
********************************************************************
    read_virtual_posting_data(
      EXPORTING
        it_rec_cost       = lt_rec_cost
        it_keys           = it_keys_monthly
        iv_recalrefpoper  = iv_recalrefpoper
      IMPORTING
        et_grpcostelement = DATA(lt_grpcostelement)
        et_le_costelement = DATA(lt_lecostelement)
        et_co_costelement = DATA(lt_co_costelement)
        et_cc_costelement = DATA(lt_cc_costelement)
        et_stdchargeout   = DATA(lt_stdchargeout)
        et_recalchargeout = DATA(lt_recalchargeout)
    ).

    SELECT * FROM /esrcc/i_costelement_f4
    WHERE CostElementType IS NOT INITIAL
    INTO TABLE @DATA(virtualcostelements).

********************************************************************
*  Read the process control data to get the existing log guids
********************************************************************
    read_processcontrol_data(
      EXPORTING
        it_keys     = it_keys_monthly
        iv_recalrefpoper = iv_recalrefpoper
      IMPORTING
        et_procctrl = procctrl
        et_std_procctrl = DATA(stdprocctrl)
    ).

*Check if errors needs to be reported
    LOOP AT it_keys_monthly ASSIGNING FIELD-SYMBOL(<key>).

********************************************************************
*  Perform Checks
********************************************************************
      perform_validations(
        EXPORTING
          key               = <key>
          it_lineitems      = lineitems
          it_cc_cost        = lt_cc_cost
          it_srvshare       = lt_srvshare
          it_rec_cost       = lt_rec_cost
          activeccode       = activeccode
          receiverchargeout = receiverchargeout
          it_stdprocctrl    = stdprocctrl
        IMPORTING
          logitems          = DATA(logitems)
          ev_nolineitems    = DATA(nolineitems)
          ev_failed         = DATA(failed)
      ).

********************************************************************
*  Add Error Messages
********************************************************************
      IF failed = abap_true OR nolineitems = abap_true.

        prockeys = CORRESPONDING #( <key> ).
        prockeys-poper = iv_recalrefpoper.

* create message logs
        create_loginstance(
          EXPORTING
            key         = prockeys
            procctrl    = procctrl
            process     = /esrcc/if_calculate_chargeout=>trueuprecal
          RECEIVING
            loginstance = DATA(loginstance)
        ).

        loginstance->add_messages( log_messages = logitems ).
        loginstance->save_messages( ).
        CLEAR logitems.
*update process control
        CLEAR ls_procctrl.
        ls_procctrl = CORRESPONDING #( prockeys ).
        ls_procctrl-process = /esrcc/if_calculate_chargeout=>trueuprecal.
        IF nolineitems = abap_true.
          ls_procctrl-status  = /esrcc/if_calculate_chargeout=>reclineitemsnot_available.
        ELSE.
          ls_procctrl-status  = /esrcc/if_calculate_chargeout=>recalculation_failed.
        ENDIF.
        ls_procctrl-log_header_uuid = loginstance->get_log_header_id( ).
*Admin data
        ls_procctrl-created_by = sy-uname.

        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_procctrl-created_at
        ).
        ls_procctrl-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_procctrl-last_changed_at
        ).
        APPEND ls_procctrl TO lt_procctrl.

        DELETE lt_cc_cost WHERE sysid       = <key>-sysid
                            AND ccode       = <key>-ccode
                            AND legalentity = <key>-legalentity
                            AND costobject  = <key>-costobject
                            AND costcenter  = <key>-costcenter
                            AND fplv        = <key>-fplv
                            AND ryear       = <key>-ryear
                            AND poper       = <key>-poper.


      ELSE.
        IF <key>-poper = iv_recalrefpoper.
          MOVE-CORRESPONDING <key> TO ls_key.
          APPEND ls_key TO lt_succ_keys.
        ENDIF.
      ENDIF.

      CLEAR: loginstance, failed.

    ENDLOOP.

********************************************************************
*  *Delete old data
********************************************************************
    delete_costbase(
      it_keys          = lt_succ_keys
      iv_recalrefpoper = iv_recalrefpoper
    ).

********************************************************************
*  *Create new data
********************************************************************
    addnew_chargeout_data(
      EXPORTING
        it_cc_cost        = lt_cc_cost
        it_srvshare       = lt_srvshare
        it_rec_cost       = lt_rec_cost
        it_indalloc       = indalloc
        it_indallocvalues = indallocvalues
        it_grpcostelement = lt_grpcostelement
        it_le_costelement = lt_lecostelement
        it_co_costelement = lt_co_costelement
        it_cc_costelement = lt_cc_costelement
        it_stdchargeout   = lt_stdchargeout
        it_recalchargeout = lt_recalchargeout
        it_virtualcostelem = virtualcostelements
        groupcurrency     = groupcurrency
        wf_active         = wf_active
        iv_recalrefpoper  = iv_recalrefpoper
      IMPORTING
        et_cbli           = DATA(lt_cbli)
        et_cc_cost        = DATA(lt_cbstw)
        et_srv_cost       = DATA(lt_srv_cost)
        et_rec_chg        = DATA(lt_rec_chg)
        et_alocshares     = DATA(lt_alocshares)
        et_alocvalues     = DATA(lt_alocvalues)
        et_wf_leadingobject = DATA(lt_wf_leadobj)
    ).

    MODIFY /esrcc/cb_stw    FROM TABLE @lt_cbstw.
    MODIFY /esrcc/srv_share FROM TABLE @lt_srv_cost.
    MODIFY /esrcc/rec_chg   FROM TABLE @lt_rec_chg.
    MODIFY /esrcc/alocshare FROM TABLE @lt_alocshares.
    MODIFY /esrcc/alcvalues FROM TABLE @lt_alocvalues.
    MODIFY /esrcc/cb_li     FROM TABLE @lt_cbli.
    MODIFY /esrcc/procctrl  FROM TABLE @lt_procctrl.

***********************************************************
**Handling of delta for direct chargeout Scenario
***********************************************************
    determine_delta_chargeout(
      it_keys  = it_keys_monthly
      iv_workflow = iv_workflow
    ).

**********************************************************
*           Determine & Save Trueup
**********************************************************
    determine_trueup(
      it_keys          = lt_succ_keys
      iv_recalrefpoper = iv_recalrefpoper
      iv_workflow      = wf_active
    ).

**********************************************************
*Check if workflow is to be triggered
**********************************************************
    IF iv_workflow EQ abap_true AND lt_wf_leadobj IS NOT INITIAL.
      trigger_workflow(
        it_leading_object = lt_wf_leadobj
        iv_application    = /esrcc/if_calculate_chargeout=>trueuprecal
      ).
    ENDIF.

**********************************************************
*Add process control status for monitoring in execution cockpit
**********************************************************
    set_process_control(
      EXPORTING
        keys    = lt_succ_keys
        process = /esrcc/if_calculate_chargeout=>trueuprecal
        status  = COND #( WHEN wf_active = abap_true THEN /esrcc/if_calculate_chargeout=>recalculation_inprocess
                                                     ELSE /esrcc/if_calculate_chargeout=>recalculation_approved )
        update  = abap_false
*      IMPORTING
*        failed  =
    ).

**********************************************************
*Add process logs for traceability
**********************************************************
    create_processlogs(
      iv_action = /esrcc/if_calculate_chargeout=>calculate_recalchargeout
      it_keys   = lt_procctrl
    ).

    CLEAR: lt_cc_cost,
          lt_procctrl.


  ENDMETHOD.


  METHOD perform_trueup_seq.

    DATA ls_cc_cost    TYPE /esrcc/cb_stw.
    DATA lt_cc_cost    TYPE TABLE OF /esrcc/cb_stw.
    DATA lt_cbstw      TYPE TABLE OF /esrcc/cb_stw.
    DATA lt_srv_cost   TYPE TABLE OF /esrcc/srv_share.
    DATA lt_rec_chg    TYPE TABLE OF /esrcc/rec_chg.
    DATA lt_alocshares TYPE TABLE OF /esrcc/alocshare.
    DATA lt_alocvalues TYPE TABLE OF /esrcc/alcvalues.
    DATA lt_wf_leadobj TYPE /esrcc/tt_wf_leadingobject.
    DATA procctrl      TYPE /esrcc/tt_keys.
    DATA lt_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA lt_err_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl   TYPE /esrcc/procctrl.
    DATA lv_validon    TYPE /esrcc/validfrom.
    DATA ls_key        TYPE /esrcc/procctrl.
    DATA lt_succ_keys  TYPE /esrcc/tt_keys.
    DATA activeccode   TYPE /esrcc/tt_le_ccode.
    DATA lt_root_key   TYPE /esrcc/tt_keys.
    DATA prockeys      TYPE /esrcc/procctrl.
    DATA lt_keys       TYPE tt_keys.


*check if workflow is on
    IF iv_workflow = abap_true.
      /esrcc/cl_wf_utility=>is_wf_on(
        EXPORTING
          iv_apptype   = /esrcc/if_calculate_chargeout=>trueuprecal
        IMPORTING
          ev_wf_active = DATA(wf_active)
      ).

    ENDIF.

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = DATA(last_changed_at)
      ).

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

*  get group currency
    SELECT SINGLE group_currency FROM /esrcc/group INTO @DATA(groupcurrency).


*Check if company code and legal entity is still active for charge-out in configuration
    SELECT DISTINCT cc~sysid,
                    cc~ccode,
                    cc~legalentity
        FROM /esrcc/le_ccode AS cc
        INNER JOIN @it_keys_monthly AS keys
         ON cc~sysid       = keys~Sysid
        AND cc~ccode       = keys~Ccode
        AND cc~legalentity = keys~legalentity
        AND cc~active = @abap_false
        ORDER BY cc~sysid,
                 cc~ccode,
                 cc~legalentity
        INTO CORRESPONDING FIELDS OF TABLE @activeccode.

********************************************************************
*   Read cost base line items
********************************************************************
    read_lineitems(
      EXPORTING
        it_keys      = it_keys_monthly
      IMPORTING
        et_lineitems = DATA(lineitems)
    ).

********************************************************************
*   Read service product information
********************************************************************
    read_serviceproduct_data(
      EXPORTING
        it_keys     = it_keys_monthly
      IMPORTING
        et_srvshare = DATA(lt_srvshare)
    ).

********************************************************************
*   Read and derive charge-out allocation data
********************************************************************
    read_receiver_data(
      EXPORTING
        it_srvshare       = lt_srvshare
      IMPORTING
        et_reccost        = DATA(lt_rec_cost)
        et_indalloc       = DATA(indalloc)
        et_indallocvalues = DATA(indallocvalues)
        et_receiverchargeout = DATA(receiverchargeout)
    ).

********************************************************************
*   Read and derive charge-out allocation data
********************************************************************
    read_virtual_posting_data(
      EXPORTING
        it_rec_cost       = lt_rec_cost
        it_keys           = it_keys_monthly
        iv_recalrefpoper  = iv_recalrefpoper
      IMPORTING
        et_grpcostelement = DATA(lt_grpcostelement)
        et_le_costelement = DATA(lt_lecostelement)
        et_co_costelement = DATA(lt_co_costelement)
        et_cc_costelement = DATA(lt_cc_costelement)
        et_stdchargeout   = DATA(lt_stdchargeout)
        et_recalchargeout = DATA(lt_recalchargeout)
    ).

    SELECT * FROM /esrcc/i_costelement_f4
    WHERE CostElementType IS NOT INITIAL
    INTO TABLE @DATA(virtualcostelements).

********************************************************************
*  Read the process control data to get the existing log guids
********************************************************************
    read_processcontrol_data(
      EXPORTING
        it_keys     = it_keys_monthly
        iv_recalrefpoper = iv_recalrefpoper
      IMPORTING
        et_procctrl = procctrl
        et_std_procctrl = DATA(stdprocctrl)
    ).


********************************************************************
*  *Delete old data
********************************************************************
    delete_costbase(
      it_keys          = CORRESPONDING #( it_keys_monthly )
      iv_recalrefpoper = iv_recalrefpoper
    ).

*Check if errors needs to be reported
    LOOP AT it_keys_monthly ASSIGNING FIELD-SYMBOL(<keys>).

      CLEAR: lt_cc_cost.
********************************************************************
*   Read cost base line items
********************************************************************
      SELECT SINGLE coststw~*
             FROM /esrcc/i_cb_stewardship_trueup AS coststw
                   WHERE coststw~fplv        = @<keys>-fplv
                     AND coststw~ryear       = @<keys>-ryear
                     AND coststw~poper       = @<keys>-poper
                     AND coststw~sysid       = @<keys>-sysid
                     AND coststw~legalentity = @<keys>-legalentity
                     AND coststw~ccode       = @<keys>-ccode
                     AND coststw~costobject  = @<keys>-costobject
                     AND coststw~costcenter  = @<keys>-costcenter
                     INTO CORRESPONDING FIELDS OF @ls_cc_cost.

      APPEND ls_cc_cost TO lt_cc_cost.

********************************************************************
*  Perform Checks
********************************************************************
      perform_validations(
        EXPORTING
          key               = <keys>
          it_lineitems      = lineitems
          it_cc_cost        = lt_cc_cost
          it_srvshare       = lt_srvshare
          it_rec_cost       = lt_rec_cost
          activeccode       = activeccode
          receiverchargeout = receiverchargeout
          it_stdprocctrl    = stdprocctrl
        IMPORTING
          logitems          = DATA(logitems)
          ev_nolineitems    = DATA(nolineitems)
          ev_failed         = DATA(failed)
      ).

********************************************************************
*  Add Error Messages
********************************************************************
      IF failed = abap_true OR nolineitems = abap_true.

        prockeys = CORRESPONDING #( <keys> ).
        prockeys-poper = iv_recalrefpoper.
* create message logs
        create_loginstance(
          EXPORTING
            key         = prockeys
            procctrl    = procctrl
            process     = /esrcc/if_calculate_chargeout=>trueuprecal
          RECEIVING
            loginstance = DATA(loginstance)
        ).

        loginstance->add_messages( log_messages = logitems ).
        loginstance->save_messages( ).
        CLEAR logitems.
*update process control
        CLEAR ls_procctrl.
        ls_procctrl = CORRESPONDING #( prockeys ).
        ls_procctrl-process = /esrcc/if_calculate_chargeout=>trueuprecal.    "Cost Base
        IF nolineitems = abap_true.
          ls_procctrl-status  = /esrcc/if_calculate_chargeout=>reclineitemsnot_available.
        ELSE.
          ls_procctrl-status  = /esrcc/if_calculate_chargeout=>recalculation_failed.     "Cost Base failed
        ENDIF.
        ls_procctrl-log_header_uuid = loginstance->get_log_header_id( ).
*Admin data
        ls_procctrl-created_by = sy-uname.

        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_procctrl-created_at
        ).
        ls_procctrl-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = ls_procctrl-last_changed_at
        ).
        APPEND ls_procctrl TO lt_procctrl.

        IF nolineitems = abap_false.
          READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<rootkey>)
                             WITH KEY poper    = iv_recalrefpoper
                                      chain_id = <keys>-chain_id
                                      chain_rootnode = abap_true.
          IF sy-subrc = 0.
            APPEND <rootkey> TO lt_err_procctrl.
          ENDIF.
          EXIT.
        ENDIF.

      ELSE.
********************************************************************
*  *Create new data
********************************************************************
        addnew_chargeout_data(
          EXPORTING
            it_cc_cost        = lt_cc_cost
            it_srvshare       = lt_srvshare
            it_rec_cost       = lt_rec_cost
            it_indalloc       = indalloc
            it_indallocvalues = indallocvalues
            it_grpcostelement = lt_grpcostelement
            it_le_costelement = lt_lecostelement
            it_co_costelement = lt_co_costelement
            it_cc_costelement = lt_cc_costelement
            it_stdchargeout   = lt_stdchargeout
            it_recalchargeout = lt_recalchargeout
            it_virtualcostelem = virtualcostelements
            groupcurrency     = groupcurrency
            wf_active         = wf_active
            iv_recalrefpoper  = iv_recalrefpoper
          IMPORTING
            et_cbli           = DATA(lt_cbli)
            et_cc_cost        = DATA(cbstw)
            et_srv_cost       = DATA(srv_cost)
            et_rec_chg        = DATA(rec_chg)
            et_alocshares     = DATA(alocshares)
            et_alocvalues     = DATA(alocvalues)
            et_wf_leadingobject = DATA(wf_leadobj)
        ).

        APPEND LINES OF cbstw      TO lt_cbstw.
        APPEND LINES OF srv_cost   TO lt_srv_cost.
        APPEND LINES OF rec_chg    TO lt_rec_chg.
        APPEND LINES OF alocshares TO lt_alocshares.
        APPEND LINES OF alocvalues TO lt_alocvalues.
        APPEND LINES OF wf_leadobj TO lt_wf_leadobj.
        APPEND <keys> TO lt_keys.

        MODIFY /esrcc/cb_li FROM TABLE @lt_cbli.

        IF <keys>-poper = iv_recalrefpoper.
          MOVE-CORRESPONDING <keys> TO ls_key.
          APPEND ls_key TO lt_succ_keys.
        ENDIF.
      ENDIF.

      CLEAR: loginstance, cbstw, srv_cost, rec_chg, alocshares, alocvalues, lt_cbli, wf_leadobj.

    ENDLOOP.

    MODIFY /esrcc/cb_stw    FROM TABLE @lt_cbstw.
    MODIFY /esrcc/srv_share FROM TABLE @lt_srv_cost.
    MODIFY /esrcc/rec_chg   FROM TABLE @lt_rec_chg.
    MODIFY /esrcc/alocshare FROM TABLE @lt_alocshares.
    MODIFY /esrcc/alcvalues FROM TABLE @lt_alocvalues.
    MODIFY /esrcc/procctrl  FROM TABLE @lt_procctrl.

***********************************************************
**Handling of delta for direct chargeout Scenario
***********************************************************
    determine_delta_chargeout(
    it_keys  = lt_keys
    iv_workflow = iv_workflow
    ).

**********************************************************
*           Determine & Save Trueup
**********************************************************
    determine_trueup(
      it_keys          = lt_succ_keys
      iv_recalrefpoper = iv_recalrefpoper
      iv_workflow      = wf_active
    ).

**********************************************************
*Check if workflow is to be triggered
**********************************************************
    IF iv_workflow EQ abap_true AND lt_wf_leadobj IS NOT INITIAL.
      trigger_workflow(
      it_leading_object = lt_wf_leadobj
      iv_application    = /esrcc/if_calculate_chargeout=>trueuprecal
      ).
    ENDIF.

**********************************************************
*Add process control status for monitoring in execution cockpit
**********************************************************
    set_process_control(
    EXPORTING
    keys    = lt_succ_keys
    process = /esrcc/if_calculate_chargeout=>trueuprecal
    status  = COND #( WHEN wf_active = abap_true THEN /esrcc/if_calculate_chargeout=>recalculation_inprocess
             ELSE /esrcc/if_calculate_chargeout=>recalculation_approved )
    update  = abap_false
*      IMPORTING
*        failed  =
    ).

    IF lt_err_procctrl IS NOT INITIAL.

      set_prc_errorflag(
        EXPORTING
          keys   = lt_err_procctrl
      ).

    ENDIF.
*    IF error_flag = abap_true.
**set error flag for root node to block finalization
**Add the root key with sequencee 1
*      READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<rootkey>) WITH KEY poper = iv_recalrefpoper.
*      IF sy-subrc = 0.
*
*        APPEND <rootkey> TO lt_root_key.
*        set_prc_errorflag(
*          EXPORTING
*            keys   = lt_root_key
**          IMPORTING
**            failed =
*        ).
*      ENDIF.
*    ENDIF.

**********************************************************
*Add process logs for traceability
**********************************************************
    create_processlogs(
    iv_action = /esrcc/if_calculate_chargeout=>calculate_recalchargeout
    it_keys   = lt_procctrl
    ).

    CLEAR: lt_cc_cost,
    lt_procctrl.


  ENDMETHOD.


  METHOD addnew_chargeout_data.

    DATA ls_wf_leadobj     TYPE /esrcc/s_wf_leadingobject.
    DATA lv_validon        TYPE /esrcc/validfrom.
    DATA number            TYPE /esrcc/doc_no.
    DATA itemno            TYPE /esrcc/buzei.
    DATA remainingcostbase TYPE /esrcc/chgamount.
    DATA srvcostshare    TYPE /esrcc/chgamount.
    DATA valueaddshare   TYPE /esrcc/chgamount.
    DATA passthrushare   TYPE /esrcc/chgamount.
    DATA costperunit     TYPE /esrcc/chgamount.
    DATA valueaddperunit TYPE /esrcc/chgamount.
    DATA passthruperunit TYPE /esrcc/chgamount.
    DATA recvalueadd       TYPE /esrcc/chgamount.
    DATA recvalueaddmarkup TYPE /esrcc/chgamount.
    DATA recpassthru       TYPE /esrcc/chgamount.
    DATA recpassthrumarkup TYPE /esrcc/chgamount.
    DATA totalchargeout  TYPE /esrcc/chgamount.
    DATA fieldname  TYPE STRING.
    DATA field_list TYPE STRING.

    CLEAR: et_cc_cost, et_srv_cost, et_alocshares, et_alocvalues, et_rec_chg, et_wf_leadingobject, et_cbli.

    /esrcc/cl_utility_core=>get_utc_date_time_ts(
    IMPORTING
    time_stamp = DATA(last_changed_at)
    ).

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

    LOOP AT it_cc_cost ASSIGNING FIELD-SYMBOL(<ls_cbstw>).

      APPEND INITIAL LINE TO et_cc_Cost ASSIGNING FIELD-SYMBOL(<ls_cc_cost>).
      MOVE-CORRESPONDING <ls_cbstw> TO <ls_cc_cost>.

* Assign the 16 digit unique identifier
      IF lo_uuid IS BOUND.
        TRY.
            <ls_cc_cost>-cc_uuid = lo_uuid->create_uuid_x16( ).
            <ls_cc_cost>-commentid = lo_uuid->create_uuid_x16( ).
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
      ENDIF.

      <ls_cc_cost>-recalrefpoper = iv_recalrefpoper.
      <ls_cc_cost>-processtype = /esrcc/if_calculate_chargeout=>recalprocesstype.
* Admin data
      <ls_cc_cost>-created_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
      time_stamp = <ls_cc_cost>-created_at
      ).
      <ls_cc_cost>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
      IMPORTING
      time_stamp = <ls_cc_cost>-last_changed_at
      ).

      IF wf_active EQ abap_true.
        CLEAR ls_wf_leadobj.
        IF iv_recalrefpoper = <ls_cc_cost>-poper.
          MOVE-CORRESPONDING <ls_cc_cost> TO ls_wf_leadobj.
          ls_wf_leadobj-refpoper = iv_recalrefpoper.
          APPEND ls_wf_leadobj TO et_wf_leadingobject.
        ENDIF.
        <ls_cc_cost>-status = /esrcc/if_calculate_chargeout=>inprocess.
      ELSE.
        <ls_cc_cost>-status = /esrcc/if_calculate_chargeout=>approved.   "Approval
      ENDIF.

      Remainingcostbase = ( ( <ls_cc_cost>-totalcost_g -  <ls_cc_cost>-excludedtotalcost_g ) *
      ( 1 - ( <ls_cc_cost>-stewardship / 100 ) ) ).

*Update service product costing
      READ TABLE it_srvshare TRANSPORTING NO FIELDS
      WITH KEY fplv        = <ls_cc_cost>-fplv
               ryear       = <ls_cc_cost>-ryear
               poper       = <ls_cc_cost>-poper
               Sysid       = <ls_cc_cost>-sysid
               legalentity = <ls_cc_cost>-legalentity
               CompanyCode = <ls_cc_cost>-ccode
               costobject  = <ls_cc_cost>-costobject
               costcenter  = <ls_cc_cost>-costcenter
               BINARY SEARCH.
      IF sy-subrc = 0.
        DATA(srvshare_tabix) = sy-tabix.
        LOOP AT it_srvshare ASSIGNING FIELD-SYMBOL(<ls_srvshare>) FROM srvshare_tabix.
          IF   <ls_srvshare>-fplv        = <ls_cc_cost>-fplv
          AND  <ls_srvshare>-ryear       = <ls_cc_cost>-ryear
          AND  <ls_srvshare>-poper       = <ls_cc_cost>-poper
          AND  <ls_srvshare>-Sysid       = <ls_cc_cost>-sysid
          AND  <ls_srvshare>-legalentity = <ls_cc_cost>-legalentity
          AND  <ls_srvshare>-CompanyCode = <ls_cc_cost>-ccode
          AND  <ls_srvshare>-costobject  = <ls_cc_cost>-costobject
          AND  <ls_srvshare>-costcenter  = <ls_cc_cost>-costcenter.


            APPEND INITIAL LINE TO et_srv_cost ASSIGNING FIELD-SYMBOL(<srv_cost>).
            MOVE-CORRESPONDING <ls_srvshare> TO <srv_cost>.
            IF wf_active EQ abap_true.
              <srv_cost>-status = /esrcc/if_calculate_chargeout=>inprocess.   "In process
            ELSE.
              <srv_cost>-status = /esrcc/if_calculate_chargeout=>approved.   "Approved
            ENDIF.

* Admin data
            <srv_cost>-created_by = sy-uname.
            /esrcc/cl_utility_core=>get_utc_date_time_ts(
            IMPORTING
            time_stamp = <srv_cost>-created_at
            ).
            <srv_cost>-last_changed_by = sy-uname.
            /esrcc/cl_utility_core=>get_utc_date_time_ts(
            IMPORTING
            time_stamp = <srv_cost>-last_changed_at
            ).

* Assign the 16 digit unique identifier
            IF lo_uuid IS BOUND.
              TRY.
                  <srv_cost>-cc_uuid   = <ls_cc_cost>-cc_uuid.
                  <srv_cost>-srv_uuid  = lo_uuid->create_uuid_x16( ).
                  <srv_cost>-commentid = lo_uuid->create_uuid_x16( ).
                CATCH cx_uuid_error.
                  "handle exception
              ENDTRY.
            ENDIF.

            srvcostshare  = ( <srv_cost>-costshare / 100 ) * remainingcostbase.
            valueaddshare = ( ( <srv_cost>-costshare / 100 ) *
                        ( <ls_cc_cost>-origtotalcost_g - ( ( <ls_cc_cost>-Stewardship / 100 )
                         * <ls_cc_cost>-origtotalcost_g ) ) ).
            passthrushare = ( ( <srv_cost>-costshare / 100 ) *
                        ( <ls_cc_cost>-passtotalcost_g - ( ( <ls_cc_cost>-Stewardship / 100 )
                         * <ls_cc_cost>-passtotalcost_g ) ) ).

            IF <srv_cost>-chargeout = 'D'.
              costperunit     = srvcostshare / <srv_cost>-planning.
              valueaddperunit = valueaddshare / <srv_cost>-planning.
              passthruperunit = passthrushare / <srv_cost>-planning.
            ENDIF.

            READ TABLE it_rec_cost TRANSPORTING NO FIELDS
                  WITH KEY
                           Fplv              = <ls_srvshare>-fplv
                           Ryear             = <ls_srvshare>-ryear
                           Poper             = <ls_srvshare>-poper
                           systemid          = <ls_srvshare>-SysId
                           legalentity       = <ls_srvshare>-LegalEntity
                           CompanyCode       = <ls_srvshare>-CompanyCode
                           costobject        = <ls_srvshare>-CostObject
                           costcenter        = <ls_srvshare>-costcenter
                           serviceproduct    = <ls_srvshare>-serviceproduct
                           BINARY SEARCH.
            IF sy-subrc = 0.
              DATA(reccost_tabix) = sy-tabix.
              LOOP AT it_rec_cost ASSIGNING FIELD-SYMBOL(<ls_rec_cost>) FROM reccost_tabix.
                IF      <ls_srvshare>-Fplv              = <ls_rec_cost>-fplv
                    AND <ls_srvshare>-Ryear             = <ls_rec_cost>-ryear
                    AND <ls_srvshare>-Poper             = <ls_rec_cost>-poper
                    AND <ls_srvshare>-sysid             = <ls_rec_cost>-SystemId
                    AND <ls_srvshare>-legalentity       = <ls_rec_cost>-LegalEntity
                    AND <ls_srvshare>-CompanyCode       = <ls_rec_cost>-CompanyCode
                    AND <ls_srvshare>-costobject        = <ls_rec_cost>-CostObject
                    AND <ls_srvshare>-costcenter        = <ls_rec_cost>-costcenter
                    AND <ls_srvshare>-serviceproduct    = <ls_rec_cost>-serviceproduct.

                  APPEND INITIAL LINE TO et_rec_chg ASSIGNING FIELD-SYMBOL(<ls_rec_chg>).
                  MOVE-CORRESPONDING <ls_rec_cost> TO <ls_rec_chg>.

                  IF wf_active EQ abap_true.
                    <ls_rec_chg>-status = /esrcc/if_calculate_chargeout=>inprocess.   "In Process
                  ELSE.
                    <ls_rec_chg>-status = /esrcc/if_calculate_chargeout=>approved.   "Approved
                  ENDIF.
                  <ls_rec_chg>-invoicestatus = '01'.
* Admin data
                  <ls_rec_chg>-created_by = sy-uname.
                  /esrcc/cl_utility_core=>get_utc_date_time_ts(
                    IMPORTING
                      time_stamp = <ls_rec_chg>-created_at
                  ).
                  <ls_rec_chg>-last_changed_by = sy-uname.
                  /esrcc/cl_utility_core=>get_utc_date_time_ts(
                    IMPORTING
                      time_stamp = <ls_rec_chg>-last_changed_at
                  ).

* Assign the 16 digit unique identifier
                  IF lo_uuid IS BOUND.
                    TRY.
                        <ls_rec_chg>-cc_uuid   = <srv_cost>-cc_uuid.
                        <ls_rec_chg>-srv_uuid  = <srv_cost>-srv_uuid.
                        <ls_rec_chg>-rec_uuid  = lo_uuid->create_uuid_x16( ).
                        <ls_rec_chg>-commentid = lo_uuid->create_uuid_x16( ).
                      CATCH cx_uuid_error.
                        "handle exception
                    ENDTRY.
                  ENDIF.

* get exchange rate day
                  determine_last_day(
                    EXPORTING
                      iv_ryear    = <ls_rec_cost>-ryear
                      iv_poper    = <ls_rec_cost>-poper
                    IMPORTING
                      ev_valid_on = <ls_rec_chg>-exchdate
                  ).

                  IF <srv_cost>-chargeout = 'I'.

                    recvalueadd = ( <ls_rec_cost>-reckpishare / 100 ) * valueaddshare.
                    recvalueaddmarkup = recvalueadd * ( <ls_rec_cost>-valueaddmarkup / 100 ).
                    recpassthru = ( <ls_rec_cost>-reckpishare / 100 ) * passthrushare.
                    recpassthrumarkup = recpassthru * ( <ls_rec_cost>-passthrumarkup / 100 ).

                    totalchargeout = ( ( ( <ls_rec_cost>-reckpishare / 100 ) * srvcostshare ) +
                                                   ( ( <ls_rec_cost>-reckpishare / 100 ) * valueaddshare * ( <ls_rec_cost>-valueaddmarkup / 100 ) ) +
                                                   ( ( <ls_rec_cost>-reckpishare / 100 ) * passthrushare * ( <ls_rec_cost>-passthrumarkup / 100 ) ) ).
                  ELSEIF <srv_cost>-chargeout = 'D'.

                    recvalueadd = <ls_rec_cost>-reckpi * valueaddperunit.
                    recvalueaddmarkup = recvalueadd * ( <ls_rec_cost>-valueaddmarkup / 100 ).
                    recpassthru = <ls_rec_cost>-reckpi * passthruperunit.
                    recpassthrumarkup = recpassthru * ( <ls_rec_cost>-passthrumarkup / 100 ).

                    totalchargeout = ( ( <ls_rec_cost>-reckpi * costperunit ) +
                                                   ( <ls_rec_cost>-reckpi * valueaddperunit * ( <ls_rec_cost>-valueaddmarkup / 100 ) ) +
                                                   ( <ls_rec_cost>-reckpi * passthruperunit * ( <ls_rec_cost>-passthrumarkup / 100 ) ) ).

                  ENDIF.

                  READ TABLE it_indalloc TRANSPORTING NO FIELDS
                                    WITH KEY
                                             Fplv              = <ls_rec_cost>-fplv
                                             Ryear             = <ls_rec_cost>-ryear
                                             Poper             = <ls_rec_cost>-poper
                                             systemid          = <ls_rec_cost>-SystemId
                                             legalentity       = <ls_rec_cost>-LegalEntity
                                             CompanyCode       = <ls_rec_cost>-CompanyCode
                                             costobject        = <ls_rec_cost>-CostObject
                                             costcenter        = <ls_rec_cost>-costcenter
                                             serviceproduct    = <ls_rec_cost>-serviceproduct
                                             ReceiverSysId       = <ls_rec_cost>-ReceiverSysId
                                             ReceiverCompanyCode = <ls_rec_cost>-ReceiverCompanyCode
                                             ReceivingEntity     = <ls_rec_cost>-ReceivingEntity
                                             ReceiverCostObject  = <ls_rec_cost>-ReceiverCostObject
                                             ReceiverCostCenter  = <ls_rec_cost>-ReceiverCostCenter
                                             BINARY SEARCH.
                  IF sy-subrc = 0.
                    DATA(indalloc_tabix) = sy-tabix.
                    LOOP AT it_indalloc ASSIGNING FIELD-SYMBOL(<indalloc>) FROM indalloc_tabix.
                      IF  <indalloc>-Fplv              = <ls_rec_cost>-fplv
                      AND <indalloc>-Ryear             = <ls_rec_cost>-ryear
                      AND <indalloc>-Poper             = <ls_rec_cost>-poper
                      AND <indalloc>-systemid          = <ls_rec_cost>-SystemId
                      AND <indalloc>-legalentity       = <ls_rec_cost>-LegalEntity
                      AND <indalloc>-CompanyCode       = <ls_rec_cost>-CompanyCode
                      AND <indalloc>-costobject        = <ls_rec_cost>-CostObject
                      AND <indalloc>-costcenter        = <ls_rec_cost>-costcenter
                      AND <indalloc>-serviceproduct    = <ls_rec_cost>-serviceproduct
                      AND <indalloc>-ReceiverSysId       = <ls_rec_cost>-ReceiverSysId
                      AND <indalloc>-ReceiverCompanyCode = <ls_rec_cost>-ReceiverCompanyCode
                      AND <indalloc>-ReceivingEntity     = <ls_rec_cost>-ReceivingEntity
                      AND <indalloc>-ReceiverCostObject  = <ls_rec_cost>-ReceiverCostObject
                      AND <indalloc>-ReceiverCostCenter  = <ls_rec_cost>-ReceiverCostCenter.

                        APPEND INITIAL LINE TO et_alocshares ASSIGNING FIELD-SYMBOL(<ls_rec_share>).
                        MOVE-CORRESPONDING <indalloc> TO <ls_rec_share>.

                        IF lo_uuid IS BOUND.
                          TRY.
                              <ls_rec_share>-uuid = lo_uuid->create_uuid_x16( ).
                            CATCH cx_uuid_error.
                              "handle exception
                          ENDTRY.
                          <ls_rec_share>-parentuuid = <ls_rec_chg>-rec_uuid.
                        ENDIF.

*          Admin data
                        <ls_rec_share>-created_by = sy-uname.
                        /esrcc/cl_utility_core=>get_utc_date_time_ts(
                          IMPORTING
                            time_stamp = <ls_rec_share>-created_at
                        ).
                        <ls_rec_share>-last_changed_by = sy-uname.
                        /esrcc/cl_utility_core=>get_utc_date_time_ts(
                          IMPORTING
                            time_stamp = <ls_rec_share>-last_changed_at
                        ).

                        READ TABLE it_indallocvalues TRANSPORTING NO FIELDS
                                    WITH KEY
                                             Fplv              = <ls_rec_cost>-fplv
                                             Ryear             = <ls_rec_cost>-ryear
                                             Poper             = <ls_rec_cost>-poper
                                             systemid          = <ls_rec_cost>-SystemId
                                             legalentity       = <ls_rec_cost>-LegalEntity
                                             CompanyCode       = <ls_rec_cost>-CompanyCode
                                             costobject        = <ls_rec_cost>-CostObject
                                             costcenter        = <ls_rec_cost>-costcenter
                                             serviceproduct    = <ls_rec_cost>-serviceproduct
                                             ReceiverSysId       = <ls_rec_cost>-ReceiverSysId
                                             ReceiverCompanyCode = <ls_rec_cost>-ReceiverCompanyCode
                                             ReceivingEntity     = <ls_rec_cost>-ReceivingEntity
                                             ReceiverCostObject  = <ls_rec_cost>-ReceiverCostObject
                                             ReceiverCostCenter  = <ls_rec_cost>-ReceiverCostCenter
                                             KeyVersion          = <indalloc>-KeyVersion
                                             Allockey            = <indalloc>-Allockey
                                             AllocationPeriod    = <indalloc>-AllocationPeriod
                                             RefPeriod           = <indalloc>-RefPeriod
                                             BINARY SEARCH.
                        IF sy-subrc = 0.
                          DATA(indvalues_tabix) = sy-tabix.
                          LOOP AT it_indallocvalues ASSIGNING FIELD-SYMBOL(<indvalues>) FROM indvalues_tabix.
                            IF        <indvalues>-Fplv                = <indalloc>-fplv
                                  AND <indvalues>-Ryear               = <indalloc>-ryear
                                  AND <indvalues>-Poper               = <indalloc>-poper
                                  AND <indvalues>-systemid            = <ls_rec_cost>-SystemId
                                  AND <indvalues>-legalentity         = <ls_rec_cost>-LegalEntity
                                  AND <indvalues>-CompanyCode         = <ls_rec_cost>-CompanyCode
                                  AND <indvalues>-costobject          = <ls_rec_cost>-CostObject
                                  AND <indvalues>-costcenter          = <ls_rec_cost>-costcenter
                                  AND <indvalues>-serviceproduct      = <indalloc>-serviceproduct
                                  AND <indvalues>-ReceiverSysId       = <indalloc>-ReceiverSysId
                                  AND <indvalues>-ReceiverCompanyCode = <indalloc>-ReceiverCompanyCode
                                  AND <indvalues>-ReceivingEntity     = <indalloc>-ReceivingEntity
                                  AND <indvalues>-ReceiverCostObject  = <indalloc>-ReceiverCostObject
                                  AND <indvalues>-ReceiverCostCenter  = <indalloc>-ReceiverCostCenter
                                  AND <indvalues>-KeyVersion          = <indalloc>-KeyVersion
                                  AND <indvalues>-Allockey            = <indalloc>-Allockey
                                  AND <indvalues>-AllocationPeriod    = <indalloc>-AllocationPeriod
                                  AND <indvalues>-RefPeriod           = <indalloc>-RefPeriod.
                              APPEND INITIAL LINE TO et_alocvalues ASSIGNING FIELD-SYMBOL(<ls_aloc_values>).
                              MOVE-CORRESPONDING <indvalues> TO <ls_aloc_values>.
                              IF lo_uuid IS BOUND.
                                TRY.
                                    <ls_aloc_values>-uuid = lo_uuid->create_uuid_x16( ).
                                  CATCH cx_uuid_error.
                                    "handle exception
                                ENDTRY.
                                <ls_aloc_values>-parentuuid = <ls_rec_share>-uuid.
                              ENDIF.
*          Admin data
                              <ls_aloc_values>-created_by = sy-uname.
                              /esrcc/cl_utility_core=>get_utc_date_time_ts(
                                IMPORTING
                                  time_stamp = <ls_aloc_values>-created_at
                              ).
                              <ls_aloc_values>-last_changed_by = sy-uname.
                              /esrcc/cl_utility_core=>get_utc_date_time_ts(
                                IMPORTING
                                  time_stamp = <ls_aloc_values>-last_changed_at
                              ).
                            ELSE.
                              EXIT.
                            ENDIF.
                          ENDLOOP.
                        ENDIF.

                      ELSE.
                        EXIT.
                      ENDIF.
                    ENDLOOP.
                  ENDIF.

***********************************************************
**           SCC Virtual posting
***********************************************************

                  LOOP AT it_virtualcostelem ASSIGNING FIELD-SYMBOL(<virtualcostelem>) WHERE Sysid = <ls_rec_cost>-systemid.
                    CLEAR totalchargeout.
                    IF <ls_rec_cost>-receivingentity <> <ls_cc_cost>-legalentity.
                      CASE <virtualcostelem>-CostElementType.
                        WHEN /esrcc/if_calculate_chargeout=>scc_intercompany.
                          totalchargeout = recvalueadd + recvalueaddmarkup + recpassthru + recpassthrumarkup.
                        WHEN /esrcc/if_calculate_chargeout=>scc_intervalueadd.
                          totalchargeout = recvalueadd.
                        WHEN /esrcc/if_calculate_chargeout=>scc_intervalueadd_markup.
                          totalchargeout = recvalueaddmarkup.
                        WHEN /esrcc/if_calculate_chargeout=>scc_interpassthrough.
                          totalchargeout = recpassthru.
                        WHEN /esrcc/if_calculate_chargeout=>scc_interpassthrough_markup.
                          totalchargeout = recpassthrumarkup.
                      ENDCASE.
                    ELSE.
                      CASE <virtualcostelem>-CostElementType.
                        WHEN /esrcc/if_calculate_chargeout=>scc_intracompany.            "Intercompany Value Add
                          totalchargeout = recvalueadd + recvalueaddmarkup + recpassthru + recpassthrumarkup.
                        WHEN /esrcc/if_calculate_chargeout=>scc_intravalueadd.           "Intercompany Value Add
                          totalchargeout = recvalueadd.
                        WHEN /esrcc/if_calculate_chargeout=>scc_intravalueadd_markup.     "Intercompany Value Add Markup
                          totalchargeout = recvalueaddmarkup.
                        WHEN /esrcc/if_calculate_chargeout=>scc_intrapassthrough.         "Intercompany Pass Through
                          totalchargeout = recpassthru.
                        WHEN /esrcc/if_calculate_chargeout=>scc_intrapassthrough_markup.  "Intercompany Pass Through Markup
                          totalchargeout = recpassthrumarkup.
                      ENDCASE.
                    ENDIF.

                    IF totalchargeout <> 0.

                      IF number IS INITIAL.
                        TRY.
                            CALL METHOD cl_numberrange_runtime=>number_get
                              EXPORTING
                                nr_range_nr = '01'
                                object      = '/ESRCC/VP'
                              IMPORTING
                                number      = DATA(lv_number)
                                returncode  = DATA(lv_rcode).
                          CATCH cx_nr_object_not_found
                                cx_number_ranges INTO DATA(cx_numberrange).
                            DATA(error) = cx_numberrange->get_longtext(  ).
                        ENDTRY.
                        number = lv_number+10(10).
                      ENDIF.
                      itemno  = itemno + 1.

                      add_virtual_posting(
                        EXPORTING
                          docno             = number
                          itemno            = itemno
                          it_grpcostelement = it_grpcostelement
                          it_le_costelement = it_le_costelement
                          it_co_costelement = it_co_costelement
                          it_cc_costelement = it_cc_costelement
                          costelemtype      = <virtualcostelem>-CostElementType
                          costelement       = <virtualcostelem>-Costelement
                          it_stdchargeout   = it_stdchargeout
                          it_recalchargeout = it_recalchargeout
                          rec_cost          = <ls_rec_cost>
                          groupcurrency     = groupcurrency
                          chargeoutamount   = totalchargeout
                          exchdate          = <ls_rec_chg>-exchdate
                          iv_recalrefpoper  = iv_recalrefpoper
                        IMPORTING
                          es_cbli           = DATA(ls_cbli)
                      ).

                      APPEND ls_cbli TO et_cbli.
                    ENDIF.
                  ENDLOOP.

                ELSE.
                  EXIT.
                ENDIF.
              ENDLOOP.
            ENDIF.

          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

*link cost base line items.
      CONCATENATE 'refguid' iv_recalrefpoper into fieldname.
      CONCATENATE fieldname '= @<ls_cc_cost>-cc_uuid,'
                  'last_changed_by = @sy-uname,'
                  'last_changed_at = @last_changed_at'
      INTO field_list SEPARATED BY space.
      UPDATE /esrcc/cb_li
      SET (field_list)
*      cc_guid         = @<ls_cc_cost>-cc_uuid,
*      last_changed_by = @sy-uname,
*      last_changed_at = @last_changed_at,
*      recalrefpoper   = @iv_recalrefpoper
      WHERE fplv      = @<ls_cc_cost>-fplv
      AND ryear       = @<ls_cc_cost>-ryear
      AND sysid       = @<ls_cc_cost>-sysid
      AND legalentity = @<ls_cc_cost>-legalentity
      AND ccode       = @<ls_cc_cost>-ccode
      AND costobject  = @<ls_cc_cost>-costobject
      AND costcenter  = @<ls_cc_cost>-costcenter
      AND poper       = @<ls_cc_cost>-poper
      AND ( status = @/esrcc/if_calculate_chargeout=>approved OR
            status = @/esrcc/if_calculate_chargeout=>finalized ).
      CLEAR: totalchargeout.
    ENDLOOP.

  ENDMETHOD.


  METHOD add_virtual_posting.

    DATA number          TYPE /esrcc/doc_no.
    DATA validon         TYPE /esrcc/validfrom.

    CLEAR: es_cbli.

    READ TABLE it_cc_costelement TRANSPORTING NO FIELDS
                              WITH KEY sysid        = rec_cost-ReceiverSysId
                                       company_code = rec_cost-ReceiverCompanyCode
                                       legal_entity = rec_cost-Receivingentity
                                       cost_object  = rec_cost-receivercostobject
                                       cost_center  = rec_cost-receivercostcenter
                                       BINARY SEARCH.
    IF sy-subrc = 0.
      LOOP AT it_cc_costelement ASSIGNING FIELD-SYMBOL(<ls_costlement>) FROM sy-tabix.
        IF <ls_costlement>-sysid        = rec_cost-ReceiverSysId
       AND <ls_costlement>-company_code = rec_cost-ReceiverCompanyCode
       AND <ls_costlement>-legal_entity = rec_cost-Receivingentity
       AND <ls_costlement>-cost_object  = rec_cost-receivercostobject
       AND <ls_costlement>-cost_center  = rec_cost-receivercostcenter
       AND <ls_costlement>-valid_from  <= rec_cost-validon
       AND <ls_costlement>-valid_to    >= rec_cost-validon
       AND <ls_costlement>-costelement_from <= costelement
       AND <ls_costlement>-costelement_to   >= costelement.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
      READ TABLE it_co_costelement TRANSPORTING NO FIELDS
                                WITH KEY sysid        = rec_cost-ReceiverSysId
                                         company_code = rec_cost-ReceiverCompanyCode
                                         legal_entity = rec_cost-Receivingentity
                                         cost_object  = rec_cost-receivercostobject
                                         BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT it_co_costelement ASSIGNING <ls_costlement> FROM sy-tabix.
          IF <ls_costlement>-sysid        = rec_cost-ReceiverSysId
         AND <ls_costlement>-company_code = rec_cost-ReceiverCompanyCode
         AND <ls_costlement>-legal_entity = rec_cost-Receivingentity
         AND <ls_costlement>-cost_object  = rec_cost-receivercostobject
         AND <ls_costlement>-valid_from  <= rec_cost-validon
         AND <ls_costlement>-valid_to    >= rec_cost-validon
         AND <ls_costlement>-costelement_from <= costelement
         AND <ls_costlement>-costelement_to   >= costelement.
            EXIT.
          ENDIF.
        ENDLOOP.
      ELSE.
        READ TABLE it_le_costelement TRANSPORTING NO FIELDS
                          WITH KEY sysid        = rec_cost-ReceiverSysId
                                   company_code = rec_cost-ReceiverCompanyCode
                                   legal_entity = rec_cost-Receivingentity
                                   BINARY SEARCH.
        IF sy-subrc = 0.
          LOOP AT it_le_costelement ASSIGNING <ls_costlement> FROM sy-tabix.
            IF <ls_costlement>-sysid        = rec_cost-ReceiverSysId
           AND <ls_costlement>-company_code = rec_cost-ReceiverCompanyCode
           AND <ls_costlement>-legal_entity = rec_cost-Receivingentity
           AND <ls_costlement>-valid_from  <= rec_cost-validon
           AND <ls_costlement>-valid_to    >= rec_cost-validon
           AND <ls_costlement>-costelement_from <= costelement
           AND <ls_costlement>-costelement_to   >= costelement.
              EXIT.
            ENDIF.
          ENDLOOP.
        ELSE.
          READ TABLE it_grpcostelement TRANSPORTING NO FIELDS
                                  WITH KEY sysid        = rec_cost-ReceiverSysId
                                           BINARY SEARCH.
          IF sy-subrc = 0.
            LOOP AT it_grpcostelement ASSIGNING <ls_costlement> FROM sy-tabix.
              IF <ls_costlement>-sysid        = rec_cost-ReceiverSysId
             AND <ls_costlement>-valid_from  <= rec_cost-validon
             AND <ls_costlement>-valid_to    >= rec_cost-validon
             AND <ls_costlement>-costelement_from <= costelement
             AND <ls_costlement>-costelement_to   >= costelement.
                EXIT.
              ENDIF.
            ENDLOOP.
          ELSE.
            RETURN.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    es_cbli-fplv             = rec_cost-fplv.
    es_cbli-ryear            = rec_cost-ryear.
    es_cbli-poper            = rec_cost-Poper.
    es_cbli-belnr            = docno.
    es_cbli-buzei            = itemno.
    es_cbli-sysid            = rec_cost-ReceiverSysId.
    es_cbli-ccode            = rec_cost-ReceiverCompanyCode.
    es_cbli-legalentity      = rec_cost-Receivingentity.
    es_cbli-costobject       = rec_cost-ReceiverCostObject.
    es_cbli-costcenter       = rec_cost-ReceiverCostCenter.
    es_cbli-costelement      = costelement.
    es_cbli-costind          = <ls_costlement>-cost_indicator.
    es_cbli-costtype         = <ls_costlement>-cost_type.
    es_cbli-usagecal         = <ls_costlement>-usage_type.
    es_cbli-value_source     = <ls_costlement>-value_source.
    es_cbli-reasonid         = <ls_costlement>-reason_id.
    es_cbli-postingtype      = <ls_costlement>-posting_type.
    es_cbli-recalrefpoper    = iv_recalrefpoper.
    es_cbli-functionalarea   = rec_cost-FunctionalArea.
    es_cbli-businessdivision = rec_cost-BusinessDivision.
    es_cbli-profitcenter     = rec_cost-ProfitCenter.
    es_cbli-groupcurr        = groupcurrency.
    es_cbli-ksl              = chargeoutamount.

    LOOP AT it_recalchargeout ASSIGNING FIELD-SYMBOL(<recal_receiverchargeout>)
                          WHERE  ryear               = rec_cost-ryear
                            AND  poper               = rec_cost-poper
                            AND  Sysid               = rec_cost-Systemid
                            AND  ccode               = rec_cost-companycode
                            AND  Legalentity         = rec_cost-Legalentity
                            AND  Costobject          = rec_cost-Costobject
                            AND  Costcenter          = rec_cost-Costcenter
                            AND  Serviceproduct      = rec_cost-Serviceproduct
                            AND  ReceiverSysId       = rec_cost-ReceiverSysId
                            AND  ReceiverCompanyCode = rec_cost-ReceiverCompanyCode
                            AND  Receivingentity     = rec_cost-Receivingentity
                            AND  ReceiverCostObject  = rec_cost-ReceiverCostObject
                            AND  ReceiverCostCenter  = rec_cost-ReceiverCostCenter.

      CASE costelemtype.
        WHEN /esrcc/if_calculate_chargeout=>scc_intervalueadd OR
             /esrcc/if_calculate_chargeout=>scc_intravalueadd.           "Intercompany Value Add
          es_cbli-ksl = es_cbli-ksl - <recal_receiverchargeout>-recvalueadded.
        WHEN /esrcc/if_calculate_chargeout=>scc_intervalueadd_markup OR
             /esrcc/if_calculate_chargeout=>scc_intravalueadd_markup.     "Intercompany Value Add Markup
          es_cbli-ksl = es_cbli-ksl - <recal_receiverchargeout>-recvalueaddmarkup.
        WHEN /esrcc/if_calculate_chargeout=>scc_interpassthrough OR
             /esrcc/if_calculate_chargeout=>scc_intrapassthrough.       "Intercompany Pass Through
          es_cbli-ksl = es_cbli-ksl - <recal_receiverchargeout>-recpassthrough.
        WHEN /esrcc/if_calculate_chargeout=>scc_interpassthrough_markup OR
             /esrcc/if_calculate_chargeout=>scc_intrapassthrough_markup.  "Intercompany Pass Through Markup
          es_cbli-ksl = es_cbli-ksl - <recal_receiverchargeout>-recpassthroughmarkup.
        WHEN /esrcc/if_calculate_chargeout=>scc_intercompany OR
             /esrcc/if_calculate_chargeout=>scc_intracompany.
          es_cbli-ksl = es_cbli-ksl - <recal_receiverchargeout>-chargeoutamount.
      ENDCASE.

      EXIT.
    ENDLOOP.
    IF sy-subrc <> 0.
*determine the delta in SCC posting value and post for Recalculations
      READ TABLE it_stdchargeout ASSIGNING FIELD-SYMBOL(<std_chargeout>)
                 WITH KEY ryear               = rec_cost-ryear
                          poper               = rec_cost-poper
                          Sysid               = rec_cost-Systemid
                          ccode               = rec_cost-companycode
                          Legalentity         = rec_cost-Legalentity
                          Costobject          = rec_cost-Costobject
                          Costcenter          = rec_cost-Costcenter
                          Serviceproduct      = rec_cost-Serviceproduct
                          ReceiverSysId       = rec_cost-ReceiverSysId
                          ReceiverCompanyCode = rec_cost-ReceiverCompanyCode
                          Receivingentity     = rec_cost-Receivingentity
                          ReceiverCostObject  = rec_cost-ReceiverCostObject
                          ReceiverCostCenter  = rec_cost-ReceiverCostCenter
                          BINARY SEARCH.

      IF sy-subrc = 0.

        CASE costelemtype.
          WHEN /esrcc/if_calculate_chargeout=>scc_intervalueadd OR
               /esrcc/if_calculate_chargeout=>scc_intravalueadd.           "Intercompany Value Add
            es_cbli-ksl = es_cbli-ksl - <std_chargeout>-recvalueadded.
          WHEN /esrcc/if_calculate_chargeout=>scc_intervalueadd_markup OR
               /esrcc/if_calculate_chargeout=>scc_intravalueadd_markup.     "Intercompany Value Add Markup
            es_cbli-ksl = es_cbli-ksl - <std_chargeout>-recvalueaddmarkup.
          WHEN /esrcc/if_calculate_chargeout=>scc_interpassthrough OR
               /esrcc/if_calculate_chargeout=>scc_intrapassthrough.       "Intercompany Pass Through
            es_cbli-ksl = es_cbli-ksl - <std_chargeout>-recpassthrough.
          WHEN /esrcc/if_calculate_chargeout=>scc_interpassthrough_markup OR
               /esrcc/if_calculate_chargeout=>scc_intrapassthrough_markup.  "Intercompany Pass Through Markup
            es_cbli-ksl = es_cbli-ksl - <std_chargeout>-recpassthroughmarkup.
          WHEN /esrcc/if_calculate_chargeout=>scc_intercompany OR
             /esrcc/if_calculate_chargeout=>scc_intracompany.
            es_cbli-ksl = es_cbli-ksl - <std_chargeout>-chargeoutamount.
        ENDCASE.

      ENDIF.
    ENDIF.

    es_cbli-localcurr    = <ls_costlement>-local_curr.
    /esrcc/cl_utility_core=>currency_conversion(
    EXPORTING
    amount          = es_cbli-ksl
    source_curr     = es_cbli-groupcurr
    target_curr     = es_cbli-localcurr
    validon         = Exchdate
    IMPORTING
    convertedamount = es_cbli-hsl
    ).

    es_cbli-vendor              = rec_cost-Legalentity.
    es_cbli-status              = /esrcc/if_calculate_chargeout=>approved.   "Approved
    es_cbli-posting_sysid       = rec_cost-Systemid.
    es_cbli-posting_ccode       = rec_cost-companycode.
    es_cbli-posting_legalentity = rec_cost-Legalentity.
    es_cbli-posting_costobject  = rec_cost-Costobject.
    es_cbli-posting_costcenter  = rec_cost-Costcenter.
* Admin data
    es_cbli-created_by = sy-uname.
    /esrcc/cl_utility_core=>get_utc_date_time_ts(
    IMPORTING
    time_stamp = es_cbli-created_at
    ).
    es_cbli-last_changed_by = sy-uname.
    /esrcc/cl_utility_core=>get_utc_date_time_ts(
    IMPORTING
    time_stamp = es_cbli-last_changed_at
    ).

  ENDMETHOD.


  METHOD perform_validations.

    DATA logitem       TYPE /esrcc/log_item.

    CLEAR: ev_failed, ev_nolineitems, logitems.

*  Information message about the period for which logs are being published
    CLEAR logitem.
    logitem-message_id     = '/ESRCC/EXECCOCKPIT'.
    logitem-message_number = '018'.
    logitem-message_type   = 'I'.
    TRY.
        DATA(parentloguuid) = cl_system_uuid=>create_uuid_c32_static( ). .
      CATCH cx_uuid_error.
        "handle exception
    ENDTRY. .
    logitem-log_uuid = parentloguuid.
    logitem-is_parent = abap_true.
*    logitem-message_v1 = '001.' && key-poper && '-' && key-ryear.
    CONCATENATE key-poper key-ryear INTO logitem-message_v1 SEPARATED BY '-'.
    APPEND logitem TO logitems.


*Authority check
    authority_check(
        EXPORTING
        keys   = CORRESPONDING #( key )
        action = /esrcc/if_calculate_chargeout=>calculate_recalchargeout
        IMPORTING
        failed = ev_failed
    ).
    IF ev_failed = abap_true.
*      log an error
      CLEAR logitem.
      logitem-message_id     = '/ESRCC/EXECCOCKPIT'.
      logitem-message_number = '006'.
      logitem-message_type   = 'E'.
      APPEND logitem TO logitems.
      ev_failed = abap_true.
    ENDIF.

*validate if company code and legal entity is active
    IF ev_failed = abap_false.
      READ TABLE activeccode TRANSPORTING NO FIELDS WITH KEY sysid = key-sysid
                               ccode = key-ccode
                               legalentity = key-legalentity
                               BINARY SEARCH.
      IF sy-subrc = 0.
*      log an error
        CLEAR logitem.
        logitem-message_id     = '/ESRCC/EXECCOCKPIT'.
        logitem-message_number = '017'.
        logitem-message_type   = 'E'.
        CONCATENATE key-legalentity key-ccode INTO logitem-message_v1 SEPARATED BY '/'.
        APPEND logitem TO logitems.
        ev_failed = abap_true.
      ENDIF.
    ENDIF.

    IF ev_failed = abap_false.
      READ TABLE it_stdprocctrl TRANSPORTING NO FIELDS
                 WITH KEY ryear = key-ryear
                          sysid = key-sysid
                          legalentity = key-legalentity
                          ccode       = key-ccode
                          CostObject  = key-costobject
                          costcenter  = key-costcenter
                          BINARY SEARCH.
      IF sy-subrc = 0.
**      log an error
        CLEAR logitem.
        logitem-parent_log_uuid = parentloguuid.
        logitem-message_id = '/ESRCC/EXECCOCKPIT'.
        logitem-message_number = '033'.
        logitem-message_type = 'E'.
        CONCATENATE key-legalentity key-ccode INTO logitem-message_v1 SEPARATED BY '/'.
        APPEND logitem TO logitems.
        ev_failed = abap_true.
      ENDIF.
    ENDIF.

    IF ev_failed = abap_false.
      READ TABLE it_lineitems TRANSPORTING NO FIELDS
                     WITH KEY    fplv        = key-fplv
                                 ryear       = key-ryear
                                 poper       = key-poper
                                 sysid       = key-sysid
                                 legalentity = key-legalentity
                                 ccode       = key-ccode
                                 CostObject  = key-costobject
                                 costcenter  = key-costcenter
                                 BINARY SEARCH.
      IF sy-subrc = 0.
*      log an error
        CLEAR logitem.
        logitem-parent_log_uuid = parentloguuid.
        logitem-message_id = '/ESRCC/EXECCOCKPIT'.
        logitem-message_number = '035'.
        logitem-message_type = 'E'.
        APPEND logitem TO logitems.
        ev_failed = abap_true.
        EXIT.
      ENDIF.
    ENDIF.
    IF ev_failed = abap_false.
      READ TABLE it_cc_cost ASSIGNING FIELD-SYMBOL(<ls_cc_cost>)
      WITH KEY    fplv        = key-fplv
          ryear       = key-ryear
          poper       = key-poper
          sysid       = key-sysid
          legalentity = key-legalentity
          ccode       = key-ccode
          CostObject  = key-costobject
          costcenter  = key-costcenter
          BINARY SEARCH.
      IF sy-subrc <> 0.
*      log an error
        CLEAR logitem.
        logitem-parent_log_uuid = parentloguuid.
        logitem-message_id = '/ESRCC/EXECCOCKPIT'.
        logitem-message_number = '020'.
        logitem-message_type = 'W'.
        CONCATENATE key-legalentity key-ccode INTO logitem-message_v1 SEPARATED BY '/'.
        APPEND logitem TO logitems.
        ev_nolineitems = abap_true.
        RETURN.
      ELSEIF <ls_cc_cost>-erptotalcost_l = 0 AND <ls_cc_cost>-virtualtotalcost_l = 0.
*      log an warning
        CLEAR logitem.
        logitem-parent_log_uuid = parentloguuid.
        logitem-message_id = '/ESRCC/EXECCOCKPIT'.
        logitem-message_number = '021'.
        logitem-message_type = 'W'.
        CONCATENATE key-legalentity key-ccode INTO logitem-message_v1 SEPARATED BY '/'.
        APPEND logitem TO logitems.
        ev_nolineitems = abap_true.
        RETURN.
      ENDIF.
    ENDIF.
********************************************
* Service product costing validations
*********************************************
    IF ev_failed = abap_false.
      READ TABLE it_srvshare TRANSPORTING NO FIELDS
      WITH KEY Sysid = <ls_cc_cost>-sysid
      legalentity = <ls_cc_cost>-legalentity
      CompanyCode = <ls_cc_cost>-ccode
      costobject  = <ls_cc_cost>-costobject
      costcenter  = <ls_cc_cost>-costcenter
      BINARY SEARCH.
      IF sy-subrc = 0.
        DATA(srvshare_tabix) = sy-tabix.
        LOOP AT it_srvshare ASSIGNING FIELD-SYMBOL(<ls_srvshare>) FROM srvshare_tabix.
          IF    <ls_srvshare>-Sysid       = <ls_cc_cost>-sysid
          AND  <ls_srvshare>-legalentity = <ls_cc_cost>-legalentity
          AND  <ls_srvshare>-CompanyCode = <ls_cc_cost>-ccode
          AND  <ls_srvshare>-costobject  = <ls_cc_cost>-costobject
          AND  <ls_srvshare>-costcenter  = <ls_cc_cost>-costcenter.

            IF <ls_srvshare>-chargeout IS INITIAL.
*      log an error
              CLEAR logitem.
              logitem-parent_log_uuid = parentloguuid.
              logitem-message_id = '/ESRCC/EXECCOCKPIT'.
              logitem-message_number = '023'.
              logitem-message_type = 'E'.
              logitem-message_v1 = <ls_srvshare>-serviceproduct.
              APPEND logitem TO logitems.
              ev_failed = abap_true.
              EXIT.
            ELSEIF <ls_srvshare>-chargeout = 'D' AND <ls_srvshare>-planning IS INITIAL.
*      log an error
              CLEAR logitem.
              logitem-parent_log_uuid = parentloguuid.
              logitem-message_id = '/ESRCC/EXECCOCKPIT'.
              logitem-message_number = '024'.
              logitem-message_type = 'E'.
              logitem-message_v1 = <ls_srvshare>-serviceproduct.
              APPEND logitem TO logitems.
              ev_failed = abap_true.
              EXIT.
            ELSEIF <ls_srvshare>-chargeout = 'D' AND <ls_srvshare>-planning = 0.
*      log an error
              CLEAR logitem.
              logitem-parent_log_uuid = parentloguuid.
              logitem-message_id = '/ESRCC/EXECCOCKPIT'.
              logitem-message_number = '025'.
              logitem-message_type = 'W'.
              logitem-message_v1 = <ls_srvshare>-serviceproduct.
              APPEND logitem TO logitems.
              ev_failed = abap_false.
            ENDIF.

            IF ev_failed = abap_false.
*check if atleast one receivers exist for the service product
              READ TABLE it_rec_cost TRANSPORTING NO FIELDS
                             WITH KEY  fplv        = <ls_srvshare>-fplv
                                       ryear       = <ls_srvshare>-ryear
                                       poper       = <ls_srvshare>-poper
                                       systemid    = <ls_srvshare>-Sysid
                                       legalentity = <ls_srvshare>-LegalEntity
                                       CompanyCode = <ls_srvshare>-CompanyCode
                                       costobject  = <ls_srvshare>-CostObject
                                       costcenter  = <ls_srvshare>-CostCenter
                                       serviceproduct = <ls_srvshare>-ServiceProduct
                                       BINARY SEARCH.
              IF sy-subrc = 0.
                DATA(reccost_tabix) = sy-tabix.
                LOOP AT it_rec_cost ASSIGNING FIELD-SYMBOL(<ls_rec_cost>) FROM reccost_tabix.
                  IF    <ls_rec_cost>-Systemid     = <ls_cc_cost>-sysid
                 AND  <ls_rec_cost>-legalentity    = <ls_cc_cost>-legalentity
                 AND  <ls_rec_cost>-CompanyCode    = <ls_cc_cost>-ccode
                 AND  <ls_rec_cost>-costobject     = <ls_cc_cost>-costobject
                 AND  <ls_rec_cost>-costcenter     = <ls_cc_cost>-costcenter
                 AND  <ls_rec_cost>-ServiceProduct = <ls_srvshare>-ServiceProduct.

                    READ TABLE receiverchargeout ASSIGNING FIELD-SYMBOL(<receiverchargeout>)
                                            WITH KEY systemid    = <ls_rec_cost>-Systemid
                                                     legalentity = <ls_rec_cost>-LegalEntity
                                                     CompanyCode = <ls_rec_cost>-CompanyCode
                                                     costobject  = <ls_rec_cost>-CostObject
                                                     costcenter  = <ls_rec_cost>-CostCenter
                                                     serviceproduct = <ls_rec_cost>-ServiceProduct
                                                     BINARY SEARCH.


                    IF <receiverchargeout>-totalkpi = 0 AND <receiverchargeout>-totalreckpishare = 0.
*      log an error
                      CLEAR logitem.
                      logitem-parent_log_uuid = parentloguuid.
                      logitem-message_id = '/ESRCC/EXECCOCKPIT'.
                      logitem-message_v1 = <ls_rec_cost>-serviceproduct.
                      logitem-message_number = '027'.
                      logitem-message_type = 'E'.
                      APPEND logitem TO logitems.
                      ev_failed = abap_true.
                      EXIT.
                    ELSE.
                      IF <ls_srvshare>-chargeout = 'I' AND <receiverchargeout>-totalreckpishare = 0.
*      log an error
                        CLEAR logitem.
                        logitem-parent_log_uuid = parentloguuid.
                        logitem-message_id = '/ESRCC/EXECCOCKPIT'.
                        logitem-message_v1 = <ls_rec_cost>-serviceproduct.
                        logitem-message_number = '029'.
                        logitem-message_type = 'E'.
                        APPEND logitem TO logitems.
                        ev_failed = abap_true.
                        EXIT.
                      ELSEIF <ls_rec_cost>-chargeout = 'D' AND <receiverchargeout>-totalkpi = 0.
*      log an error
                        CLEAR logitem.
                        logitem-parent_log_uuid = parentloguuid.
                        logitem-message_id = '/ESRCC/EXECCOCKPIT'.
                        logitem-message_v1 = <ls_rec_cost>-serviceproduct.
                        logitem-message_number = '028'.
                        logitem-message_type = 'W'.
                        APPEND logitem TO logitems.
                        ev_failed = abap_false.
                      ELSEIF <ls_srvshare>-chargeout = 'D' AND <receiverchargeout>-totalkpi <> 0
                            AND <ls_srvshare>-planninguom IS NOT INITIAL
                            AND <ls_rec_cost>-consumptionuom IS NOT INITIAL
                            AND  <ls_srvshare>-planninguom <> <ls_rec_cost>-consumptionuom.
**      log an error
                        CLEAR logitem.
                        logitem-parent_log_uuid = parentloguuid.
                        logitem-message_id = '/ESRCC/EXECCOCKPIT'.
                        logitem-message_v1 = <ls_rec_cost>-serviceproduct.
                        logitem-message_number = '030'.
                        logitem-message_type = 'E'.
                        APPEND logitem TO logitems.
                        ev_failed = abap_true.
                        EXIT.
                      ENDIF.
                    ENDIF.


                  ELSE.
                    EXIT.
                  ENDIF.
                ENDLOOP.
              ELSE.
*      log an error
                CLEAR logitem.
                logitem-parent_log_uuid = parentloguuid.
                logitem-message_id = '/ESRCC/EXECCOCKPIT'.
                logitem-message_v1 = <ls_srvshare>-serviceproduct.
                logitem-message_number = '004'.
                logitem-message_type = 'E'.
                APPEND logitem TO logitems.
                ev_failed = abap_true.

              ENDIF.
            ENDIF.
          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.
      ELSE.
*      log an error
        CLEAR logitem.
        logitem-parent_log_uuid = parentloguuid.
        logitem-message_id = '/ESRCC/EXECCOCKPIT'.
        logitem-message_number = '031'.
        logitem-message_type = 'E'.
        APPEND logitem TO logitems.
        ev_failed = abap_true.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD read_processcontrol_data.

* read the process control data to get the existing log guids
    SELECT DISTINCT procctrl~fplv,
    procctrl~ryear,
    procctrl~poper,
    procctrl~sysid,
    procctrl~legalentity,
    procctrl~ccode,
    procctrl~costobject,
    procctrl~costcenter,
    procctrl~process,
    procctrl~log_header_uuid
    FROM /esrcc/procctrl AS procctrl
    INNER JOIN @it_keys AS keys
    ON  procctrl~fplv          = keys~fplv
    AND  procctrl~ryear         = keys~ryear
    AND  procctrl~sysid         = keys~sysid
    AND  procctrl~legalentity   = keys~legalentity
    AND  procctrl~ccode         = keys~ccode
    AND  procctrl~costobject    = keys~costobject
    AND  procctrl~costcenter    = keys~costcenter
    AND  procctrl~process       = @/esrcc/if_calculate_chargeout=>trueuprecal
    WHERE procctrl~poper        = @iv_recalrefpoper
    AND procctrl~log_header_uuid IS NOT INITIAL
    ORDER BY procctrl~fplv,
    procctrl~ryear,
    procctrl~poper,
    procctrl~sysid,
    procctrl~legalentity,
    procctrl~ccode,
    procctrl~costobject,
    procctrl~costcenter,
    procctrl~process
    INTO CORRESPONDING FIELDS OF TABLE @et_procctrl.

** read the process control data to get the statuses
    SELECT DISTINCT procctrl~ryear,
                    procctrl~sysid,
                    procctrl~legalentity,
                    procctrl~ccode,
                    procctrl~costobject,
                    procctrl~costcenter
            FROM /esrcc/procctrl AS procctrl
            INNER JOIN @it_keys AS keys
                    ON  procctrl~ryear         = keys~ryear
                   AND  procctrl~poper         = keys~poper
                   AND  procctrl~sysid         = keys~sysid
                   AND  procctrl~legalentity   = keys~legalentity
                   AND  procctrl~ccode         = keys~ccode
                   AND  procctrl~costobject    = keys~costobject
                   AND  procctrl~costcenter    = keys~costcenter
                   AND  procctrl~process       = @/esrcc/if_calculate_chargeout=>stdchargeout
                   AND  procctrl~status        <> @/esrcc/if_calculate_chargeout=>stdchargeout_finalized
                   ORDER BY
                    procctrl~ryear,
                    procctrl~sysid,
                    procctrl~legalentity,
                    procctrl~ccode,
                    procctrl~costobject,
                    procctrl~costcenter
                   INTO CORRESPONDING FIELDS OF TABLE @et_std_procctrl.

  ENDMETHOD.


  METHOD read_receiver_data.

*Read and derive chargeout allocation data
*Receiver charge out and markup
    SELECT DISTINCT
    srvshare~fplv,
    srvshare~ryear,
    srvshare~poper,
    rec~systemid,
    rec~legalentity,
    rec~CompanyCode,
    rec~costobject,
    rec~costcenter,
    rec~serviceproduct,
    rec~ReceiverSysId,
    rec~ReceiverCompanyCode,
    rec~ReceivingEntity,
    rec~ReceiverCostObject,
    rec~ReceiverCostCenter,
    coscen~FunctionalArea,
    coscen~BusinessDivision,
    coscen~ProfitCenter,
    rec~ContractId,
    rec~ErpSalesOrder,
    rec~InvoicingCurrency,
    CASE WHEN rec~Legalentity <> rec~ReceivingEntity THEN
    srvmkp~origcost
    ELSE
    srvmkp~intra_origcost
    END AS valueaddmarkup,
    CASE WHEN rec~Legalentity <> rec~ReceivingEntity THEN
    srvmkp~passcost
    ELSE
    srvmkp~intra_passcost
    END AS passthrumarkup,
    _diralloc~Uom AS consumptionuom,
    srvshare~planninguom,
    CASE WHEN srvshare~chargeout = 'D' THEN
    _diralloc~Consumption
    ELSE 0 END AS reckpi,
    srvshare~chargeout,
    srvshare~consumption_version,
    0 AS initialreckpishare,
    0 AS reckpishare,
    srvshare~validon
    FROM /esrcc/i_srvproduct_receivers AS  rec

    INNER JOIN @it_srvshare AS srvshare
    ON  rec~SystemId        = srvshare~sysid
    AND  rec~legalentity    = srvshare~legalentity
    AND  rec~CompanyCode    = srvshare~CompanyCode
    AND  rec~costobject     = srvshare~costobject
    AND  rec~costcenter     = srvshare~costcenter
    AND  rec~ServiceProduct = srvshare~serviceproduct

    INNER JOIN /esrcc/i_coscen_f4 AS coscen
    ON  coscen~Sysid       = rec~ReceiverSysId
    AND coscen~LegalEntity = rec~Receivingentity
    AND coscen~CompanyCode = rec~ReceiverCompanyCode
    AND coscen~Costobject  = rec~ReceiverCostObject
    AND coscen~Costcenter  = rec~ReceiverCostCenter

    LEFT OUTER JOIN /esrcc/srvmkp AS srvmkp
    ON srvmkp~serviceproduct   = rec~ServiceProduct
    AND srvmkp~validfrom      <= srvshare~validon
    AND srvmkp~validto        >= srvshare~validon
    AND srvmkp~workflow_status = @/esrcc/if_calculate_chargeout=>finalized

    LEFT OUTER JOIN /esrcc/i_diralocconsumptn  AS _diralloc
    ON _diralloc~ServiceProduct       =  rec~serviceproduct
    AND _diralloc~Sysid               =  rec~ReceiverSysId
    AND _diralloc~ReceivingCompany    =  rec~ReceiverCompanyCode
    AND _diralloc~ReceivingEntity     =  rec~ReceivingEntity
    AND _diralloc~Costobject          =  rec~ReceiverCostObject
    AND _diralloc~Costcenter          =  rec~ReceiverCostCenter
    AND _diralloc~ProviderSysid       =  rec~SystemId
    AND _diralloc~ProviderCompany     =  rec~CompanyCode
    AND _diralloc~ProviderEntity      =  rec~legalentity
    AND _diralloc~ProviderCostobject  =  rec~costobject
    AND _diralloc~ProviderCostcenter  =  rec~costcenter
    AND _diralloc~Ryear               =  srvshare~Ryear
    AND _diralloc~Poper               =  srvshare~Poper
    AND _diralloc~Fplv                =  srvshare~consumption_version
    AND srvshare~chargeout            =  'D'

    WHERE  rec~StewardshipValidFrom   <= srvshare~validon
    AND  rec~StewardshipValidto       >= srvshare~validon
    AND  ServiceValidFrom             <= srvshare~validon
    AND  ServiceValidto               >= srvshare~validon
    AND  rec~status                   = @/esrcc/if_calculate_chargeout=>finalized
    AND  active                       = @abap_true
    ORDER BY
    srvshare~fplv,
    srvshare~ryear,
    srvshare~poper,
    rec~systemid,
    rec~legalentity,
    rec~CompanyCode,
    rec~costobject,
    rec~costcenter,
    rec~serviceproduct
    INTO CORRESPONDING FIELDS OF TABLE @et_reccost.

    IF et_reccost IS NOT INITIAL.

      SELECT
      receivers~fplv,
      receivers~ryear,
      receivers~poper,
      receivers~systemid,
      receivers~legalentity,
      receivers~CompanyCode,
      receivers~costobject,
      receivers~costcenter,
      receivers~serviceproduct,
      receivers~ReceiverSysId,
      receivers~ReceiverCompanyCode,
      receivers~ReceivingEntity,
      receivers~ReceiverCostObject,
      receivers~ReceiverCostCenter,
      rule~key_version AS keyversion,
      _Weightage~allocation_key AS allockey,
      _Weightage~allocation_period AS allocationperiod,
      _Weightage~ref_period AS refperiod,
      _Weightage~weightage,
      receivers~validon,
      CAST(
      CASE _Weightage~allocation_period
      WHEN '04' THEN
      CASE WHEN CAST( receivers~poper AS DEC( 3 ) ) - CAST( _Weightage~ref_period AS DEC( 3 ) ) < 0 THEN
      concat( '000',CAST( CAST( receivers~poper AS DEC( 3 ) ) - CAST( _Weightage~ref_period AS DEC( 3 ) ) AS CHAR( 6 ) ) )
      ELSE
      CASE WHEN CAST( receivers~poper AS DEC( 3 ) ) - CAST( _Weightage~ref_period AS DEC( 3 ) ) <= 9 THEN
      concat( '00',CAST( CAST( receivers~poper AS DEC( 3 ) ) - CAST( _Weightage~ref_period AS DEC( 3 ) ) AS CHAR( 6 ) ) )
      ELSE
      concat( '0',CAST( CAST( receivers~poper AS DEC( 3 ) ) - CAST( _Weightage~ref_period AS DEC( 3 ) ) AS CHAR( 6 ) ) )
      END END
      WHEN '05' THEN
      CASE WHEN CAST( receivers~poper AS DEC( 3 ) ) - CAST( 1 AS DEC( 3 ) ) <= 0 THEN
      CAST( '000' AS CHAR( 6 ) )
      ELSE
      CASE WHEN CAST( receivers~poper AS DEC( 3 ) ) - 1 > 9 THEN
      concat( '0',CAST( CAST( receivers~poper AS DEC( 3 ) ) - CAST( 1 AS DEC( 3 ) ) AS CHAR( 6 ) ) )
      ELSE
      concat( '00',CAST( CAST( receivers~poper AS DEC( 3 ) ) - CAST( 1 AS DEC( 3 ) ) AS CHAR( 6 ) ) )
      END
      END
      ELSE
      _Weightage~ref_period END AS NUMC( 3 ) ) AS fromRefPeriod
      FROM @et_reccost AS receivers

      INNER JOIN /esrcc/chargeout AS chargeout
      ON chargeout~serviceproduct = receivers~ServiceProduct
      AND chargeout~validfrom    <= receivers~validon
      AND chargeout~validto      >= receivers~validon

      INNER JOIN /esrcc/co_rule AS rule
      ON  rule~rule_id          = chargeout~chargeout_rule_id
      AND rule~workflow_status  = @/esrcc/if_calculate_chargeout=>finalized

      INNER JOIN /esrcc/aloc_wgt AS _Weightage
      ON _Weightage~rule_id      = chargeout~chargeout_rule_id

      WHERE receivers~chargeout         = 'I'
      ORDER BY
      receivers~fplv,
      receivers~ryear,
      receivers~poper,
      receivers~systemid,
      receivers~legalentity,
      receivers~CompanyCode,
      receivers~costobject,
      receivers~costcenter,
      receivers~serviceproduct,
      receivers~ReceiverSysId,
      receivers~ReceiverCompanyCode,
      receivers~ReceivingEntity,
      receivers~ReceiverCostObject,
      receivers~ReceiverCostCenter,
      rule~key_version,
      _Weightage~allocation_key
      INTO TABLE @DATA(lt_indallocvalues).

      SELECT
      receivers~fplv,
      receivers~ryear,
      receivers~poper,
      receivers~systemid,
      receivers~legalentity,
      receivers~CompanyCode,
      receivers~costobject,
      receivers~costcenter,
      receivers~serviceproduct,
      receivers~ReceiverSysId,
      receivers~ReceiverCompanyCode,
      receivers~ReceivingEntity,
      receivers~ReceiverCostObject,
      receivers~ReceiverCostCenter,
      keyversion,
      allockey,
      allocationperiod,
      refperiod,
      weightage,
      periodindalloc~Poper AS refpoper,
      periodindalloc~value AS reckpivalue
      FROM @lt_indallocvalues AS receivers

      LEFT OUTER JOIN /esrcc/i_indkeybasevalues AS periodindalloc
       ON receivers~ReceiverSysId       = periodindalloc~ReceiverSysId
      AND receivers~ReceiverCompanyCode = periodindalloc~ReceiverCompanyCode
      AND receivers~ReceivingEntity     = periodindalloc~ReceivingEntity
      AND receivers~ReceiverCostObject  = periodindalloc~ReceiverCostObject
      AND receivers~ReceiverCostCenter  = periodindalloc~ReceiverCostCenter
      AND receivers~allockey            = periodindalloc~AllocationKey
      AND receivers~keyversion          = periodindalloc~Fplv
      AND receivers~ryear               = periodindalloc~Ryear
      AND ( ( receivers~poper          >= periodindalloc~Poper
      AND allocationperiod              = '01' )     "YTD
      OR
      ( receivers~poper                 = periodindalloc~Poper
      AND allocationperiod              = '02' )     "CurrentMonth
      OR
      ( receivers~fromrefperiod        >= periodindalloc~Poper
      AND allocationperiod              = '03' )     "No. Of Months
      OR
      ( periodindalloc~Poper           <= receivers~poper
      AND periodindalloc~Poper          > receivers~fromrefperiod
      AND allocationperiod              = '04' )    "Rolling Months
      OR
      (    periodindalloc~Poper         = receivers~fromrefperiod
      AND allocationperiod              = '05' )    "Previous Month
      OR
      ( receivers~fromrefperiod         = periodindalloc~Poper
      AND allocationperiod              = '06' ) )   "Reference Month

      ORDER BY
      receivers~fplv,
      receivers~ryear,
      receivers~poper,
      receivers~systemid,
      receivers~legalentity,
      receivers~CompanyCode,
      receivers~costobject,
      receivers~costcenter,
      receivers~serviceproduct,
      receivers~ReceiverSysId,
      receivers~ReceiverCompanyCode,
      receivers~ReceivingEntity,
      receivers~ReceiverCostObject,
      receivers~ReceiverCostCenter,
      keyversion,
      allockey
      INTO CORRESPONDING FIELDS OF TABLE @et_indallocvalues.

      IF et_indallocvalues IS NOT INITIAL.

        SELECT
        fplv,
        ryear,
        poper,
        systemid,
        legalentity,
        CompanyCode,
        costobject,
        costcenter,
        serviceproduct,
        ReceiverSysId,
        ReceiverCompanyCode,
        ReceivingEntity,
        ReceiverCostObject,
        ReceiverCostCenter,
        KeyVersion,
        allockey,
        allocationperiod,
        refperiod,
        weightage,
        SUM( reckpivalue ) AS reckpivalue
        FROM @et_indallocvalues AS indvalues
        GROUP BY
        fplv,
        ryear,
        poper,
        systemid,
        legalentity,
        CompanyCode,
        costobject,
        costcenter,
        serviceproduct,
        ReceiverSysId,
        ReceiverCompanyCode,
        ReceivingEntity,
        ReceiverCostObject,
        ReceiverCostCenter,
        KeyVersion,
        allockey,
        AllocationPeriod,
        RefPeriod,
        weightage
        ORDER BY
        fplv,
        ryear,
        poper,
        systemid,
        legalentity,
        CompanyCode,
        costobject,
        costcenter,
        serviceproduct,
        ReceiverSysId,
        ReceiverCompanyCode,
        ReceivingEntity,
        ReceiverCostObject,
        ReceiverCostCenter,
        KeyVersion,
        allockey
        INTO CORRESPONDING FIELDS OF TABLE @et_indalloc.

        SELECT
        Fplv,
        Ryear,
        Poper,
        systemid,
        legalentity,
        CompanyCode,
        costobject,
        costcenter,
        serviceproduct,
        SUM( reckpivalue )  AS totalreckpi
        FROM @et_indalloc AS indvalues
        GROUP BY
         Fplv,
         Ryear,
         Poper,
         systemid,
         legalentity,
         CompanyCode,
         costobject,
         costcenter,
         serviceproduct
        ORDER BY
         fplv,
         ryear,
         poper,
         systemid,
         legalentity,
         CompanyCode,
         costobject,
         costcenter,
         serviceproduct
         INTO TABLE @DATA(indkpisum).

      ENDIF.
    ENDIF.

    LOOP AT et_reccost ASSIGNING FIELD-SYMBOL(<ls_rec_cost>).

      READ TABLE et_indalloc TRANSPORTING NO FIELDS
                        WITH KEY
                                 Fplv              = <ls_rec_cost>-fplv
                                 Ryear             = <ls_rec_cost>-ryear
                                 Poper             = <ls_rec_cost>-poper
                                 systemid          = <ls_rec_cost>-SystemId
                                 legalentity       = <ls_rec_cost>-LegalEntity
                                 CompanyCode       = <ls_rec_cost>-CompanyCode
                                 costobject        = <ls_rec_cost>-CostObject
                                 costcenter        = <ls_rec_cost>-costcenter
                                 serviceproduct    = <ls_rec_cost>-serviceproduct
                                 ReceiverSysId       = <ls_rec_cost>-ReceiverSysId
                                 ReceiverCompanyCode = <ls_rec_cost>-ReceiverCompanyCode
                                 ReceivingEntity     = <ls_rec_cost>-ReceivingEntity
                                 ReceiverCostObject  = <ls_rec_cost>-ReceiverCostObject
                                 ReceiverCostCenter  = <ls_rec_cost>-ReceiverCostCenter
                                 BINARY SEARCH.
      IF sy-subrc = 0.
        DATA(indalloc_tabix) = sy-tabix.
        LOOP AT et_indalloc ASSIGNING FIELD-SYMBOL(<indalloc>) FROM indalloc_tabix.
          IF  <indalloc>-Fplv              = <ls_rec_cost>-fplv
          AND <indalloc>-Ryear             = <ls_rec_cost>-ryear
          AND <indalloc>-Poper             = <ls_rec_cost>-poper
          AND <indalloc>-systemid          = <ls_rec_cost>-SystemId
          AND <indalloc>-legalentity       = <ls_rec_cost>-LegalEntity
          AND <indalloc>-CompanyCode       = <ls_rec_cost>-CompanyCode
          AND <indalloc>-costobject        = <ls_rec_cost>-CostObject
          AND <indalloc>-costcenter        = <ls_rec_cost>-costcenter
          AND <indalloc>-serviceproduct    = <ls_rec_cost>-serviceproduct
          AND <indalloc>-ReceiverSysId       = <ls_rec_cost>-ReceiverSysId
          AND <indalloc>-ReceiverCompanyCode = <ls_rec_cost>-ReceiverCompanyCode
          AND <indalloc>-ReceivingEntity     = <ls_rec_cost>-ReceivingEntity
          AND <indalloc>-ReceiverCostObject  = <ls_rec_cost>-ReceiverCostObject
          AND <indalloc>-ReceiverCostCenter  = <ls_rec_cost>-ReceiverCostCenter.
            READ TABLE indkpisum ASSIGNING FIELD-SYMBOL(<indkpisum>)
                         WITH KEY Fplv              = <indalloc>-fplv
                                  Ryear             = <indalloc>-ryear
                                  Poper             = <indalloc>-poper
                                  systemid          = <indalloc>-SystemId
                                  legalentity       = <indalloc>-LegalEntity
                                  CompanyCode       = <indalloc>-CompanyCode
                                  costobject        = <indalloc>-CostObject
                                  costcenter        = <indalloc>-costcenter
                                  serviceproduct    = <indalloc>-serviceproduct
                                  BINARY SEARCH.
            IF sy-subrc = 0.
              <indalloc>-initialreckpishare = ( <indalloc>-reckpivalue / <indkpisum>-totalreckpi ).
              <indalloc>-reckpishare        = ( <indalloc>-reckpivalue / <indkpisum>-totalreckpi ) * ( <indalloc>-weightage / 100 ).

*              <ls_rec_cost>-initialreckpishare = <ls_rec_cost>-initialreckpishare + ( <indalloc>-reckpivalue / <indkpisum>-totalreckpi ) * 100.
              <ls_rec_cost>-reckpishare        = <ls_rec_cost>-reckpishare + ( <indalloc>-reckpivalue / <indkpisum>-totalreckpi ) * <indalloc>-weightage.
            ENDIF.
          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.


    SELECT
     systemid,
     legalentity,
     CompanyCode,
     costobject,
     costcenter,
     serviceproduct,
     SUM( reckpi ) AS totalkpi,
     SUM( reckpishare ) AS totalreckpishare
    FROM @et_reccost AS recchg
    GROUP BY
    systemid,
    legalentity,
    CompanyCode,
    costobject,
    costcenter,
    serviceproduct
    ORDER BY
    systemid,
    legalentity,
    CompanyCode,
    costobject,
    costcenter,
    serviceproduct
    INTO CORRESPONDING FIELDS OF TABLE @et_receiverchargeout.

  ENDMETHOD.


  METHOD read_serviceproduct_data.

*Read service product information
    SELECT DISTINCT
           cbstw~fplv,
           cbstw~ryear,
           cbstw~poper,
           stwsp~sysid,
           stwsp~legalentity,
           stwsp~CompanyCode,
           stwsp~costobject,
           stwsp~costcenter,
           stwsp~ServiceProduct,
           srvpro~servicetype,
           srvpro~transactiongroup,
           rule~chargeout_method AS chargeout,
           stwsp~ShareOfCost AS costshare,
           rule~consumption_version,
           rule~capacity_version,
           rule~key_version,
           dirplan~Planning AS planning,
           dirplan~Uom AS PlanningUoM,
           cbstw~validon
    FROM /esrcc/i_stw_serviceproduct AS stwsp

    INNER JOIN @it_keys AS cbstw
      ON  stwsp~sysid         = cbstw~sysid
     AND  stwsp~legalentity   = cbstw~legalentity
     AND  stwsp~CompanyCode   = cbstw~ccode
     AND  stwsp~costobject    = cbstw~costobject
     AND  stwsp~costcenter    = cbstw~costcenter
     AND  stwsp~ValidFrom     <= cbstw~validon
     AND  stwsp~Validto       >= cbstw~validon
     AND  SpValidFrom         <= cbstw~validon
     AND  SpValidto           >= cbstw~validon

    LEFT OUTER JOIN /esrcc/srvpro AS srvpro
    ON srvpro~serviceproduct = stwsp~ServiceProduct

    LEFT OUTER JOIN /esrcc/chgtrup AS chargeout
    ON chargeout~serviceproduct = stwsp~ServiceProduct
    AND chargeout~validfrom   <= cbstw~validon
    AND chargeout~validto     >= cbstw~validon

    LEFT OUTER JOIN /esrcc/co_rule AS rule
    ON  rule~rule_id          = chargeout~chargeout_rule_id
    AND rule~workflow_status  = @/esrcc/if_calculate_chargeout=>finalized

    LEFT OUTER JOIN /ESRCC/I_ServiceCapacity AS dirplan
    ON  dirplan~Sysid          = cbstw~sysid
    AND dirplan~CompanyCode    = cbstw~ccode
    AND dirplan~LegalEntity    = cbstw~legalentity
    AND dirplan~Costobject     = cbstw~costobject
    AND dirplan~Costcenter     = cbstw~costcenter
    AND dirplan~Ryear          = cbstw~ryear
    AND dirplan~Poper          = cbstw~poper
    AND dirplan~Fplv           = rule~capacity_version
    AND dirplan~ServiceProduct = stwsp~ServiceProduct
    AND rule~chargeout_method  = 'D'

    WHERE  stwsp~workflow_status  = @/esrcc/if_calculate_chargeout=>finalized
    ORDER BY
    cbstw~fplv,
    cbstw~ryear,
    cbstw~poper,
    stwsp~sysid,
    stwsp~legalentity,
    stwsp~CompanyCode,
    stwsp~costobject,
    stwsp~costcenter,
    stwsp~ServiceProduct
    INTO CORRESPONDING FIELDS OF TABLE @et_srvshare.

  ENDMETHOD.


  METHOD read_virtual_posting_data.

**check if virtual cost element  is configured for receivers.
    SELECT DISTINCT costelem~sysid,
                    costelem~company_code,
                    costelem~legal_entity,
                    costelem~cost_object,
                    costelem~cost_center,
                    costelem~costelement_from,
                    costelem~costelement_to,
                    le~local_curr,
                    cost_indicator,
                    cost_type,
                    usage_type,
                    value_source,
                    reason_id,
                    posting_type,
                    costelem~valid_from,
                    costelem~valid_to
          FROM /esrcc/cstelmtch AS costelem
          INNER JOIN @it_rec_cost AS rc
          ON  costelem~sysid          = rc~receiversysid
          INNER JOIN /esrcc/le AS le
          ON le~legalentity           = rc~receivingentity
          WHERE costelem~value_source  = @/esrcc/if_calculate_chargeout=>scc_valuesource
            AND costelem~valid_from   <= rc~validon
            AND costelem~valid_to     >= rc~validon
            AND costelem~legal_entity IS INITIAL
            AND costelem~company_code IS INITIAL
            AND costelem~cost_object  IS INITIAL
            AND costelem~cost_center  IS INITIAL
            AND costelem~workflow_status = @/esrcc/if_calculate_chargeout=>finalized
          ORDER BY costelem~sysid,
                   costelem~valid_from
          INTO CORRESPONDING FIELDS OF TABLE @et_grpcostelement.

    SELECT DISTINCT costelem~sysid,
                    costelem~company_code,
                    costelem~legal_entity,
                    costelem~cost_object,
                    costelem~cost_center,
                    costelem~costelement_from,
                    costelem~costelement_to,
                    le~local_curr,
                    cost_indicator,
                    cost_type,
                    usage_type,
                    value_source,
                    reason_id,
                    posting_type,
                    costelem~valid_from,
                    costelem~valid_to
          FROM /esrcc/cstelmtch AS costelem
          INNER JOIN @it_rec_cost AS rc
          ON  costelem~legal_entity    = rc~receivingentity
          AND costelem~company_code    = rc~receivercompanycode
          AND costelem~sysid           = rc~receiversysid
          INNER JOIN /esrcc/le AS le
          ON le~legalentity = rc~receivingentity
          WHERE costelem~value_source  = @/esrcc/if_calculate_chargeout=>scc_valuesource
            AND costelem~valid_from   <= rc~validon
            AND costelem~valid_to     >= rc~validon
            AND costelem~cost_object IS INITIAL
            AND costelem~cost_center IS INITIAL
            AND costelem~workflow_status = @/esrcc/if_calculate_chargeout=>finalized
          ORDER BY costelem~sysid,
                   costelem~company_code,
                   costelem~legal_entity,
                   costelem~valid_from
          INTO CORRESPONDING FIELDS OF TABLE @et_le_costelement.

    SELECT DISTINCT costelem~sysid,
                    costelem~company_code,
                    costelem~legal_entity,
                    costelem~cost_object,
                    costelem~cost_center,
                    costelem~costelement_from,
                    costelem~costelement_to,
                    le~local_curr,
                    cost_indicator,
                    cost_type,
                    usage_type,
                    value_source,
                    reason_id,
                    posting_type,
                    costelem~valid_from,
                    costelem~valid_to
          FROM /esrcc/cstelmtch AS costelem
          INNER JOIN @it_rec_cost AS rc
          ON  costelem~legal_entity   = rc~receivingentity
          AND costelem~company_code   = rc~receivercompanycode
          AND costelem~sysid          = rc~receiversysid
          AND costelem~cost_object    = rc~receivercostobject
          INNER JOIN /esrcc/le AS le
          ON le~legalentity = rc~receivingentity
          WHERE costelem~value_source  = @/esrcc/if_calculate_chargeout=>scc_valuesource
            AND costelem~valid_from   <= rc~validon
            AND costelem~valid_to     >= rc~validon
            AND costelem~cost_center IS INITIAL
            AND costelem~workflow_status = @/esrcc/if_calculate_chargeout=>finalized
          ORDER BY costelem~sysid,
                   costelem~company_code,
                   costelem~legal_entity,
                   costelem~cost_object,
                   costelem~valid_from
          INTO CORRESPONDING FIELDS OF TABLE @et_co_costelement.

    SELECT DISTINCT costelem~sysid,
                    costelem~company_code,
                    costelem~legal_entity,
                    costelem~cost_object,
                    costelem~cost_center,
                    costelem~costelement_from,
                    costelem~costelement_to,
                    le~local_curr,
                    cost_indicator,
                    cost_type,
                    usage_type,
                    value_source,
                    reason_id,
                    posting_type,
                    costelem~valid_from,
                    costelem~valid_to
          FROM /esrcc/cstelmtch AS costelem
          INNER JOIN @it_rec_cost AS rc
          ON  costelem~legal_entity   = rc~receivingentity
          AND costelem~company_code   = rc~receivercompanycode
          AND costelem~sysid          = rc~receiversysid
          AND costelem~cost_object    = rc~receivercostobject
          AND costelem~cost_center    = rc~receivercostcenter
          INNER JOIN /esrcc/le AS le
          ON le~legalentity = rc~receivingentity
          WHERE costelem~value_source  = @/esrcc/if_calculate_chargeout=>scc_valuesource
            AND costelem~valid_from   <= rc~validon
            AND costelem~valid_to     >= rc~validon
            AND costelem~workflow_status = @/esrcc/if_calculate_chargeout=>finalized
          ORDER BY costelem~sysid,
                   costelem~company_code,
                   costelem~legal_entity,
                   costelem~cost_object,
                   costelem~cost_center,
                   costelem~valid_from
          INTO CORRESPONDING FIELDS OF TABLE @et_cc_costelement.


*SCC Standard Chargeout
    SELECT DISTINCT
               cb~ryear,
               cb~poper,
               cb~sysid,
               cb~ccode,
               cb~legalentity,
               cb~Costobject,
               cb~Costcenter,
               sp~serviceproduct,
               co~ReceiverSysId,
               co~ReceiverCompanyCode,
               co~Receivingentity,
               co~ReceiverCostObject,
               co~ReceiverCostCenter,
               co~currency,
               co~RecValueadded,
               co~RecPassthrough,
               co~RecValueaddMarkup,
               co~RecPassthroughMarkup,
               co~TotalChargeout AS ChargeoutAmount
          FROM /ESRCC/I_ReceiverChargeout AS co
          INNER JOIN /esrcc/i_costbasestewardship AS cb
          ON co~RootUUID = cb~uuid
          INNER JOIN /ESRCC/I_ServiceProductShare AS sp
          ON co~ParentUUID = sp~uuid
          INNER JOIN @it_keys AS keys
           ON cb~poper          = keys~poper
          AND cb~ryear          = keys~ryear
          AND cb~Sysid          = keys~sysid
          AND cb~Legalentity    = keys~legalentity
          AND cb~ccode          = keys~ccode
          AND cb~Costobject     = keys~costobject
          AND cb~Costcenter     = keys~costcenter
          WHERE co~Currencytype   = 'G'
          AND cb~ProcessType    = @/esrcc/if_calculate_chargeout=>standardprocesstype
        ORDER BY
               cb~ryear,
               cb~poper,
               cb~sysid,
               cb~ccode,
               cb~legalentity,
               cb~Costobject,
               cb~Costcenter,
               sp~serviceproduct,
               co~ReceiverSysId,
               co~ReceiverCompanyCode,
               co~Receivingentity,
               co~ReceiverCostObject,
               co~ReceiverCostCenter
        INTO CORRESPONDING FIELDS OF TABLE @et_stdchargeout.

*SCC Recalculation
    SELECT DISTINCT
           cb~fplv,
           cb~ryear,
           cb~poper,
           cb~recalrefpoper AS Refpoper,
           cb~sysid,
           cb~ccode,
           cb~legalentity,
           cb~Costobject,
           cb~Costcenter,
           sp~serviceproduct,
           co~ReceiverSysId,
           co~ReceiverCompanyCode,
           co~Receivingentity,
           co~ReceiverCostObject,
           co~ReceiverCostCenter,
           co~RecValueadded,
           co~RecPassthrough,
           co~RecValueaddMarkup,
           co~RecPassthroughMarkup,
           co~TotalChargeout AS ChargeoutAmount
      FROM /ESRCC/I_ReceiverChargeout AS co
      INNER JOIN /esrcc/i_costbasestewardship AS cb
      ON co~RootUUID  = cb~uuid
      INNER JOIN /ESRCC/I_ServiceProductShare AS sp
      ON co~ParentUUID = sp~uuid
     INNER JOIN @it_keys AS keys
       ON  cb~ryear          = keys~ryear
       AND cb~Sysid          = keys~sysid
       AND cb~Legalentity    = keys~legalentity
       AND cb~ccode          = keys~ccode
       AND cb~Costobject     = keys~costobject
       AND cb~Costcenter     = keys~costcenter
     WHERE co~Currencytype   = 'G'
      AND cb~RefPoper        < @iv_recalrefpoper
      AND cb~ProcessType    = @/esrcc/if_calculate_chargeout=>recalprocesstype
      AND co~Receivingentity IS NOT INITIAL
      ORDER BY cb~recalrefpoper DESCENDING
    INTO CORRESPONDING FIELDS OF TABLE @et_recalchargeout.

  ENDMETHOD.


  METHOD get_sequential_keys.

    DATA ls_key           TYPE /esrcc/procctrl.
    DATA lt_nonseq_keys   TYPE /esrcc/tt_keys.
    DATA lt_seq_keys      TYPE /esrcc/tt_keys.
    DATA lv_validon       TYPE /esrcc/validfrom.

*   consider YTD scenario and derive all popers
    derive_poper(
      EXPORTING
        it_keys  = it_keys
      IMPORTING
        et_poper = DATA(_poper)
      ).

    SORT _poper BY low.

*get the chain and sequence.
* each cost object could be providing multiple services
    READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<keys>) INDEX 1.
    IF sy-subrc = 0.
      SELECT stewardship~*
        FROM /ESRCC/I_Stewardship AS stewardship
        INNER JOIN @it_keys AS it_keys
          ON stewardship~sysid       = it_keys~sysid
         AND stewardship~legalentity = it_keys~legalentity
         AND stewardship~CompanyCode = it_keys~ccode
         AND stewardship~costobject  = it_keys~costobject
         AND stewardship~costcenter  = it_keys~costcenter
         AND stewardship~workflow_status = @/esrcc/if_calculate_chargeout=>finalized
      WHERE stewardship~chain_id IS NOT INITIAL
      INTO TABLE @DATA(lt_stewardship).

      IF lt_stewardship IS NOT INITIAL.
        SELECT DISTINCT stewardship~*
          FROM /ESRCC/I_Stewardship AS stewardship
          INNER JOIN @lt_stewardship AS lt_stewardship
            ON stewardship~chain_id = lt_stewardship~chain_id
        INTO TABLE @DATA(lt_chain_stw).

      ENDIF.

      SORT lt_chain_stw BY chain_id chain_sequence validfrom.

      LOOP AT lt_chain_stw ASSIGNING FIELD-SYMBOL(<ls_chain_stw>).

        LOOP AT _poper ASSIGNING FIELD-SYMBOL(<poper>).

          CLEAR: ls_key..
          CONCATENATE <keys>-ryear <poper>-low+1(2) '01' INTO lv_validon.

          IF <ls_chain_stw>-ValidFrom <= lv_validon AND <ls_chain_stw>-Validto   >= lv_validon.
            CLEAR: ls_key.
            MOVE-CORRESPONDING <ls_chain_stw> TO ls_key.
            ls_key-fplv  = <keys>-fplv.
            ls_key-ryear = <keys>-ryear.
            ls_key-poper = <poper>-low.
            ls_key-ccode = <ls_chain_stw>-CompanyCode.
            IF it_keys[ 1 ]-poper = ls_key-poper.
              APPEND ls_key TO et_seq_keys.
            ENDIF.
            ls_key-chain_id = <ls_chain_stw>-chain_id.
            IF <ls_chain_stw>-chain_sequence = 1.
              ls_key-chain_rootnode = abap_true.
            ENDIF.
            APPEND INITIAL LINE TO et_seq_mon_keys ASSIGNING FIELD-SYMBOL(<trueupkeys>).
            MOVE-CORRESPONDING ls_key TO <trueupkeys>.
            <trueupkeys>-validon = lv_validon.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    LOOP AT it_keys ASSIGNING <keys>.
      READ TABLE et_seq_keys TRANSPORTING NO FIELDS
                         WITH KEY sysid       = <keys>-sysid
                                  ryear       = <keys>-ryear
                                  poper       = <keys>-poper
                                  ccode       = <keys>-ccode
                                  legalentity = <keys>-legalentity
                                  costobject  = <keys>-costobject
                                  costcenter  = <keys>-costcenter.
      IF sy-subrc <> 0.
        LOOP AT _poper ASSIGNING <poper>.
          CLEAR: ls_key.
          MOVE-CORRESPONDING <keys> TO ls_key.
          ls_key-poper = <poper>-low.
          IF it_keys[ 1 ]-poper = ls_key-poper.
            APPEND ls_key TO et_nonseq_keys.
          ENDIF.
          APPEND INITIAL LINE TO et_nonseq_mon_keys ASSIGNING <trueupkeys>.
          MOVE-CORRESPONDING ls_key TO <trueupkeys>.
          CONCATENATE <keys>-ryear <keys>-poper+1(2) '01' INTO <trueupkeys>-validon.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD read_lineitems.

*Read line items for cost base status
    SELECT DISTINCT
        cbli~fplv,
        cbli~ryear,
        cbli~poper,
        cbli~sysid,
        cbli~legalentity,
        cbli~ccode,
        cbli~costobject,
        cbli~costcenter
        FROM /esrcc/cb_li AS cbli
        INNER JOIN @it_keys AS keys
        ON  cbli~fplv  = keys~fplv
        AND cbli~ryear = keys~ryear
        AND cbli~poper = keys~poper
        AND cbli~sysid = keys~sysid
        AND cbli~legalentity = keys~legalentity
        AND cbli~ccode = keys~ccode
        AND cbli~costobject = keys~costobject
        AND cbli~costcenter = keys~costcenter
        WHERE cbli~status = 'D'
          OR  cbli~status = 'W'
        ORDER BY
        cbli~fplv,
        cbli~ryear,
        cbli~poper,
        cbli~sysid,
        cbli~legalentity,
        cbli~ccode,
        cbli~costobject,
        cbli~costcenter
        INTO CORRESPONDING FIELDS OF TABLE @et_lineitems.

  ENDMETHOD.
ENDCLASS.
