*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
INTERFACE upload_data_to_db.
  METHODS: refine_data IMPORTING table_name        TYPE tabname
                                 table_components  TYPE cl_abap_structdescr=>component_table
                                 uploaded_data     TYPE REF TO data
                                 is_extraction     TYPE abap_boolean DEFAULT abap_false
                       RETURNING VALUE(is_refined) TYPE abap_boolean,

    update_data_to_db,
    get_refined_data RETURNING VALUE(refined_table) TYPE REF TO data.
ENDINTERFACE.


CLASS upload_data_to_db_handler DEFINITION.
  PUBLIC SECTION.
    INTERFACES upload_data_to_db.

    CLASS-METHODS:
      create IMPORTING logger          TYPE REF TO /esrcc/if_application_logs
             RETURNING VALUE(instance) TYPE REF TO upload_data_to_db.

  PRIVATE SECTION.
    CLASS-DATA _application_logger TYPE REF TO /esrcc/if_application_logs.

    TYPES: BEGIN OF _master_data,
             relative_name TYPE string,
             valid_data    TYPE REF TO data,
             field_name    TYPE string,
           END OF _master_data,

           _master_data_list TYPE SORTED TABLE OF _master_data WITH UNIQUE KEY relative_name.

    TYPES: BEGIN OF _line_item,
             ryear       TYPE /esrcc/ryear,
             poper       TYPE poper,
             fplv        TYPE /esrcc/costdataset_de,
             sysid       TYPE /esrcc/sysid,
             legalentity TYPE /esrcc/legalentity,
             ccode       TYPE /esrcc/ccode_de,
             belnr       TYPE /esrcc/doc_no,
             buzei       TYPE /esrcc/buzei,
             costobject  TYPE /esrcc/costobject_de,
             costcenter  TYPE /esrcc/costcenter,
             status      TYPE /esrcc/status_de,
           END OF _line_item,

           _line_items TYPE STANDARD TABLE OF _line_item WITH EMPTY KEY.


    TYPES: BEGIN OF _rr_line_item,
             ryear           TYPE /esrcc/ryear,
             poper           TYPE poper,
             fplv            TYPE /esrcc/costdataset_de,
             sysid           TYPE /esrcc/sysid,
             legalentity     TYPE /esrcc/legalentity,
             ccode           TYPE /esrcc/ccode_de,
             object_type     TYPE /esrcc/rr_object_type,
             object_number   TYPE /esrcc/rr_object_number,
             ledger          TYPE /esrcc/ledger_de,
             belnr           TYPE /esrcc/doc_no,
             buzei           TYPE /esrcc/buzei,
             rr_matter       TYPE /esrcc/rr_matter,
             material        TYPE /esrcc/rr_related_material,
             reference_belnr TYPE /esrcc/ref_doc_no,
             p_system_id     TYPE /esrcc/sysid_partner,
             p_legalentity   TYPE /esrcc/legalentity_partner,
             p_company_code  TYPE /esrcc/ccode_partner,
             p_object_type   TYPE /esrcc/rr_object_type_partner,
             p_object_number TYPE /esrcc/rr_object_number_partne,
           END OF _rr_line_item,

           _rr_line_items TYPE STANDARD TABLE OF _rr_line_item WITH EMPTY KEY.

    TYPES: BEGIN OF _rr_object,
             sysid            TYPE /esrcc/sysid,
             legalentity      TYPE /esrcc/legalentity,
             ccode            TYPE /esrcc/ccode_de,
             object_type      TYPE /esrcc/rr_object_type,
             object_number    TYPE /esrcc/rr_object_number,
             functionalarea   TYPE /esrcc/functional_area,
             profitcenter     TYPE /esrcc/profit_center,
             businessdivision TYPE /esrcc/businessdivision,
             accountingtype   TYPE  /esrcc/rr_accounting_type,
           END OF _rr_object,

           _rr_objects TYPE STANDARD TABLE OF _rr_object WITH EMPTY KEY.

    TYPES: BEGIN OF cost_element_mapping_type,
             sysid            TYPE /esrcc/sysid,
             legalentity      TYPE /esrcc/legalentity,
             ccode            TYPE /esrcc/ccode_de,
             cost_object      TYPE /esrcc/costobject_de,
             cost_center      TYPE /esrcc/costcenter,
             costelement      TYPE /esrcc/costelement,
             costelement_from TYPE /esrcc/costelement,
             costelement_to   TYPE /esrcc/costelement,
             valid_from       TYPE datn,
             costtype         TYPE /esrcc/costtype_de,
             postingtype      TYPE /esrcc/postingtype_de,
             costind          TYPE /esrcc/costind_de,
             usagetype        TYPE /esrcc/usage,
             valid_to         TYPE datn,
             reason_id        TYPE /esrcc/reasonid,
             value_source     TYPE /esrcc/value_source,
           END OF cost_element_mapping_type,

           _cost_elements_mapping_type TYPE STANDARD TABLE OF cost_element_mapping_type WITH EMPTY KEY.

    TYPES: BEGIN OF _cost_object_type,
             sysid             TYPE /esrcc/sysid,
             legalentity       TYPE /esrcc/legalentity,
             company_code      TYPE /esrcc/ccode_de,
             cost_object       TYPE /esrcc/costobject_de,
             cost_center       TYPE /esrcc/costcenter,
             functional_area   TYPE /esrcc/functional_area,
             profit_center     TYPE /esrcc/profit_center,
             business_division TYPE /esrcc/businessdivision,
           END OF _cost_object_type,

           _cost_objects_type TYPE STANDARD TABLE OF _cost_object_type WITH EMPTY KEY.

    TYPES: BEGIN OF _table_fields_description,
             field       TYPE sxco_ad_field_name,
             description TYPE if_xco_dbt_field_content=>tv_short_description,
           END OF _table_fields_description.
    DATA _table_fields_descriptions TYPE SORTED TABLE OF _table_fields_description WITH NON-UNIQUE KEY field.
    DATA _non_initial_fields TYPE RANGE OF sxco_ad_field_name.

    DATA _refined_table            TYPE REF TO data.
    DATA _db_table_reader          TYPE REF TO if_xco_database_table.
    DATA _time_stamp               TYPE timestampl.
    DATA _date                     TYPE datn.
    DATA _time                     TYPE timn.
    DATA _group_configuration      TYPE /esrcc/group.
    DATA _cost_elements_mapping    TYPE _cost_elements_mapping_type.
    DATA _cost_objects_mapping     TYPE _cost_objects_type.
    DATA _master_data_store        TYPE _master_data_list.
    DATA _key_field_list           TYPE sxco_t_ad_field_names.
    DATA _source_cost_data_sign    TYPE /esrcc/sign_for_cogs.
    DATA _all_fields_list          TYPE sxco_t_dbt_fields.
    DATA _valid_rr_objects         TYPE _rr_objects.
    DATA _valid_rr_objects_partner TYPE _rr_objects.
    DATA: BEGIN OF _table_information,
            name       TYPE tabname,
            components TYPE cl_abap_structdescr=>component_table,
          END OF _table_information.
    DATA: _extraction TYPE abap_boolean.
    METHODS _set_table_info IMPORTING table_name       TYPE tabname
                                      table_components TYPE cl_abap_structdescr=>component_table.

    METHODS _prepare_master_data IMPORTING table_data TYPE STANDARD TABLE.
    METHODS _populate_db_table_reader.

    METHODS _validate_row IMPORTING parent_msg_id         TYPE sysuuid_c32
                                    row_data              TYPE any
                          RETURNING VALUE(is_valid_entry) TYPE abap_boolean.

    METHODS _determine_additional_values IMPORTING parent_msg_id        TYPE sysuuid_c32
                                         CHANGING  row_data             TYPE any
                                         RETURNING VALUE(is_successful) TYPE abap_boolean.
ENDCLASS.


CLASS upload_data_to_db_handler IMPLEMENTATION.
  METHOD create.
    instance = NEW upload_data_to_db_handler( ).
    _application_logger = logger.
  ENDMETHOD.

  METHOD upload_data_to_db~get_refined_data.
    refined_table = _refined_table.
  ENDMETHOD.

  METHOD upload_data_to_db~refine_data.
    DATA actual_table TYPE REF TO data.

    FIELD-SYMBOLS <table>        TYPE STANDARD TABLE.
    FIELD-SYMBOLS <actual_table> TYPE STANDARD TABLE.
    CREATE DATA _refined_table TYPE STANDARD TABLE OF (table_name).

    ASSIGN uploaded_data->* TO <table>.
    _extraction = is_extraction.

    "Delete header line only if its excel upload
    IF _extraction = abap_false.
      DELETE <table> INDEX 1.
    ENDIF.

    IF lines( <table> ) = 0.
      " Message: Excel file is empty or not compatible with the table selected.
      _application_logger->add_message( log_message = VALUE #( message_id     = /esrcc/data_upload_util=>message_class
                                                               message_type   = /esrcc/if_const_msg=>error
                                                               message_number = cond #( when _extraction = abap_false then 004 else 041 ) ) ).
      RETURN.

    ENDIF.

    CREATE DATA actual_table TYPE STANDARD TABLE OF (table_name).
    ASSIGN actual_table->* TO <actual_table>.

    <actual_table> = CORRESPONDING #( <table> ).

    IF _extraction = abap_false.
      IF lines( <actual_table> ) = 0.
        " Message: Excel file is empty or not compatible with the table selected.
        _application_logger->add_message( log_message = VALUE #( message_id     = /esrcc/data_upload_util=>message_class
                                                                 message_type   = /esrcc/if_const_msg=>error
                                                                 message_number = 004 ) ).
        RETURN.
      ELSE.
        " ... records read from the source file.
        _application_logger->add_message( log_message = VALUE #( message_id     = /esrcc/data_upload_util=>message_class
                                                                 message_type   = /esrcc/if_const_msg=>success
                                                                 message_number = 031
                                                                 message_v1     = lines( <actual_table> ) ) ).
      ENDIF.
    ENDIF.

    _set_table_info( table_name       = table_name
                     table_components = table_components ).

    _populate_db_table_reader( ).

    _prepare_master_data( <actual_table> ).

    "Data processing start/ Excel Sheet processing start..
    FINAL(worksheet_processing_msg_id) = _application_logger->add_message(
        log_message = VALUE #( message_id     = /esrcc/data_upload_util=>message_class
                               message_type   = /esrcc/if_const_msg=>info
                               message_number = COND #( WHEN _extraction = abap_false THEN 011 ELSE 033 )
                               is_parent      = abap_true ) ).

    ASSIGN _refined_table->* TO <table>.

    LOOP AT <actual_table> ASSIGNING FIELD-SYMBOL(<data_row>).
      IF NOT _validate_row( parent_msg_id = worksheet_processing_msg_id
                            row_data      = <data_row> ).
        CONTINUE.
      ENDIF.

      IF _determine_additional_values( EXPORTING parent_msg_id = worksheet_processing_msg_id
                                       CHANGING  row_data      = <data_row> ).
        APPEND <data_row> TO <table>.
      ENDIF.
    ENDLOOP.

    "Data processing end. / Excel Sheet processing end.
    _application_logger->add_message( log_message = VALUE #( message_id     = /esrcc/data_upload_util=>message_class
                                                             message_type   = /esrcc/if_const_msg=>info
                                                             message_number = COND #( WHEN _extraction = abap_false THEN 012 ELSE 034 ) ) ).
    IF <table> IS ASSIGNED AND lines( <table> ) <> 0.
      is_refined = abap_true.
    ENDIF.

    IF lines( <actual_table> ) <> lines( <table> ).
      IF <table> IS ASSIGNED.
        "&1 out of &2 lines are invalid and not updated.
        _application_logger->add_message( log_message = VALUE #( message_id     = /esrcc/data_upload_util=>message_class
                                                             message_type   = /esrcc/if_const_msg=>warning
                                                             message_number = 032
                                                             message_v1 = lines( <actual_table> ) - lines( <table> )
                                                             message_v2 = lines( <actual_table> ) ) ).

      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD upload_data_to_db~update_data_to_db.
    FIELD-SYMBOLS <refined_table> TYPE STANDARD TABLE.

    IF _refined_table IS NOT BOUND.
      RETURN.
    ENDIF.

    ASSIGN _refined_table->* TO <refined_table>.
    IF <refined_table> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    IF lines( <refined_table> ) = 0.
      RETURN.
    ENDIF.

    MODIFY (_table_information-name) FROM TABLE @<refined_table>.
    IF sy-subrc = 0.
      " Message: Number of records updated.
      FINAL(no_of_records) = sy-dbcnt.
      IF _db_table_reader IS BOUND.
        FINAL(table_technical_name) = _db_table_reader->name.
        FINAL(description) = _db_table_reader->content( )->get_short_description( ).
      ENDIF.
      _application_logger->add_message(
          log_message = VALUE #( message_id     = /esrcc/data_upload_util=>message_class
                                 message_type   = /esrcc/if_const_msg=>info
                                 message_number = 005
                                 message_v1     = no_of_records
                                 message_v2     = |{ description } ({ table_technical_name })| ) ).
    ENDIF.
  ENDMETHOD.

  METHOD _set_table_info.
    _table_information = VALUE #( name       = table_name
                                  components = table_components ).
  ENDMETHOD.

  METHOD _prepare_master_data.
    DATA temp_data_table TYPE REF TO data.
    DATA _finalized_rr_lineitems TYPE _rr_line_items.

    FIELD-SYMBOLS <temp_data_table> TYPE STANDARD TABLE.

    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = _time_stamp
                                                            date       = _date
                                                            time       = _time ).

    IF _table_information-name = '/ESRCC/FC_LI'.
      FINAL(forecasts) = CORRESPONDING _line_items( table_data ).
      SELECT DISTINCT ryear, poper, fplv, sysid, legalentity, ccode, belnr, buzei, costobject, costcenter, status
        FROM /esrcc/fc_li
        FOR ALL ENTRIES IN @forecasts
        WHERE ryear       = @forecasts-ryear
          AND poper       = @forecasts-poper       AND fplv       = @forecasts-fplv       AND sysid = @forecasts-sysid
          AND legalentity = @forecasts-legalentity AND ccode      = @forecasts-ccode      AND belnr = @forecasts-belnr
          AND buzei       = @forecasts-buzei       AND costobject = @forecasts-costobject
          AND costcenter  = @forecasts-costcenter
        INTO TABLE @FINAL(_finalized_forecasts).
      IF sy-subrc = 0.
        DATA(table_handler) = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _finalized_forecasts ) ).
        CREATE DATA temp_data_table TYPE HANDLE table_handler.
        ASSIGN temp_data_table->* TO <temp_data_table>.
        <temp_data_table> = CORRESPONDING #( _finalized_forecasts ).
        INSERT VALUE #( relative_name = '/ESRCC/FC_LI'
                        valid_data    = temp_data_table ) INTO TABLE _master_data_store.
      ENDIF.

      SELECT DISTINCT sysid,
                      legal_entity AS legalentity,
                      company_code AS ccode,
                      cost_object,
                      cost_center,
*                      cost_element AS costelement,
                      costelement_from AS costelement_from,
                      costelement_to AS costelement_to,
                      valid_from,
                      valid_to,
                      cost_type AS costtype,
                      posting_type AS postingtype,
                      cost_indicator AS costind,
                      usage_type AS usagetype,
                      reason_id,
                      value_source
        FROM /esrcc/cstelmtch AS matching
        WHERE workflow_status = 'F' AND active = @abap_true
        INTO CORRESPONDING FIELDS OF TABLE @_cost_elements_mapping. "#EC CI_NOWHERE

      SELECT sysid,                                     "#EC CI_NOWHERE
             legal_entity,
             company_code,
             cost_object,
             cost_center,
             functional_area,
             profit_center,
             business_division
        FROM /esrcc/cst_objct
        INTO TABLE @_cost_objects_mapping.

      _group_configuration = /esrcc/cl_utility_core=>get_group_configuration( ).
    ELSEIF _table_information-name = '/ESRCC/CB_LI'.
      FINAL(cost_bases) = CORRESPONDING _line_items( table_data ).
      SELECT DISTINCT ryear, poper, fplv, sysid, legalentity, ccode, belnr, buzei, costobject, costcenter, status
        FROM /esrcc/cb_li
        FOR ALL ENTRIES IN @cost_bases
        WHERE ryear       = @cost_bases-ryear
          AND poper       = @cost_bases-poper
*          AND fplv        = @cost_bases-fplv
*          AND sysid = @cost_bases-sysid
*          AND legalentity = @cost_bases-legalentity
*          AND ccode      = @cost_bases-ccode
          AND belnr       = @cost_bases-belnr
          AND buzei       = @cost_bases-buzei
*          AND status      NE 'A'
        INTO TABLE @FINAL(_finalized_cost_bases).
      IF sy-subrc = 0.
        table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _finalized_cost_bases ) ).
        CREATE DATA temp_data_table TYPE HANDLE table_handler.
        ASSIGN temp_data_table->* TO <temp_data_table>.
        <temp_data_table> = CORRESPONDING #( _finalized_cost_bases ).
        INSERT VALUE #( relative_name = '/ESRCC/CB_LI'
                        valid_data    = temp_data_table ) INTO TABLE _master_data_store.
      ENDIF.

      SELECT DISTINCT sysid,
                      legal_entity AS legalentity,
                      company_code AS ccode,
                      cost_object,
                      cost_center,
*                      cost_element AS costelement,
                      costelement_from AS costelement_from,
                      costelement_to AS costelement_to,
                      valid_from,
                      valid_to,
                      cost_type AS costtype,
                      posting_type AS postingtype,
                      cost_indicator AS costind,
                      usage_type AS usagetype,
                      reason_id,
                      value_source
        FROM /esrcc/cstelmtch AS matching
        WHERE workflow_status = 'F' AND active = @abap_true
        INTO CORRESPONDING FIELDS OF TABLE @_cost_elements_mapping. "#EC CI_NOWHERE

      SELECT sysid,                                     "#EC CI_NOWHERE
             legal_entity,
             company_code,
             cost_object,
             cost_center,
             functional_area,
             profit_center,
             business_division
        FROM /esrcc/cst_objct
        INTO TABLE @_cost_objects_mapping.

      _group_configuration = /esrcc/cl_utility_core=>get_group_configuration( ).
    ELSEIF _table_information-name = '/ESRCC/RR_LI'.
      FINAL(uploaded_rr_lineitems) = CORRESPONDING _rr_line_items( table_data ).

      " For status check
      SELECT DISTINCT rr_li~ryear,
                      rr_li~poper,
                      rr_li~fplv,
                      rr_li~sysid,
                      rr_li~legalentity,
                      rr_li~ccode,
                      rr_li~object_type,
                      rr_li~object_number,
                      rr_li~ledger,
                      rr_li~belnr,
                      rr_li~buzei,
                      rr_li~rr_matter,
                      rr_li~material
        FROM /esrcc/rr_li AS rr_li
               INNER JOIN
                 @uploaded_rr_lineitems AS uploaded_rr_lineitems ON  rr_li~ryear              = uploaded_rr_lineitems~ryear
                                                                 AND rr_li~poper              = uploaded_rr_lineitems~poper
                                                                 AND rr_li~fplv               = uploaded_rr_lineitems~fplv
                                                                 AND rr_li~sysid              = uploaded_rr_lineitems~sysid
                                                                 AND rr_li~legalentity        = uploaded_rr_lineitems~legalentity
                                                                 AND rr_li~ccode              = uploaded_rr_lineitems~ccode
                                                                 AND rr_li~object_type        = uploaded_rr_lineitems~object_type
                                                                 AND rr_li~object_number      = uploaded_rr_lineitems~object_number
                                                                 AND rr_li~ledger             = uploaded_rr_lineitems~ledger
                                                                 AND rr_li~belnr              = uploaded_rr_lineitems~belnr
                                                                 AND rr_li~buzei              = uploaded_rr_lineitems~buzei
                                                                 AND rr_li~rr_matter          = uploaded_rr_lineitems~rr_matter
                                                                 AND rr_li~material           = uploaded_rr_lineitems~material
                                                                 AND rr_li~status NE 'A' "NOT IN ( 'A' , 'E' )
        INTO CORRESPONDING FIELDS OF TABLE @_finalized_rr_lineitems.
      IF sy-subrc = 0.
        table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _finalized_rr_lineitems ) ).
        CREATE DATA temp_data_table TYPE HANDLE table_handler.
        ASSIGN temp_data_table->* TO <temp_data_table>.
        <temp_data_table> = CORRESPONDING #( _finalized_rr_lineitems ).
        INSERT VALUE #( relative_name = '/ESRCC/RR_LI'
                        valid_data    = temp_data_table ) INTO TABLE _master_data_store.
      ENDIF.

      " RR Objects
      SELECT DISTINCT uploaded_lineitems~sysid,
                      uploaded_lineitems~legalentity,
                      uploaded_lineitems~ccode,
                      uploaded_lineitems~object_type,
                      uploaded_lineitems~object_number,
                      rr_object~functionalarea,
                      rr_object~profitcenter,
                      rr_object~businessdivision
        FROM @uploaded_rr_lineitems AS uploaded_lineitems
               INNER JOIN
                 /esrcc/i_rr_objctpr_f4 AS rr_object ON  uploaded_lineitems~sysid         = rr_object~sysid
                                                     AND uploaded_lineitems~legalentity   = rr_object~legalentity
                                                     AND uploaded_lineitems~ccode         = rr_object~companycode
                                                     AND uploaded_lineitems~object_type   = rr_object~objecttype
                                                     AND uploaded_lineitems~object_number = rr_object~objectnumber
                                                     AND rr_object~activeflag             = @abap_true
        INTO TABLE @_valid_rr_objects.
      IF sy-subrc = 0.
        table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_rr_objects ) ).
        CREATE DATA temp_data_table TYPE HANDLE table_handler.
        ASSIGN temp_data_table->* TO <temp_data_table>.
        <temp_data_table> = CORRESPONDING #( _valid_rr_objects ).
        INSERT VALUE #( relative_name = '/ESRCC/RR_LI_OBJECTS'
                        valid_data    = temp_data_table ) INTO TABLE _master_data_store.
      ENDIF.

      " RR Objects - Partner
      SELECT DISTINCT uploaded_lineitems~p_system_id,
                      uploaded_lineitems~p_legalentity,
                      uploaded_lineitems~p_company_code,
                      uploaded_lineitems~p_object_type,
                      uploaded_lineitems~p_object_number,
                      rr_object~functionalarea,
                      rr_object~profitcenter,
                      rr_object~businessdivision
        FROM @uploaded_rr_lineitems AS uploaded_lineitems
               INNER JOIN
                 /esrcc/i_rr_objctrec_f4 AS rr_object ON  uploaded_lineitems~p_system_id     = rr_object~sysid
                                                      AND uploaded_lineitems~p_legalentity   = rr_object~legalentity
                                                      AND uploaded_lineitems~p_company_code  = rr_object~companycode
                                                      AND uploaded_lineitems~p_object_type   = rr_object~objecttype
                                                      AND uploaded_lineitems~p_object_number = rr_object~objectnumber
                                                      AND rr_object~activeflag               = @abap_true
        INTO TABLE @_valid_rr_objects_partner.

      " RR Object types
      SELECT DISTINCT rr_object_types~object_type
        FROM /esrcc/rr_objtyp AS rr_object_types
        ORDER BY rr_object_types~object_type
        INTO TABLE @FINAL(_valid_rr_object_types).      "#EC CI_NOWHERE
      IF sy-subrc = 0.
        table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_rr_object_types ) ).
        CREATE DATA temp_data_table TYPE HANDLE table_handler.
        ASSIGN temp_data_table->* TO <temp_data_table>.
        <temp_data_table> = CORRESPONDING #( _valid_rr_object_types ).
        INSERT VALUE #( relative_name = '/ESRCC/RR_OBJECT_TYPE'
                        valid_data    = temp_data_table
                        field_name    = |OBJECT_TYPE| ) INTO TABLE _master_data_store.
      ENDIF.

      " RR Matter
      SELECT DISTINCT rr_matter~rr_matter
        FROM /esrcc/rrmatter AS rr_matter
        ORDER BY rr_matter~rr_matter
        INTO TABLE @FINAL(_valid_rr_matter).            "#EC CI_NOWHERE
      IF sy-subrc = 0.
        table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_rr_matter ) ).
        CREATE DATA temp_data_table TYPE HANDLE table_handler.
        ASSIGN temp_data_table->* TO <temp_data_table>.
        <temp_data_table> = CORRESPONDING #( _valid_rr_matter ).
        INSERT VALUE #( relative_name = '/ESRCC/RR_MATTER'
                        valid_data    = temp_data_table
                        field_name    = |RR_MATTER| ) INTO TABLE _master_data_store.
      ENDIF.
      " Functional Area
      SELECT DISTINCT functional_area
        FROM /esrcc/fnc_area
        ORDER BY functional_area
        INTO TABLE @FINAL(_valid_functional_areas).     "#EC CI_NOWHERE
      IF sy-subrc = 0.
        table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_functional_areas ) ).
        CREATE DATA temp_data_table TYPE HANDLE table_handler.
        ASSIGN temp_data_table->* TO <temp_data_table>.
        <temp_data_table> = CORRESPONDING #( _valid_functional_areas ).
        INSERT VALUE #( relative_name = '/ESRCC/FUNCTIONAL_AREA'
                        valid_data    = temp_data_table
                        field_name    = |FUNCTIONAL_AREA| ) INTO TABLE _master_data_store.
      ENDIF.

      " For Initial Check - fields and description
      TRY.
          DATA(db_table_readers) = xco_cp_abap_repository=>objects->tabl->database_tables->where(
                                       VALUE #( ( xco_cp_abap_repository=>object_name->get_filter(
                                                      xco_cp_abap_sql=>constraint->equal( _db_table_reader->name ) ) ) ) )->in(
                                                          xco_cp_abap=>repository )->get( ).
          DATA(db_table_reader) = db_table_readers[ 1 ]->fields->all->get( ).

          LOOP AT db_table_reader ASSIGNING FIELD-SYMBOL(<lfs>).
            _table_fields_descriptions = VALUE #( BASE _table_fields_descriptions
                                                  ( field       = <lfs>->name
                                                    description = <lfs>->content( )->get_short_description( ) ) ).

          ENDLOOP.

        CATCH cx_root INTO DATA(descr_fetch_error).
      ENDTRY.

      " Fields for initial Check
      _non_initial_fields = VALUE #( sign   = 'I'
                                     option = 'EQ'
                                     (  low = 'RYEAR' )
                                     (  low = 'POPER' )
                                     (  low = 'SYSID' )
                                     (  low = 'LEGALENTITY' )
                                     (  low = 'CCODE' )
                                     (  low = 'OBJECT_NUMBER' )
                                     (  low = 'LEDGER' )
                                     (  low = 'BELNR' )
                                     (  low = 'RR_MATTER' )
                                     (  low = 'LOCALCURR' )
*                                     (  low = 'MEINS' )
                                     (  low = 'BSCHL' )
                                     (  low = 'BUDAT' )
                                     (  low = 'PROFITCENTER' )
                                     (  low = 'P_OBJECT_NUMBER' )
                                     (  low = 'DOCUMENT_DATE' ) ).

      _group_configuration = /esrcc/cl_utility_core=>get_group_configuration( ).
    ENDIF.

    " Build the list of key fields
    IF _db_table_reader IS BOUND.
      _key_field_list = _db_table_reader->fields->key->get_names( ).
      _all_fields_list = _db_table_reader->fields->all->get( ).
    ENDIF.

    LOOP AT _table_information-components ASSIGNING FIELD-SYMBOL(<component>).

      FINAL(relative_name) = <component>-type->get_relative_name( ).
      CASE relative_name.
        WHEN '/ESRCC/LEGALENTITY'.
          IF _table_information-name <> '/ESRCC/LE'.
            SELECT legalentity FROM /esrcc/le
              ORDER BY legalentity
              INTO TABLE @FINAL(_valid_legal_entites).  "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_legal_entites ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_legal_entites ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |LEGALENTITY| ) INTO TABLE _master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/COSTCENTER'.
          IF _table_information-name <> '/ESRCC/CST_OBJCT'.
            SELECT DISTINCT cost_center AS costcenter
              FROM /esrcc/cst_objct
              ORDER BY costcenter
              INTO TABLE @FINAL(_valid_cost_centers).   "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_cost_centers ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_cost_centers ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |COSTCENTER| ) INTO TABLE _master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/COSTELEMENT'.
          IF _table_information-name <> '/ESRCC/CSTELEMNT'.
            SELECT DISTINCT cost_element AS costelement
              FROM /esrcc/cstelemnt
              ORDER BY costelement
              INTO TABLE @FINAL(_valid_cost_elements).  "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_cost_elements ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_cost_elements ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |COSTELEMENT| ) INTO TABLE _master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/SYSID'.
          IF _table_information-name <> '/ESRCC/SYS_INFO'.
            SELECT system_id FROM /esrcc/sys_info
              ORDER BY system_id
              INTO TABLE @FINAL(_valid_system_ids).     "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_system_ids ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_system_ids ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |SYSTEM_ID| ) INTO TABLE _master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/CCODE_DE'.
          IF _table_information-name <> '/ESRCC/LE_CCODE'.
            SELECT DISTINCT ccode FROM /esrcc/le_ccode
              ORDER BY ccode
              INTO TABLE @FINAL(_valid_company_codes).  "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_company_codes ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_company_codes ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |CCODE| ) INTO TABLE _master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/BUSINESSDIVISION'.
          IF _table_information-name <> '/ESRCC/BUS_DIV'. " AND field_value IS NOT INITIAL.
            SELECT business_division FROM /esrcc/bus_div
              ORDER BY business_division
              INTO TABLE @FINAL(_valid_business_divisions). "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_business_divisions ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_business_divisions ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |BUSINESS_DIVISION| ) INTO TABLE _master_data_store.
            ENDIF.

          ENDIF.
        WHEN '/ESRCC/PROFIT_CENTER'.
          IF _table_information-name <> '/ESRCC/PFC'. " AND field_value IS NOT INITIAL.
            SELECT profit_center FROM /esrcc/pfc
              ORDER BY profit_center
              INTO TABLE @FINAL(_valid_profit_centers). "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_profit_centers ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_profit_centers ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |PROFIT_CENTER| ) INTO TABLE _master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/SRVPRODUCT'.
          IF _table_information-name <> '/ESRCC/SRVPRO'.
            SELECT serviceproduct FROM /esrcc/srvpro
              ORDER BY serviceproduct
              INTO TABLE @FINAL(_valid_service_products). "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_service_products ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_service_products ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |SERVICEPRODUCT| ) INTO TABLE _master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/SRVTYPE_DE'.
          IF _table_information-name <> '/ESRCC/SRTYPE'.
            SELECT srvtype FROM /esrcc/srtype
              ORDER BY srvtype
              INTO TABLE @FINAL(_valid_service_type).   "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_service_type ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_service_type ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |SRVTYPE| ) INTO TABLE _master_data_store.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/TG'.
          IF _table_information-name <> '/ESRCC/SRVTG'.
            SELECT transactiongroup FROM /esrcc/srvtg
              ORDER BY transactiongroup
              INTO TABLE @FINAL(_valid_transaction_group). "#EC CI_NOWHERE
            IF sy-subrc = 0.
              table_handler = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( _valid_transaction_group ) ).
              CREATE DATA temp_data_table TYPE HANDLE table_handler.
              ASSIGN temp_data_table->* TO <temp_data_table>.
              <temp_data_table> = CORRESPONDING #( _valid_transaction_group ).
              INSERT VALUE #( relative_name = relative_name
                              valid_data    = temp_data_table
                              field_name    = |TRANSACTIONGROUP| ) INTO TABLE _master_data_store.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD _validate_row.
    FIELD-SYMBOLS <finalized_forecasts>    TYPE _line_items.
    FIELD-SYMBOLS <finalized_cost_bases>   TYPE _line_items.
    FIELD-SYMBOLS <finalized_rr_lineitems> TYPE _rr_line_items.
    FIELD-SYMBOLS <valid_rr_objects>       TYPE _rr_objects.
    FIELD-SYMBOLS <valid_value_table>      TYPE STANDARD TABLE.

    DATA(list_of_message_ids) = VALUE /esrcc/if_application_logs=>message_ids_type( ).

    is_valid_entry = abap_true.

    IF _table_information-name = '/ESRCC/FC_LI'.
      FINAL(finalized_forecasts) = VALUE #( _master_data_store[ relative_name = '/ESRCC/FC_LI' ]-valid_data OPTIONAL ).
      ASSIGN finalized_forecasts->* TO <finalized_forecasts>.

      ASSIGN COMPONENT 'RYEAR' OF STRUCTURE row_data TO FIELD-SYMBOL(<ryear>).
      ASSIGN COMPONENT 'POPER' OF STRUCTURE row_data TO FIELD-SYMBOL(<poper>).
      ASSIGN COMPONENT 'FPLV' OF STRUCTURE row_data TO FIELD-SYMBOL(<fplv>).
      ASSIGN COMPONENT 'SYSID' OF STRUCTURE row_data TO FIELD-SYMBOL(<sysid>).
      IF _source_cost_data_sign IS INITIAL.
        SELECT SINGLE FROM /esrcc/sys_info FIELDS sign_for_cogs WHERE system_id = @<sysid> INTO @_source_cost_data_sign.
      ENDIF.
      ASSIGN COMPONENT 'LEGALENTITY' OF STRUCTURE row_data TO FIELD-SYMBOL(<legalentity>).
      ASSIGN COMPONENT 'CCODE' OF STRUCTURE row_data TO FIELD-SYMBOL(<ccode>).
      ASSIGN COMPONENT 'BELNR' OF STRUCTURE row_data TO FIELD-SYMBOL(<belnr>).
      ASSIGN COMPONENT 'BUZEI' OF STRUCTURE row_data TO FIELD-SYMBOL(<buzei>).
      ASSIGN COMPONENT 'COSTOBJECT' OF STRUCTURE row_data TO FIELD-SYMBOL(<costobject>).
      ASSIGN COMPONENT 'COSTCENTER' OF STRUCTURE row_data TO FIELD-SYMBOL(<costcenter>).
      IF     <ryear>       IS ASSIGNED
         AND <poper>       IS ASSIGNED
         AND <fplv>        IS ASSIGNED
         AND <sysid>       IS ASSIGNED
         AND <legalentity> IS ASSIGNED
         AND <ccode>       IS ASSIGNED
         AND <belnr>       IS ASSIGNED
         AND <buzei>       IS ASSIGNED
         AND <costobject>  IS ASSIGNED
         AND <costcenter>  IS ASSIGNED.

        IF <finalized_forecasts> IS ASSIGNED AND line_exists( <finalized_forecasts>[ ryear       = <ryear>
                                                                                     poper       = <poper>
                                                                                     fplv        = <fplv>
                                                                                     sysid       = <sysid>
                                                                                     legalentity = <legalentity>
                                                                                     ccode       = <ccode>
                                                                                     belnr       = <belnr>
                                                                                     buzei       = <buzei>
                                                                                     costobject  = <costobject>
                                                                                     costcenter  = <costcenter>
                                                                                     status      = 'F'  ] ).
          is_valid_entry = abap_false.
          _application_logger->add_message(
              log_message    = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
                                        message_type    = /esrcc/if_const_msg=>error
                                        message_number  = 016
                                        parent_log_uuid = parent_msg_id )
              invalid_record = row_data ).
          RETURN.
        ENDIF.
      ENDIF.

      ASSIGN COMPONENT 'HSL' OF STRUCTURE row_data TO FIELD-SYMBOL(<hsl>).
      IF <hsl> IS ASSIGNED AND ( <hsl> IS INITIAL OR <hsl> = 0 ).
        " Amount in Local Currency is entered as 0.
        DATA(message_id) = _application_logger->add_message(
                               log_message = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
                                                      message_type    = /esrcc/if_const_msg=>warning
                                                      message_number  = 015
                                                      parent_log_uuid = parent_msg_id ) ).
        APPEND message_id TO list_of_message_ids.

      ENDIF.

    ELSEIF _table_information-name = '/ESRCC/CB_LI'.

      FINAL(finalized_cost_bases) = VALUE #( _master_data_store[ relative_name = '/ESRCC/CB_LI' ]-valid_data OPTIONAL ).
      ASSIGN finalized_cost_bases->* TO <finalized_cost_bases>.

      ASSIGN COMPONENT 'RYEAR' OF STRUCTURE row_data TO <ryear>.
      ASSIGN COMPONENT 'POPER' OF STRUCTURE row_data TO <poper>.
      ASSIGN COMPONENT 'FPLV' OF STRUCTURE row_data TO <fplv>.
      ASSIGN COMPONENT 'SYSID' OF STRUCTURE row_data TO <sysid>.
      IF _source_cost_data_sign IS INITIAL.
        SELECT SINGLE FROM /esrcc/sys_info FIELDS sign_for_cogs WHERE system_id = @<sysid> INTO @_source_cost_data_sign.
      ENDIF.
      ASSIGN COMPONENT 'LEGALENTITY' OF STRUCTURE row_data TO <legalentity>.
      ASSIGN COMPONENT 'CCODE' OF STRUCTURE row_data TO <ccode>.
      ASSIGN COMPONENT 'BELNR' OF STRUCTURE row_data TO <belnr>.
      ASSIGN COMPONENT 'BUZEI' OF STRUCTURE row_data TO <buzei>.
      ASSIGN COMPONENT 'COSTOBJECT' OF STRUCTURE row_data TO <costobject>.
      ASSIGN COMPONENT 'COSTCENTER' OF STRUCTURE row_data TO <costcenter>.

      IF     <ryear>       IS ASSIGNED
         AND <poper>       IS ASSIGNED
         AND <fplv>        IS ASSIGNED
         AND <sysid>       IS ASSIGNED
         AND <legalentity> IS ASSIGNED
         AND <ccode>       IS ASSIGNED
         AND <belnr>       IS ASSIGNED
         AND <buzei>       IS ASSIGNED
         AND <costobject>  IS ASSIGNED
         AND <costcenter>  IS ASSIGNED.

        IF <finalized_cost_bases> IS ASSIGNED.
          READ TABLE <finalized_cost_bases> ASSIGNING FIELD-SYMBOL(<finalized_cost_base>) WITH KEY
                                                                                        ryear       = <ryear>
                                                                                        poper       = <poper>
                                                                                         belnr      = <belnr>
                                                                                         buzei      = <buzei>.
          IF sy-subrc = 0.
            IF <finalized_cost_base>-status <> 'A' OR <finalized_cost_base>-costobject <> <costobject>.
*            IF <finalized_cost_bases> IS ASSIGNED AND line_exists( <finalized_cost_bases>[ ryear       = <ryear>
*                                                                                           poper       = <poper>
**                                                                                       fplv        = <fplv>
**                                                                                       sysid       = <sysid>
**                                                                                       legalentity = <legalentity>
**                                                                                       ccode       = <ccode>
*                                                                                           belnr       = <belnr>
*                                                                                           buzei       = <buzei>
*                                                                                            ] ).
              is_valid_entry = abap_false.
              _application_logger->add_message(
                  log_message    = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
                                            message_type    = /esrcc/if_const_msg=>error
                                            message_number  = 016
                                            parent_log_uuid = parent_msg_id )
                  invalid_record = row_data ).
              RETURN.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      ASSIGN COMPONENT 'HSL' OF STRUCTURE row_data TO <hsl>.
      IF <hsl> IS ASSIGNED AND ( <hsl> IS INITIAL OR <hsl> = 0 ).
        " Amount in Local Currency is entered as 0.
        message_id = _application_logger->add_message(
                         log_message = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
                                                message_type    = /esrcc/if_const_msg=>warning
                                                message_number  = 015
                                                parent_log_uuid = parent_msg_id ) ).
        APPEND message_id TO list_of_message_ids.

      ENDIF.
    ELSEIF _table_information-name = '/ESRCC/RR_LI'.

      FINAL(finalized_rr_lineitems) = VALUE #( _master_data_store[ relative_name = '/ESRCC/RR_LI' ]-valid_data OPTIONAL ).
      ASSIGN finalized_rr_lineitems->* TO <finalized_rr_lineitems>.
      FINAL(valid_rr_objects) = VALUE #( _master_data_store[ relative_name = '/ESRCC/RR_LI_OBJECTS' ]-valid_data OPTIONAL ).
      ASSIGN valid_rr_objects->* TO <valid_rr_objects>.

      ASSIGN COMPONENT 'RYEAR' OF STRUCTURE row_data TO <ryear>.
      ASSIGN COMPONENT 'POPER' OF STRUCTURE row_data TO <poper>.
      ASSIGN COMPONENT 'FPLV' OF STRUCTURE row_data TO <fplv>.
      ASSIGN COMPONENT 'SYSID' OF STRUCTURE row_data TO <sysid>.
      ASSIGN COMPONENT 'LEGALENTITY' OF STRUCTURE row_data TO <legalentity>.
      ASSIGN COMPONENT 'CCODE' OF STRUCTURE row_data TO <ccode>.
      ASSIGN COMPONENT 'OBJECT_TYPE' OF STRUCTURE row_data TO FIELD-SYMBOL(<object_type>).
      ASSIGN COMPONENT 'OBJECT_NUMBER' OF STRUCTURE row_data TO FIELD-SYMBOL(<object_number>).
      ASSIGN COMPONENT 'LEDGER ' OF STRUCTURE row_data TO FIELD-SYMBOL(<ledger>).
      ASSIGN COMPONENT 'BELNR' OF STRUCTURE row_data TO <belnr>.
      ASSIGN COMPONENT 'BUZEI' OF STRUCTURE row_data TO <buzei>.
      ASSIGN COMPONENT 'RR_MATTER' OF STRUCTURE row_data TO FIELD-SYMBOL(<rr_matter>).
      ASSIGN COMPONENT 'MATERIAL' OF STRUCTURE row_data TO FIELD-SYMBOL(<material>).
      ASSIGN COMPONENT 'REFERENCE_BELNR' OF STRUCTURE row_data TO FIELD-SYMBOL(<reference_belnr>).
      ASSIGN COMPONENT 'BSCHL' OF STRUCTURE row_data TO FIELD-SYMBOL(<bschl>).
      ASSIGN COMPONENT 'P_OBJECT_NUMBER' OF STRUCTURE row_data TO FIELD-SYMBOL(<p_objnr>).


      " Validating Status: Only A(Available) status should be allowed
      IF     <ryear>           IS ASSIGNED
         AND <poper>           IS ASSIGNED
         AND <fplv>            IS ASSIGNED
         AND <sysid>           IS ASSIGNED
         AND <legalentity>     IS ASSIGNED
         AND <ccode>           IS ASSIGNED
         AND <object_type>     IS ASSIGNED
         AND <object_number>   IS ASSIGNED
         AND <ledger>          IS ASSIGNED
         AND <belnr>           IS ASSIGNED
         AND <buzei>           IS ASSIGNED
         AND <rr_matter>       IS ASSIGNED
         AND <material>        IS ASSIGNED.

        IF <finalized_rr_lineitems> IS ASSIGNED AND line_exists( <finalized_rr_lineitems>[
                                                                     ryear           = <ryear>
                                                                     poper           = <poper>
                                                                     fplv            = <fplv>
                                                                     sysid           = <sysid>
                                                                     legalentity     = <legalentity>
                                                                     ccode           = <ccode>
                                                                     object_type     = <object_type>
                                                                     object_number   = <object_number>
                                                                     ledger          = <ledger>
                                                                     belnr           = <belnr>
                                                                     buzei           = <buzei>
                                                                     rr_matter       = <rr_matter>
                                                                     material        = <material> ] ).
          is_valid_entry = abap_false.
          "Records not updated as the status is not 'Available'.
          _application_logger->add_message(
              log_message    = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
                                        message_type    = /esrcc/if_const_msg=>error
                                        message_number  = 035
                                        parent_log_uuid = parent_msg_id )
              invalid_record = row_data ).
          RETURN.
        ENDIF.

        " Validating posting Key
        IF <bschl> IS ASSIGNED AND <bschl> IS NOT INITIAL.
          IF NOT ( <bschl> = '50' OR <bschl> = '40' ).
            is_valid_entry = abap_false.
            _application_logger->add_message(
                log_message    = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
                                          message_type    = /esrcc/if_const_msg=>error
                                          message_number  = 037
                                          parent_log_uuid = parent_msg_id )
                invalid_record = row_data ).
          ENDIF.
        ENDIF.


        " Validating RR Object
        IF        <valid_rr_objects> IS NOT ASSIGNED
           OR NOT line_exists( <valid_rr_objects>[ sysid         = <sysid>
                                                   legalentity   = <legalentity>
                                                   ccode         = <ccode>
                                                   object_type   = <object_type>
                                                   object_number = <object_number> ] ).
          is_valid_entry = abap_false.
          _application_logger->add_message(
              log_message    = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
                                        message_type    = /esrcc/if_const_msg=>error
                                        message_number  = 028
                                        parent_log_uuid = parent_msg_id )
              invalid_record = row_data ).
        ENDIF.
      ENDIF.

      "   ASSIGN COMPONENT 'HSL' OF STRUCTURE row_data TO <hsl>.
      "   IF <hsl> IS ASSIGNED AND ( <hsl> IS INITIAL OR <hsl> = 0 ).
      "     " Message: Invalid value for &1. Please check configuration or domain values.
      "     message_id = _application_logger->add_message(
      "                      log_message = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
      "                                             message_type    = /esrcc/if_const_msg=>warning
      "                                             message_number  = 015
      "                                             parent_log_uuid = parent_msg_id ) ).
      "     APPEND message_id TO list_of_message_ids.

      "   ENDIF.
    ENDIF.

    LOOP AT _table_information-components ASSIGNING FIELD-SYMBOL(<component>) WHERE name IS NOT INITIAL.

      ASSIGN COMPONENT <component>-name OF STRUCTURE row_data TO FIELD-SYMBOL(<field_value>).
      IF <field_value> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      "To Check if the field is initial
      IF <field_value> IS INITIAL AND <component>-name IN _non_initial_fields AND _non_initial_fields IS NOT INITIAL.
        message_id = _application_logger->add_message(
            log_message = VALUE #(
                message_id      = /esrcc/data_upload_util=>message_class
                message_type    = /esrcc/if_const_msg=>error
                message_number  = 038
                message_v1      = |{ VALUE #( _table_fields_descriptions[ field = <component>-name ]-description OPTIONAL ) }({ <component>-name })|
                parent_log_uuid = parent_msg_id ) ).
        APPEND message_id TO list_of_message_ids.
        is_valid_entry = abap_false.
        CONTINUE.
      ENDIF.

      "To Check if the currency is initial
      IF <component>-name = 'LOCALCURR' AND <field_value> IS INITIAL.
        message_id = _application_logger->add_message(
                         log_message = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
                                                message_type    = /esrcc/if_const_msg=>error
                                                message_number  = 021
                                                parent_log_uuid = parent_msg_id ) ).
        APPEND message_id TO list_of_message_ids.
        CONTINUE.
      ENDIF.

      "To check if the UOM is initial
      IF _table_information-name = '/ESRCC/SRV_CPCTY' AND <component>-name = 'UOM' AND <field_value> IS INITIAL.
        message_id = _application_logger->add_message(
                         log_message = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
                                                message_type    = /esrcc/if_const_msg=>error
                                                message_number  = 023
                                                parent_log_uuid = parent_msg_id ) ).
        APPEND message_id TO list_of_message_ids.
        CONTINUE.
      ENDIF.

      "If its not a key field and value is initial then no need to check further
      IF NOT line_exists( _key_field_list[ table_line = <component>-name ] ) AND <field_value> IS INITIAL.
        CONTINUE.
      ENDIF.

      FINAL(relative_name) = <component>-type->get_relative_name( ).
      FINAL(master_data_store_index) = line_index( _master_data_store[ relative_name = relative_name ] ).

      IF master_data_store_index IS INITIAL.

        IF <field_value> IS INITIAL.
          CONTINUE.
        ENDIF.

        FINAL(fixed_values) = CAST cl_abap_elemdescr( <component>-type )->get_ddic_fixed_values( ).
        IF lines( fixed_values ) = 0.
          CONTINUE.
        ENDIF.

        " Check Domain
        IF NOT line_exists( fixed_values[ low = <field_value> ] ).
          is_valid_entry = abap_false.
          DATA(is_error_domain) = abap_true.
        ENDIF.
      ELSE.

        " Check master data - Configuration
        FINAL(master_data_store) = _master_data_store[ master_data_store_index ].
        ASSIGN master_data_store-valid_data->* TO <valid_value_table>.
        IF NOT line_exists( <valid_value_table>[ (master_data_store-field_name) = <field_value> ] ).
          is_valid_entry = abap_false.
          DATA(is_error_config) = abap_true.
        ENDIF.
      ENDIF.
      IF is_error_config = abap_true OR is_error_domain = abap_true.
        " Invalid value for &1. Please check configuration.
        " Invalid value for &1. Please check domain values.
        FINAL(field_description) = _all_fields_list[
                                       table_line->name = <component>-name ]->content( )->get_short_description( ).
        message_id = _application_logger->add_message(
                         log_message = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
                                                message_type    = /esrcc/if_const_msg=>error
                                                message_number  = COND #( WHEN is_error_config = abap_true THEN 039 ELSE 040 )
                                                message_v1      = |{ field_description } ({ <component>-name })|
                                                parent_log_uuid = parent_msg_id ) ).
        APPEND message_id TO list_of_message_ids.
        CLEAR : is_error_config, is_error_domain.
      ENDIF.
    ENDLOOP.

    DELETE list_of_message_ids WHERE table_line IS INITIAL.
    _application_logger->map_invalid_record_to_messages( invalid_record = row_data
                                                         message_ids    = list_of_message_ids ).
  ENDMETHOD.

  METHOD _determine_additional_values.
    is_successful = abap_true.
    ASSIGN COMPONENT 'CREATED_AT' OF STRUCTURE row_data TO FIELD-SYMBOL(<created_at>).
    ASSIGN COMPONENT 'CREATED_BY' OF STRUCTURE row_data TO FIELD-SYMBOL(<created_by>).
    ASSIGN COMPONENT 'LAST_CHANGED_BY' OF STRUCTURE row_data TO FIELD-SYMBOL(<last_changed_by>).
    ASSIGN COMPONENT 'LAST_CHANGED_AT' OF STRUCTURE row_data TO FIELD-SYMBOL(<last_changed_at>).

    IF <created_at> IS ASSIGNED.
      <created_at> = _time_stamp.
    ENDIF.
    IF <created_by> IS ASSIGNED.
      <created_by> = sy-uname.
    ENDIF.
    IF <last_changed_at> IS ASSIGNED.
      <last_changed_at> = _time_stamp.
    ENDIF.
    IF <last_changed_by> IS ASSIGNED.
      <last_changed_by> = sy-uname.
    ENDIF.

    IF _table_information-name = '/ESRCC/CB_LI' OR _table_information-name = '/ESRCC/FC_LI'.

      ASSIGN COMPONENT 'SYSID' OF STRUCTURE row_data TO FIELD-SYMBOL(<system_id>).
      IF _source_cost_data_sign IS INITIAL.
        SELECT SINGLE FROM /esrcc/sys_info
          FIELDS sign_for_cogs
          WHERE system_id = @<system_id>
          INTO @_source_cost_data_sign.
      ENDIF.
      ASSIGN COMPONENT 'RYEAR' OF STRUCTURE row_data TO FIELD-SYMBOL(<ryear>).
      ASSIGN COMPONENT 'POPER' OF STRUCTURE row_data TO FIELD-SYMBOL(<poper>).
      ASSIGN COMPONENT 'LEGALENTITY' OF STRUCTURE row_data TO FIELD-SYMBOL(<legal_entity>).
      ASSIGN COMPONENT 'CCODE' OF STRUCTURE row_data TO FIELD-SYMBOL(<company_code>).
      ASSIGN COMPONENT 'COSTOBJECT' OF STRUCTURE row_data TO FIELD-SYMBOL(<cost_object>).
      ASSIGN COMPONENT 'COSTCENTER' OF STRUCTURE row_data TO FIELD-SYMBOL(<cost_center>).
      ASSIGN COMPONENT 'COSTELEMENT' OF STRUCTURE row_data TO FIELD-SYMBOL(<cost_element>).

      IF    <system_id>    IS NOT ASSIGNED OR <system_id>    IS INITIAL
         OR <ryear>        IS NOT ASSIGNED OR <ryear>        IS INITIAL
         OR <poper>        IS NOT ASSIGNED OR <poper>        IS INITIAL
         OR <legal_entity> IS NOT ASSIGNED OR <legal_entity> IS INITIAL
         OR <company_code> IS NOT ASSIGNED OR <company_code> IS INITIAL
         OR <cost_object>  IS NOT ASSIGNED OR <cost_object>  IS INITIAL
         OR <cost_center>  IS NOT ASSIGNED OR <cost_center>  IS INITIAL
         OR <cost_element> IS NOT ASSIGNED OR <cost_element> IS INITIAL.
        RETURN.
      ENDIF.

      SELECT SINGLE * FROM @_cost_objects_mapping AS objects
        WHERE sysid        = @<system_id>    AND legalentity = @<legal_entity>
          AND company_code = @<company_code> AND cost_object = @<cost_object> AND cost_center = @<cost_center>
        INTO @FINAL(cost_object_mapping).
      IF sy-subrc = 0.
        ASSIGN COMPONENT 'FUNCTIONALAREA' OF STRUCTURE row_data TO FIELD-SYMBOL(<functional_area>).
        IF <functional_area> IS ASSIGNED.
          <functional_area> = cost_object_mapping-functional_area.
          UNASSIGN <functional_area>.
        ENDIF.

        ASSIGN COMPONENT 'BUSINESSDIVISION' OF STRUCTURE row_data TO FIELD-SYMBOL(<business_division>).
        IF <business_division> IS ASSIGNED.
          <business_division> = cost_object_mapping-business_division.
          UNASSIGN <business_division>.
        ENDIF.

        ASSIGN COMPONENT 'PROFITCENTER' OF STRUCTURE row_data TO FIELD-SYMBOL(<profit_center>).
        IF <profit_center> IS ASSIGNED.
          <profit_center> = cost_object_mapping-profit_center.
          UNASSIGN <profit_center>.
        ENDIF.
      ELSE.
        is_successful = abap_false.
        _application_logger->add_message(
            log_message    = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
                                      message_type    = /esrcc/if_const_msg=>error
                                      message_number  = 025
                                      parent_log_uuid = parent_msg_id )
            invalid_record = row_data ).
      ENDIF.

      FINAL(valid_on) = |{ <ryear> }{ <poper>+1 }01|.
      SELECT SINGLE * FROM @_cost_elements_mapping AS mapping
        WHERE sysid        = @<system_id>
          AND legalentity  = @<legal_entity> AND ccode = @<company_code> AND cost_object = @<cost_object> AND cost_center = @<cost_center>
          AND ( costelement_from  <= @<cost_element>
          AND costelement_to    >= @<cost_element> )
          AND valid_from  <= @valid_on
          AND valid_to    >= @valid_on
          INTO @DATA(mapping_information).
      IF sy-subrc <> 0.
        SELECT SINGLE * FROM @_cost_elements_mapping AS mapping
         WHERE sysid        = @<system_id>
           AND ( legalentity  = @<legal_entity> AND ccode = @<company_code> AND cost_object = @<cost_object> AND cost_center IS INITIAL )
           AND ( costelement_from  <= @<cost_element>
           AND costelement_to    >= @<cost_element> )
           AND valid_from  <= @valid_on
           AND valid_to    >= @valid_on
           INTO @mapping_information.
        IF sy-subrc <> 0.
          SELECT SINGLE * FROM @_cost_elements_mapping AS mapping
           WHERE sysid        = @<system_id>
             AND ( legalentity  = @<legal_entity> AND ccode = @<company_code> AND cost_object IS INITIAL AND cost_center IS INITIAL )
             AND ( costelement_from  <= @<cost_element>
             AND costelement_to    >= @<cost_element> )
             AND valid_from  <= @valid_on
             AND valid_to    >= @valid_on
             INTO @mapping_information.

          IF sy-subrc <> 0.
            SELECT SINGLE * FROM @_cost_elements_mapping AS mapping
            WHERE sysid        = @<system_id>
            AND ( legalentity IS INITIAL AND ccode IS INITIAL AND cost_object IS INITIAL AND cost_center IS INITIAL )
            AND costelement_from  <= @<cost_element>
            AND costelement_to    >= @<cost_element>
            AND valid_from  <= @valid_on
            AND valid_to    >= @valid_on
            INTO @mapping_information.
          ENDIF.
        ENDIF.
      ENDIF.

      IF mapping_information IS NOT INITIAL.
        ASSIGN COMPONENT 'COSTTYPE' OF STRUCTURE row_data TO FIELD-SYMBOL(<cost_type>).
        IF <cost_type> IS ASSIGNED.
          <cost_type> = mapping_information-costtype.
        ENDIF.
        ASSIGN COMPONENT 'COSTIND' OF STRUCTURE row_data TO FIELD-SYMBOL(<cost_indicator>).
        IF <cost_indicator> IS ASSIGNED.
          <cost_indicator> = mapping_information-costind.
        ENDIF.
        ASSIGN COMPONENT 'USAGECAL' OF STRUCTURE row_data TO FIELD-SYMBOL(<usage_type>).
        IF <usage_type> IS ASSIGNED.
          <usage_type> = COND #( WHEN mapping_information-usagetype IS INITIAL
                                 THEN 'I'
                                 ELSE mapping_information-usagetype ).
        ENDIF.
        ASSIGN COMPONENT 'REASONID' OF STRUCTURE row_data TO FIELD-SYMBOL(<reason_id>).
        IF <reason_id> IS ASSIGNED.
          <reason_id> = mapping_information-reason_id.
          UNASSIGN <reason_id>.
        ENDIF.

        ASSIGN COMPONENT 'VALUE_SOURCE' OF STRUCTURE row_data TO FIELD-SYMBOL(<value_source>).
        IF <value_source> IS ASSIGNED.
          <value_source> = 'UPL'. " mapping_information-value_source.
          UNASSIGN <value_source>.
        ENDIF.
      ELSE.
        is_successful = abap_false.
        _application_logger->add_message(
            log_message    = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
                                      message_type    = /esrcc/if_const_msg=>error
                                      message_number  = 017
                                      parent_log_uuid = parent_msg_id )
            invalid_record = row_data ).
      ENDIF.

      ASSIGN COMPONENT 'STATUS' OF STRUCTURE row_data TO FIELD-SYMBOL(<status>).
      IF <status> IS ASSIGNED.
        <status> = 'A'.
      ENDIF.

      ASSIGN COMPONENT 'HSL' OF STRUCTURE row_data TO FIELD-SYMBOL(<local_amount>).
      IF <local_amount> IS ASSIGNED.
        <local_amount> = COND /esrcc/hsl( WHEN _source_cost_data_sign = _group_configuration-cost_sign
                                          THEN <local_amount>
                                          ELSE <local_amount> * -1 ).
        ASSIGN COMPONENT 'LOCALCURR' OF STRUCTURE row_data TO FIELD-SYMBOL(<local_currency>).
        IF <local_currency> IS NOT INITIAL. " AND from_extraction = abap_false.
          /esrcc/cl_utility_core=>curr_external_to_internal( EXPORTING currency        = <local_currency>
                                                                       amount_external = <local_amount>
                                                             IMPORTING amount_internal = <local_amount> ).
        ENDIF.

        ASSIGN COMPONENT 'POSTINGTYPE' OF STRUCTURE row_data TO FIELD-SYMBOL(<posting_type>).
        IF <posting_type> IS NOT ASSIGNED OR <local_amount> IS NOT ASSIGNED.
          RETURN.
        ENDIF.

        <posting_type> = COND /esrcc/postingtype_de( WHEN _group_configuration-cost_sign = '+'
                                                     THEN COND #( WHEN <local_amount> < 0 THEN |INCOME| ELSE |EXPENSE| )
                                                     ELSE COND #( WHEN <local_amount> < 0 THEN |EXPENSE| ELSE |INCOME| ) ).

        ASSIGN COMPONENT 'KSL' OF STRUCTURE row_data TO FIELD-SYMBOL(<group_amount>).
        IF <group_amount> IS NOT ASSIGNED.
          RETURN.
        ENDIF.

        ASSIGN COMPONENT 'GROUPCURR' OF STRUCTURE row_data TO FIELD-SYMBOL(<group_currency>).
        IF <group_currency> IS ASSIGNED.
          <group_currency> = _group_configuration-group_currency.
        ENDIF.

        IF <local_amount> = 0.
          RETURN.
        ENDIF.

        FINAL(last_date) = /esrcc/cl_utility_core=>get_last_day_of_month( date = |{ <ryear> }{ <poper>+1 }01| ).

        TRY.
            cl_exchange_rates=>convert_to_foreign_currency(
              EXPORTING date             = last_date
                        foreign_currency = _group_configuration-group_currency
                        local_amount     = <local_amount>
                        local_currency   = <local_currency>
              IMPORTING foreign_amount   = <group_amount> ).
          CATCH cx_exchange_rates INTO FINAL(ex_exchange_rates).
            " handle exception
            " TODO: variable is assigned but never used (ABAP cleaner)
            FINAL(text) = ex_exchange_rates->get_text( ).
        ENDTRY.
      ENDIF.

    ELSEIF _table_information-name = '/ESRCC/RR_LI'.

      ASSIGN COMPONENT 'RYEAR' OF STRUCTURE row_data TO <ryear>.
      ASSIGN COMPONENT 'POPER' OF STRUCTURE row_data TO <poper>.

      ASSIGN COMPONENT 'SYSID' OF STRUCTURE row_data TO <system_id>.
      ASSIGN COMPONENT 'LEGALENTITY' OF STRUCTURE row_data TO <legal_entity>.
      ASSIGN COMPONENT 'CCODE' OF STRUCTURE row_data TO <company_code>.
      ASSIGN COMPONENT 'OBJECT_TYPE' OF STRUCTURE row_data TO FIELD-SYMBOL(<object_type>).
      ASSIGN COMPONENT 'OBJECT_NUMBER' OF STRUCTURE row_data TO FIELD-SYMBOL(<object_number>).

      ASSIGN COMPONENT 'P_SYSTEM_ID' OF STRUCTURE row_data TO FIELD-SYMBOL(<p_system_id>).
      ASSIGN COMPONENT 'P_LEGALENTITY' OF STRUCTURE row_data TO FIELD-SYMBOL(<p_legal_entity>).
      ASSIGN COMPONENT 'P_COMPANY_CODE' OF STRUCTURE row_data TO FIELD-SYMBOL(<p_company_code>).
      ASSIGN COMPONENT 'P_OBJECT_TYPE' OF STRUCTURE row_data TO FIELD-SYMBOL(<p_object_type>).
      ASSIGN COMPONENT 'P_OBJECT_NUMBER' OF STRUCTURE row_data TO FIELD-SYMBOL(<p_object_number>).

      IF    <system_id>     IS NOT ASSIGNED OR <system_id>     IS INITIAL
         OR <ryear>         IS NOT ASSIGNED OR <ryear>         IS INITIAL
         OR <poper>         IS NOT ASSIGNED OR <poper>         IS INITIAL
         OR <legal_entity>  IS NOT ASSIGNED OR <legal_entity>  IS INITIAL
         OR <company_code>  IS NOT ASSIGNED OR <company_code>  IS INITIAL
         OR <object_type>   IS NOT ASSIGNED OR <object_type>   IS INITIAL
         OR <object_number> IS NOT ASSIGNED OR <object_number> IS INITIAL.
        RETURN.
      ENDIF.

      SELECT SINGLE * FROM @_valid_rr_objects AS objects
        WHERE sysid = @<system_id>    AND legalentity = @<legal_entity>
          AND ccode = @<company_code> AND object_type = @<object_type> AND object_number = @<object_number>
        INTO @FINAL(rr_object_mapping).
      IF sy-subrc = 0.
        ASSIGN COMPONENT 'FUNCTIONALAREA' OF STRUCTURE row_data TO <functional_area>.
        IF <functional_area> IS ASSIGNED AND <functional_area> IS INITIAL.
          <functional_area> = rr_object_mapping-functionalarea.
          UNASSIGN <functional_area>.
        ENDIF.

        ASSIGN COMPONENT 'BUSINESSDIVISION' OF STRUCTURE row_data TO <business_division>.
        IF <business_division> IS ASSIGNED AND <business_division> IS INITIAL.
          <business_division> = rr_object_mapping-businessdivision.
          UNASSIGN <business_division>.
        ENDIF.

        ASSIGN COMPONENT 'PROFITCENTER' OF STRUCTURE row_data TO <profit_center>.
        IF <profit_center> IS ASSIGNED AND <profit_center> IS INITIAL.
          <profit_center> = rr_object_mapping-profitcenter.
          UNASSIGN <profit_center>.
        ENDIF.

      ELSE.
*        is_successful = abap_false.
*        _application_logger->add_message(
*            log_message    = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
*                                      message_type    = /esrcc/if_const_msg=>error
*                                      message_number  = 029
*                                      parent_log_uuid = parent_msg_id )
*            invalid_record = row_data ).
      ENDIF.

      SELECT SINGLE * FROM @_valid_rr_objects_partner AS objects
        WHERE sysid = @<p_system_id>    AND legalentity = @<p_legal_entity>
          AND ccode = @<p_company_code> AND object_type = @<p_object_type> AND object_number = @<p_object_number>
        INTO @FINAL(rr_p_object_mapping).
      IF sy-subrc = 0.
        ASSIGN COMPONENT 'P_FUNCTIONALAREA' OF STRUCTURE row_data TO <functional_area>.
        IF <functional_area> IS ASSIGNED AND <functional_area> IS INITIAL.
          <functional_area> = rr_p_object_mapping-functionalarea.
          UNASSIGN <functional_area>.
        ENDIF.

        ASSIGN COMPONENT 'P_BUSINESSDIVISION' OF STRUCTURE row_data TO <business_division>.
        IF <business_division> IS ASSIGNED AND <business_division> IS INITIAL.
          <business_division> = rr_p_object_mapping-businessdivision.
          UNASSIGN <business_division>.
        ENDIF.

        ASSIGN COMPONENT 'P_PROFIT_CENTER' OF STRUCTURE row_data TO <profit_center>.
        IF <profit_center> IS ASSIGNED AND <profit_center> IS INITIAL.
          <profit_center> = rr_p_object_mapping-profitcenter.
          UNASSIGN <profit_center>.
        ENDIF.

        ASSIGN COMPONENT 'P_ACCOUNTING_TYPE' OF STRUCTURE row_data TO FIELD-SYMBOL(<acct_type>).
        IF <acct_type> IS ASSIGNED.
          <acct_type> = rr_p_object_mapping-accountingtype.
          UNASSIGN <acct_type>.
        ENDIF.
      ELSE.
*        is_successful = abap_false.
*        _application_logger->add_message(
*            log_message    = VALUE #( message_id      = /esrcc/data_upload_util=>message_class
*                                      message_type    = /esrcc/if_const_msg=>error
*                                      message_number  = 029
*                                      parent_log_uuid = parent_msg_id )
*            invalid_record = row_data ).
      ENDIF.

      ASSIGN COMPONENT 'STATUS' OF STRUCTURE row_data TO <status>.
      IF <status> IS ASSIGNED.
        <status> = 'A'.
        UNASSIGN <status>.
      ENDIF.

      ASSIGN COMPONENT 'DATA_SOURCE' OF STRUCTURE row_data TO <value_source>.
      IF <value_source> IS ASSIGNED.
        <value_source> = 'UPL'. " mapping_information-value_source.
        UNASSIGN <value_source>.
      ENDIF.

      ASSIGN COMPONENT 'HSL' OF STRUCTURE row_data TO <local_amount>.
      IF <local_amount> IS ASSIGNED.
        ASSIGN COMPONENT 'LOCALCURR' OF STRUCTURE row_data TO <local_currency>.
        IF <local_currency> IS ASSIGNED.
          IF <local_currency> IS NOT INITIAL.
            /esrcc/cl_utility_core=>curr_external_to_internal( EXPORTING currency        = <local_currency>
                                                                         amount_external = <local_amount>
                                                               IMPORTING amount_internal = <local_amount> ).
          ENDIF.
        ENDIF.

        ASSIGN COMPONENT 'KSL' OF STRUCTURE row_data TO <group_amount>.
        IF <group_amount> IS NOT ASSIGNED.
          RETURN.
        ENDIF.

        ASSIGN COMPONENT 'GROUPCURR' OF STRUCTURE row_data TO <group_currency>.
        IF <group_currency> IS ASSIGNED.
          <group_currency> = _group_configuration-group_currency.
        ENDIF.

        IF <local_amount> = 0.
          RETURN.
        ENDIF.

        FINAL(last_day_of_month) = /esrcc/cl_utility_core=>get_last_day_of_month( date = |{ <ryear> }{ <poper>+1 }01| ).

        TRY.
            cl_exchange_rates=>convert_to_foreign_currency(
              EXPORTING date             = last_day_of_month
                        foreign_currency = _group_configuration-group_currency
                        local_amount     = <local_amount>
                        local_currency   = <local_currency>
              IMPORTING foreign_amount   = <group_amount> ).
          CATCH cx_exchange_rates INTO FINAL(lref_exchange_rates).
            " handle exception
            " TODO: variable is assigned but never used (ABAP cleaner)
            FINAL(text1) = lref_exchange_rates->get_text( ).
        ENDTRY.
      ENDIF.

    ENDIF.
  ENDMETHOD.

  METHOD _populate_db_table_reader.
    IF _table_information-name IS INITIAL.
      RETURN.
    ENDIF.

    DATA(db_table_readers) = xco_cp_abap_repository=>objects->tabl->database_tables->where(
                                 VALUE #( ( xco_cp_abap_repository=>object_name->get_filter(
                                                xco_cp_abap_sql=>constraint->equal( _table_information-name ) ) ) ) )->in(
                                                    xco_cp_abap=>repository )->get( ).

    IF lines( db_table_readers ) > 0.
      _db_table_reader = db_table_readers[ 1 ].
    ENDIF.
  ENDMETHOD.
ENDCLASS.
