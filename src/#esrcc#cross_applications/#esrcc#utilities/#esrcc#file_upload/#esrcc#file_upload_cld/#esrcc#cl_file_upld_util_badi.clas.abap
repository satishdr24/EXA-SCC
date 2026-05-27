CLASS /esrcc/cl_file_upld_util_badi DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_badi_interface.
    INTERFACES /esrcc/if_file_upld_util_badi.

  PRIVATE SECTION.
  CONSTANTS: gc_object_type TYPE /esrcc/rr_object_type VALUE 'GL',
             gc_pobject_type TYPE /esrcc/rr_object_type VALUE 'BP',
             gc_fplv        TYPE /esrcc/costdataset_de VALUE 'ACOS'.
    TYPES:
      BEGIN OF cost_element_mapping_type,
        sysid            TYPE /esrcc/sysid,
        legalentity      TYPE /esrcc/legalentity,
        ccode            TYPE /esrcc/ccode_de,
        costobject       TYPE /esrcc/costobject_de,
        costcenter       TYPE /esrcc/costcenter,
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
      END OF cost_element_mapping_type.
    TYPES:
      cost_elements_mapping_type TYPE STANDARD TABLE OF cost_element_mapping_type WITH EMPTY KEY.
    TYPES:
      BEGIN OF cost_object_type,
        sysid             TYPE /esrcc/sysid,
        legalentity       TYPE /esrcc/legalentity,
        company_code      TYPE /esrcc/ccode_de,
        cost_object       TYPE /esrcc/costobject_de,
        cost_center       TYPE /esrcc/costcenter,
        functional_area   TYPE /esrcc/functional_area,
        profit_center     TYPE /esrcc/profit_center,
        business_division TYPE /esrcc/businessdivision,
      END OF cost_object_type.
    TYPES:
      cost_objects_type TYPE STANDARD TABLE OF cost_object_type WITH EMPTY KEY.
    TYPES:
      BEGIN OF _cost_object_format_type,
        host_object_type   TYPE /esrcc/costobject_de,
        source_object_type TYPE /esrcc/costobject_de,
      END OF _cost_object_format_type.
    TYPES:
      _cost_object_formats_type TYPE STANDARD TABLE OF _cost_object_format_type WITH EMPTY KEY.
    TYPES:
      BEGIN OF rr_object_type,
        sysid             TYPE /esrcc/sysid,
        legalentity       TYPE /esrcc/legalentity,
        company_code      TYPE /esrcc/ccode_de,
        object_type       TYPE /esrcc/rr_object_type,
        object_number     TYPE /esrcc/rr_object_number,
        functional_area   TYPE /esrcc/functional_area,
        profit_center     TYPE /esrcc/profit_center,
        business_division TYPE /esrcc/businessdivision,
      END OF rr_object_type.
    TYPES:
      rr_objects_type TYPE STANDARD TABLE OF rr_object_type WITH EMPTY KEY.

    TYPES:
      BEGIN OF rr_partner_data_type,
        sysid             TYPE /esrcc/sysid,
        legalentity       TYPE /esrcc/legalentity,
        company_code      TYPE /esrcc/ccode_de,
        object_type       TYPE /esrcc/rr_object_type,
        object_number     TYPE /esrcc/rr_object_number,
        psystem_id        TYPE /esrcc/sysid_partner,
        plegalentity      TYPE /esrcc/legalentity_partner,
        pcompany_code     TYPE /esrcc/ccode_partner,
        pobject_type      TYPE /esrcc/rr_object_type_partner,
        pobject_number    TYPE /esrcc/rr_object_number_partne,
        paccounting_type  TYPE /esrcc/rr_accounting_type,
        pbusinessdivision TYPE /esrcc/businessdivision,
        pprofit_center    TYPE /esrcc/profit_center,
        pfunctionalarea   TYPE /esrcc/functional_area,
        valid_from        TYPE datn,
        valid_to          TYPE datn,
      END OF rr_partner_data_type.
    TYPES:
      rr_partners_data_type TYPE STANDARD TABLE OF rr_partner_data_type WITH EMPTY KEY.

    TYPES:
      BEGIN OF rr_accounting_type,
        object_type     TYPE /esrcc/rr_object_type,
        accounting_type TYPE /esrcc/rr_acc_type,
      END OF rr_accounting_type.
    TYPES:
    rr_accounting_data_type TYPE STANDARD TABLE OF rr_accounting_type WITH EMPTY KEY.

    DATA _cost_elements_mapping TYPE cost_elements_mapping_type.
    DATA _cost_objects          TYPE cost_objects_type.
    DATA _group_configuration   TYPE /esrcc/group.
    DATA _source_cost_data_sign TYPE /esrcc/sign_for_cogs.
    DATA _user_decimal_format   TYPE xsdboolean.
    DATA _object_types          TYPE _cost_object_formats_type.
    DATA:
      _legal_entity_data TYPE STANDARD TABLE OF /esrcc/le_ccode WITH EMPTY KEY.
    DATA _rr_objects      TYPE rr_objects_type.
    DATA _rr_partner_data TYPE rr_partners_data_type.
    DATA _rr_accounting_type TYPE  rr_accounting_data_type.

    METHODS _fetch_rr_partner_data
      RETURNING VALUE(_result) TYPE rr_partners_data_type.
    METHODS _fetch_rr_object
      RETURNING VALUE(_result) TYPE rr_objects_type.
    METHODS _rr_lineitems_mapping
      IMPORTING from_extraction TYPE xsdboolean
      CHANGING  data_structure  TYPE any.
    METHODS _costs_elements_mapping
      IMPORTING from_extraction TYPE xsdboolean
      CHANGING  data_structure  TYPE any.
    METHODS _convert_date_to_internal
      IMPORTING date_format    TYPE xsdboolean
      CHANGING  !value         TYPE any
      RETURNING VALUE(message) TYPE string.
    METHODS _convert_local_to_group_amount
      IMPORTING year                 TYPE /esrcc/ryear
                !period              TYPE poper
                local_amount         TYPE /esrcc/hsl
                local_currency       TYPE /esrcc/localcurr
                group_currency       TYPE /esrcc/groupcurr
                conversion_rate_type TYPE /esrcc/conversion_rate_type
      RETURNING VALUE(amount)        TYPE /esrcc/ksl.
    METHODS _fetch_from_db
      RETURNING VALUE(_result) TYPE cost_elements_mapping_type.
    METHODS _fetch_cost_object
      RETURNING VALUE(_result) TYPE cost_objects_type.
ENDCLASS.



CLASS /ESRCC/CL_FILE_UPLD_UTIL_BADI IMPLEMENTATION.


  METHOD /esrcc/if_file_upld_util_badi~convert_standard_data_type.
*    message = SWITCH #( component-type->type_kind
*                     WHEN 'D' THEN _convert_date_to_internal( EXPORTING date_format = date_format CHANGING value = cell_value ) ).
  ENDMETHOD.


  METHOD /esrcc/if_file_upld_util_badi~determine_business_field.
    IF table_name = '/ESRCC/CB_LI_TMP'.
      _costs_elements_mapping( EXPORTING from_extraction = from_extraction
                               CHANGING  data_structure  = change_structure ).
    ELSEIF table_name = '/ESRCC/RR_LI_TMP'.
      _rr_lineitems_mapping( EXPORTING from_extraction = from_extraction
                             CHANGING  data_structure  = change_structure ).
    ENDIF.
  ENDMETHOD.


  METHOD /esrcc/if_file_upld_util_badi~validate_business_field.
    is_validated = abap_true.

    ASSIGN COMPONENT 'SYSID' OF STRUCTURE data_structure TO FIELD-SYMBOL(<system_id>).
    ASSIGN COMPONENT 'LEGALENTITY' OF STRUCTURE data_structure TO FIELD-SYMBOL(<legal_entity>).
    ASSIGN COMPONENT 'CCODE' OF STRUCTURE data_structure TO FIELD-SYMBOL(<ccode>).
    ASSIGN COMPONENT 'COSTOBJECT' OF STRUCTURE data_structure TO FIELD-SYMBOL(<cost_object>).

    " TODO: variable is assigned but never used (ABAP cleaner)
    ASSIGN COMPONENT 'COSTCENTER' OF STRUCTURE data_structure TO FIELD-SYMBOL(<cost_center>).
    " TODO: variable is assigned but never used (ABAP cleaner)
    ASSIGN COMPONENT 'COSTELEMENT' OF STRUCTURE data_structure TO FIELD-SYMBOL(<cost_element>).
*    ASSIGN COMPONENT 'RYEAR' OF STRUCTURE data_structure TO FIELD-SYMBOL(<reporting_year>).
*    ASSIGN COMPONENT 'POPER' OF STRUCTURE data_structure TO FIELD-SYMBOL(<poper>).
    " TODO: variable is assigned but never used (ABAP cleaner)
    FINAL(relative_name) = component-type->get_relative_name( ).

    IF field_value IS NOT INITIAL.
      CASE component-type->get_relative_name( ).
        WHEN '/ESRCC/LEGALENTITY'.
          IF table_name <> '/ESRCC/LE'.
            FINAL(legal_entity) = CONV /esrcc/legalentity( field_value ).
            SELECT SINGLE 'X' FROM /esrcc/le WHERE LegalEntity = @legal_entity INTO @is_validated.
            IF sy-subrc <> 0.
              CLEAR is_validated.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/COSTCENTER'.
          IF table_name <> '/ESRCC/CST_OBJCT'.
            FINAL(cost_center) = CONV /esrcc/costcenter( field_value ).
            SELECT SINGLE 'X' FROM /esrcc/cst_objct
              WHERE sysid = @<system_id> AND legal_entity = @<legal_entity> AND company_code = @<ccode> AND cost_object = @<cost_object> AND cost_center = @cost_center
              INTO @is_validated.
            IF sy-subrc <> 0.
              CLEAR is_validated.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/COSTELEMENT'.
          IF table_name <> '/ESRCC/CSTELEMNT'.
            FINAL(cost_element) = CONV /esrcc/costelement( field_value ).
            SELECT SINGLE 'X' FROM /esrcc/cstelemnt
*              WHERE sysid = @<system_id> AND legal_entity = @<legal_entity> AND company_code = @<ccode> AND cost_element = @cost_element
              WHERE sysid = @<system_id> AND cost_element = @cost_element
              INTO @is_validated.
            IF sy-subrc <> 0.
              CLEAR is_validated.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/SYSID'.
          IF table_name <> '/ESRCC/SYS_INFO'.
            FINAL(system_id) = CONV /esrcc/sysid( field_value ).
            SELECT SINGLE 'X' FROM /esrcc/sys_info WHERE system_id = @system_id INTO @is_validated.
            IF sy-subrc <> 0.
              CLEAR is_validated.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/CCODE_DE'.
          IF table_name <> '/ESRCC/LE_CCODE'.
            FINAL(company_code) = CONV /esrcc/ccode_de( field_value ).
            SELECT SINGLE 'X' FROM /esrcc/le_ccode WHERE ccode = @company_code INTO @is_validated.
            IF sy-subrc <> 0.
              CLEAR is_validated.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/BUSINESSDIVISION'.
          IF table_name <> '/ESRCC/BUS_DIV' AND field_value IS NOT INITIAL.
            FINAL(business_division) = CONV /esrcc/businessdivision( field_value ).
            SELECT SINGLE 'X' FROM /esrcc/bus_div WHERE business_division = @business_division INTO @is_validated.
            IF sy-subrc <> 0.
              CLEAR is_validated.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/PROFIT_CENTER'.
          IF table_name <> '/ESRCC/PFC' AND field_value IS NOT INITIAL.
            FINAL(profit_center) = CONV /esrcc/profit_center( field_value ).
            SELECT SINGLE 'X' FROM /esrcc/pfc WHERE profit_center = @profit_center INTO @is_validated.
            IF sy-subrc <> 0.
              CLEAR is_validated.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/SRVPRODUCT'.
          IF table_name <> '/ESRCC/SRVPRO'.
            FINAL(service_product) = CONV /esrcc/srvproduct( field_value ).
            SELECT SINGLE 'X' FROM /esrcc/srvpro WHERE serviceproduct = @service_product INTO @is_validated.
            IF sy-subrc <> 0.
              CLEAR is_validated.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/SRVTYPE_DE'.
          IF table_name <> '/ESRCC/SRTYPE' AND field_value IS NOT INITIAL.
            FINAL(service_type) = CONV /esrcc/srvtype_de( field_value ).
            SELECT SINGLE 'X' FROM /esrcc/srtype WHERE srvtype = @service_type INTO @is_validated.
            IF sy-subrc <> 0.
              CLEAR is_validated.
            ENDIF.
          ENDIF.
        WHEN '/ESRCC/TG'.
          IF table_name <> '/ESRCC/SRVTG' AND field_value IS NOT INITIAL.
            FINAL(transaction_group) = CONV /esrcc/tg( field_value ).
            SELECT SINGLE 'X' FROM /esrcc/srvtg WHERE TransactionGroup = @transaction_group INTO @is_validated.
            IF sy-subrc <> 0.
              CLEAR is_validated.
            ENDIF.
          ENDIF.
        WHEN OTHERS.
          FINAL(domain_validator) = /esrcc/cl_domain_validator=>get_instance( ).
          is_validated = domain_validator->validate_domain( field_name = CONV #( component-name )
                                                            table_name = table_name
                                                            value      = CONV #( field_value ) ).
      ENDCASE.
    ENDIF.

    IF table_name = '/ESRCC/CB_LI' OR table_name = '/ESRCC/CB_LI_TMP'.
      IF component-name = 'HSL' AND ( field_value IS INITIAL OR field_value = 0 ).
        message-message_id     = /esrcc/if_file_upload_handler=>message_class.
        message-message_type   = 'W'.
        message-message_number = 015.
      ENDIF.
      IF component-name = 'LOCALCURR' AND field_value IS INITIAL.
*        message-message_id      = /esrcc/if_file_upload_handler=>message_class.
*        message-message_type    = 'E'.
*        message-message_number  = 021.
        is_validated = abap_false.
      ENDIF.
    ENDIF.
    IF table_name = '/ESRCC/SRV_CPCTY' AND component-name = 'UOM' AND field_value IS INITIAL.
      message-message_id     = /esrcc/if_file_upload_handler=>message_class.
      message-message_type   = 'E'.
      message-message_number = 023.
      is_validated = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD _convert_date_to_internal.
    " TODO: parameter DATE_FORMAT is only used in commented-out code (ABAP cleaner)

    CLEAR: message.
    DATA(external_format) = VALUE /esrcc/sysid( ).
    external_format = value.

*    IF date_format IS INITIAL.
*      DATA(user_date_format) = cl_abap_datfm=>get_datfm( ).
*    ELSE.
*      user_date_format = date_format.
*    ENDIF.

    CASE cl_abap_datfm=>get_datfm( ).
*    CASE user_date_format. ##DATE_FORMAT
      WHEN '1'.
        IF external_format CA '.'.
          value = |{ external_format+6 }{ external_format+3(2) }{ external_format+0(2) }|.
          " if the template used has date field characteristics then the API converts it into yyyy-mm-dd format
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN '2'.
        IF external_format CA '/'.
          value = |{ external_format+6 }{ external_format+0(2) }{ external_format+3(2) }|.
          " if the template used has date field characteristics then the API converts it into yyyy-mm-dd format
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN '3'.
        IF external_format+2(1) = '-'.
          value = |{ external_format+6 }{ external_format+0(2) }{ external_format+3(2) }|.
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN '4'.
        IF external_format CA '.'.
          REPLACE ALL OCCURRENCES OF '.' IN external_format WITH ''.
          value = external_format.
          " if the template used has date field characteristics then the API converts it into yyyy-mm-dd format
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN '5'.
        IF external_format CA '/'.
          REPLACE ALL OCCURRENCES OF '/' IN external_format WITH ''.
          value = external_format.
          " if the template used has date field characteristics then the API converts it into yyyy-mm-dd format
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN '6'.
        IF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN '7'.
        IF external_format CA '.'.
          REPLACE ALL OCCURRENCES OF '.' IN external_format WITH ''.
          value = external_format.
          " if the template used has date field characteristics then the API converts it into yyyy-mm-dd format
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN '8'.
        IF external_format CA '/'.
          REPLACE ALL OCCURRENCES OF '/' IN external_format WITH ''.
          value = external_format.
          " if the template used has date field characteristics then the API converts it into yyyy-mm-dd format
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN '9'.
        IF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
          " if the template used has date field characteristics then the API converts it into yyyy-mm-dd format
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN 'A'.
        IF external_format CA '/'.
          REPLACE ALL OCCURRENCES OF '/' IN external_format WITH ''.
          value = external_format.
          " if the template used has date field characteristics then the API converts it into yyyy-mm-dd format
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN 'B'.
        IF external_format CA '/'.
          REPLACE ALL OCCURRENCES OF '/' IN external_format WITH ''.
          value = external_format.
          " if the template used has date field characteristics then the API converts it into yyyy-mm-dd format
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN 'C'.
        IF external_format CA '/'.
          REPLACE ALL OCCURRENCES OF '/' IN external_format WITH ''.
          value = external_format.
          " if the template used has date field characteristics then the API converts it into yyyy-mm-dd format
        ELSEIF external_format CA '-'.
          REPLACE ALL OCCURRENCES OF '-' IN external_format WITH ''.
          value = external_format.
        ELSE.
          MESSAGE s022(/esrcc/file_upload) INTO message.
        ENDIF.
      WHEN OTHERS.
        MESSAGE s022(/esrcc/file_upload) INTO message.
    ENDCASE.
  ENDMETHOD.


  METHOD _convert_local_to_group_amount.
    FINAL(last_date) = /esrcc/cl_utility_core=>get_last_day_of_month( date = |{ year }{ period+1 }01| ).

    CALL FUNCTION '/ESRCC/CONV_LCL_TO_GRP_AMOUNT'
      EXPORTING
        date             = last_date
        foreign_currency = group_currency
        local_amount     = local_amount
        local_currency   = local_currency
        type_of_rate     = conversion_rate_type
      IMPORTING
*       exchange_rate    =
        foreign_amount   = amount.
    " message          =
  ENDMETHOD.


  METHOD _costs_elements_mapping.
    IF _cost_elements_mapping IS INITIAL.
      _cost_elements_mapping = _fetch_from_db( ).
    ENDIF.

    IF _cost_objects IS INITIAL.
      _cost_objects = _fetch_cost_object( ).
    ENDIF.

    IF _group_configuration IS INITIAL.
      _group_configuration = /esrcc/cl_utility_core=>get_group_configuration( ).
    ENDIF.

*    IF _object_types IS INITIAL.
*      SELECT
*        FROM
**        /esrcc/cstobjtyp AS object_type
**               INNER JOIN
*                 /esrcc/cobjtymp AS mapping "ON mapping~object_type = object_type~cost_object
*        FIELDS OBJECT_TYPE                     AS host_object_type,
*               mapping~source_cost_object_type AS source_object_type
*        WHERE mapping~active = @abap_true
*        INTO TABLE @_object_types.
*    ENDIF.

    IF _legal_entity_data IS INITIAL.
      SELECT FROM /esrcc/le_ccode AS legal_entity_master
        FIELDS sysid, ccode, legalentity
        WHERE active = @abap_true
        ORDER BY sysid, ccode, legalentity
        INTO TABLE @_legal_entity_data.
    ENDIF.

    ASSIGN COMPONENT 'SYSID' OF STRUCTURE data_structure TO FIELD-SYMBOL(<system_id>).
    IF _source_cost_data_sign IS INITIAL.
      SELECT SINGLE FROM /esrcc/sys_info
        FIELDS sign_for_cogs
        WHERE system_id = @<system_id>
        INTO @_source_cost_data_sign.
    ENDIF.
    ASSIGN COMPONENT 'LEGALENTITY' OF STRUCTURE data_structure TO FIELD-SYMBOL(<legal_entity>).
    ASSIGN COMPONENT 'CCODE' OF STRUCTURE data_structure TO FIELD-SYMBOL(<ccode>).
    ASSIGN COMPONENT 'COSTOBJECT' OF STRUCTURE data_structure TO FIELD-SYMBOL(<cost_object>).
*    IF <cost_object> IS ASSIGNED.
*      <cost_object> = VALUE #( _object_types[ source_object_type = <cost_object> ]-host_object_type OPTIONAL ).
*    ENDIF.
    ASSIGN COMPONENT 'COSTCENTER' OF STRUCTURE data_structure TO FIELD-SYMBOL(<cost_center>).
    ASSIGN COMPONENT 'COSTELEMENT' OF STRUCTURE data_structure TO FIELD-SYMBOL(<cost_element>).
    ASSIGN COMPONENT 'RYEAR' OF STRUCTURE data_structure TO FIELD-SYMBOL(<reporting_year>).
    ASSIGN COMPONENT 'POPER' OF STRUCTURE data_structure TO FIELD-SYMBOL(<poper>).

    IF    <reporting_year> IS NOT ASSIGNED OR <reporting_year> IS INITIAL      OR <poper>        IS NOT ASSIGNED
       OR <poper>          IS INITIAL      OR <legal_entity>   IS NOT ASSIGNED OR <legal_entity> IS INITIAL
       OR <ccode>          IS NOT ASSIGNED OR <ccode>          IS INITIAL      OR <cost_element> IS NOT ASSIGNED
       OR <cost_element>   IS INITIAL.
      RETURN.
    ENDIF.

    READ TABLE _legal_entity_data ASSIGNING FIELD-SYMBOL(<legal_entity_data>) WITH KEY ccode       = <ccode>
                                                                                       legalentity = <legal_entity> BINARY SEARCH.
    IF sy-subrc = 0 AND <system_id> <> <legal_entity_data>-sysid.
      <system_id> = <legal_entity_data>-sysid.
    ENDIF.

*    SELECT SINGLE * FROM @_cost_objects AS objects WHERE sysid = @<system_id> AND legalentity = @<legal_entity>
*        AND company_code = @<ccode> AND  cost_object = @<cost_object> AND cost_center = @<cost_center>
*        INTO @DATA(<cost_object_mapping>).
    READ TABLE _cost_objects ASSIGNING FIELD-SYMBOL(<cost_object_mapping>) WITH KEY sysid        = <system_id>
                                                                                    legalentity  = <legal_entity>
                                                                                    company_code = <ccode>
                                                                                    cost_object  = <cost_object>
                                                                                    cost_center  = <cost_center> BINARY SEARCH.
    IF sy-subrc = 0.
      ASSIGN COMPONENT 'FUNCTIONALAREA' OF STRUCTURE data_structure TO FIELD-SYMBOL(<functional_area>).
      IF <functional_area> IS ASSIGNED.
        <functional_area> = <cost_object_mapping>-functional_area.
        UNASSIGN <functional_area>.
      ENDIF.

      ASSIGN COMPONENT 'BUSINESSDIVISION' OF STRUCTURE data_structure TO FIELD-SYMBOL(<business_division>).
      IF <business_division> IS ASSIGNED.
        <business_division> = <cost_object_mapping>-business_division.
        UNASSIGN <business_division>.
      ENDIF.

      ASSIGN COMPONENT 'PROFITCENTER' OF STRUCTURE data_structure TO FIELD-SYMBOL(<profit_center>).
      IF <profit_center> IS ASSIGNED.
        <profit_center> = <cost_object_mapping>-profit_center.
        UNASSIGN <profit_center>.
      ENDIF.
    ENDIF.

    FINAL(valid_on) = |{ <reporting_year> }{ <poper>+1 }01|.
*    SELECT SINGLE * FROM @_cost_elements_mapping AS mapping WHERE legalentity = @<legal_entity> AND
*      ccode = @<ccode> AND costelement = @<cost_element> AND valid_from <= @valid_on AND
*      valid_to >= @valid_on INTO @DATA(<mapping_information>).
    SELECT SINGLE * FROM @_cost_elements_mapping AS mapping
        WHERE sysid        = @<system_id>
          AND legalentity  = @<legal_entity> AND ccode = @<ccode> AND costobject = @<cost_object> AND costcenter = @<cost_center>
          AND ( costelement_from  <= @<cost_element>
          AND costelement_to    >= @<cost_element> )
          AND valid_from  <= @valid_on
          AND valid_to    >= @valid_on
          INTO @DATA(mapping_information).
    IF sy-subrc <> 0.
      SELECT SINGLE * FROM @_cost_elements_mapping AS mapping
       WHERE sysid        = @<system_id>
         AND ( legalentity  = @<legal_entity> AND ccode = @<ccode> AND costobject = @<cost_object> AND costcenter IS INITIAL )
         AND ( costelement_from  <= @<cost_element>
         AND costelement_to    >= @<cost_element> )
         AND valid_from  <= @valid_on
         AND valid_to    >= @valid_on
         INTO @mapping_information.
      IF sy-subrc <> 0.
        SELECT SINGLE * FROM @_cost_elements_mapping AS mapping
         WHERE sysid        = @<system_id>
           AND ( legalentity  = @<legal_entity> AND ccode = @<ccode> AND costobject IS INITIAL AND costcenter IS INITIAL )
           AND ( costelement_from  <= @<cost_element>
           AND costelement_to    >= @<cost_element> )
           AND valid_from  <= @valid_on
           AND valid_to    >= @valid_on
           INTO @mapping_information.

        IF sy-subrc <> 0.
          SELECT SINGLE * FROM @_cost_elements_mapping AS mapping
          WHERE sysid        = @<system_id>
          AND ( legalentity IS INITIAL AND ccode IS INITIAL AND costobject IS INITIAL AND costcenter IS INITIAL )
          AND costelement_from  <= @<cost_element>
          AND costelement_to    >= @<cost_element>
          AND valid_from  <= @valid_on
          AND valid_to    >= @valid_on
          INTO @mapping_information.
        ENDIF.
      ENDIF.
    ENDIF.
    IF mapping_information IS NOT INITIAL.
      ASSIGN COMPONENT 'COSTTYPE' OF STRUCTURE data_structure TO FIELD-SYMBOL(<cost_element_type>).
      IF <cost_element_type> IS ASSIGNED.
        <cost_element_type> = mapping_information-costtype.
        UNASSIGN <cost_element_type>.
      ENDIF.

      ASSIGN COMPONENT 'COSTIND' OF STRUCTURE data_structure TO FIELD-SYMBOL(<costing_indicator>).
      IF <costing_indicator> IS ASSIGNED.
        <costing_indicator> = mapping_information-costind.
        UNASSIGN <costing_indicator>.
      ENDIF.

      ASSIGN COMPONENT 'USAGECAL' OF STRUCTURE data_structure TO FIELD-SYMBOL(<usage_type>).
      IF <usage_type> IS ASSIGNED.
        <usage_type> = COND #( WHEN mapping_information-usagetype IS INITIAL
                               THEN 'E'
                               ELSE mapping_information-usagetype ).
        UNASSIGN <usage_type>.
      ENDIF.

      ASSIGN COMPONENT 'REASONID' OF STRUCTURE data_structure TO FIELD-SYMBOL(<reason_id>).
      IF <reason_id> IS ASSIGNED.
        <reason_id> = mapping_information-reason_id.
        UNASSIGN <reason_id>.
      ENDIF.

      ASSIGN COMPONENT 'VALUE_SOURCE' OF STRUCTURE data_structure TO FIELD-SYMBOL(<value_source>).
      IF <value_source> IS ASSIGNED.
        <value_source> = mapping_information-value_source.
        UNASSIGN <value_source>.
      ENDIF.
    ENDIF.

    ASSIGN COMPONENT 'HSL' OF STRUCTURE data_structure TO FIELD-SYMBOL(<local_amount>).
    IF <local_amount> IS ASSIGNED.
      <local_amount> = COND /esrcc/hsl( WHEN _source_cost_data_sign = _group_configuration-cost_sign
                                        THEN <local_amount>
                                        ELSE <local_amount> * -1 ).
      ASSIGN COMPONENT 'LOCALCURR' OF STRUCTURE data_structure TO FIELD-SYMBOL(<local_currency>).
      IF <local_currency> IS NOT INITIAL AND from_extraction = abap_false.
        /esrcc/cl_utility_core=>curr_external_to_internal( EXPORTING currency        = <local_currency>
                                                                     amount_external = <local_amount>
                                                           IMPORTING amount_internal = <local_amount> ).
      ENDIF.
      ASSIGN COMPONENT 'POSTINGTYPE' OF STRUCTURE data_structure TO FIELD-SYMBOL(<posting_type>).
      IF <posting_type> IS ASSIGNED.
        <posting_type> = COND /esrcc/postingtype_de( WHEN _group_configuration-cost_sign = '+'
                                                     THEN COND #( WHEN <local_amount> < 0 THEN |INCOME| ELSE |EXPENSE| )
                                                     ELSE COND #( WHEN <local_amount> < 0 THEN |EXPENSE| ELSE |INCOME| ) ).
        UNASSIGN <posting_type>.
      ENDIF.
      ASSIGN COMPONENT 'KSL' OF STRUCTURE data_structure TO FIELD-SYMBOL(<group_amount>).
      IF <group_amount> IS ASSIGNED AND <local_currency> IS ASSIGNED AND <local_amount> <> 0.
        <group_amount> = _convert_local_to_group_amount(
                             year                 = <reporting_year>
                             period               = <poper>
                             local_amount         = <local_amount>
                             local_currency       = <local_currency>
                             group_currency       = _group_configuration-group_currency
                             conversion_rate_type = _group_configuration-conversion_rate_type ).
        UNASSIGN <group_amount>.
      ENDIF.
      ASSIGN COMPONENT 'GROUPCURR' OF STRUCTURE data_structure TO FIELD-SYMBOL(<group_currency>).
      IF <group_currency> IS ASSIGNED.
        <group_currency> = _group_configuration-group_currency.
        UNASSIGN <group_currency>.
      ENDIF.
    ENDIF.

    ASSIGN COMPONENT 'STATUS' OF STRUCTURE data_structure TO FIELD-SYMBOL(<status>).
    IF <status> IS ASSIGNED.
      <status> = 'A'.
      UNASSIGN <status>.
    ENDIF.
    CLEAR mapping_information.

  ENDMETHOD.


  METHOD _fetch_cost_object.
    SELECT sysid,                                       "#EC CI_NOWHERE
           legal_entity,
           company_code,
           cost_object,
           cost_center,
           functional_area,
           profit_center,
           business_division
      FROM /esrcc/cst_objct
      ORDER BY sysid, legal_entity, company_code, cost_object, cost_center
      INTO TABLE @_result.
  ENDMETHOD.


  METHOD _fetch_from_db.
    " Remove corresponding once satish removed the unwanted fields from the table
    SELECT sysid,
           legal_entity     AS legalentity,
           company_code     AS ccode,
           cost_object      AS costobject,
           cost_center      AS costcenter,
           costelement_from,
           costelement_to,
           valid_from,
           cost_type        AS costtype,
           posting_type     AS postingtype,
           cost_indicator   AS costind,
           usage_type       AS usagetype,
           valid_to,
           reason_id,
           value_source
      FROM /esrcc/cstelmtch AS matching
      WHERE workflow_status = 'F' AND active = @abap_true
      ORDER BY sysid, legal_entity, company_code, cost_object, costcenter, costelement_from, costelement_to, valid_from
      INTO CORRESPONDING FIELDS OF TABLE @_result.      "#EC CI_NOWHERE
  ENDMETHOD.


  METHOD _fetch_rr_object.
    SELECT system_id,                                   "#EC CI_NOWHERE
           legal_entity,
           company_code,
           object_type,
           object_number,
           functional_area,
           profit_center,
           business_division
      FROM /esrcc/rr_objct
      WHERE active_flag = @abap_true
      ORDER BY system_id, legal_entity, company_code, object_type, object_number
      INTO TABLE @_result.
  ENDMETHOD.


  METHOD _fetch_rr_partner_data.
    SELECT systemid                AS system_id,
           legalentity             AS legal_entity,
           companycode             AS company_code,
           objecttype              AS object_type,
           objectnumber            AS object_number,
           partnersystemid         AS psystem_id,
           partnerlegalentity      AS plegalentity,
           partnercompanycode      AS pcompany_code,
           partnerobjecttype       AS pobject_type,
           partnerobjectnumber     AS pobject_number,
           partnerfunctionalarea   AS pfunctionalarea,
           partnerprofitcenter     AS pprofit_center,
           partnerbusinessdivision AS pbusinessdivision
      FROM /esrcc/i_rr_rule
      WHERE activeflag = @abap_true
      ORDER BY system_id, legal_entity, company_code, object_type, object_number
      INTO CORRESPONDING FIELDS OF TABLE @_result.
  ENDMETHOD.


  METHOD _rr_lineitems_mapping.
    IF _rr_objects IS INITIAL.
      _rr_objects = _fetch_rr_object( ).
    ENDIF.

    IF _group_configuration IS INITIAL.
      _group_configuration = /esrcc/cl_utility_core=>get_group_configuration( ).
    ENDIF.

    IF _rr_partner_data IS INITIAL.
      _rr_partner_data = _fetch_rr_partner_data( ).
    ENDIF.

    IF _legal_entity_data IS INITIAL.
      SELECT FROM /esrcc/le_ccode AS legal_entity_master
        FIELDS sysid, ccode, legalentity
        WHERE active = @abap_true
        ORDER BY sysid, ccode, legalentity
        INTO TABLE @_legal_entity_data.
    ENDIF.

    IF _rr_accounting_type IS INITIAL.
      SELECT FROM /esrcc/rr_objtyp
        FIELDS object_type, accounting_type
        INTO TABLE @_rr_accounting_type .
    ENDIF.


    ASSIGN COMPONENT 'SYSID' OF STRUCTURE data_structure TO FIELD-SYMBOL(<system_id>).
    ASSIGN COMPONENT 'LEGALENTITY' OF STRUCTURE data_structure TO FIELD-SYMBOL(<legal_entity>).
    ASSIGN COMPONENT 'CCODE' OF STRUCTURE data_structure TO FIELD-SYMBOL(<ccode>).
    ASSIGN COMPONENT 'OBJECT_TYPE' OF STRUCTURE data_structure TO FIELD-SYMBOL(<object_type>).
    ASSIGN COMPONENT 'OBJECT_NUMBER' OF STRUCTURE data_structure TO FIELD-SYMBOL(<object_number>).
    ASSIGN COMPONENT 'RYEAR' OF STRUCTURE data_structure TO FIELD-SYMBOL(<reporting_year>).
    ASSIGN COMPONENT 'POPER' OF STRUCTURE data_structure TO FIELD-SYMBOL(<poper>).
    ASSIGN COMPONENT 'FPLV'  OF STRUCTURE data_structure TO FIELD-SYMBOL(<fplv>).
    ASSIGN COMPONENT 'P_OBJECT_TYPE'  OF STRUCTURE data_structure TO FIELD-SYMBOL(<p_objtype>).

    IF    <reporting_year> IS NOT ASSIGNED OR <reporting_year> IS INITIAL      OR <poper>        IS NOT ASSIGNED
       OR <poper>          IS INITIAL      OR <legal_entity>   IS NOT ASSIGNED OR <legal_entity> IS INITIAL
       OR <ccode>          IS NOT ASSIGNED OR <ccode>          IS INITIAL.
      RETURN.
    ENDIF.

    READ TABLE _legal_entity_data ASSIGNING FIELD-SYMBOL(<legal_entity_data>) WITH KEY  sysid      = <system_id>
                                                                                       ccode       = <ccode>
                                                                                       legalentity = <legal_entity> BINARY SEARCH.
    IF sy-subrc = 0 AND <system_id> <> <legal_entity_data>-sysid.
      <system_id> = <legal_entity_data>-sysid.
    ENDIF.

    IF <object_type> IS ASSIGNED.
      <object_type> = gc_object_type.
    ENDIF.

    IF <p_objtype> IS ASSIGNED.
      <p_objtype> = gc_pobject_type.
    ENDIF.

    READ TABLE _rr_objects ASSIGNING FIELD-SYMBOL(<rr_object_mapping>) WITH KEY sysid         = <system_id>
                                                                                legalentity   = <legal_entity>
                                                                                company_code  = <ccode>
                                                                                object_type   = <object_type>
                                                                                object_number = <object_number> BINARY SEARCH.
    IF sy-subrc = 0.
      ASSIGN COMPONENT 'FUNCTIONALAREA' OF STRUCTURE data_structure TO FIELD-SYMBOL(<functional_area>).
      IF <functional_area> IS ASSIGNED AND <functional_area> IS INITIAL.
        <functional_area> = <rr_object_mapping>-functional_area.
        UNASSIGN <functional_area>.
      ENDIF.

      ASSIGN COMPONENT 'BUSINESSDIVISION' OF STRUCTURE data_structure TO FIELD-SYMBOL(<business_division>).
      IF <business_division> IS ASSIGNED AND <business_division> IS INITIAL.
        <business_division> = <rr_object_mapping>-business_division.
        UNASSIGN <business_division>.
      ENDIF.

      ASSIGN COMPONENT 'PROFITCENTER' OF STRUCTURE data_structure TO FIELD-SYMBOL(<profit_center>).
      IF <profit_center> IS ASSIGNED AND <profit_center> IS INITIAL.
        <profit_center> = <rr_object_mapping>-profit_center.
        UNASSIGN <profit_center>.
      ENDIF.
    ENDIF.

    IF <fplv> IS ASSIGNED.
      <fplv> = gc_fplv.
    ENDIF.

    ASSIGN COMPONENT 'HSL' OF STRUCTURE data_structure TO FIELD-SYMBOL(<local_amount>).
    IF <local_amount> IS ASSIGNED.
      <local_amount> = COND /esrcc/hsl( WHEN _source_cost_data_sign = _group_configuration-cost_sign
                                        THEN <local_amount>
                                        ELSE <local_amount> * -1 ).
      ASSIGN COMPONENT 'LOCALCURR' OF STRUCTURE data_structure TO FIELD-SYMBOL(<local_currency>).
      IF <local_currency> IS NOT INITIAL AND from_extraction = abap_false.
        /esrcc/cl_utility_core=>curr_external_to_internal( EXPORTING currency        = <local_currency>
                                                                     amount_external = <local_amount>
                                                           IMPORTING amount_internal = <local_amount> ).
      ENDIF.

      ASSIGN COMPONENT 'KSL' OF STRUCTURE data_structure TO FIELD-SYMBOL(<group_amount>).
      IF <group_amount> IS ASSIGNED AND <local_currency> IS ASSIGNED AND <local_amount> <> 0.
        <group_amount> = _convert_local_to_group_amount(
                             year                 = <reporting_year>
                             period               = <poper>
                             local_amount         = <local_amount>
                             local_currency       = <local_currency>
                             group_currency       = _group_configuration-group_currency
                             conversion_rate_type = _group_configuration-conversion_rate_type ).
        UNASSIGN <group_amount>.
      ENDIF.
      ASSIGN COMPONENT 'GROUPCURR' OF STRUCTURE data_structure TO FIELD-SYMBOL(<group_currency>).
      IF <group_currency> IS ASSIGNED.
        <group_currency> = _group_configuration-group_currency.
        UNASSIGN <group_currency>.
      ENDIF.
    ENDIF.

    FINAL(valid_on) = |{ <reporting_year> }{ <poper>+1 }01|.

    READ TABLE _rr_accounting_type ASSIGNING FIELD-SYMBOL(<accounting_type_mapping>) WITH KEY object_type = <object_type>.

    IF sy-subrc = 0.
      ASSIGN COMPONENT 'P_ACCOUNTING_TYPE' OF STRUCTURE data_structure TO FIELD-SYMBOL(<accounting_type>).
      IF <accounting_type> IS ASSIGNED.
        <accounting_type> = <accounting_type_mapping>-accounting_type.
        UNASSIGN <accounting_type>.
      ENDIF.
    ENDIF.

    LOOP AT _rr_partner_data ASSIGNING FIELD-SYMBOL(<partner_mapping_information>) WHERE     sysid          = <system_id>
                                                                                         AND legalentity    = <legal_entity>
                                                                                         AND company_code   = <ccode>
                                                                                         AND object_type    = <object_type>
                                                                                         AND object_number  = <object_number>
                                                                                         AND valid_from    <= valid_on
                                                                                         AND valid_to      >= valid_on.
      ASSIGN COMPONENT 'P_SYSTEM_ID' OF STRUCTURE data_structure TO FIELD-SYMBOL(<partner_system_id>).
      IF <partner_system_id> IS ASSIGNED.
        <partner_system_id> = <partner_mapping_information>-psystem_id.
        UNASSIGN <partner_system_id>.
      ENDIF.

      ASSIGN COMPONENT 'P_LEGALENTITY' OF STRUCTURE data_structure TO FIELD-SYMBOL(<partner_legal_entity>).
      IF <partner_legal_entity> IS ASSIGNED.
        <partner_legal_entity> = <partner_mapping_information>-plegalentity.
        UNASSIGN <partner_legal_entity>.
      ENDIF.

      ASSIGN COMPONENT 'P_COMPANY_CODE' OF STRUCTURE data_structure TO FIELD-SYMBOL(<partner_ccode>).
      IF <partner_ccode> IS ASSIGNED.
        <partner_ccode> = <partner_mapping_information>-pcompany_code.
        UNASSIGN <partner_ccode>.
      ENDIF.

      ASSIGN COMPONENT 'P_OBJECT_TYPE' OF STRUCTURE data_structure TO FIELD-SYMBOL(<partner_objecttype>).
      IF <partner_objecttype> IS ASSIGNED.
        <partner_objecttype> = <partner_mapping_information>-pobject_type.
        UNASSIGN <partner_objecttype>.
      ENDIF.

      ASSIGN COMPONENT 'P_OBJECT_NUMBER' OF STRUCTURE data_structure TO FIELD-SYMBOL(<partner_object_number>).
      IF <partner_object_number> IS ASSIGNED.
        <partner_object_number> = <partner_mapping_information>-pobject_number.
        UNASSIGN <partner_object_number>.
      ENDIF.

      ASSIGN COMPONENT 'P_BUSINESSDIVISION' OF STRUCTURE data_structure TO FIELD-SYMBOL(<partner_business_division>).
      IF <partner_business_division> IS ASSIGNED.
        <partner_business_division> = <partner_mapping_information>-pbusinessdivision.
        UNASSIGN <partner_business_division>.
      ENDIF.

      ASSIGN COMPONENT 'P_PROFIT_CENTER' OF STRUCTURE data_structure TO FIELD-SYMBOL(<partner_profit_center>).
      IF <partner_profit_center> IS ASSIGNED.
        <partner_profit_center> = <partner_mapping_information>-pprofit_center.
        UNASSIGN <partner_profit_center>.
      ENDIF.

      ASSIGN COMPONENT 'P_FUNCTIONALAREA' OF STRUCTURE data_structure TO FIELD-SYMBOL(<partner_functional_area>).
      IF <partner_functional_area> IS ASSIGNED.
        <partner_functional_area> = <partner_mapping_information>-pfunctionalarea.
        UNASSIGN <partner_functional_area>.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
