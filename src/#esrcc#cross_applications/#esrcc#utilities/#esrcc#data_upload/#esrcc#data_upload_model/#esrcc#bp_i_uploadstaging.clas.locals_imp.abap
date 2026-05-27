CLASS lhc_uploadstaging DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR uploadstaging RESULT result.

    METHODS setfilename FOR DETERMINE ON MODIFY
      IMPORTING keys FOR uploadstaging~setfilename.

    METHODS uploadfields FOR DETERMINE ON SAVE
      IMPORTING keys FOR uploadstaging~uploadfields.

    METHODS validate_create FOR VALIDATE ON SAVE
      IMPORTING keys FOR uploadstaging~validate_create.
    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE uploadstaging.

ENDCLASS.

CLASS lhc_uploadstaging IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD setfilename.
    READ ENTITIES OF /esrcc/i_uploadstaging IN LOCAL MODE
         ENTITY uploadstaging
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(uploaddata)
         " TODO: variable is assigned but never used (ABAP cleaner)
         FAILED FINAL(read_failed).

    ASSIGN uploaddata[ 1 ] TO FIELD-SYMBOL(<uploaddata>).
    IF NOT ( sy-subrc = 0 AND <uploaddata>-temporaryfilename IS INITIAL ).
      RETURN.
    ENDIF.
    <uploaddata>-temporaryfilename = SWITCH #( <uploaddata>-subapplication
                                               WHEN 'FCI' THEN |Forecast Line Items|
                                               WHEN 'FLI' THEN |Cost Base Line Items|
                                               WHEN 'FPD' THEN |Service Capacities|
                                               WHEN 'FAB' THEN |Allocation Base Keys|
                                               WHEN 'FCD' THEN |Service Consumptions|
                                               WHEN 'FRB' THEN |Royal Base Values|
                                               WHEN 'FRL' THEN |RR Line Items|
                                               WHEN 'FBC' THEN <uploaddata>-tablename ).
    <uploaddata>-temporarymimetype = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.
    MODIFY ENTITIES OF /esrcc/i_uploadstaging IN LOCAL MODE
           ENTITY uploadstaging
           UPDATE FIELDS ( temporaryfilename temporarymimetype )
           WITH VALUE #( " UploadUIID = <uploaddata>-UploadUIID
                         (
*                %is_draft   = <uploaddata>-%is_draft
                           %tky              = <uploaddata>-%tky
                           temporaryfilename = <uploaddata>-temporaryfilename
                           temporarymimetype = <uploaddata>-temporarymimetype ) )
               " TODO: variable is assigned but never used (ABAP cleaner)
           REPORTED FINAL(rep)
           " TODO: variable is assigned but never used (ABAP cleaner)
           FAILED FINAL(fa)
           " TODO: variable is assigned but never used (ABAP cleaner)
           MAPPED FINAL(ma).
  ENDMETHOD.

  METHOD uploadfields.
    READ ENTITIES OF /esrcc/i_uploadstaging IN LOCAL MODE
         ENTITY uploadstaging
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT FINAL(uploaddata)
         " TODO: variable is assigned but never used (ABAP cleaner)
         FAILED FINAL(read_failed).

    ASSIGN uploaddata[ 1 ] TO FIELD-SYMBOL(<uploaddata>).
    IF sy-subrc = 0 AND <uploaddata>-filename IS NOT INITIAL AND <uploaddata>-datastream IS NOT INITIAL.
      IF <uploaddata>-subapplication = 'FBC' AND <uploaddata>-tablename IS INITIAL.
      ELSEIF <uploaddata>-subapplication = 'FLI' OR <uploaddata>-subapplication = 'FCI'
          OR <uploaddata>-tablename = '/ESRCC/STWDSPREC' OR <uploaddata>-SubApplication ='FRL'.
        TRY.

            /esrcc/fup_bg_job_srvc=>stream_length = xstrlen( <uploaddata>-datastream ).
            cl_apj_rt_api=>schedule_job(
              EXPORTING
                iv_job_template_name   = CONV cl_apj_rt_api=>ty_template_name( '/ESRCC/FUP_BG_JOB_TEMPL' )
                iv_job_text            = |File Upload of { COND #( WHEN <uploaddata>-subapplication = 'FLI'
                                                                   THEN 'Cost Base Line Items.'
                                                                   WHEN <uploaddata>-SubApplication = 'FCI'
                                                                   THEN 'Forecast Line Items.'
                                                                   WHEN <uploaddata>-SubApplication = 'FRL'
                                                                   THEN 'RR Line Items.'
                                                                   ELSE 'Stewardship Receivers.' ) }|
                is_start_info          = VALUE cl_apj_rt_api=>ty_start_info( start_immediately = abap_true )
                it_job_parameter_value = VALUE cl_apj_rt_api=>tt_job_parameter_value( ( name    = 'SUB_APP'
                                                                                        t_value = VALUE #( sign   = 'I'
                                                                                                           option = 'EQ'
                                                                                                         ( low = <uploaddata>-subapplication ) ) )
                                                                                      ( name    = 'TAB_NAME'
                                                                                        t_value = VALUE #( sign   = 'I'
                                                                                                           option = 'EQ'
                                                                                                         ( low = COND #( WHEN <uploaddata>-subapplication = 'FLI'
                                                                                                                         THEN '/ESRCC/CB_LI'
                                                                                                                         WHEN <uploaddata>-SubApplication = 'FCI'
                                                                                                                         THEN '/ESRCC/FC_LI'
                                                                                                                         WHEN <uploaddata>-SubApplication = 'FRL'
                                                                                                                         THEN '/ESRCC/RR_LI'
                                                                                                                         ELSE <uploaddata>-tablename ) ) ) )
                                                                                      ( name    = 'CREATOR'
                                                                                        t_value = VALUE #( sign   = 'I'
                                                                                                           option = 'EQ'
                                                                                                         ( low = <uploaddata>-createdby ) ) )
                                                                                      ( name    = 'UPLD_ID'
                                                                                        t_value = VALUE #( sign   = 'I'
                                                                                                           option = 'EQ'
                                                                                                         ( low = <uploaddata>-uploaduuid ) ) ) )
*                                                                                      ( name    = 'STREAM'
*                                                                                        t_value = VALUE #( sign   = 'I'
*                                                                                                           option = 'EQ'
*                                                                                                         ( low = <uploaddata>-datastream ) ) ) )
              IMPORTING
                ev_jobname             = DATA(job_name)
                ev_jobcount            = DATA(job_count) ).
          CATCH cx_apj_rt INTO DATA(cx_job_scheduling_error).
            "handle exception
        ENDTRY.
        DATA(status) = CONV /esrcc/upload_status( 'B' ).
      ELSE.
        DATA(uploader) = /esrcc/data_upload=>create( ).

        status = uploader->upload_data(
          application     = 'FUP'
          sub_application = <uploaddata>-subapplication
          table_name      = <uploaddata>-tablename
          created_by      = <uploaddata>-createdby
          upload_uiid     = <uploaddata>-uploaduuid
          datastream      = <uploaddata>-datastream
        ).

      ENDIF.
    ENDIF.

    DATA(log_information) = /esrcc/cl_application_logs=>get_instance(  )->get_log_header_info( ).
    MODIFY ENTITIES OF /esrcc/i_uploadstaging IN LOCAL MODE
           ENTITY uploadstaging
           UPDATE FIELDS ( status Application hid RunNumber )
           WITH VALUE #( ( uploaduuid    = <uploaddata>-uploaduuid
                           status        = status
                           Application   = 'FUP'
                           hid           = log_information-log_header_uuid
                           RunNumber     = log_information-run_number ) ).
  ENDMETHOD.

  METHOD validate_create.
    READ ENTITIES OF /esrcc/i_uploadstaging IN LOCAL MODE
         ENTITY uploadstaging
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT FINAL(uploaddata)
         " TODO: variable is assigned but never used (ABAP cleaner)
         FAILED FINAL(read_failed).

    ASSIGN uploaddata[ 1 ] TO FIELD-SYMBOL(<uploaddata>).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF <uploaddata>-subapplication = 'FBC' AND <uploaddata>-tablename IS INITIAL.
      APPEND VALUE #( %tky = <uploaddata>-%tky
                      %msg = new_message( id       = '/ESRCC/DATA_UPLOAD'
                                          number   = '000'
                                          v1       = <uploaddata>-application
                                          v2       = <uploaddata>-createdby
                                          severity = if_abap_behv_message=>severity-error ) )
             TO reported-uploadstaging.
      APPEND VALUE #( %tky = <uploaddata>-%tky ) TO
                      failed-uploadstaging.
    ELSEIF <uploaddata>-filename IS NOT INITIAL.
      SELECT SINGLE *                         "#EC CI_ALL_FIELDS_NEEDED
        FROM /esrcc/upld_stg
        WHERE application     = @<uploaddata>-application
          AND sub_application = @<uploaddata>-subapplication
        " TODO: variable is assigned but never used (ABAP cleaner)
          AND status          = 'I'
        INTO @FINAL(_currentuploadeddata).
      IF sy-subrc = 0.
        APPEND VALUE #( %tky = <uploaddata>-%tky
                        %msg = new_message( id       = '/ESRCC/DATA_UPLOAD'
                                            number   = '000'
                                            v1       = <uploaddata>-application
                                            v2       = <uploaddata>-createdby
                                            severity = if_abap_behv_message=>severity-error ) )
               TO reported-uploadstaging.
        APPEND VALUE #( %tky = <uploaddata>-%tky ) TO
                        failed-uploadstaging.
      ENDIF.
    ELSEIF <uploaddata>-filename IS INITIAL.
      APPEND VALUE #( %tky = <uploaddata>-%tky
                      %msg = new_message( id       = '/ESRCC/DATA_UPLOAD'
                                          number   = '001'
                                          severity = if_abap_behv_message=>severity-error ) )
             TO reported-uploadstaging.
      APPEND VALUE #( %tky = <uploaddata>-%tky ) TO
                      failed-uploadstaging.
    ELSEIF <uploaddata>-application IS INITIAL OR <uploaddata>-subapplication IS INITIAL.
      APPEND VALUE #( %tky = <uploaddata>-%tky
                      %msg = new_message( id       = '/ESRCC/DATA_UPLOAD'
                                          number   = '002'
                                          severity = if_abap_behv_message=>severity-error ) )
             TO reported-uploadstaging.
      APPEND VALUE #( %tky = <uploaddata>-%tky ) TO
                      failed-uploadstaging.
    ENDIF.
  ENDMETHOD.

  METHOD precheck_create.
    DATA(lo_validation) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'UploadStaging' ) )
        source_entity_name = '/ESRCC/C_UPLOADSTAGING'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-uploadstaging
        failed_entity      = failed-uploadstaging ).

    LOOP AT entities INTO DATA(entity).
      IF entity-subapplication = 'FBC'.
        lo_validation->validate_initial(
          fields = VALUE #( ( fieldname = 'TABLENAME' ) )
          entity = entity
        ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
