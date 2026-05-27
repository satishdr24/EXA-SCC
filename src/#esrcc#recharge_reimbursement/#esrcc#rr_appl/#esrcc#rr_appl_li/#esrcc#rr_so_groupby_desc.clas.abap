CLASS /esrcc/rr_so_groupby_desc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
    " Type for field → data element mapping
    TYPES: BEGIN OF ty_field_map,
             field_name   TYPE sxco_cds_field_name,
             data_element TYPE sxco_ad_object_name,
           END OF ty_field_map.

    " Table of mappings
    DATA lt_field_map TYPE STANDARD TABLE OF ty_field_map WITH DEFAULT KEY.

    CLASS-DATA dictionary TYPE REF TO /esrcc/cl_abap_dictionary.

    " Helper method to get label for a field
    METHODS get_field_label
      IMPORTING !field          TYPE sxco_cds_field_name
      RETURNING VALUE(rv_label) TYPE string.

    METHODS get_description IMPORTING field_names               TYPE string
                            RETURNING VALUE(field_descriptions) TYPE string.
ENDCLASS.

CLASS /esrcc/rr_so_groupby_desc IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA original_data      TYPE TABLE OF /ESRCC/C_RR_Sales_Config.
    DATA calculated_data    TYPE TABLE OF /ESRCC/C_RR_Sales_Config.
    DATA calculated_data_li TYPE TABLE OF /ESRCC/I_RR_SO_Config_F4.

    " Initialize mapping table once
    lt_field_map = VALUE #( ( field_name = 'RYEAR'                data_element = '/ESRCC/RYEAR' )
                            ( field_name = 'POPER'                data_element = '/ESRCC/POPER' )
                            ( field_name = 'FPLV'                 data_element = '/ESRCC/COSTDATASET_DE' )
                            ( field_name = 'SYSID'                data_element = '/ESRCC/SYSID' )
                            ( field_name = 'LEGALENTITY'          data_element = '/ESRCC/LEGALENTITY' )
                            ( field_name = 'CCODE'                data_element = '/ESRCC/CCODE_DE' )
                            ( field_name = 'OBJECT_TYPE'          data_element = '/ESRCC/RR_OBJECT_TYPE' )
                            ( field_name = 'OBJECT_NUMBER'        data_element = '/ESRCC/RR_OBJECT_NUMBER' )
                            ( field_name = 'LEDGER'               data_element = '/ESRCC/LEDGER_DE' )
                            ( field_name = 'BELNR'                data_element = '/ESRCC/DOC_NO' )
                            ( field_name = 'BUZEI'                data_element = '/ESRCC/BUZEI' )
                            ( field_name = 'RR_MATTER'            data_element = '/ESRCC/RR_MATTER' )
                            ( field_name = 'MATERIAL'             data_element = '/ESRCC/RR_RELATED_MATERIAL' )
                            ( field_name = 'REFERENCE_BELNR'      data_element = '/ESRCC/REF_DOC_NO' )
                            ( field_name = 'BELNR_TEXT'           data_element = '/ESRCC/DOC_TEXT' )
                            ( field_name = 'DATA_SOURCE'          data_element = '/ESRCC/RR_VALUE_SOURCE' )
                            ( field_name = 'HSL'                  data_element = '/ESRCC/HSL' )
                            ( field_name = 'LOCALCURR'            data_element = '/ESRCC/LOCALCURR' )
                            ( field_name = 'KSL'                  data_element = '/ESRCC/KSL' )
                            ( field_name = 'GROUPCURR'            data_element = '/ESRCC/GROUPCURR' )
                            ( field_name = 'QUANTITY'             data_element = '/ESRCC/QUANTITY' )
                            ( field_name = 'MEINS'                data_element = '/ESRCC/UOM' )
                            ( field_name = 'BSCHL'                data_element = '/ESRCC/BSCHL' )
                            ( field_name = 'BUDAT'                data_element = '/ESRCC/POSTINGDATE' )
                            ( field_name = 'VENDOR'               data_element = '/ESRCC/VENDOR' )
                            ( field_name = 'PROFITCENTER'         data_element = '/ESRCC/PROFIT_CENTER' )
                            ( field_name = 'BUSINESSDIVISION'     data_element = '/ESRCC/BUSINESSDIVISION' )
                            ( field_name = 'FUNCTIONALAREA'       data_element = '/ESRCC/FUNCTIONAL_AREA' )
                            ( field_name = 'DOCUMENT_DATE'        data_element = '/ESRCC/DOCUMENT_DATE' )
                            ( field_name = 'ASSIGNMENT'           data_element = '/ESRCC/ASSIGNMENT' )
                            ( field_name = 'ITEM_TEXT'            data_element = '/ESRCC/ITEM_TEXT' )
                            ( field_name = 'SO_ITEM'              data_element = '/ESRCC/SO_ITEM' )
                            ( field_name = 'SALES_ORG'            data_element = '/ESRCC/SALES_ORG' )
                            ( field_name = 'DISTRIBUTION_CHANNEL' data_element = '/ESRCC/DISTRIBUTION_CHANNEL' )
                            ( field_name = 'DIVISION'             data_element = '/ESRCC/DIVISION' )
                            ( field_name = 'SALESORDER_REFERENCE' data_element = 'SYSUUID_C22' )
                            ( field_name = 'SALESORDER_NUMBER'    data_element = '/ESRCC/SO_NUMBER' )
                            ( field_name = 'P_SYSTEM_ID'          data_element = '/ESRCC/SYSID_PARTNER' )
                            ( field_name = 'P_LEGALENTITY'        data_element = '/ESRCC/LEGALENTITY_PARTNER' )
                            ( field_name = 'P_COMPANY_CODE'       data_element = '/ESRCC/CCODE_PARTNER' )
                            ( field_name = 'P_OBJECT_TYPE'        data_element = '/ESRCC/RR_OBJECT_TYPE_PARTNER' )
                            ( field_name = 'P_OBJECT_NUMBER'      data_element = '/ESRCC/RR_OBJECT_NUMBER_PARTNE' )
                            ( field_name = 'P_ACCOUNTING_TYPE'    data_element = '/ESRCC/RR_ACCOUNTING_TYPE' )
                            ( field_name = 'P_BUSINESSDIVISION'   data_element = '/ESRCC/BUSINESSDIVISION' )
                            ( field_name = 'P_PROFIT_CENTER'      data_element = '/ESRCC/PROFIT_CENTER' )
                            ( field_name = 'P_FUNCTIONALAREA'     data_element = '/ESRCC/FUNCTIONAL_AREA' )
                            ( field_name = 'P_SALESORDER_CREATED' data_element = '/ESRCC/SO_CREATED' ) ).

    CLEAR ct_calculated_data.

    original_data = CORRESPONDING #( it_original_data ).

    " Create dictionary instance for table (or CDS)
    dictionary = NEW /esrcc/cl_abap_dictionary( iv_entity_name = '/ESRCC/RR_LI' ).

    " F4 help group by fields from SO creation in RR LI Application
    IF VALUE #( it_requested_calc_elements[ 1 ] OPTIONAL ) = 'GROUPBYFIELDS'.
      LOOP AT original_data ASSIGNING FIELD-SYMBOL(<lfs_original_data>).

        calculated_data_li = VALUE #( BASE calculated_data_li
                                      ( GroupByFields = get_description( CONV string( <lfs_original_data>-GroupBy ) ) ) ).
      ENDLOOP.
      ct_calculated_data = CORRESPONDING #( calculated_data_li ).
    ELSE.

      " For the Group by CBC
      LOOP AT original_data ASSIGNING <lfs_original_data>.

        calculated_data = VALUE #( BASE calculated_data
                                   ( GroupByDescription     = get_description(
                                                                  CONV string( <lfs_original_data>-GroupBy ) )
                                     GroupByitemDescription = get_description(
                                                                  CONV string( <lfs_original_data>-GroupByItem ) ) ) ).
        ct_calculated_data = CORRESPONDING #( calculated_data ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    DATA lv_requested TYPE string.
    LOOP AT it_requested_calc_elements INTO lv_requested.

      " Check if our virtual field is requested
      IF lv_requested = 'GROUPBYDESCRIPTION' OR lv_requested = 'GROUPBYFIELDS' .
        " Declare original fields required for calculation
        APPEND 'GROUPBY' TO et_requested_orig_elements.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_field_label.
    DATA ls_map TYPE ty_field_map.

    READ TABLE lt_field_map WITH KEY field_name = field INTO ls_map.
    IF sy-subrc = 0 AND ls_map-data_element IS NOT INITIAL.
      TRY.
          rv_label = dictionary->read_data_element_text(
                       iv_field_name   = field
                       iv_data_element = ls_map-data_element ).
        CATCH cx_root.
          rv_label = field.
      ENDTRY.
    ELSE.
      rv_label = field.
    ENDIF.
  ENDMETHOD.

  METHOD get_description.
    SPLIT field_names AT ',' INTO TABLE DATA(lt_fields).

    LOOP AT lt_fields INTO DATA(lv_field_str).
      CONDENSE lv_field_str NO-GAPS.
      DATA(lv_label) = get_field_label( field = CONV sxco_cds_field_name( lv_field_str ) ).

      " Build comma-separated description
      IF field_descriptions IS INITIAL.
        field_descriptions = lv_label.
      ELSE.
        field_descriptions = |{ field_descriptions }, { lv_label }|.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
