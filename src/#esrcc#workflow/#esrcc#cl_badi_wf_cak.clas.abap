CLASS /esrcc/cl_badi_wf_cak DEFINITION
  PUBLIC
  INHERITING FROM /esrcc/cl_badi_wf_cbc
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS /esrcc/if_badi_workflow_bc~set_wf_task_title REDEFINITION.
    METHODS /esrcc/if_badi_workflow_bc~set_wf_task_description REDEFINITION.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS build_allocation_key
      IMPORTING
        it_leading_object TYPE /esrcc/tt_wf_leadingobject_bc
      CHANGING
        ct_task_desc      TYPE /esrcc/tt_wf_st_len.
ENDCLASS.



CLASS /ESRCC/CL_BADI_WF_CAK IMPLEMENTATION.


  METHOD /esrcc/if_badi_workflow_bc~set_wf_task_title.
    CLEAR: ev_header.

    READ TABLE it_leading_object INTO DATA(ls_leading_object) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

*   Get allocation key with descriptions
    SELECT SINGLE FROM /esrcc/i_allocationkey
      FIELDS allocationkey,
             \_allocationkeytext[ spras = @sy-langu ]-description
      WHERE allocationkey = @ls_leading_object-allocation_key
      INTO @DATA(ls_allocation_key).

*   Create Workflow Title
    ev_header = |{ TEXT-001 }: { ls_allocation_key-allocationkey } ({ ls_allocation_key-description })|.
  ENDMETHOD.


  METHOD /esrcc/if_badi_workflow_bc~set_wf_task_description.
    CLEAR et_task_desc.

    build_allocation_key(
      EXPORTING
        it_leading_object = it_leading_object
      CHANGING
        ct_task_desc      = et_task_desc ).
  ENDMETHOD.


  METHOD build_allocation_key.
    CONSTANTS lc_entity_name TYPE sxco_cds_object_name VALUE '/ESRCC/C_ALLOCATIONKEY'.

*   Get allocation key with descriptions
    SELECT FROM /esrcc/i_allocationkey AS alloc_key
      INNER JOIN @it_leading_object AS lobj
        ON lobj~allocation_key = alloc_key~allocationkey
      FIELDS alloc_key~allocationkey,
             alloc_key~\_allocationkeytext[ spras = @sy-langu ]-description,
             alloc_key~commentid
      INTO TABLE @DATA(lt_alloc_key).

*   Get fieldname descriptions
    DATA(lo_html) = NEW /esrcc/cl_wf_html(
      cds_entity_name = lc_entity_name
      fields          = VALUE #( ( field_name = 'ALLOCATIONKEY' data_element = '/ESRCC/ALLOCKEY' )
                                 ( field_name = 'COMMENTS'      data_element = '/ESRCC/COMMENT' ) ) ).

    APPEND |<h2>{ TEXT-001 }</h2>| TO ct_task_desc.

    APPEND lo_html->html_tag_new_table( ) TO ct_task_desc.
    LOOP AT lt_alloc_key INTO DATA(ls_alloc_key).
      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'ALLOCATIONKEY'
                        iv_id        = CONV #( ls_alloc_key-allocationkey )
                        iv_id_desc   = CONV #( ls_alloc_key-description )
                      ) TO ct_task_desc.

      /esrcc/cl_comments_util=>read_comments(
        EXPORTING
          instanceid = ls_alloc_key-commentid
        IMPORTING
          comments   = DATA(comments)
      ).

      DELETE comments WHERE workflow_id IS NOT INITIAL.
      APPEND LINES OF lo_html->generate_table_line(
                      iv_fieldname = 'COMMENTS'
                      iv_id        = VALUE #( comments[ 1 ]-wfcommenttext OPTIONAL )
                    ) TO ct_task_desc.
    ENDLOOP.

    APPEND '</table>' TO ct_task_desc.
  ENDMETHOD.
ENDCLASS.
