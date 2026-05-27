class /ESRCC/CL_BADI_DATA_UPLOAD definition
  public
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /ESRCC/BG_DATA_UPLOAD_BADI .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/CL_BADI_DATA_UPLOAD IMPLEMENTATION.


  METHOD /esrcc/bg_data_upload_badi~upload_data.

    FINAL(upload_handler) = upload_data_to_db_handler=>create( logger ).
    upload_handler->refine_data( table_name       = table_name
                                 table_components = table_component
                                 uploaded_data    = file_data
                                 is_extraction    = is_extraction ).

      IF is_extraction = abap_true.
        file_data = upload_handler->get_refined_data( ).
      ELSE.
        "Updating table in this point applicable only for Excel upload
        upload_handler->update_data_to_db( ).
      ENDIF.

  ENDMETHOD.
ENDCLASS.
