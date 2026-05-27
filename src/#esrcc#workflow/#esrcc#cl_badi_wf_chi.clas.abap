CLASS /esrcc/cl_badi_wf_chi DEFINITION
  PUBLIC
  INHERITING FROM /esrcc/cl_badi_wf_cbc
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS /esrcc/if_badi_workflow_bc~set_wf_task_title REDEFINITION.
    METHODS /esrcc/if_badi_workflow_bc~set_wf_task_description REDEFINITION.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS build_hierarchy
      IMPORTING
        it_leading_object TYPE /esrcc/tt_wf_leadingobject_bc
      CHANGING
        ct_task_desc      TYPE /esrcc/tt_wf_st_len.
ENDCLASS.



CLASS /ESRCC/CL_BADI_WF_CHI IMPLEMENTATION.


  METHOD /esrcc/if_badi_workflow_bc~set_wf_task_title.
    CLEAR: ev_header.

    READ TABLE it_leading_object INTO DATA(ls_leading_object) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

*   Get hierarchy with descriptions
    SELECT SINGLE FROM /esrcc/i_hier1
      FIELDS hierarchy,
             \_hierarchytext[ spras = @sy-langu ]-description
      WHERE hierarchy = @ls_leading_object-hierarchy1
      INTO @DATA(ls_hierarchy).

*   Create Workflow Title
    ev_header = |{ TEXT-001 }: { ls_hierarchy-hierarchy } ({ ls_hierarchy-description })|.
  ENDMETHOD.


  METHOD /esrcc/if_badi_workflow_bc~set_wf_task_description.
    CLEAR et_task_desc.

    build_hierarchy(
      EXPORTING
        it_leading_object = it_leading_object
      CHANGING
        ct_task_desc      = et_task_desc ).
  ENDMETHOD.


  METHOD build_hierarchy.
    CONSTANTS lc_entity_name TYPE sxco_cds_object_name VALUE '/ESRCC/C_HIER1'.

*   Get chargeout rules with descriptions
    SELECT FROM /esrcc/i_hier1 AS hier
      INNER JOIN @it_leading_object AS lobj
        ON lobj~hierarchy1 = hier~hierarchy
      FIELDS hier~hierarchy,
             hier~\_hierarchytext[ spras = @sy-langu ]-description,
             hier~commentid
      INTO TABLE @DATA(lt_hier).

*   Get fieldname descriptions
    DATA(lo_html) = NEW /esrcc/cl_wf_html(
      cds_entity_name = lc_entity_name
      fields          = VALUE #( ( field_name = 'HIERARCHY' data_element = '/ESRCC/HIERARCHY1' )
                                 ( field_name = 'COMMENTS'  data_element = '/ESRCC/COMMENT' ) ) ).

    APPEND |<h2>{ TEXT-001 }</h2>| TO ct_task_desc.

    APPEND lo_html->html_tag_new_table( ) TO ct_task_desc.
    LOOP AT lt_hier INTO DATA(ls_hier).
      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'HIERARCHY'
                        iv_id        = CONV #( ls_hier-hierarchy )
                        iv_id_desc   = CONV #( ls_hier-description )
                      ) TO ct_task_desc.

      /esrcc/cl_comments_util=>read_comments(
        EXPORTING
          instanceid = ls_hier-commentid
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
