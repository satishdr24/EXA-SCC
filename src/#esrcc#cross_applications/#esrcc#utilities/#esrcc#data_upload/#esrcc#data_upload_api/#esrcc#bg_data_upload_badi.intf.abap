INTERFACE /esrcc/bg_data_upload_badi
  PUBLIC.


  INTERFACES if_badi_interface.

  METHODS upload_data IMPORTING table_name      TYPE tabname
                                table_component TYPE cl_abap_structdescr=>component_table
                                logger          TYPE REF TO /esrcc/if_application_logs
                                is_extraction   TYPE abap_boolean DEFAULT abap_false
                      CHANGING  file_data       TYPE data.
ENDINTERFACE.
