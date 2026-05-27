class /ESRCC/RR_SO_CREATE definition
  public
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /ESRCC/IF_RR_CREATE_SO_BADI .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS: BEGIN OF _status,
                 send_for_so_creation TYPE c LENGTH 1 VALUE 'S',
                 available            TYPE c LENGTH 1 VALUE 'A',
                 finalized            TYPE c LENGTH 1 VALUE 'F',
               END OF _status.
    CONSTANTS _msg_id TYPE cl_bali_message_setter=>ty_id VALUE '/ESRCC/RR'.

    METHODS:  _get_msg IMPORTING msg_no          TYPE cl_bali_message_setter=>ty_id
                                 var1            TYPE  cl_bali_message_setter=>ty_variable OPTIONAL
                                 var2            TYPE  cl_bali_message_setter=>ty_variable OPTIONAL
                       RETURNING VALUE(msg_text) TYPE /esrcc/api_message .
ENDCLASS.



CLASS /ESRCC/RR_SO_CREATE IMPLEMENTATION.


  METHOD /esrcc/if_rr_create_so_badi~create_so.
    TYPES: BEGIN OF _rank,
             header_rank TYPE int8,
             item_rank   TYPE int8,
           END OF _rank.
    TYPES: BEGIN OF _rr_li_with_rank.
             INCLUDE TYPE /esrcc/rr_li.
             INCLUDE TYPE _rank.
    TYPES: END OF _rr_li_with_rank.



    DATA line_items TYPE STANDARD TABLE OF _rr_li_with_rank.
    DATA where_cond TYPE string.
    DATA error_flag TYPE string.

    TRY.

        " Fetching group by config
        SELECT SINGLE group_by      AS header,
                      group_by_item AS item,
                      item_count
          FROM /esrcc/rr_soconf
          WHERE group_by_key = @grp_by_key
          INTO @DATA(group_by_config).

        IF sy-subrc <> 0.
          TRY.
              log->add_item( cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_error
                                                             id       = _msg_id
                                                             number   = 002 ) ). " 'Entered Group By is invalid'
              RETURN.
            CATCH cx_bali_runtime.
          ENDTRY.
        ENDIF.

        FINAL(group_by_header_str) = |{ group_by_config-header },SALESORDER_REFERENCE,STATUS,GROUPCURR,LOCALCURR,MEINS|.
        FINAL(group_by_field_str) = |{ group_by_config-header },{ group_by_config-item },SALESORDER_REFERENCE,STATUS,GROUPCURR,LOCALCURR,MEINS|.
        SPLIT group_by_field_str AT ',' INTO TABLE DATA(group_by_fields).

        LOOP AT group_by_fields ASSIGNING FIELD-SYMBOL(<field_name>).
          CONDENSE <field_name> NO-GAPS.
        ENDLOOP.

        FINAL(selection_fields) = |{ group_by_field_str },SUM( KSL ) as KSL, SUM( HSL ) as HSL, SUM( QUANTITY ) AS QUANTITY, | &&
                                  |DENSE_RANK( )  OVER(  ORDER BY { group_by_header_str } )     AS header_rank,| &&
                                  |DENSE_RANK( )  OVER( PARTITION BY { group_by_header_str } ORDER BY { group_by_config-item } ) AS item_rank|.

        " Fetching RR line Items to update Status and  Sales order reference
        SELECT (selection_fields) FROM /esrcc/rr_li
          WHERE status = @_status-available OR status = @/esrcc/if_const_msg=>error
          GROUP BY (group_by_field_str)
          ORDER BY (group_by_field_str)
          INTO CORRESPONDING FIELDS OF TABLE @line_items.

        IF sy-subrc <> 0.
          TRY.
              log->add_item( cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_warning
                                                             id       = _msg_id
                                                             number   = 003 ) ). " 'No lines exist with status Available'
              RETURN.
            CATCH cx_bali_runtime.
          ENDTRY.
        ENDIF.

        DATA(rank) = 0.
        DATA(header_count) = 0.
        DATA(item_count) = 1.

        " Update Status and  Sales order reference - for each dynamic groupings
        LOOP AT line_items ASSIGNING FIELD-SYMBOL(<rr_lineitem>).
          FINAL(index) = sy-tabix.

          " Header changes / Item count exceeds
          IF <rr_lineitem>-header_rank <> rank OR item_count >= group_by_config-item_count.

            /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = DATA(time_stamp) ).
            rank = <rr_lineitem>-header_rank.
            header_count += 1.
            FINAL(so_ref_no) = cl_system_uuid=>create_uuid_c32_static( ).

            " POPULATE HEADER DETAILS
            "---------------------------------------------
            "---------------------------------------------

            CLEAR item_count.
          ENDIF.

          " Populate item Details

          item_count += 1.
          IF <rr_lineitem>-status = _status-available.
            <rr_lineitem>-salesorder_reference = so_ref_no.
          ENDIF.
          <rr_lineitem>-so_item = item_count.
          "---------------------------------------------
          "---------------------------------------------

*          " Populating dynamic where
          CLEAR where_cond.
          LOOP AT group_by_fields ASSIGNING <field_name> WHERE table_line <> 'SALESORDER_REFERENCE'.

            ASSIGN COMPONENT <field_name> OF STRUCTURE <rr_lineitem> TO FIELD-SYMBOL(<field_value>) ELSE UNASSIGN.
            IF where_cond IS INITIAL.
              where_cond = |{ <field_name> } = '{ <field_value> }' |.
            ELSE.
              where_cond = |{ where_cond } AND { <field_name> } = '{ <field_value> }' |.
            ENDIF.

          ENDLOOP.

          " Status Available Case
          IF <rr_lineitem>-status = _status-available.
            UPDATE /esrcc/rr_li SET status = @_status-send_for_so_creation,
                                    salesorder_reference = @<rr_lineitem>-salesorder_reference,
                                    so_item = @<rr_lineitem>-so_item,
                                    last_changed_at = @time_stamp,
                                    last_changed_by = @sy-uname
                                 WHERE (where_cond).
          ELSE.
            " Status Failed Case - From Previous SO creation
            UPDATE /esrcc/rr_li SET status = @_status-send_for_so_creation,
                                     so_item = @<rr_lineitem>-so_item,
                                     last_changed_at = @time_stamp,
                                     last_changed_by = @sy-uname
                                  WHERE (where_cond).
          ENDIF.

          " Once Item Population is done( No new item/Next header changes/item count reaches). Call API for SO Creation
          IF ( NOT line_exists( line_items[ index + 1 ] ) ) OR line_items[ index + 1 ]-header_rank <> rank OR item_count >= group_by_config-item_count.
            " IMPLEMENT THE SO CREATION LOGIC HERE - update the table back based on so ref no
            "---------------------------------------------
            "---------------------------------------------
          ENDIF.

        ENDLOOP.
      CATCH cx_uuid_error
            cx_root INTO DATA(lref_error).
        error_flag = abap_true.
        TRY.
            log->add_item( cl_bali_message_setter=>create(
                               severity   = if_bali_constants=>c_severity_error
                               id         = _msg_id
                               number     = 000
                               variable_1 = CONV cl_bali_message_setter=>ty_variable( lref_error->get_text( ) ) ) ).
          CATCH cx_bali_runtime.
        ENDTRY.

    ENDTRY.

    TRY.
        IF error_flag = abap_false.
          log->add_item( cl_bali_message_setter=>create(
                             severity   = if_bali_constants=>c_severity_status
                             id         = _msg_id
                             number     = 004
                             variable_1 = CONV cl_bali_message_setter=>ty_variable( header_count  ) ) ). " 'records sent for SO creation
        ENDIF.
      CATCH cx_bali_runtime.
    ENDTRY.
  ENDMETHOD.


  METHOD /esrcc/if_rr_create_so_badi~update_so.

    CONSTANTS: BEGIN OF msg_no,
                 no5  TYPE cl_bali_message_setter=>ty_id VALUE '005',
                 no6  TYPE cl_bali_message_setter=>ty_id VALUE '006',
                 no7  TYPE cl_bali_message_setter=>ty_id VALUE '007',
                 no8  TYPE cl_bali_message_setter=>ty_id VALUE '008',
                 no9  TYPE cl_bali_message_setter=>ty_id VALUE '009',
                 no10 TYPE cl_bali_message_setter=>ty_id VALUE '010',
               END OF msg_no.


    IF so_detail-salesorder_number IS INITIAL OR so_detail-salesorder_reference IS INITIAL.

      response = VALUE #( Message_type = /esrcc/if_const_msg=>error
                          message      = _get_msg( msg_no-no5 ) ). " Sales Order Number and Reference is Mandatory'

    ELSEIF so_detail-so_created_by IS INITIAL OR so_detail-timestamp IS INITIAL.

      response = VALUE #( Message_type = /esrcc/if_const_msg=>error
                          message      = _get_msg( msg_no-no6 ) ). " SO Created By and time is Mandatory

    ELSE.
      SELECT salesorder_number, status
        FROM /esrcc/rr_li
        WHERE salesorder_reference = @so_detail-salesorder_reference
        ORDER BY salesorder_number, status
        INTO TABLE @FINAL(salesorders) UP TO 1 ROWS.

      IF sy-subrc = 0.
        FINAL(salesorder) = VALUE #( salesorders[ 1 ] OPTIONAL ).
        IF salesorder-status = _status-send_for_so_creation AND salesorder-salesorder_number IS INITIAL.

          UPDATE /esrcc/rr_li SET salesorder_number = @so_detail-salesorder_number,
                                  status = @_status-finalized,
                                  last_changed_by = @so_detail-so_created_by,
                                  last_changed_at = @so_detail-timestamp
                              WHERE salesorder_reference = @so_detail-salesorder_reference.

          IF sy-subrc = 0 AND sy-dbcnt > 0.
            response = VALUE #(
                Message_type = /esrcc/if_const_msg=>success
                message      = _get_msg(
                    msg_no = msg_no-no7
                    var1   = CONV cl_bali_message_setter=>ty_variable( so_detail-salesorder_number )
                    var2   = CONV cl_bali_message_setter=>ty_variable(  so_detail-salesorder_reference )  ) ). " SO &1 Updated Successfully for Reference No &2
          ELSE.
            response = VALUE #(
                Message_type = /esrcc/if_const_msg=>error
                message      = |{ _get_msg(
                                      msg_no = msg_no-no8
                                      var1   = CONV cl_bali_message_setter=>ty_variable( so_detail-salesorder_reference ) ) }| ). " Error in Updating SO details. SO Reference No :
          ENDIF.
        ELSE.
          response = VALUE #(
              Message_type = /esrcc/if_const_msg=>error
              message      = _get_msg(
                  msg_no = msg_no-no9
                  var1   = CONV cl_bali_message_setter=>ty_variable( salesorder-salesorder_number )
                  var2   = CONV cl_bali_message_setter=>ty_variable(  so_detail-salesorder_reference ) ) ). " SO already Created. SO : &1, SO Reference No: &2
        ENDIF.
      ELSE.
        response = VALUE #(
            Message_type = /esrcc/if_const_msg=>error
            message      = _get_msg(
                               msg_no = msg_no-no10
                               var1   = CONV cl_bali_message_setter=>ty_variable(  so_detail-salesorder_reference ) ) ). " Invalid SO Reference No : &1
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD _get_msg.
    MESSAGE ID _msg_id TYPE /esrcc/if_const_msg=>info NUMBER msg_no WITH var1 var2 INTO msg_text.
  ENDMETHOD.
ENDCLASS.
