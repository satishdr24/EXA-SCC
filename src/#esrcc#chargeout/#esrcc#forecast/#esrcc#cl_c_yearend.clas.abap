CLASS /esrcc/cl_c_yearend DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS /esrcc/cl_c_yearend IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    TRY.
**filter
        DATA(lv_sql_filter) = io_request->get_filter( )->get_as_sql_string( ).
        TRY.
            DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).
          CATCH cx_rap_query_filter_no_range.
            "handle exception
        ENDTRY.

**parameters
*            DATA(lt_parameters) = io_request->get_parameters( ).
*            DATA(lv_next_year) =  CONV /dmo/end_date( cl_abap_context_info=>get_system_date( ) + 365 )  .
*            DATA(lv_par_filter) = | BEGIN_DATE >= '{ cl_abap_dyn_prg=>escape_quotes( VALUE #( lt_parameters[ parameter_name = 'P_START_DATE' ]-value
*                                                                                              DEFAULT cl_abap_context_info=>get_system_date( ) ) ) }'| &&
*                                  | AND | &&
*                                  | END_DATE <= '{ cl_abap_dyn_prg=>escape_quotes( VALUE #( lt_parameters[ parameter_name = 'P_END_DATE' ]-value
*                                                                                            DEFAULT lv_next_year ) ) }'| .
*            IF lv_sql_filter IS INITIAL.
*              lv_sql_filter = lv_par_filter.
*            ELSE.
*              lv_sql_filter = |( { lv_sql_filter } AND { lv_par_filter } )| .
*            ENDIF.
**search
        DATA(lv_search_string) = io_request->get_search_expression( ).
        DATA(lv_search_sql) = |DESCRIPTION LIKE '%{ cl_abap_dyn_prg=>escape_quotes( lv_search_string ) }%'|.

        IF lv_sql_filter IS INITIAL.
          lv_sql_filter = lv_search_sql.
        ELSE.
          lv_sql_filter = |( { lv_sql_filter } AND { lv_search_sql } )|.
        ENDIF.
**request data

*        IF io_request->is_data_requested( ).
***paging
        DATA(lv_offset) = io_request->get_paging( )->get_offset( ).
        DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).
        DATA(lv_max_rows) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited
                                    THEN 0 ELSE lv_page_size ).

**sorting
        DATA(sort_elements) = io_request->get_sort_elements( ).
        DATA(lt_sort_criteria) = VALUE string_table( FOR sort_element IN sort_elements
                                                   ( sort_element-element_name && COND #( WHEN sort_element-descending = abap_true THEN ` DESCENDING`
                                                                                                                                   ELSE ` ASCENDING` ) ) ).
        DATA(lv_sort_string)  = COND #( WHEN lt_sort_criteria IS INITIAL THEN `primary key`
                                                                         ELSE concat_lines_of( table = lt_sort_criteria sep = `, ` ) ).
**requested elements
        DATA(lt_req_elements) = io_request->get_requested_elements( ).


****grouping
        DATA(lt_grouped_element) = io_request->get_aggregation( )->get_grouped_elements( ).
        DATA(lv_grouping) = concat_lines_of( table = lt_grouped_element sep = `, ` ).

**aggregate
        DATA(lt_aggr_element) = io_request->get_aggregation( )->get_aggregated_elements( ).

        IF lt_aggr_element IS NOT INITIAL.
          LOOP AT lt_aggr_element ASSIGNING FIELD-SYMBOL(<fs_aggr_element>).
            DELETE lt_req_elements WHERE table_line = <fs_aggr_element>-result_element.
            DATA(lv_aggregation) = |{ <fs_aggr_element>-aggregation_method }( { <fs_aggr_element>-input_element } ) as { <fs_aggr_element>-result_element }|.
            APPEND lv_aggregation TO lt_req_elements.
          ENDLOOP.
        ENDIF.
        DATA(lv_req_elements)  = concat_lines_of( table = lt_req_elements sep = `, ` ).

*
***select data
        DATA lt_result        TYPE STANDARD TABLE OF /esrcc/c_yearend_review.
        DATA lt_fin_result    TYPE STANDARD TABLE OF /esrcc/c_yearend_review.
        DATA ls_result        TYPE /esrcc/c_yearend_review.
        DATA _sysid           TYPE RANGE OF /esrcc/sysid.
        DATA _fplv            TYPE RANGE OF /esrcc/costdataset_de.
        DATA _ryear           TYPE RANGE OF /esrcc/ryear.
        DATA _poper           TYPE RANGE OF poper.
        DATA _refpoper        TYPE RANGE OF poper.
        DATA _legalentity     TYPE RANGE OF /esrcc/legalentity.
        DATA _ccode           TYPE RANGE OF /esrcc/ccode_de.
        DATA _costobject      TYPE RANGE OF /esrcc/costobject_de.
        DATA _costcenter      TYPE RANGE OF /esrcc/costcenter.
        DATA _receivingentity TYPE RANGE OF /esrcc/legalentity.
        DATA _recccode        TYPE RANGE OF /esrcc/ccode_de.
        DATA _reccostobject   TYPE RANGE OF /esrcc/costobject_de.
        DATA _reccostcenter   TYPE RANGE OF /esrcc/costcenter.
        DATA _serviceproduct  TYPE RANGE OF /esrcc/srvproduct.
        DATA _currencytype    TYPE RANGE OF /esrcc/sendercurr.

*   filters
        LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<ls_filter>).

          CASE <ls_filter>-name.

            WHEN 'RYEAR'.
              _ryear = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'REFPOPER'.
              _refpoper = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'LEGALENTITY'.
              _legalentity = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'CCODE'.
              _ccode = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'COSTOBJECT'.
              _costobject = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'COSTCENTER'.
              _costcenter = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'SERVICEPRODUCT'.
              _serviceproduct = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'RECEIVINGENTITY'.
              _receivingentity = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'RECEIVERCOMPANYCODE'.
              _recccode = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'RECEIVERCOSTOBJECT'.
              _reccostobject = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'RECEIVERCOSTCENTER'.
              _reccostcenter = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'CURRENCYTYPE'.
              _currencytype = CORRESPONDING #( <ls_filter>-range ).
            WHEN OTHERS.
          ENDCASE.

        ENDLOOP.


**Derive poper from reference poper
        IF _refpoper IS NOT INITIAL.
          DATA(poper) = 1.
          DATA(refpoper) = _refpoper[ 1 ]-low.
          DATA(ryear)    = _ryear[ 1 ]-low.
          DATA(currencytype) = _currencytype[ 1 ]-low.


*   Get Year To Date Charge-outs
          SELECT yearend~ryear,
                 yearend~refpoper,
                 yearend~sysid,
                 yearend~Legalentity,
                 yearend~ccode,
                 yearend~Costobject,
                 yearend~Costcenter,
                 yearend~profitcenter,
                 yearend~functionalarea,
                 yearend~businessdivision,
                 yearend~Serviceproduct,
                 yearend~oecd,
                 yearend~servicetype,
                 yearend~transactiongroup,
                 yearend~Receivingentity,
                 yearend~ReceiverCompanyCode,
                 yearend~ReceiverCostObject,
                 yearend~ReceiverCostCenter,
                 yearend~Currencytype,
                 yearend~currency,
                 Ytdamount + Amount AS Ytdamount,
                 Forecastamount  ,
                 Yearendamount + Amount AS Yearendamount,
                  reccountry,
                  lecountry,
                  legalentitydescription,
                  ccodedescription,
                  costobjectdescription,
                  costcenterdescription,
                  profitcenterdescription,
                  businessdescription,
                  functionalareadescription,
                  serviceproductdescription,
                  oecdDescription,
                  servicetypedescription,
                  transactiongroupdescription,
                  recccodedescription,
                  receivingentitydescription,
                  recCostObjectdescription,
                  recCostCenterdescription,
                  currencytypedescription
             FROM /esrcc/i_yearend( p_ryear      = @ryear,
                                    p_refpoper   = @refpoper
                                   ) AS yearend
             LEFT OUTER JOIN /esrcc/i_trueup_ytd( p_ryear      = @ryear,
                                                  p_refpoper   = @refpoper,
                                                  p_currencytype = @currencytype
                                            ) AS trueup
               ON   yearend~sysid               = trueup~sysid
               AND  yearend~Legalentity         = trueup~Legalentity
               AND  yearend~ccode               = trueup~ccode
               AND  yearend~Costobject          = trueup~Costobject
               AND  yearend~Costcenter          = trueup~Costcenter
               AND  yearend~Serviceproduct      = trueup~Serviceproduct
               AND  yearend~Receivingentity     = trueup~Receivingentity
               AND  yearend~ReceiverCompanyCode = trueup~ReceiverCompanyCode
               AND  yearend~ReceiverCostObject  = trueup~ReceiverCostObject
               AND  yearend~ReceiverCostCenter  = trueup~ReceiverCostCenter
             WHERE yearend~Legalentity         IN @_legalentity
              AND  yearend~ccode               IN @_ccode
              AND  yearend~Costobject          IN @_costobject
              AND  yearend~Costcenter          IN @_costcenter
              AND  yearend~Serviceproduct      IN @_serviceproduct
              AND  yearend~Receivingentity     IN @_receivingentity
              AND  yearend~ReceiverCompanyCode IN @_recccode
              AND  yearend~ReceiverCostObject  IN @_reccostobject
              AND  yearend~ReceiverCostCenter  IN @_reccostcenter
              AND  Currencytype        IN @_currencytype
              AND  Yearendamount       <> 0
              INTO CORRESPONDING FIELDS OF TABLE @lt_result.

        ENDIF.

        CLEAR lt_fin_result.
        IF sort_elements IS NOT INITIAL.
          SELECT (lv_req_elements)
                 FROM @lt_result AS result
                 GROUP BY (lv_grouping)
                 ORDER BY (lv_sort_string)
                 INTO CORRESPONDING FIELDS OF TABLE @lt_fin_result
                 OFFSET @lv_offset UP TO @lv_max_rows ROWS.
        ELSE.
          SELECT (lv_req_elements)
                 FROM @lt_result AS result
                 GROUP BY (lv_grouping)
                 INTO CORRESPONDING FIELDS OF TABLE @lt_fin_result.
        ENDIF.

***fill response
        io_response->set_data( lt_fin_result ).
*
**request count
        IF io_request->is_total_numb_of_rec_requested( ).
**select count
**fill response
          io_response->set_total_number_of_records( lines( lt_result ) ).
        ENDIF.

      CATCH cx_rap_query_provider.

    ENDTRY.
  ENDMETHOD.

ENDCLASS.
