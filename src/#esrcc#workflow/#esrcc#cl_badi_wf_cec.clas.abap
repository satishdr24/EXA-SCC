CLASS /esrcc/cl_badi_wf_cec DEFINITION
  PUBLIC
    INHERITING FROM /esrcc/cl_badi_wf_cbc
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS /esrcc/if_badi_workflow_bc~set_wf_task_title REDEFINITION.
    METHODS /esrcc/if_badi_workflow_bc~set_wf_task_description REDEFINITION.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS build_ce_char
      IMPORTING
        it_leading_object TYPE /esrcc/tt_wf_leadingobject_bc
      CHANGING
        ct_task_desc      TYPE /esrcc/tt_wf_st_len.
ENDCLASS.



CLASS /esrcc/cl_badi_wf_cec IMPLEMENTATION.

  METHOD /esrcc/if_badi_workflow_bc~set_wf_task_title.
    CLEAR: ev_header.

    READ TABLE it_leading_object INTO DATA(ls_leading_object) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

*   Get cost element characteristics with descriptions
    SELECT SINGLE FROM /esrcc/i_costelmenetcharacte
      FIELDS sysid,
             \_ccodetext-sysiddescription AS sysid_desc,
             legalentity,
             \_ccodetext-legalentitydescription AS legalentity_desc,
             companycode,
             \_ccodetext-ccodedescription AS ccode_desc,
             costobject,
             \_costobjecttext-costobjectdescription AS costobject_desc,
             costcenter,
             \_costobjecttext-description AS costcenter_desc,
             costelementfrom,
             \_costelementtext-description AS costelement_desc,
             costelementto,
             \_costelementtotext-description AS costelementto_desc,
             validfrom,
             validto,
             active,
             costtype,
             \_costtypetext-text AS costtype_desc,
             postingtype,
             \_postingtypetext-text AS postingtype_desc,
             costindicator,
             \_costindtext-text AS costindicator_desc,
             usagetype,
             \_usagetypetext-text AS usagetype_desc,
             reasonid,
             \_reasontext-reasondescription AS reason_desc,
             valuesource,
             \_valuesourcetext-text AS valuesource_desc,
             commentid
      WHERE cstelmntcharuuid = @ls_leading_object-cost_element_char_uuid
      INTO @DATA(ls_ce_char).

*   Create Workflow Title
    DATA(lv_cost_element_info) = |{ ls_ce_char-costelementfrom } ({ ls_ce_char-costelement_desc })|.
    IF ls_ce_char-costelementfrom <> ls_ce_char-costelementto.
      lv_cost_element_info = lv_cost_element_info && | - { ls_ce_char-costelementto } ({ ls_ce_char-costelementto_desc })|.
    ENDIF.
    ev_header = |{ TEXT-001 }: { lv_cost_element_info }|.
  ENDMETHOD.

  METHOD /esrcc/if_badi_workflow_bc~set_wf_task_description.
    CLEAR et_task_desc.

    build_ce_char(
      EXPORTING
        it_leading_object = it_leading_object
      CHANGING
        ct_task_desc      = et_task_desc ).
  ENDMETHOD.

  METHOD build_ce_char.
    CONSTANTS lc_entity_name TYPE sxco_cds_object_name VALUE '/ESRCC/C_COSTELMENETCHARACTE'.

*   Get royalty key with descriptions
    SELECT FROM /esrcc/i_costelmenetcharacte AS char
      INNER JOIN @it_leading_object AS lobj
        ON lobj~cost_element_char_uuid = char~cstelmntcharuuid
      FIELDS char~sysid,
             char~\_ccodetext-sysiddescription AS sysid_desc,
             char~legalentity,
             char~\_ccodetext-legalentitydescription AS legalentity_desc,
             char~companycode,
             char~\_ccodetext-ccodedescription AS companycode_desc,
             char~costobject,
             char~\_costobjecttext-costobjectdescription AS costobject_desc,
             char~costcenter,
             char~\_costobjecttext-description AS costcenter_desc,
             char~costelementfrom,
             char~\_costelementtext-description AS costelementfrom_desc,
             char~costelementto,
             char~\_costelementtotext-description AS costelementto_desc,
             char~validfrom,
             char~validto,
             char~active,
             char~costtype,
             char~\_costtypetext-text AS costtype_desc,
             char~postingtype,
             char~\_postingtypetext-text AS postingtype_desc,
             char~costindicator,
             char~\_costindtext-text AS costindicator_desc,
             char~usagetype,
             char~\_usagetypetext-text AS usagetype_desc,
             char~reasonid,
             char~\_reasontext-reasondescription AS reason_desc,
             char~valuesource,
             char~\_valuesourcetext-text AS valuesource_desc,
             char~commentid
      INTO TABLE @DATA(lt_ce_char).

*   Get fieldname descriptions
    DATA(lo_html) = NEW /esrcc/cl_wf_html(
      cds_entity_name = lc_entity_name
      fields          = VALUE #( ( field_name = 'SYSID'           data_element = '/ESRCC/SYSID' )
                                 ( field_name = 'LEGALENTITY'     data_element = '/ESRCC/LEGALENTITY' )
                                 ( field_name = 'COMPANYCODE'     data_element = '/ESRCC/CCODE_DE' )
                                 ( field_name = 'COSTOBJECT'      data_element = '/ESRCC/COSTOBJECT_DE' )
                                 ( field_name = 'COSTCENTER'      data_element = '/ESRCC/COSTCENTER' )
                                 ( field_name = 'COSTELEMENTFROM' data_element = '/ESRCC/COSTELEMENT_FROM' )
                                 ( field_name = 'COSTELEMENTTO'   data_element = '/ESRCC/COSTELEMENT_TO' )
                                 ( field_name = 'ACTIVE'          data_element = '/ESRCC/ACTIVEERP' )
                                 ( field_name = 'COSTTYPE'        data_element = '/ESRCC/COSTTYPE_DE' )
                                 ( field_name = 'POSTINGTYPE'     data_element = '/ESRCC/POSTINGTYPE_DE' )
                                 ( field_name = 'COSTINDICATOR'   data_element = '/ESRCC/COSTIND_DE' )
                                 ( field_name = 'USAGETYPE'       data_element = '/ESRCC/USAGE' )
                                 ( field_name = 'REASONID'        data_element = '/ESRCC/REASONID' )
                                 ( field_name = 'VALUESOURCE'     data_element = '/ESRCC/VALUE_SOURCE' )
                                 ( field_name = 'COMMENTS'        data_element = '/ESRCC/COMMENT' ) ) ).

    APPEND |<h2>{ TEXT-001 }</h2>| TO ct_task_desc.

    APPEND lo_html->html_tag_new_table( ) TO ct_task_desc.
    LOOP AT lt_ce_char INTO DATA(ls_ce_char).
      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'SYSID'
                        iv_id        = CONV #( ls_ce_char-sysid )
                        iv_id_desc   = CONV #( ls_ce_char-sysid_desc )
                      ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'LEGALENTITY'
                        iv_id        = CONV #( ls_ce_char-legalentity )
                        iv_id_desc   = CONV #( ls_ce_char-legalentity_desc )
                      ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'COMPANYCODE'
                        iv_id        = CONV #( ls_ce_char-companycode )
                        iv_id_desc   = CONV #( ls_ce_char-companycode_desc )
                      ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'COSTOBJECT'
                        iv_id        = CONV #( ls_ce_char-costobject )
                        iv_id_desc   = CONV #( ls_ce_char-costobject_desc )
                      ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'COSTCENTER'
                        iv_id        = CONV #( ls_ce_char-costcenter )
                        iv_id_desc   = CONV #( ls_ce_char-costcenter_desc )
                      ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'COSTELEMENTFROM'
                        iv_id        = CONV #( ls_ce_char-costelementfrom )
                        iv_id_desc   = CONV #( ls_ce_char-costelementfrom_desc )
                      ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'COSTELEMENTTO'
                        iv_id        = CONV #( ls_ce_char-costelementto )
                        iv_id_desc   = CONV #( ls_ce_char-costelementto_desc )
                      ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                      iv_fieldname = TEXT-002
                      iv_id        = |{ ls_ce_char-validfrom DATE = ENVIRONMENT } - { ls_ce_char-validto DATE = ENVIRONMENT }|
                    ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'COSTTYPE'
                        iv_id        = CONV #( ls_ce_char-costtype )
                        iv_id_desc   = CONV #( ls_ce_char-costtype_desc )
                      ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'POSTINGTYPE'
                        iv_id        = CONV #( ls_ce_char-postingtype )
                        iv_id_desc   = CONV #( ls_ce_char-postingtype_desc )
                      ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'COSTINDICATOR'
                        iv_id        = CONV #( ls_ce_char-costindicator )
                        iv_id_desc   = CONV #( ls_ce_char-costindicator_desc )
                      ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'USAGETYPE'
                        iv_id        = CONV #( ls_ce_char-usagetype )
                        iv_id_desc   = CONV #( ls_ce_char-usagetype_desc )
                      ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'REASONID'
                        iv_id        = CONV #( ls_ce_char-reasonid )
                        iv_id_desc   = CONV #( ls_ce_char-reason_desc )
                      ) TO ct_task_desc.

      APPEND LINES OF lo_html->generate_table_line(
                        iv_fieldname = 'VALUESOURCE'
                        iv_id        = CONV #( ls_ce_char-valuesource )
                        iv_id_desc   = CONV #( ls_ce_char-valuesource_desc )
                      ) TO ct_task_desc.

      /esrcc/cl_comments_util=>read_comments(
        EXPORTING
          instanceid = ls_ce_char-commentid
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
