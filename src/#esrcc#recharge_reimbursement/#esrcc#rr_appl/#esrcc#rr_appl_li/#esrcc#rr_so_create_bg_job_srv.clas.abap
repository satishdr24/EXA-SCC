CLASS /esrcc/rr_so_create_bg_job_srv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    CLASS-DATA:stream_length TYPE int4.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA log TYPE REF TO if_bali_log.

    METHODS send_for_so_creation   IMPORTING   it_parameters   TYPE if_apj_rt_exec_object=>tt_templ_val.

ENDCLASS.



CLASS /esrcc/rr_so_create_bg_job_srv IMPLEMENTATION.

  METHOD if_apj_dt_exec_object~get_parameters.
    et_parameter_def = VALUE if_apj_dt_exec_object=>tt_templ_def(
                                                                  ( selname        = 'GRP'
                                                                    kind           = if_apj_dt_exec_object=>parameter
                                                                    datatype       = 'NUMC'
                                                                    length         = 3
                                                                    component_type = '/ESRCC/RR_GROUP_BY_KEY'
                                                                    section_text   = 'Group By'
                                                                    param_text     = 'Group By'
                                                                    changeable_ind = abap_true
                                                                    mandatory_ind  = abap_false
                                                                    )
                                                                   ).

  ENDMETHOD.

  METHOD if_apj_rt_exec_object~execute.
    " Create the Log Header
    TRY.
        log = cl_bali_log=>create_with_header( header = cl_bali_header_setter=>create(
                                                            object    = '/ESRCC/RR'
                                                            subobject = '/ESRCC/RR_SO_CREATE' ) ).
      CATCH cx_bali_runtime INTO DATA(cx_bali_error). " TODO: variable is assigned but never used (ABAP cleaner)
        RETURN.
    ENDTRY.

    " Checking Authorization
    IF /esrcc/cl_authorization=>check_auth_create( ) = abap_false.
      TRY.
          log->add_item( cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_error
                                                         id       = '/ESRCC/RR'
                                                         number   = '001' ) ). " 'No Authorization to send for SO Creation
        CATCH cx_bali_runtime INTO cx_bali_error.
      ENDTRY.
    ELSE.

      " Check if there is any existing Jobs for this SO Creation apart from this job
      TRY.
          DATA(running_jobs) = cl_apj_rt_api=>find_jobs_with_jce( iv_catalog_name = '/ESRCC/RR_SO_CREATE_CATALOG' ).
        CATCH cx_apj_rt.
      ENDTRY.

      IF lines( running_jobs ) > 1.
        TRY.
            log->add_item( cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_error
                                                           id       = '/ESRCC/RR'
                                                           number   = '011' ) ). "  "Please wait till the existing SO creation jobs completes.
          CATCH cx_bali_runtime INTO cx_bali_error.
        ENDTRY.
      ELSE.
        send_for_so_creation( it_parameters = it_parameters ).
      ENDIF.
    ENDIF.

    TRY.
        cl_bali_log_db=>get_instance( )->save_log( log                        = log
                                                   assign_to_current_appl_job = abap_true ).
      CATCH cx_bali_runtime INTO cx_bali_error.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD send_for_so_creation.

    DATA create_so_badi TYPE REF TO /esrcc/rr_create_so_badi.

    " Populating SO Ref and group by key
    FINAL(grp_by_key) = COND /esrcc/rr_group_by_key( WHEN it_parameters IS INITIAL                     THEN '001'
                                                     WHEN it_parameters[ selname = 'GRP' ]-low = '000' THEN '001'
                                                     ELSE it_parameters[ selname = 'GRP' ]-low ).

    GET BADI create_so_badi.
    IF create_so_badi IS BOUND.

      " Call sales order creation -> This Fetches the data, group and send for SO creation
      CALL BADI create_so_badi->create_so
        EXPORTING
          grp_by_key = grp_by_key
        CHANGING
          log          = log.

    ENDIF.


  ENDMETHOD.

ENDCLASS.


