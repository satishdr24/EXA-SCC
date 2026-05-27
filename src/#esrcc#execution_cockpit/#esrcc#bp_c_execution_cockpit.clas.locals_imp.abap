CLASS lhc_c_execution_cockpit DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR /esrcc/c_execution_cockpit RESULT result.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE /esrcc/c_execution_cockpit.

    METHODS read FOR READ
      IMPORTING keys FOR READ /esrcc/c_execution_cockpit RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK /esrcc/c_execution_cockpit.

    METHODS finalize_recalchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~finalize_recalchargeout.

    METHODS finalize_stdchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~finalize_stdchargeout.

    METHODS perform_recalchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~perform_recalchargeout RESULT result.

    METHODS perform_stdchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~perform_stdchargeout RESULT result.

    METHODS reopen_recalchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~reopen_recalchargeout.

    METHODS reopen_stdchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~reopen_stdchargeout.
    METHODS finalize_forecast FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~finalize_forecast.

    METHODS perform_forecast FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~perform_forecast RESULT result.

    METHODS reopen_forecast FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~reopen_forecast.

    METHODS schedule_job
      IMPORTING
        action   TYPE /esrcc/actions
        job_name TYPE cl_apj_rt_api=>ty_jobname
        proclogs TYPE /esrcc/tt_processlogs.

    METHODS get_sequential_keys
      IMPORTING
        it_keys TYPE /esrcc/tt_keys
      EXPORTING
        et_keys TYPE /esrcc/tt_keys.

ENDCLASS.

CLASS lhc_c_execution_cockpit IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD schedule_job.

**********************************************************************
*Schedule a JOB
**********************************************************************
    DATA job_template_name TYPE cl_apj_rt_api=>ty_template_name VALUE '/ESRCC/CHARGEOUT_CALCULATION_JT'.
    DATA job_start_info    TYPE cl_apj_rt_api=>ty_start_info.
    DATA job_parameters    TYPE cl_apj_rt_api=>tt_job_parameter_value.
    DATA job_parameter     TYPE cl_apj_rt_api=>ty_job_parameter_value.
    DATA range_value       TYPE cl_apj_rt_api=>ty_value_range.
    DATA jobname           TYPE cl_apj_rt_api=>ty_jobname.
    DATA job_count         TYPE cl_apj_rt_api=>ty_jobcount.

    job_start_info-start_immediately = abap_true.

    job_parameter-name = /esrcc/cl_apj_rt_service=>action_param.
    range_value-sign = 'I'.
    range_value-option = 'EQ'.
    range_value-low = action.
    APPEND range_value TO job_parameter-t_value.
    APPEND job_parameter TO job_parameters.
    CLEAR job_parameter.

    job_parameter-name = 'ID'.
    LOOP AT proclogs ASSIGNING FIELD-SYMBOL(<ls_proclogs>).
      CLEAR:  range_value.
      range_value-sign = 'I'.
      range_value-option = 'EQ'.
      range_value-low = <ls_proclogs>-uuid.
      APPEND range_value TO job_parameter-t_value.
    ENDLOOP.
    APPEND job_parameter TO job_parameters.

*    /esrcc/cl_utility_core=>get_utc_date_time_ts(
*      IMPORTING
*        time_stamp = DATA(timestamp)
*    ).

*    job_count = timestamp.
*    jobname  = job_name && timestamp.

    TRY.
        cl_apj_rt_api=>schedule_job(
                          EXPORTING
                          iv_job_template_name   = job_template_name
                          iv_job_text            = |Calculate Chargeout|
                          is_start_info          = job_start_info
                          it_job_parameter_value = job_parameters
*                          iv_jobname             = jobname
*                          iv_jobcount            = job_count
                          IMPORTING
                          ev_jobname             = jobname
                          ev_jobcount            = job_count
                          ).
      CATCH cx_apj_rt INTO DATA(job_scheduling_error).

        DATA(error_message) = job_scheduling_error->bapimsg-message.
        "handle exception
    ENDTRY.

  ENDMETHOD.

  METHOD Finalize_recalchargeout.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_trueuprecal.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE costobject IS INITIAL.

*get the chain and sequence.
* each cost object could be providing multiple services
    get_sequential_keys(
      EXPORTING
        it_keys = lt_keys
      IMPORTING
        et_keys = lt_procctrl
    ).

    APPEND LINES OF lt_keys TO lt_procctrl.
    SORT lt_procctrl BY fplv sysid ryear poper legalentity ccode costobject costcenter.
    DELETE ADJACENT DUPLICATES FROM lt_procctrl.

*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_procctrl
        process = /esrcc/if_calculate_chargeout=>trueuprecal
        status  = /esrcc/if_calculate_chargeout=>recalculation_fin_inproces
        update  = abap_true
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>finalize_recalchargeout
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>finalize_recalchargeout
      job_name = '/ESRCC/FINALIZE_RECALCHARGEOUT'
      proclogs = lt_procclogs
    ).

  ENDMETHOD.

  METHOD Finalize_stdchargeout.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_stdchargeout.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE costobject IS INITIAL.

*get the chain and sequence.
* each cost object could be providing multiple services
    get_sequential_keys(
      EXPORTING
        it_keys = lt_keys
      IMPORTING
        et_keys = lt_procctrl
    ).

    APPEND LINES OF lt_keys TO lt_procctrl.
    SORT lt_procctrl BY fplv sysid ryear poper legalentity ccode costobject costcenter.
    DELETE ADJACENT DUPLICATES FROM lt_procctrl.

*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_procctrl
        process = /esrcc/if_calculate_chargeout=>stdchargeout
        status  = /esrcc/if_calculate_chargeout=>stdchargeout_fin_inprocess
        update  = abap_true
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>finalize_stdchargeout
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>finalize_stdchargeout
      job_name = '/ESRCC/FINALIZE_STDCHARGEOUT'
      proclogs = lt_procclogs
    ).

  ENDMETHOD.

  METHOD perform_recalchargeout.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_trueuprecal.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys MAPPING fplv = %param-fplv ).
    DELETE lt_keys WHERE costobject IS INITIAL.

*get the chain and sequence.
* each cost object could be providing multiple services
    get_sequential_keys(
      EXPORTING
        it_keys = lt_keys
      IMPORTING
        et_keys = lt_procctrl
    ).

    APPEND LINES OF lt_keys TO lt_procctrl.
    SORT lt_procctrl BY fplv sysid ryear poper legalentity ccode costobject costcenter.
    DELETE ADJACENT DUPLICATES FROM lt_procctrl.

*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_procctrl
        process = /esrcc/if_calculate_chargeout=>trueuprecal
        status  = /esrcc/if_calculate_chargeout=>recalculation_inprocess
        update  = abap_false
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>calculate_recalchargeout
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>calculate_recalchargeout
      job_name = '/ESRCC/CALCULATE_RECALCHARGEOUT'
      proclogs = lt_procclogs
    ).

  ENDMETHOD.

  METHOD perform_stdchargeout.

    DATA lt_keys          TYPE /esrcc/tt_keys.
    DATA lo_badi          TYPE REF TO /esrcc/badi_stdchargeout.
    DATA lt_procclogs     TYPE /esrcc/tt_processlogs.
    DATA lt_procctrl      TYPE TABLE OF /esrcc/procctrl.

    lt_keys = CORRESPONDING #( keys MAPPING fplv = %param-fplv ).
    DELETE lt_keys WHERE costobject IS INITIAL.

*get the chain and sequence.
* each cost object could be providing multiple services
    get_sequential_keys(
      EXPORTING
        it_keys = lt_keys
      IMPORTING
        et_keys = lt_procctrl
    ).

    APPEND LINES OF lt_keys TO lt_procctrl.
    SORT lt_procctrl BY fplv sysid ryear poper legalentity ccode costobject costcenter.
    DELETE ADJACENT DUPLICATES FROM lt_procctrl.


*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_procctrl
        process = /esrcc/if_calculate_chargeout=>stdchargeout
        status  = /esrcc/if_calculate_chargeout=>stdchargeout_inprocess
        update  = abap_false
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>calculate_stdchargeout
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>calculate_stdchargeout
      job_name = '/ESRCC/CALCULATE_STDCHARGEOUT'
      proclogs = lt_procclogs
    ).

  ENDMETHOD.

  METHOD reopen_recalchargeout.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_trueuprecal.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE costobject IS INITIAL.

*get the chain and sequence.
* each cost object could be providing multiple services
    get_sequential_keys(
      EXPORTING
        it_keys = lt_keys
      IMPORTING
        et_keys = lt_procctrl
    ).

    APPEND LINES OF lt_keys TO lt_procctrl.
    SORT lt_procctrl BY fplv sysid ryear poper legalentity ccode costobject costcenter.
    DELETE ADJACENT DUPLICATES FROM lt_procctrl.

*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_procctrl
        process = /esrcc/if_calculate_chargeout=>trueuprecal
        status  = /esrcc/if_calculate_chargeout=>recalculation_reopen_inprocess
        update  = abap_true
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>reopen_recalchargeout
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>reopen_recalchargeout
      job_name = '/ESRCC/REOPEN_RECALCHARGEOUT'
      proclogs = lt_procclogs
    ).

  ENDMETHOD.

  METHOD reopen_stdchargeout.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lo_badi      TYPE REF TO /esrcc/badi_stdchargeout.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE costobject IS INITIAL.

*get the chain and sequence.
* each cost object could be providing multiple services
    get_sequential_keys(
      EXPORTING
        it_keys = lt_keys
      IMPORTING
        et_keys = lt_procctrl
    ).

    APPEND LINES OF lt_keys TO lt_procctrl.
    SORT lt_procctrl BY fplv sysid ryear poper legalentity ccode costobject costcenter.
    DELETE ADJACENT DUPLICATES FROM lt_procctrl.

*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_procctrl
        process = /esrcc/if_calculate_chargeout=>stdchargeout
        status  = /esrcc/if_calculate_chargeout=>stdchargeout_reopen_inprocess
        update  = abap_true
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>reopen_stdchargeout
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>reopen_stdchargeout
      job_name = '/ESRCC/REOPEN_STDCHARGEOUT'
      proclogs = lt_procclogs
    ).

  ENDMETHOD.

  METHOD get_sequential_keys.

    DATA lv_validon TYPE /esrcc/validfrom.
    DATA ls_key     TYPE /esrcc/procctrl.

*get the chain and sequence.
* each cost object could be providing multiple services
    READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<keys>) INDEX 1.
    IF sy-subrc = 0.
      SELECT stewardship~*
        FROM /ESRCC/I_Stewardship AS stewardship
        INNER JOIN @it_keys AS keys
          ON stewardship~sysid       = keys~sysid
         AND stewardship~legalentity = keys~legalentity
         AND stewardship~CompanyCode = keys~ccode
         AND stewardship~costobject  = keys~costobject
         AND stewardship~costcenter  = keys~costcenter
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

*   it could be billing frequency used quarterly or half yearly
      CLEAR: lv_validon.
      DATA(poper) = it_keys[ 1 ]-poper.
      CONCATENATE <keys>-ryear poper+1(2) '01' INTO lv_validon.

      LOOP AT lt_chain_stw ASSIGNING FIELD-SYMBOL(<ls_chain_stw>)
                           WHERE ValidFrom <= lv_validon
                             AND Validto   >= lv_validon.
        CLEAR: ls_key.
        MOVE-CORRESPONDING <ls_chain_stw> TO ls_key.
        ls_key-poper = poper.
        ls_key-ryear = <keys>-ryear.
        ls_key-fplv  = <keys>-fplv.
        ls_key-ccode = <ls_chain_stw>-CompanyCode.
        APPEND ls_key TO et_keys.

      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD Finalize_forecast.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE costobject IS INITIAL.

*get the chain and sequence.
* each cost object could be providing multiple services
    get_sequential_keys(
      EXPORTING
        it_keys = lt_keys
      IMPORTING
        et_keys = lt_procctrl
    ).

    APPEND LINES OF lt_keys TO lt_procctrl.
    SORT lt_procctrl BY fplv sysid ryear poper legalentity ccode costobject costcenter.
    DELETE ADJACENT DUPLICATES FROM lt_procctrl.

*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_procctrl
        process = /esrcc/if_calculate_chargeout=>forecast
        status  = /esrcc/if_calculate_chargeout=>forecast_fin_inproces
        update  = abap_true
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>finalize_forecast
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>finalize_forecast
      job_name = '/ESRCC/FINALIZE_FORECAST'
      proclogs = lt_procclogs
    ).

  ENDMETHOD.

  METHOD perform_forecast.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys MAPPING fplv = %param-fplv ).
    DELETE lt_keys WHERE costobject IS INITIAL.

*get the chain and sequence.
* each cost object could be providing multiple services
    get_sequential_keys(
      EXPORTING
        it_keys = lt_keys
      IMPORTING
        et_keys = lt_procctrl
    ).

    APPEND LINES OF lt_keys TO lt_procctrl.
    SORT lt_procctrl BY fplv sysid ryear poper legalentity ccode costobject costcenter.
    DELETE ADJACENT DUPLICATES FROM lt_procctrl.

*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_procctrl
        process = /esrcc/if_calculate_chargeout=>forecast
        status  = /esrcc/if_calculate_chargeout=>forecast_inprocess
        update  = abap_false
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>calculate_forecast
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>calculate_forecast
      job_name = '/ESRCC/CALCULATE_FORECAST'
      proclogs = lt_procclogs
    ).

  ENDMETHOD.

  METHOD reopen_forecast.

    DATA lt_keys      TYPE /esrcc/tt_keys.
    DATA lt_procclogs TYPE /esrcc/tt_processlogs.
    DATA ls_procctrl  TYPE /esrcc/procctrl.
    DATA lt_procctrl  TYPE TABLE OF /esrcc/procctrl.


    lt_keys = CORRESPONDING #( keys ).
    DELETE lt_keys WHERE costobject IS INITIAL.

*get the chain and sequence.
* each cost object could be providing multiple services
    get_sequential_keys(
      EXPORTING
        it_keys = lt_keys
      IMPORTING
        et_keys = lt_procctrl
    ).

    APPEND LINES OF lt_keys TO lt_procctrl.
    SORT lt_procctrl BY fplv sysid ryear poper legalentity ccode costobject costcenter.
    DELETE ADJACENT DUPLICATES FROM lt_procctrl.

*update process control
    /esrcc/cl_calculate_chargeout=>set_process_control(
      EXPORTING
        keys    = lt_procctrl
        process = /esrcc/if_calculate_chargeout=>forecast
        status  = /esrcc/if_calculate_chargeout=>forecast_reopen_inprocess
        update  = abap_true
      IMPORTING
        failed  = DATA(failure)
    ).

* set process logs
    /esrcc/cl_calculate_chargeout=>create_processlogs(
       EXPORTING
         iv_action      = /esrcc/if_calculate_chargeout=>reopen_forecast
         it_keys        = lt_keys
       IMPORTING
         et_processlogs = lt_procclogs
     ).

*Schedule the job
    schedule_job(
      action   = /esrcc/if_calculate_chargeout=>reopen_forecast
      job_name = '/ESRCC/REOPEN_FORECAST'
      proclogs = lt_procclogs
    ).

  ENDMETHOD.

ENDCLASS.
