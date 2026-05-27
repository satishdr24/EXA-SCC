CLASS /esrcc/fup_bg_job_srvc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .

    CLASS-DATA:stream_length TYPE int4.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/FUP_BG_JOB_SRVC IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    et_parameter_def = VALUE if_apj_dt_exec_object=>tt_templ_def( (
                                                                    selname        = 'SUB_APP'
                                                                    kind           = if_apj_dt_exec_object=>parameter
                                                                    datatype       = 'C'
                                                                    length         = 3
                                                                    component_type = '/ESRCC/SUB_APPLICATION'
                                                                    section_text   = 'Sub Application'
                                                                    param_text     = 'Sub Application'
                                                                    changeable_ind = abap_true
                                                                    mandatory_ind  = abap_true )
                                                                  ( selname        = 'TAB_NAME'
                                                                    kind           = if_apj_dt_exec_object=>parameter
                                                                    datatype       = 'C'
                                                                    length         = 30
                                                                    component_type = 'TABNAME'
                                                                    section_text   = 'Table Name'
                                                                    param_text     = 'Table Name'
*                                                                    changeable_ind = abap_true
*                                                                    mandatory_ind  = abap_true
                                                                    )
                                                                  ( selname        = 'CREATOR'
                                                                    kind           = if_apj_dt_exec_object=>parameter
                                                                    datatype       = 'C'
                                                                    length         = 12
                                                                    component_type = 'ABP_CREATION_USER'
                                                                    section_text   = 'Created By'
                                                                    param_text     = 'Created By'
                                                                    changeable_ind = abap_true
                                                                    mandatory_ind  = abap_true )
                                                                  ( selname        = 'UPLD_ID'
                                                                    kind           = if_apj_dt_exec_object=>parameter
                                                                    datatype       = 'X'
                                                                    length         = 16
                                                                    component_type = 'SYSUUID_X16'
                                                                    section_text   = 'Upload UUID'
                                                                    param_text     = 'Upload UUID'
                                                                    changeable_ind = abap_true
                                                                    mandatory_ind  = abap_true ) ).
*                                                                  ( selname        = 'STREAM'
*                                                                    kind           = if_apj_dt_exec_object=>parameter
*                                                                    datatype       = 'C'
*                                                                    length         = stream_length
*                                                                    component_type = '/ESRCC/DATA_STREAM'
*                                                                    section_text   = 'Data Stream'
*                                                                    param_text     = 'Data Stream'
*                                                                    changeable_ind = abap_true
*                                                                    mandatory_ind  = abap_true )

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    DATA(sub_application) = VALUE /esrcc/sub_application( it_parameters[ selname = 'SUB_APP' ]-low OPTIONAL ).
    DATA(table_name) = VALUE tabname( it_parameters[ selname = 'TAB_NAME' ]-low OPTIONAL ).
    DATA(created_by) = VALUE abp_creation_user( it_parameters[ selname = 'CREATOR' ]-low OPTIONAL ).
    DATA(upload_uuid) = VALUE sysuuid_x16( it_parameters[ selname = 'UPLD_ID' ]-low OPTIONAL ).
*    DATA(data_stream) = VALUE /esrcc/data_stream( it_parameters[ selname = 'STREAM' ]-low OPTIONAL ).

    SELECT SINGLE FROM /esrcc/upld_stg FIELDS data_stream WHERE upload_uuid = @upload_uuid INTO @DATA(lv_stream).
    DATA(uploader) = /esrcc/data_upload=>create( ).
    DATA(status) = uploader->upload_data(
      application     = 'FUP'
      sub_application = sub_application
      table_name      = table_name
      created_by      = created_by
      upload_uiid     = upload_uuid
      datastream      = lv_stream
    ).

    DATA(log_information) = /esrcc/cl_application_logs=>get_instance(  )->get_log_header_info( ).

    UPDATE /esrcc/upld_stg SET status = @status, run_number = @log_information-run_number WHERE upload_uuid = @upload_uuid.
*    UPDATE /esrcc/upld_stg SET status = @status WHERE upload_uuid = @upload_uuid.
  ENDMETHOD.
ENDCLASS.
