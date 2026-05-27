CLASS /esrcc/cl_app_upd_from_wf_cbc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS update_stewardship
      IMPORTING
        it_leading_data TYPE /esrcc/tt_wf_leadingobject
        iv_wi_id        TYPE /esrcc/workflowid
        iv_status       TYPE /esrcc/status_de
        iv_user         TYPE syst-uname OPTIONAL
        iv_comment      TYPE /esrcc/comment OPTIONAL.
    CLASS-METHODS update_co_rule
      IMPORTING
        it_leading_data TYPE /esrcc/tt_wf_leadingobject
        iv_wi_id        TYPE /esrcc/workflowid
        iv_status       TYPE /esrcc/status_de
        iv_user         TYPE syst-uname OPTIONAL
        iv_comment      TYPE /esrcc/comment OPTIONAL.
    CLASS-METHODS update_service_markup
      IMPORTING
        it_leading_data TYPE /esrcc/tt_wf_leadingobject
        iv_wi_id        TYPE /esrcc/workflowid
        iv_status       TYPE /esrcc/status_de
        iv_user         TYPE syst-uname OPTIONAL
        iv_comment      TYPE /esrcc/comment OPTIONAL.
    CLASS-METHODS update_hier_def
      IMPORTING
        it_leading_data TYPE /esrcc/tt_wf_leadingobject_bc
        iv_wi_id        TYPE /esrcc/workflowid
        iv_status       TYPE /esrcc/status_de
        iv_user         TYPE syst-uname OPTIONAL
        iv_comment      TYPE /esrcc/comment OPTIONAL.
    CLASS-METHODS update_hierarchy
      IMPORTING
        it_leading_data TYPE /esrcc/tt_wf_leadingobject_bc
        iv_wi_id        TYPE /esrcc/workflowid
        iv_status       TYPE /esrcc/status_de
        iv_user         TYPE syst-uname OPTIONAL
        iv_comment      TYPE /esrcc/comment OPTIONAL.
    CLASS-METHODS update_ce_char
      IMPORTING
        it_leading_data TYPE /esrcc/tt_wf_leadingobject_bc
        iv_wi_id        TYPE /esrcc/workflowid
        iv_status       TYPE /esrcc/status_de
        iv_user         TYPE syst-uname OPTIONAL
        iv_comment      TYPE /esrcc/comment OPTIONAL.
    CLASS-METHODS update_allocation_key
      IMPORTING
        it_leading_data TYPE /esrcc/tt_wf_leadingobject_bc
        iv_wi_id        TYPE /esrcc/workflowid
        iv_status       TYPE /esrcc/status_de
        iv_user         TYPE syst-uname OPTIONAL
        iv_comment      TYPE /esrcc/comment OPTIONAL.
    CLASS-METHODS update_royalty_base
      IMPORTING
        it_leading_data TYPE /esrcc/tt_wf_leadingobject_bc
        iv_wi_id        TYPE /esrcc/workflowid
        iv_status       TYPE /esrcc/status_de
        iv_user         TYPE syst-uname OPTIONAL
        iv_comment      TYPE /esrcc/comment OPTIONAL.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /esrcc/cl_app_upd_from_wf_cbc IMPLEMENTATION.




  METHOD update_co_rule.
    DATA lr_rule_id TYPE RANGE OF /esrcc/chargeout_rule_id.

    CHECK it_leading_data IS NOT INITIAL.
    lr_rule_id = VALUE #( FOR rule IN it_leading_data ( sign = 'I' option = 'EQ' low = rule-rule_id ) ).

    UPDATE /esrcc/co_rule SET workflow_id     = @iv_wi_id,
                              workflow_status = @iv_status,
                              last_changed_by = @iv_user
                          WHERE rule_id IN @lr_rule_id.

    IF sy-subrc = 0 AND iv_comment IS NOT INITIAL.
      SELECT DISTINCT rule~comment_id AS comment_id
        FROM /esrcc/co_rule AS rule
        INNER JOIN @it_leading_data AS lobj
          ON  lobj~rule_id = rule~rule_id
        INTO TABLE @DATA(lt_comment).

      LOOP AT lt_comment INTO DATA(ls_comment).
        /esrcc/cl_comments_util=>modify_comments(
          comments    = VALUE #( instanceid = ls_comment-comment_id worfklow_id = iv_wi_id created_by = iv_user last_changed_by = iv_user status = iv_status )
          iv_comments = iv_comment
        ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD update_service_markup.
    DATA lt_markup TYPE TABLE OF /esrcc/srvmkp.

    CHECK it_leading_data IS NOT INITIAL.

    SELECT mkp~*
      FROM /esrcc/srvmkp AS mkp
      INNER JOIN @it_leading_data AS lobj
        ON  lobj~serviceproduct = mkp~serviceproduct
        AND lobj~valid_from     = mkp~validfrom
      INTO CORRESPONDING FIELDS OF TABLE @lt_markup.

    MODIFY lt_markup FROM VALUE #( workflow_id = iv_wi_id workflow_status = iv_status last_changed_by = iv_user )
      TRANSPORTING workflow_id workflow_status last_changed_by
      WHERE serviceproduct IS NOT INITIAL.

    UPDATE /esrcc/srvmkp FROM TABLE @lt_markup.

    IF sy-subrc = 0 AND iv_comment IS NOT INITIAL.
      SORT lt_markup BY comment_id.
      DELETE ADJACENT DUPLICATES FROM lt_markup COMPARING comment_id.
      LOOP AT lt_markup INTO DATA(markup) GROUP BY ( comment_id = markup-comment_id ) INTO DATA(comment_id).
        /esrcc/cl_comments_util=>modify_comments(
          comments    = VALUE #( instanceid = comment_id-comment_id worfklow_id = iv_wi_id created_by = iv_user last_changed_by = iv_user status = iv_status )
          iv_comments = iv_comment
        ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD update_stewardship.
    DATA lr_stewardship_uuid TYPE RANGE OF sysuuid_x16.

    CHECK it_leading_data IS NOT INITIAL.
    lr_stewardship_uuid = VALUE #( FOR stw IN it_leading_data ( sign = 'I' option = 'EQ' low = stw-stewardship_uuid ) ).

    UPDATE /esrcc/stewrdshp SET workflow_id     = @iv_wi_id,
                                workflow_status = @iv_status,
                                last_changed_by = @iv_user
*                              last_changed_at = @sy-timlo
      WHERE stewardship_uuid IN @lr_stewardship_uuid.

    IF sy-subrc = 0 AND iv_comment IS NOT INITIAL.
      SELECT DISTINCT stw~comment_id AS comment_id
        FROM /esrcc/stewrdshp AS stw
        INNER JOIN @it_leading_data AS lobj
          ON  lobj~stewardship_uuid = stw~stewardship_uuid
        INTO TABLE @DATA(lt_comment).

      LOOP AT lt_comment INTO DATA(ls_comment).
        /esrcc/cl_comments_util=>modify_comments(
          comments    = VALUE #( instanceid = ls_comment-comment_id worfklow_id = iv_wi_id created_by = iv_user last_changed_by = iv_user status = iv_status )
          iv_comments = iv_comment
        ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD update_hier_def.
    DATA lt_hier_def TYPE TABLE OF /esrcc/hier_def.

    CHECK it_leading_data IS NOT INITIAL.

    SELECT FROM /esrcc/hier_def AS hd
      INNER JOIN @it_leading_data AS lobj
        ON  lobj~hierarchy1 = hd~hierarchy1
        AND lobj~hierarchy2 = hd~hierarchy2
        AND lobj~hierarchy3 = hd~hierarchy3
        AND lobj~hierarchy4 = hd~hierarchy4
        AND lobj~valid_from = hd~valid_from
      FIELDS hd~*
      INTO CORRESPONDING FIELDS OF TABLE @lt_hier_def.

    MODIFY lt_hier_def FROM VALUE #( workflow_id = iv_wi_id workflow_status = iv_status last_changed_by = iv_user )
      TRANSPORTING workflow_id workflow_status last_changed_by
      WHERE valid_from IS NOT INITIAL.

    UPDATE /esrcc/hier_def FROM TABLE @lt_hier_def.

    IF sy-subrc = 0 AND iv_comment IS NOT INITIAL.
      SORT lt_hier_def BY comment_id.
      DELETE ADJACENT DUPLICATES FROM lt_hier_def COMPARING comment_id.
      LOOP AT lt_hier_def INTO DATA(hier_def) GROUP BY ( comment_id = hier_def-comment_id ) INTO DATA(comment_id).
        /esrcc/cl_comments_util=>modify_comments(
          comments    = VALUE #( instanceid = comment_id-comment_id worfklow_id = iv_wi_id created_by = iv_user last_changed_by = iv_user status = iv_status )
          iv_comments = iv_comment
        ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD update_hierarchy.
    DATA lt_hierarchy TYPE TABLE OF /esrcc/hier1.

    CHECK it_leading_data IS NOT INITIAL.

    SELECT FROM /esrcc/hier1 AS hier
      INNER JOIN @it_leading_data AS lobj
        ON lobj~hierarchy1 = hier~hierarchy
      FIELDS hier~*
      INTO CORRESPONDING FIELDS OF TABLE @lt_hierarchy.

    MODIFY lt_hierarchy FROM VALUE #( workflow_id = iv_wi_id workflow_status = iv_status last_changed_by = iv_user )
      TRANSPORTING workflow_id workflow_status last_changed_by
      WHERE hierarchy IS NOT INITIAL.

    UPDATE /esrcc/hier1 FROM TABLE @lt_hierarchy.

    IF sy-subrc = 0 AND iv_comment IS NOT INITIAL.
      SORT lt_hierarchy BY comment_id.
      DELETE ADJACENT DUPLICATES FROM lt_hierarchy COMPARING comment_id.
      LOOP AT lt_hierarchy INTO DATA(hier) GROUP BY ( comment_id = hier-comment_id ) INTO DATA(comment_id).
        /esrcc/cl_comments_util=>modify_comments(
          comments    = VALUE #( instanceid = comment_id-comment_id worfklow_id = iv_wi_id created_by = iv_user last_changed_by = iv_user status = iv_status )
          iv_comments = iv_comment
        ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD update_ce_char.
    DATA lt_ce_char TYPE TABLE OF /esrcc/cstelmtch.

    CHECK it_leading_data IS NOT INITIAL.

    SELECT FROM /esrcc/cstelmtch AS ce
      INNER JOIN @it_leading_data AS lobj
        ON  lobj~cost_element_char_uuid = ce~cst_elmnt_char_uuid
      FIELDS ce~*
      INTO CORRESPONDING FIELDS OF TABLE @lt_ce_char.

    MODIFY lt_ce_char FROM VALUE #( workflow_id = iv_wi_id workflow_status = iv_status last_changed_by = iv_user )
      TRANSPORTING workflow_id workflow_status last_changed_by
      WHERE valid_from IS NOT INITIAL.

    UPDATE /esrcc/cstelmtch FROM TABLE @lt_ce_char.

    IF sy-subrc = 0 AND iv_comment IS NOT INITIAL.
      SORT lt_ce_char BY comment_id.
      DELETE ADJACENT DUPLICATES FROM lt_ce_char COMPARING comment_id.
      LOOP AT lt_ce_char INTO DATA(ce_char) GROUP BY ( comment_id = ce_char-comment_id ) INTO DATA(comment_id).
        /esrcc/cl_comments_util=>modify_comments(
          comments    = VALUE #( instanceid = comment_id-comment_id worfklow_id = iv_wi_id created_by = iv_user last_changed_by = iv_user status = iv_status )
          iv_comments = iv_comment
        ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD update_allocation_key.
    DATA lt_allocation_key TYPE TABLE OF /esrcc/allockeys.

    CHECK it_leading_data IS NOT INITIAL.

    SELECT FROM /esrcc/allockeys AS ak
      INNER JOIN @it_leading_data AS lobj
        ON lobj~allocation_key = ak~allocationkey
      FIELDS ak~*
      INTO CORRESPONDING FIELDS OF TABLE @lt_allocation_key.

    MODIFY lt_allocation_key FROM VALUE #( workflow_id = iv_wi_id workflow_status = iv_status last_changed_by = iv_user )
      TRANSPORTING workflow_id workflow_status last_changed_by
      WHERE allocationkey IS NOT INITIAL.

    UPDATE /esrcc/allockeys FROM TABLE @lt_allocation_key.

    IF sy-subrc = 0 AND iv_comment IS NOT INITIAL.
      SORT lt_allocation_key BY comment_id.
      DELETE ADJACENT DUPLICATES FROM lt_allocation_key COMPARING comment_id.
      LOOP AT lt_allocation_key INTO DATA(alloc_key) GROUP BY ( comment_id = alloc_key-comment_id ) INTO DATA(comment_id).
        /esrcc/cl_comments_util=>modify_comments(
          comments    = VALUE #( instanceid = comment_id-comment_id worfklow_id = iv_wi_id created_by = iv_user last_changed_by = iv_user status = iv_status )
          iv_comments = iv_comment
        ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD update_royalty_base.
    DATA lt_royalty_key TYPE TABLE OF /esrcc/roykey.

    CHECK it_leading_data IS NOT INITIAL.

    SELECT FROM /esrcc/roykey AS rk
      INNER JOIN @it_leading_data AS lobj
        ON  lobj~royalty_base_key = rk~royalty_base_key
      FIELDS rk~*
      INTO CORRESPONDING FIELDS OF TABLE @lt_royalty_key.

    MODIFY lt_royalty_key FROM VALUE #( workflow_id = iv_wi_id workflow_status = iv_status last_changed_by = iv_user )
      TRANSPORTING workflow_id workflow_status last_changed_by
      WHERE royalty_base_key IS NOT INITIAL.

    UPDATE /esrcc/roykey FROM TABLE @lt_royalty_key.

    IF sy-subrc = 0 AND iv_comment IS NOT INITIAL.
      SORT lt_royalty_key BY comment_id.
      DELETE ADJACENT DUPLICATES FROM lt_royalty_key COMPARING comment_id.
      LOOP AT lt_royalty_key INTO DATA(roy_key) GROUP BY ( comment_id = roy_key-comment_id ) INTO DATA(comment_id).
        /esrcc/cl_comments_util=>modify_comments(
          comments    = VALUE #( instanceid = comment_id-comment_id worfklow_id = iv_wi_id created_by = iv_user last_changed_by = iv_user status = iv_status )
          iv_comments = iv_comment
        ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
