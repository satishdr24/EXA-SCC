CLASS lsc_/esrcc/i_rr_li_so DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save REDEFINITION.

ENDCLASS.

CLASS lsc_/esrcc/i_rr_li_so IMPLEMENTATION.
  METHOD save.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_I_RR_LI_SO DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR /esrcc/i_rr_li_so RESULT result.

    METHODS CreateSO FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/i_rr_li_so~CreateSO RESULT result..
    METHODS read FOR READ
      IMPORTING keys FOR READ /esrcc/i_rr_li_so RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK /esrcc/i_rr_li_so.
    METHODS: AcknowledgeSO FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/i_rr_li_so~AcknowledgeSO RESULT result,
      precheck_createso FOR PRECHECK
        IMPORTING keys FOR ACTION /esrcc/i_rr_li_so~createso,
      _get_msg IMPORTING msg_id          TYPE cl_bali_message_setter=>ty_id
                         var1            TYPE  cl_bali_message_setter=>ty_variable OPTIONAL
                         var2            TYPE  cl_bali_message_setter=>ty_variable OPTIONAL
               RETURNING VALUE(msg_text) TYPE /esrcc/api_message .

ENDCLASS.

CLASS lhc_I_RR_LI_SO IMPLEMENTATION.


  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD CreateSO.

    CONSTANTS job_catalog  TYPE cl_apj_rt_api=>ty_catalog_name  VALUE '/ESRCC/RR_SO_CREATE_CATALOG'.
    CONSTANTS job_template TYPE cl_apj_rt_api=>ty_template_name VALUE '/ESRCC/RR_SO_CEATE_JOB_TEMPL'.
    CONSTANTS job_text     TYPE cl_apj_rt_api=>ty_job_text      VALUE 'Recharge/Reimbursement SO Create'.

    IF /esrcc/cl_authorization=>check_auth_create( ) = abap_false.

      result = VALUE #( ( %cid   = VALUE #( keys[ 1 ]-%cid  OPTIONAL )
                          %param = VALUE #( message = _get_msg( msg_id = '001' ) ) ) ). " No authorization to send for SO Creation
      RETURN.
    ENDIF.

    " Check if there is any existing Jobs for this SO Creation
    TRY.
        DATA(running_jobs) = cl_apj_rt_api=>find_jobs_with_jce( iv_catalog_name = job_catalog ).

        IF lines( running_jobs ) >= 1.
          result = VALUE #( ( %cid   = VALUE #( keys[ 1 ]-%cid  OPTIONAL )
                              %param = VALUE #( message = _get_msg( msg_id = '011' ) ) ) ). " Please wait till the existing SO creation jobs completes.
          RETURN.
        ENDIF.

        DATA(group_by_key) = VALUE /esrcc/rr_group_by_key( keys[ 1 ]-%param OPTIONAL ).
        IF group_by_key IS INITIAL.
          RETURN.
        ENDIF.

        " Scheduling Job
        cl_apj_rt_api=>schedule_job(
          EXPORTING iv_job_template_name   = job_template
                    iv_job_text            = job_text
                    is_start_info          = VALUE cl_apj_rt_api=>ty_start_info( start_immediately = abap_true )
                    it_job_parameter_value = VALUE cl_apj_rt_api=>tt_job_parameter_value(
                                                       ( name    = 'GRP'
                                                         t_value = VALUE #( sign   = 'I'
                                                                            option = 'EQ'
                                                                            ( low = group_by_key ) ) ) )
          IMPORTING ev_jobname             = DATA(job_name)
                    ev_jobcount            = DATA(job_count) ).

        result = VALUE #( ( %cid   = VALUE #( keys[ 1 ]-%cid  OPTIONAL )
                            %param = VALUE #( message = _get_msg( msg_id = '012' ) ) ) ). " Job Scheduled for SO Creation.

      CATCH cx_apj_rt INTO DATA(error_in_job_creation).
        result = VALUE #(
            ( %cid   = VALUE #( keys[ 1 ]-%cid  OPTIONAL )
              %param = VALUE #(
                  Message_type = /esrcc/if_const_msg=>error
                  message      = |{ error_in_job_creation->get_longtext( ) && error_in_job_creation->get_text( ) } | ) ) ).
    ENDTRY.
  ENDMETHOD.


  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD AcknowledgeSO.
    DATA create_so_badi TYPE REF TO /esrcc/rr_create_so_badi.

    DATA(so_detail) = VALUE /esrcc/d_rr_update_so_no( keys[ 1 ]-%param OPTIONAL ).

    GET BADI create_so_badi.
    IF create_so_badi IS BOUND.

      " Update SO number to RR Line items
      CALL BADI create_so_badi->update_so
        EXPORTING so_detail = so_detail
        RECEIVING response  = DATA(response).

    ENDIF.

    result = VALUE #( ( %cid   = VALUE #( keys[ 1 ]-%cid  OPTIONAL )
                        %param = response ) ).

  ENDMETHOD.

  METHOD precheck_CreateSO.
  ENDMETHOD.

  METHOD _get_msg.
    MESSAGE ID '/ESRCC/RR' TYPE /esrcc/if_const_msg=>info NUMBER msg_id WITH var1 var2 INTO msg_text.
  ENDMETHOD.

ENDCLASS.
