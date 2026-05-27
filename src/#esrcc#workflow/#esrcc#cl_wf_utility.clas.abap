CLASS /esrcc/cl_wf_utility DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      tt_workflow_status TYPE RANGE OF /esrcc/status_de .

    CONSTANTS:
      BEGIN OF c_wf_status,
        initial             TYPE /esrcc/status_de VALUE '',
        draft               TYPE /esrcc/status_de VALUE 'D',
        in_process          TYPE /esrcc/status_de VALUE 'P',
        approval_pending    TYPE /esrcc/status_de VALUE 'W',
        approved            TYPE /esrcc/status_de VALUE 'A',
        rejected            TYPE /esrcc/status_de VALUE 'R',
        finalize_in_process TYPE /esrcc/status_de VALUE 'J',
        finalize_in_error   TYPE /esrcc/status_de VALUE 'O',
        finalized           TYPE /esrcc/status_de VALUE 'F',
        failed              TYPE /esrcc/status_de VALUE 'E',
        reopen_in_process   TYPE /esrcc/status_de VALUE 'L',
      END OF c_wf_status,

      BEGIN OF c_app,
        cost_base_line_item     TYPE /esrcc/application_type_de VALUE 'CBL',
        stdchargeout            TYPE /esrcc/application_type_de VALUE 'STD',
        trueuprecal             TYPE /esrcc/application_type_de VALUE 'TRU',
        forecast                TYPE /esrcc/application_type_de VALUE 'FCA',
        adhoc_chargeout         TYPE /esrcc/application_type_de VALUE 'ADH',
        royalty_chargeout       TYPE /esrcc/application_type_de VALUE 'ROY',
        bc_stewardship          TYPE /esrcc/application_type_de VALUE 'CST',
        bc_charge_out_rule      TYPE /esrcc/application_type_de VALUE 'CCR',
        bc_product_markup       TYPE /esrcc/application_type_de VALUE 'CPM',
        bc_hierarchy_definition TYPE /esrcc/application_type_de VALUE 'CHD',
        bc_hierarchy            TYPE /esrcc/application_type_de VALUE 'CHI',
        bc_cost_elem_char       TYPE /esrcc/application_type_de VALUE 'CEC',
        bc_allocation_key       TYPE /esrcc/application_type_de VALUE 'CAK',
        bc_royalty_base         TYPE /esrcc/application_type_de VALUE 'CRB',
      END OF c_app,

      BEGIN OF c_groupby,
        provider TYPE /esrcc/wf_groupby VALUE 'P',
        receiver TYPE /esrcc/wf_groupby VALUE 'R',
      END OF c_groupby,

      BEGIN OF c_wf_appl_category,
        business_configuration TYPE /esrcc/wf_appl_category VALUE 'BC',
        others                 TYPE /esrcc/wf_appl_category VALUE '',
      END OF c_wf_appl_category,

      c_title_separator  TYPE c LENGTH 2 VALUE '||',
      c_title_separator2 TYPE c LENGTH 1 VALUE '|'.

    CLASS-METHODS is_wf_on
      IMPORTING
        !iv_apptype   TYPE /esrcc/application_type_de
      EXPORTING
        !ev_wf_active TYPE /esrcc/workflow_on .
    CLASS-METHODS wf_status_action_update
      RETURNING
        VALUE(rt_list) TYPE tt_workflow_status .
    CLASS-METHODS wf_status_action_delete
      RETURNING
        VALUE(rt_list) TYPE tt_workflow_status .
    CLASS-METHODS wf_status_action_submit
      RETURNING
        VALUE(rt_list) TYPE tt_workflow_status .
    CLASS-METHODS wf_status_action_copy
      RETURNING
        VALUE(rt_list) TYPE tt_workflow_status .
    CLASS-METHODS wf_status_action_copy_obj_page
      RETURNING
        VALUE(rt_list) TYPE tt_workflow_status .
    CLASS-METHODS wf_status_action_finalize
      RETURNING
        VALUE(rt_list) TYPE tt_workflow_status .
    CLASS-METHODS wf_status_action_reopen
      RETURNING
        VALUE(rt_list) TYPE tt_workflow_status .
    CLASS-METHODS wf_status_action_sync
      RETURNING
        VALUE(rt_list) TYPE tt_workflow_status .
    CLASS-METHODS wf_status_action_autogenerate
      RETURNING
        VALUE(rt_list) TYPE tt_workflow_status .
    CLASS-METHODS wf_status_criticality
      IMPORTING
        !status            TYPE /esrcc/status_de
      RETURNING
        VALUE(criticality) TYPE int1 .
    CLASS-METHODS wf_application_category
      IMPORTING
        application_type TYPE /esrcc/application_type_de
      RETURNING
        VALUE(category)  TYPE /esrcc/wf_appl_category.
    CLASS-METHODS split_and_create_wf_data
      IMPORTING
        !iv_application    TYPE /esrcc/application_type_de
        !it_leading_object TYPE /esrcc/tt_wf_leadingobject
      CHANGING
        !et_wf_split_data  TYPE /esrcc/tt_split_workflow .
    CLASS-METHODS set_wf_task_title
      IMPORTING
        !iv_application    TYPE /esrcc/application_type_de
        !it_leading_object TYPE /esrcc/tt_wf_leadingobject
      CHANGING
        !ev_header         TYPE string .
    CLASS-METHODS set_stdprovider_task_descr
      IMPORTING
        !it_leading_object TYPE /esrcc/tt_wf_leadingobject
      CHANGING
        !et_task_desc      TYPE /esrcc/tt_wf_st_len .
    CLASS-METHODS set_stdreceiver_task_descr
      IMPORTING
        !it_leading_object TYPE /esrcc/tt_wf_leadingobject
      CHANGING
        !et_task_desc      TYPE /esrcc/tt_wf_st_len .
    CLASS-METHODS set_truprovider_task_descr
      IMPORTING
        !it_leading_object TYPE /esrcc/tt_wf_leadingobject
      CHANGING
        !et_task_desc      TYPE /esrcc/tt_wf_st_len .
    CLASS-METHODS set_trureceiver_task_descr
      IMPORTING
        !it_leading_object TYPE /esrcc/tt_wf_leadingobject
      CHANGING
        !et_task_desc      TYPE /esrcc/tt_wf_st_len .
    CLASS-METHODS set_fcaprovider_task_descr
      IMPORTING
        !it_leading_object TYPE /esrcc/tt_wf_leadingobject
      CHANGING
        !et_task_desc      TYPE /esrcc/tt_wf_st_len .
    CLASS-METHODS set_fcareceiver_task_descr
      IMPORTING
        !it_leading_object TYPE /esrcc/tt_wf_leadingobject
      CHANGING
        !et_task_desc      TYPE /esrcc/tt_wf_st_len .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /esrcc/cl_wf_utility IMPLEMENTATION.


  METHOD is_wf_on.
    CLEAR ev_wf_active.
    SELECT SINGLE application , workflowactive FROM /esrcc/wf_switch  WHERE application = @iv_apptype INTO @DATA(ls_switch).
    IF sy-subrc EQ 0.
      ev_wf_active =  ls_switch-workflowactive.
    ENDIF.

  ENDMETHOD.


  METHOD wf_status_action_delete.
    rt_list = VALUE #( ( sign = 'I' option = 'EQ' low = c_wf_status-initial )
                       ( sign = 'I' option = 'EQ' low = c_wf_status-draft )
                       ( sign = 'I' option = 'EQ' low = c_wf_status-approved )
                       ( sign = 'I' option = 'EQ' low = c_wf_status-rejected )
                       ( sign = 'I' option = 'EQ' low = c_wf_status-failed ) ).
  ENDMETHOD.


  METHOD wf_status_action_finalize.
    rt_list = VALUE #( ( sign = 'I' option = 'EQ' low = c_wf_status-approved )
                       ( sign = 'I' option = 'EQ' low = c_wf_status-finalize_in_error ) ).
  ENDMETHOD.


  METHOD wf_status_action_reopen.
    rt_list = VALUE #( ( sign = 'I' option = 'EQ' low = c_wf_status-finalized ) ).
  ENDMETHOD.


  METHOD wf_status_action_submit.
    rt_list = VALUE #( ( sign = 'I' option = 'EQ' low = c_wf_status-draft ) ).
  ENDMETHOD.


  METHOD wf_status_action_sync.
    rt_list = wf_status_action_reopen( ).
  ENDMETHOD.


  METHOD wf_status_action_autogenerate.
    rt_list = wf_status_action_reopen( ).
  ENDMETHOD.


  METHOD wf_status_action_copy.
    rt_list = VALUE #( ( sign = 'I' option = 'EQ' low = c_wf_status-initial )
                       ( sign = 'I' option = 'EQ' low = c_wf_status-draft )
                       ( sign = 'I' option = 'EQ' low = c_wf_status-in_process )
                       ( sign = 'I' option = 'EQ' low = c_wf_status-approval_pending )
                       ( sign = 'I' option = 'EQ' low = c_wf_status-approved )
                       ( sign = 'I' option = 'EQ' low = c_wf_status-rejected )
                       ( sign = 'I' option = 'EQ' low = c_wf_status-finalize_in_process )
                       ( sign = 'I' option = 'EQ' low = c_wf_status-finalize_in_error )
                       ( sign = 'I' option = 'EQ' low = c_wf_status-finalized )
                       ( sign = 'I' option = 'EQ' low = c_wf_status-failed )
                       ( sign = 'I' option = 'EQ' low = c_wf_status-reopen_in_process ) ).
  ENDMETHOD.


  METHOD wf_status_action_copy_obj_page.
    rt_list = wf_status_action_update( ).
  ENDMETHOD.


  METHOD wf_status_action_update.
    rt_list = VALUE #( ( sign = 'I' option = 'EQ' low = c_wf_status-initial )
                       ( sign = 'I' option = 'EQ' low = c_wf_status-draft )
                       ( sign = 'I' option = 'EQ' low = c_wf_status-approved )
                       ( sign = 'I' option = 'EQ' low = c_wf_status-rejected )
                       ( sign = 'I' option = 'EQ' low = c_wf_status-failed ) ).
  ENDMETHOD.


  METHOD wf_status_criticality.
    criticality = SWITCH #( status " Red
                                   WHEN c_wf_status-rejected OR
                                        c_wf_status-failed OR
                                        c_wf_status-finalize_in_error THEN 1
                                   " Yellow
                                   WHEN c_wf_status-draft OR
                                        c_wf_status-in_process OR
                                        c_wf_status-approval_pending OR
                                        c_wf_status-finalize_in_process OR
                                        c_wf_status-reopen_in_process THEN 2
                                   " Green
                                   WHEN c_wf_status-approved OR
                                        c_wf_status-finalized THEN 3 ).
  ENDMETHOD.


  METHOD set_stdprovider_task_descr.

    DATA : lv_price     TYPE c LENGTH 50.
    DATA : lv_price_str TYPE string.
    DATA lv_text_concat        TYPE string.
    DATA lv_cost_decimal_2         TYPE p  DECIMALS 2.

    APPEND '<h3>General Information</h3>' TO et_task_desc.

** Keys for CDS
    SELECT fplv,ryear,poper,sysid,legalentity,ccode,costobject,costcenter,serviceproduct,
          receivingentity,
          receiversysid,
          receivercompanycode,
          receivercostobject,
          receivercostcenter,
          costbase~currency,
          totalchargeout,
          totalrecmarkup,
          reccostshare,
          recvalueadded,
          recpassthrough,
          costbase~legalentitydescription,
          costbase~ccodedescription,
          costbase~costobjectdescription,
          costbase~costcenterdescription,
          costbase~costdatasetdescription,
          receivingentitydescription,
          serviceproductdescription,
          receiverchargeout~ccodedescription AS recccodedescription,
          receiverchargeout~costobjectdescription AS reccostobejctdescription,
          receiverchargeout~costcenterdescription AS reccostcenterdescription
      FROM /esrcc/i_costbasestewardship AS costbase
           INNER JOIN /esrcc/i_serviceproductshare AS serviceproductshare
            ON costbase~uuid = serviceproductshare~parentuuid
            AND costbase~currencytype = serviceproductshare~currencytype
           INNER JOIN /esrcc/i_receiverchargeout AS receiverchargeout
            ON costbase~uuid = receiverchargeout~rootuuid
           AND serviceproductshare~uuid = receiverchargeout~parentuuid
           AND costbase~currencytype = receiverchargeout~currencytype
      FOR ALL ENTRIES IN @it_leading_object WHERE costbase~uuid = @it_leading_object-cc_uuid
                                              AND  costbase~currencytype = 'L'
*                                              AND  receiverchargeout~Receivingentity = @it_leading_object-receivingentity
      INTO  TABLE @DATA(lt_rec_cost_row).

** Do sum
    SELECT fplv,ryear,poper,sysid,legalentity,ccode,costobject,costcenter,
          currency,
          SUM( totalchargeout ) AS chargeoutforservice  ,
          SUM( totalrecmarkup  ) AS totaludmarkupabs,
          SUM( reccostshare ) AS totalcostbaseabs,
          SUM( recvalueadded ) AS valuaddabs,
          SUM( recpassthrough ) AS passthruabs,
          legalentitydescription,
          ccodedescription,
          costobjectdescription,
          costcenterdescription,
          costdatasetdescription
        FROM @lt_rec_cost_row AS rec_cost
        GROUP BY fplv,ryear,poper,sysid,legalentity,ccode,costobject,costcenter,
          currency,
          legalentitydescription,
          ccodedescription,
          costobjectdescription,
          costcenterdescription,
          costdatasetdescription
        INTO TABLE @DATA(lt_prov_cost_sum).

    READ TABLE lt_prov_cost_sum INTO DATA(ls_prov_cost_sum) INDEX 1.
    IF sy-subrc = 0.
      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Cost Dataset</td> <td>  { ls_prov_cost_sum-costdatasetdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td> Year </td> <td>{ ls_prov_cost_sum-ryear }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td> Period </td> <td>{ ls_prov_cost_sum-poper }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>System Id (Source) </td> <td> { ls_prov_cost_sum-sysid }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Legal Entity </td> <td>  { ls_prov_cost_sum-legalentity } ({ ls_prov_cost_sum-legalentitydescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Company Code</td> <td>  { ls_prov_cost_sum-ccode } ({ ls_prov_cost_sum-ccodedescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Type (Source) </td> <td>  { ls_prov_cost_sum-costobjectdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Number (Source) </td> <td>  { ls_prov_cost_sum-costcenter } ({ ls_prov_cost_sum-costcenterdescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

*          CLEAR lv_text_concat.
*          lv_text_concat =   |<tr><td>Service Product </td> <td>  { ls_prov_cost_sum-serviceproduct } ({ ls_prov_cost_sum-serviceproductdescription })</td></tr> | .
*          APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '</table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<h3>Charge-Out Details</h3> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-chargeoutforservice TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_prov_cost_sum-chargeoutforservice.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_prov_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Charge-Out Amount</td> <td> { lv_price_str  } | & | { ls_prov_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-totaludmarkupabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_prov_cost_sum-totaludmarkupabs.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_prov_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Mark-up</td> <td> { lv_price_str  } | & | { ls_prov_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-totalcostbaseabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_prov_cost_sum-totalcostbaseabs.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_prov_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Cost Remaining</td> <td> { lv_price_str  } | & | { ls_prov_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-valuaddabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_prov_cost_sum-valuaddabs.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_prov_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Thereof Value-Add</td> <td> { lv_price_str  } | & | { ls_prov_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-passthruabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_prov_cost_sum-passthruabs.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_prov_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Thereof Pass-Through</td> <td> { lv_price_str  } | & | { ls_prov_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '</table>' .
      APPEND lv_text_concat TO et_task_desc.

    ENDIF.

  ENDMETHOD.


  METHOD set_wf_task_title.
*CDS Name   /ESRCC/I_REC_COST
    CLEAR: ev_header.
    DATA : lv_price              TYPE c LENGTH 50.
    DATA : lv_price_str          TYPE string.
    DATA : lv_text_concat        TYPE string.

*check workflow config for group by
    SELECT SINGLE * FROM /esrcc/wf_switch
             WHERE application = @iv_application
             INTO @DATA(workflowswitch).

    READ TABLE it_leading_object INTO DATA(ls_leading_object) INDEX 1.
    IF sy-subrc EQ 0.

      DATA(lv_billing_period) =   |{ ls_leading_object-poper }.| & |{ ls_leading_object-ryear }|.

* Description should be like
      CASE workflowswitch-workflowgroupby.
        WHEN /esrcc/cl_wf_utility=>c_groupby-provider.  "provider
          CONCATENATE lv_billing_period '|| from' ls_leading_object-legalentity ls_leading_object-costobject
                      ls_leading_object-costcenter 'to Receiver(s)'
                            INTO  ev_header SEPARATED BY space .
        WHEN /esrcc/cl_wf_utility=>c_groupby-receiver.
          CONCATENATE lv_billing_period '|| from'
                      ls_leading_object-legalentity ls_leading_object-costobject  ls_leading_object-costcenter
                      'to'
                      ls_leading_object-receivingentity ls_leading_object-reccostobject ls_leading_object-reccostcenter
                      INTO  ev_header SEPARATED BY space .
        WHEN OTHERS.
          CONCATENATE lv_billing_period '|| from' ls_leading_object-legalentity ls_leading_object-costobject
                      ls_leading_object-costcenter 'to Receiver(s)'
                            INTO  ev_header SEPARATED BY space .
      ENDCASE.


    ENDIF.
  ENDMETHOD.


  METHOD split_and_create_wf_data.

* Group based on Legal Entity and Cost Center Service Product and Receiving Entity
    DATA lt_leading_object_inp  TYPE /esrcc/tt_wf_leadingobject.
    DATA lt_leading_object_out  TYPE /esrcc/tt_wf_leadingobject.
    DATA ls_out_split_data      TYPE /esrcc/s_split_workflow.

*check workflow config for group by
    SELECT SINGLE * FROM /esrcc/wf_switch
             WHERE application = @iv_application
             INTO @DATA(workflowswitch).

    CASE workflowswitch-workflowgroupby.
      WHEN /esrcc/cl_wf_utility=>c_groupby-provider.  "provider
        SELECT
              costbase~uuid AS cc_uuid,
              fplv,
              ryear,
              poper,
              refpoper,
              sysid,
              legalentity,
              ccode,
              costobject,
              costcenter
          FROM /esrcc/i_costbasestewardship AS costbase
          FOR ALL ENTRIES IN @it_leading_object WHERE  costbase~uuid = @it_leading_object-cc_uuid
                                                  AND  costbase~currencytype = 'L'
          INTO  CORRESPONDING FIELDS OF TABLE @lt_leading_object_inp.

      WHEN /esrcc/cl_wf_utility=>c_groupby-receiver.   "provider,receiver

        SELECT
              costbase~uuid AS cc_uuid,
              fplv,
              ryear,
              poper,
              refpoper,
              sysid,
              legalentity,
              ccode,
              costobject,
              costcenter,
              serviceproduct,
              receivingentity,
              receiversysid AS recsysid,
              receivercompanycode AS recccode,
              receivercostobject AS reccostobject,
              receivercostcenter AS reccostcenter
          FROM /esrcc/i_costbasestewardship AS costbase
               INNER JOIN /esrcc/i_serviceproductshare AS serviceproductshare
                ON costbase~uuid = serviceproductshare~parentuuid
                AND costbase~currencytype = serviceproductshare~currencytype
               INNER JOIN /esrcc/i_receiverchargeout AS receiverchargeout
                ON costbase~uuid = receiverchargeout~rootuuid
               AND serviceproductshare~uuid = receiverchargeout~parentuuid
               AND costbase~currencytype = receiverchargeout~currencytype
          FOR ALL ENTRIES IN @it_leading_object WHERE  costbase~uuid = @it_leading_object-cc_uuid
                                                  AND  costbase~currencytype = 'L'
          INTO  CORRESPONDING FIELDS OF TABLE @lt_leading_object_inp.

      WHEN OTHERS.
        SELECT
              costbase~uuid AS cc_uuid,
              fplv,
              ryear,
              poper,
              refpoper,
              sysid,
              legalentity,
              ccode,
              costobject,
              costcenter
          FROM /esrcc/i_costbasestewardship AS costbase
          FOR ALL ENTRIES IN @it_leading_object WHERE  costbase~uuid = @it_leading_object-cc_uuid
                                                  AND  costbase~currencytype = 'L'
          INTO  CORRESPONDING FIELDS OF TABLE @lt_leading_object_inp.
    ENDCASE.

    SORT lt_leading_object_inp BY fplv ryear sysid ccode costobject costcenter legalentity serviceproduct receivingentity recsysid recccode reccostobject reccostcenter.

    DELETE ADJACENT DUPLICATES FROM lt_leading_object_inp COMPARING fplv ryear ccode costobject costcenter legalentity serviceproduct receivingentity recsysid recccode reccostobject reccostcenter.

    LOOP AT lt_leading_object_inp INTO DATA(ls_leading_object_cb_inp).
      CLEAR lt_leading_object_out.
      CLEAR ls_out_split_data.

      APPEND ls_leading_object_cb_inp TO lt_leading_object_out.
      IF lt_leading_object_out IS NOT INITIAL.

        APPEND LINES OF lt_leading_object_out TO ls_out_split_data-segment.
        APPEND ls_out_split_data TO et_wf_split_data.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD set_stdreceiver_task_descr.

    DATA : lv_price     TYPE c LENGTH 50.
    DATA : lv_price_str TYPE string.
    DATA lv_text_concat        TYPE string.
    DATA lv_cost_decimal_2         TYPE p  DECIMALS 2.

    APPEND '<h3>General Information</h3>' TO et_task_desc.

** Keys for CDS
    SELECT fplv,ryear,poper,sysid,legalentity,ccode,costobject,costcenter,serviceproduct,
          receivingentity,
          receiversysid,
          receivercompanycode,
          receivercostobject,
          receivercostcenter,
          costbase~currency,
          totalchargeout,
          totalrecmarkup,
          reccostshare,
          recvalueadded,
          recpassthrough,
          costbase~legalentitydescription,
          costbase~ccodedescription,
          costbase~costobjectdescription,
          costbase~costcenterdescription,
          costbase~costdatasetdescription,
          receivingentitydescription,
          serviceproductdescription,
          receiverchargeout~ccodedescription AS recccodedescription,
          receiverchargeout~costobjectdescription AS reccostobejctdescription,
          receiverchargeout~costcenterdescription AS reccostcenterdescription
      FROM /esrcc/i_costbasestewardship AS costbase
           INNER JOIN /esrcc/i_serviceproductshare AS serviceproductshare
            ON costbase~uuid = serviceproductshare~parentuuid
            AND costbase~currencytype = serviceproductshare~currencytype
           INNER JOIN /esrcc/i_receiverchargeout AS receiverchargeout
            ON costbase~uuid = receiverchargeout~rootuuid
           AND serviceproductshare~uuid = receiverchargeout~parentuuid
           AND costbase~currencytype = receiverchargeout~currencytype
      FOR ALL ENTRIES IN @it_leading_object WHERE costbase~uuid = @it_leading_object-cc_uuid
                                              AND  costbase~currencytype = 'I'
                                              AND  receiverchargeout~receiversysid   = @it_leading_object-recsysid
                                              AND  receiverchargeout~receivercompanycode = @it_leading_object-recccode
                                              AND  receiverchargeout~receivingentity = @it_leading_object-receivingentity
                                              AND  receiverchargeout~receivercostobject = @it_leading_object-reccostobject
                                              AND  receiverchargeout~receivercostcenter = @it_leading_object-reccostcenter
      INTO  TABLE @DATA(lt_rec_cost_row).

** Do sum
    SELECT fplv,ryear,poper,sysid,legalentity,ccode,costobject,costcenter,serviceproduct,
          receivingentity,
          receiversysid,
          receivercompanycode,
          receivercostobject,
          receivercostcenter,
          currency,
          SUM( totalchargeout ) AS chargeoutforservice  ,
          SUM( totalrecmarkup  ) AS totaludmarkupabs,
          SUM( reccostshare ) AS totalcostbaseabs,
          SUM( recvalueadded ) AS valuaddabs,
          SUM( recpassthrough ) AS passthruabs,
          legalentitydescription,
          ccodedescription,
          costobjectdescription,
          costcenterdescription,
          costdatasetdescription,
          serviceproductdescription,
          receivingentitydescription,
          recccodedescription,
          reccostobejctdescription,
          reccostcenterdescription
        FROM @lt_rec_cost_row AS rec_cost
        GROUP BY fplv,ryear,poper,sysid,legalentity,ccode,costobject,costcenter,serviceproduct,
          receivingentity,
          receiversysid,
          receivercompanycode,
          receivercostobject,
          receivercostcenter,
          currency,
          legalentitydescription,
          ccodedescription,
          costobjectdescription,
          costcenterdescription,
          costdatasetdescription,
          serviceproductdescription,
          receivingentitydescription,
          recccodedescription,
          reccostobejctdescription,
          reccostcenterdescription
        INTO TABLE @DATA(lt_rec_cost_sum).

    READ TABLE lt_rec_cost_sum INTO DATA(ls_rec_cost_sum) INDEX 1.
    IF sy-subrc = 0.
      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Cost Dataset</td> <td>  { ls_rec_cost_sum-costdatasetdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td> Year </td> <td>{ ls_rec_cost_sum-ryear }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td> Period </td> <td>{ ls_rec_cost_sum-poper }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>System Id (Source) </td> <td> { ls_rec_cost_sum-sysid }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Legal Entity </td> <td>  { ls_rec_cost_sum-legalentity } ({ ls_rec_cost_sum-legalentitydescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Company Code</td> <td>  { ls_rec_cost_sum-ccode } ({ ls_rec_cost_sum-ccodedescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Type (Source) </td> <td>  { ls_rec_cost_sum-costobjectdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Number (Source) </td> <td>  { ls_rec_cost_sum-costcenter } ({ ls_rec_cost_sum-costcenterdescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Service Product </td> <td>  { ls_rec_cost_sum-serviceproduct } ({ ls_rec_cost_sum-serviceproductdescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Receiver System Id (Source) </td> <td> { ls_rec_cost_sum-receiversysid }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Receiving Entity </td> <td>  { ls_rec_cost_sum-receivingentity } ({ ls_rec_cost_sum-receivingentitydescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Receiver Company Code</td> <td>  { ls_rec_cost_sum-receivercompanycode } ({ ls_rec_cost_sum-recccodedescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Receiver Cost Object Type (Source) </td> <td>  { ls_rec_cost_sum-reccostobejctdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Receiver Cost Object Number (Source) </td> <td>  { ls_rec_cost_sum-receivercostcenter } ({ ls_rec_cost_sum-reccostcenterdescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '</table>' .
      APPEND lv_text_concat TO et_task_desc.

*      LOOP AT lt_rec_cost_sum INTO ls_rec_cost_sum.

      CLEAR lv_text_concat.
      lv_text_concat =   |<h3>Charge-Out Details</h3> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-chargeoutforservice TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_rec_cost_sum-chargeoutforservice.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_rec_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Charge-Out Received</td> <td> { lv_price_str  } | & | { ls_rec_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-totaludmarkupabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_rec_cost_sum-totaludmarkupabs.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_rec_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Mark-up</td> <td> { lv_price_str  } | & | { ls_rec_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-totalcostbaseabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_rec_cost_sum-totalcostbaseabs.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_rec_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Cost Remaining</td> <td> { lv_price_str  } | & | { ls_rec_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-valuaddabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_rec_cost_sum-valuaddabs.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_rec_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Thereof Value-Add</td> <td> { lv_price_str  } | & | { ls_rec_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-passthruabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_rec_cost_sum-passthruabs.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_rec_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Thereof Pass-Through</td> <td> { lv_price_str  } | & | { ls_rec_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '</table>' .
      APPEND lv_text_concat TO et_task_desc.

*      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD set_truprovider_task_descr.

    DATA : lv_price     TYPE c LENGTH 50.
    DATA : lv_price_str TYPE string.
    DATA lv_text_concat        TYPE string.
    DATA lv_cost_decimal_2         TYPE p  DECIMALS 2.
    DATA trueupamount       TYPE /esrcc/amount.
    DATA finaltrueupamount  TYPE /esrcc/amount.
    DATA standardamount     TYPE /esrcc/amount.
    DATA recalculatedamount TYPE /esrcc/amount.
    DATA lt_trueup        TYPE TABLE OF /esrcc/trueup.
    DATA ls_trueup        TYPE /esrcc/trueup.

    APPEND '<h3>General Information</h3>' TO et_task_desc.

    IF it_leading_object IS NOT INITIAL.
      DATA(refpoper) = it_leading_object[ 1 ]-refpoper.
    ENDIF.

*   Get the recalculated chargeouts
    SELECT trueup~ryear,
           trueup~legalentity,
           trueup~ccode,
           trueup~costobject,
           trueup~costcenter,
           trueup~sysid,
           trueup~refpoper,
           trueup~currency,
           ccodedescription,
           legalentitydescription,
           costobjectdescription,
           costcenterdescription,
           SUM( totalchargeoutamount ) AS totalchargeoutamount
       FROM /esrcc/i_trup_analysis AS trueup
       INNER JOIN @it_leading_object AS keys
         ON  trueup~ryear          = keys~ryear
        AND  trueup~legalentity    = keys~legalentity
        AND  trueup~ccode          = keys~ccode
        AND  trueup~costobject     = keys~costobject
        AND  trueup~costcenter     = keys~costcenter
        AND  trueup~sysid          = keys~sysid
        WHERE  trueup~refpoper     = @refpoper
        AND  processtype           = @/esrcc/if_calculate_chargeout=>recalprocesstype
        AND  currencytype          = 'L'   "sender local currency
        GROUP BY
          trueup~ryear,
          trueup~legalentity,
          trueup~ccode,
          trueup~costobject,
          trueup~costcenter,
          trueup~sysid,
          trueup~refpoper,
          trueup~currency,
          ccodedescription,
          legalentitydescription,
          costobjectdescription,
          costcenterdescription
        INTO TABLE @DATA(lt_recalculated).

*   Get the standard chargeouts
    SELECT trueup~ryear,
           trueup~legalentity,
           trueup~ccode,
           trueup~costobject,
           trueup~costcenter,
           trueup~sysid,
           SUM( totalchargeoutamount ) AS totalchargeoutamount
       FROM /esrcc/i_trup_analysis AS trueup
       INNER JOIN @it_leading_object AS keys
         ON  trueup~ryear          = keys~ryear
        AND  trueup~legalentity    = keys~legalentity
        AND  trueup~ccode          = keys~ccode
        AND  trueup~costobject     = keys~costobject
        AND  trueup~costcenter     = keys~costcenter
        AND  trueup~sysid          = keys~sysid
       WHERE trueup~poper          <= @refpoper
        AND  processtype           = @/esrcc/if_calculate_chargeout=>standardprocesstype
        AND  currencytype          = 'L'   "sender local currency
        GROUP BY
          trueup~ryear,
          trueup~legalentity,
          trueup~ccode,
          trueup~costobject,
          trueup~costcenter,
          trueup~sysid
        INTO TABLE @DATA(lt_standard).

*   Get the true up amounts
    SELECT trueup~ryear,
           trueup~legalentity,
           trueup~ccode,
           trueup~costobject,
           trueup~costcenter,
           trueup~sysid,
           SUM( amount_l ) AS totaltrueupamount
       FROM /esrcc/trueup AS trueup
       INNER JOIN @it_leading_object AS keys
         ON  trueup~ryear          = keys~ryear
        AND  trueup~legalentity    = keys~legalentity
        AND  trueup~ccode          = keys~ccode
        AND  trueup~costobject     = keys~costobject
        AND  trueup~costcenter     = keys~costcenter
        AND  trueup~sysid          = keys~sysid
       WHERE recalrefpoper         < @refpoper
       GROUP BY
          trueup~ryear,
          trueup~legalentity,
          trueup~ccode,
          trueup~costobject,
          trueup~costcenter,
          trueup~sysid
        INTO TABLE @DATA(lt_trueups).

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

    LOOP AT lt_recalculated ASSIGNING FIELD-SYMBOL(<recalculated>).
      READ TABLE lt_standard ASSIGNING FIELD-SYMBOL(<standard>)
                               WITH KEY ryear          = <recalculated>-ryear
                                        sysid          = <recalculated>-sysid
                                        legalentity    = <recalculated>-legalentity
                                        ccode          = <recalculated>-ccode
                                        costobject     = <recalculated>-costobject
                                        costcenter     = <recalculated>-costcenter.

      IF sy-subrc = 0.
        CLEAR trueupamount.
        LOOP AT lt_trueups INTO DATA(trueup)
                             WHERE ryear               = <recalculated>-ryear
                               AND sysid               = <recalculated>-sysid
                               AND legalentity         = <recalculated>-legalentity
                               AND ccode               = <recalculated>-ccode
                               AND costobject          = <recalculated>-costobject
                               AND costcenter          = <recalculated>-costcenter.

          trueupamount = trueup-totaltrueupamount + trueupamount.
        ENDLOOP.

        recalculatedamount = <recalculated>-totalchargeoutamount  + recalculatedamount.
        standardamount     = ( <standard>-totalchargeoutamount + trueupamount ) + standardamount.
        finaltrueupamount  = finaltrueupamount + ( <recalculated>-totalchargeoutamount - ( <standard>-totalchargeoutamount + trueupamount ) ).

      ENDIF.

      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td> Year </td> <td>{ <recalculated>-ryear }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td> True-up Ref Period </td> <td>{ | 001 - | && |{ <recalculated>-refpoper }| }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>System Id (Source) </td> <td> { <recalculated>-sysid }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Legal Entity </td> <td>  { <recalculated>-legalentity } ({ <recalculated>-legalentitydescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Company Code</td> <td>  { <recalculated>-ccode } ({ <recalculated>-ccodedescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Type (Source) </td> <td>  { <recalculated>-costobjectdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Number (Source) </td> <td>  { <recalculated>-costcenter } ({ <recalculated>-costcenterdescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '</table>' .
      APPEND lv_text_concat TO et_task_desc.



      CLEAR lv_text_concat.
      lv_text_concat =   |<h3>True-up Calculation Details</h3> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_cost_decimal_2 = recalculatedamount.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = <recalculated>-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Re-calculated Charge-out Amount</td> <td> { lv_price_str  } | & | { <recalculated>-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.
*
      CLEAR lv_text_concat.
      lv_cost_decimal_2 = standardamount.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = <recalculated>-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Standard Charge-out Amount</td> <td> { lv_price_str  } | & | { <recalculated>-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.
*
      CLEAR lv_text_concat.
      lv_cost_decimal_2 = finaltrueupamount.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = <recalculated>-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total True-up Amount</td> <td> { lv_price_str  } | & | { <recalculated>-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '</table>' .
      APPEND lv_text_concat TO et_task_desc.

    ENDLOOP.

  ENDMETHOD.


  METHOD set_trureceiver_task_descr.

    DATA : lv_price     TYPE c LENGTH 50.
    DATA : lv_price_str TYPE string.
    DATA lv_text_concat        TYPE string.
    DATA lv_cost_decimal_2         TYPE p  DECIMALS 2.
    DATA trueupamount       TYPE /esrcc/amount.
    DATA finaltrueupamount  TYPE /esrcc/amount.
    DATA standardamount     TYPE /esrcc/amount.
    DATA recalculatedamount TYPE /esrcc/amount.
    DATA lt_trueup        TYPE TABLE OF /esrcc/trueup.
    DATA ls_trueup        TYPE /esrcc/trueup.

    APPEND '<h3>General Information</h3>' TO et_task_desc.

    IF it_leading_object IS NOT INITIAL.
      DATA(refpoper) = it_leading_object[ 1 ]-refpoper.
    ENDIF.

*   Get the recalculated chargeouts
    SELECT trueup~ryear,
           trueup~legalentity,
           trueup~ccode,
           trueup~costobject,
           trueup~costcenter,
           trueup~sysid,
           trueup~refpoper,
           trueup~currency,
           trueup~serviceproduct,
           trueup~receiversysid,
           trueup~receivercompanycode,
           trueup~receivingentity,
           trueup~receivercostobject,
           trueup~receivercostcenter,
           ccodedescription,
           legalentitydescription,
           costobjectdescription,
           costcenterdescription,
           trueup~serviceproductdescription,
           trueup~recccodedescription,
           trueup~receivingentitydescription,
           trueup~reccostobjectdescription,
           trueup~reccostcenterdescription,
           SUM( totalchargeoutamount ) AS totalchargeoutamount
       FROM /esrcc/i_trup_analysis AS trueup
       INNER JOIN @it_leading_object AS keys
         ON  trueup~ryear          = keys~ryear
        AND  trueup~legalentity    = keys~legalentity
        AND  trueup~ccode          = keys~ccode
        AND  trueup~costobject     = keys~costobject
        AND  trueup~costcenter     = keys~costcenter
        AND  trueup~sysid          = keys~sysid
        AND  trueup~serviceproduct = keys~serviceproduct
        AND  trueup~receiversysid  = keys~recsysid
        AND  trueup~receivingentity = keys~receivingentity
        AND  trueup~receivercompanycode = keys~recccode
        AND  trueup~receivercostobject  = keys~reccostobject
        AND  trueup~receivercostcenter  = keys~reccostcenter
        WHERE  trueup~refpoper     = @refpoper
        AND  processtype           = @/esrcc/if_calculate_chargeout=>recalprocesstype
        AND  currencytype          = 'I'   "sender local currency
        GROUP BY
          trueup~ryear,
          trueup~legalentity,
          trueup~ccode,
          trueup~costobject,
          trueup~costcenter,
          trueup~sysid,
          trueup~refpoper,
          trueup~currency,
          trueup~serviceproduct,
          trueup~receiversysid,
          trueup~receivercompanycode,
          trueup~receivingentity,
          trueup~receivercostobject,
          trueup~receivercostcenter,
          ccodedescription,
          legalentitydescription,
          costobjectdescription,
          costcenterdescription,
          trueup~serviceproductdescription,
          trueup~recccodedescription,
          trueup~receivingentitydescription,
          trueup~reccostobjectdescription,
          trueup~reccostcenterdescription
        INTO TABLE @DATA(lt_recalculated).

*   Get the standard chargeouts
    SELECT trueup~ryear,
           trueup~legalentity,
           trueup~ccode,
           trueup~costobject,
           trueup~costcenter,
           trueup~sysid,
           trueup~serviceproduct,
           trueup~receiversysid,
           trueup~receivercompanycode,
           trueup~receivingentity,
           trueup~receivercostobject,
           trueup~receivercostcenter,
           SUM( totalchargeoutamount ) AS totalchargeoutamount
       FROM /esrcc/i_trup_analysis AS trueup
       INNER JOIN @it_leading_object AS keys
         ON  trueup~ryear          = keys~ryear
        AND  trueup~legalentity    = keys~legalentity
        AND  trueup~ccode          = keys~ccode
        AND  trueup~costobject     = keys~costobject
        AND  trueup~costcenter     = keys~costcenter
        AND  trueup~sysid          = keys~sysid
        AND  trueup~serviceproduct = keys~serviceproduct
        AND  trueup~receiversysid  = keys~recsysid
        AND  trueup~receivingentity = keys~receivingentity
        AND  trueup~receivercompanycode = keys~recccode
        AND  trueup~receivercostobject  = keys~reccostobject
        AND  trueup~receivercostcenter  = keys~reccostcenter
       WHERE trueup~poper          <= @refpoper
        AND  processtype           = @/esrcc/if_calculate_chargeout=>standardprocesstype
        AND  currencytype          = 'I'   "sender local currency
        GROUP BY
          trueup~ryear,
          trueup~legalentity,
          trueup~ccode,
          trueup~costobject,
          trueup~costcenter,
          trueup~sysid,
          trueup~serviceproduct,
          trueup~receiversysid,
          trueup~receivercompanycode,
          trueup~receivingentity,
          trueup~receivercostobject,
          trueup~receivercostcenter
        INTO TABLE @DATA(lt_standard).

*   Get the true up amounts
    SELECT trueup~ryear,
           trueup~legalentity,
           trueup~ccode,
           trueup~costobject,
           trueup~costcenter,
           trueup~sysid,
           trueup~serviceproduct,
           trueup~receiversysid,
           trueup~receivercompanycode,
           trueup~receivingentity,
           trueup~receivercostobject,
           trueup~receivercostcenter,
           localcurr,
           exchdate,
           SUM( amount_l ) AS totaltrueupamount
       FROM /esrcc/trueup AS trueup
       INNER JOIN @it_leading_object AS keys
         ON  trueup~ryear          = keys~ryear
        AND  trueup~legalentity    = keys~legalentity
        AND  trueup~ccode          = keys~ccode
        AND  trueup~costobject     = keys~costobject
        AND  trueup~costcenter     = keys~costcenter
        AND  trueup~sysid          = keys~sysid
        AND  trueup~serviceproduct = keys~serviceproduct
        AND  trueup~receiversysid  = keys~recsysid
        AND  trueup~receivingentity = keys~receivingentity
        AND  trueup~receivercompanycode = keys~recccode
        AND  trueup~receivercostobject  = keys~reccostobject
        AND  trueup~receivercostcenter  = keys~reccostcenter
       WHERE recalrefpoper         < @refpoper
       GROUP BY
          trueup~ryear,
          trueup~legalentity,
          trueup~ccode,
          trueup~costobject,
          trueup~costcenter,
          trueup~sysid,
          trueup~serviceproduct,
          trueup~receiversysid,
          trueup~receivercompanycode,
          trueup~receivingentity,
          trueup~receivercostobject,
          trueup~receivercostcenter,
          localcurr,
          exchdate
        INTO TABLE @DATA(lt_trueups).

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

    LOOP AT lt_recalculated ASSIGNING FIELD-SYMBOL(<recalculated>).
      READ TABLE lt_standard ASSIGNING FIELD-SYMBOL(<standard>)
                               WITH KEY ryear          = <recalculated>-ryear
                                        sysid          = <recalculated>-sysid
                                        legalentity    = <recalculated>-legalentity
                                        ccode          = <recalculated>-ccode
                                        costobject     = <recalculated>-costobject
                                        costcenter     = <recalculated>-costcenter
                                        serviceproduct = <recalculated>-serviceproduct
                                        receiversysid  = <recalculated>-receiversysid
                                        receivercompanycode = <recalculated>-receivercompanycode
                                        receivingentity     = <recalculated>-receivingentity
                                        receivercostobject  = <recalculated>-receivercostobject
                                        receivercostcenter  = <recalculated>-receivercostcenter.

      IF sy-subrc = 0.
        CLEAR trueupamount.
        LOOP AT lt_trueups INTO DATA(trueup)
                             WHERE ryear               = <recalculated>-ryear
                               AND sysid               = <recalculated>-sysid
                               AND legalentity         = <recalculated>-legalentity
                               AND ccode               = <recalculated>-ccode
                               AND costobject          = <recalculated>-costobject
                               AND costcenter          = <recalculated>-costcenter
                               AND serviceproduct      = <recalculated>-serviceproduct
                               AND receiversysid       = <recalculated>-receiversysid
                               AND receivercompanycode = <recalculated>-receivercompanycode
                               AND receivingentity     = <recalculated>-receivingentity
                               AND receivercostobject  = <recalculated>-receivercostobject
                               AND receivercostcenter  = <recalculated>-receivercostcenter.

          /esrcc/cl_utility_core=>currency_conversion(
                      EXPORTING
                        amount          = trueup-totaltrueupamount
                        source_curr     = trueup-localcurr
                        target_curr     = <recalculated>-currency
                        validon         = trueup-exchdate
                      IMPORTING
                        convertedamount = DATA(amount)
                    ).

          trueupamount = trueup-totaltrueupamount + trueupamount.
        ENDLOOP.

        recalculatedamount = <recalculated>-totalchargeoutamount  + recalculatedamount.
        standardamount     = ( <standard>-totalchargeoutamount + trueupamount ) + standardamount.
        finaltrueupamount  = finaltrueupamount + ( <recalculated>-totalchargeoutamount - ( <standard>-totalchargeoutamount + trueupamount ) ).

      ENDIF.

      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td> Year </td> <td>{ <recalculated>-ryear }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td> True-up Ref Period </td> <td>{ | 001 - | && |{ <recalculated>-refpoper }| }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>System Id (Source) </td> <td> { <recalculated>-sysid }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Legal Entity </td> <td>  { <recalculated>-legalentity } ({ <recalculated>-legalentitydescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Company Code</td> <td>  { <recalculated>-ccode } ({ <recalculated>-ccodedescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Type (Source) </td> <td>  { <recalculated>-costobjectdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Number (Source) </td> <td>  { <recalculated>-costcenter } ({ <recalculated>-costcenterdescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Service Product </td> <td>  { <recalculated>-serviceproduct } ({ <recalculated>-serviceproductdescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Receiver System Id (Source) </td> <td> { <recalculated>-receiversysid }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Receiving Entity </td> <td>  { <recalculated>-receivingentity } ({ <recalculated>-receivingentitydescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Receiver Company Code</td> <td>  { <recalculated>-receivercompanycode } ({ <recalculated>-recccodedescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Receiver Cost Object Type (Source) </td> <td>  { <recalculated>-reccostobjectdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Receiver Cost Object Number (Source) </td> <td>  { <recalculated>-receivercostcenter } ({ <recalculated>-reccostcenterdescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '</table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<h3>True-up Calculation Details</h3> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_cost_decimal_2 = recalculatedamount.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = <recalculated>-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Re-calculated Charge-out Amount</td> <td> { lv_price_str  } | & | { <recalculated>-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.
*
      CLEAR lv_text_concat.
      lv_cost_decimal_2 = standardamount.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = <recalculated>-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Standard Charge-out Amount</td> <td> { lv_price_str  } | & | { <recalculated>-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.
*
      CLEAR lv_text_concat.
      lv_cost_decimal_2 = finaltrueupamount.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = <recalculated>-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total True-up Amount</td> <td> { lv_price_str  } | & | { <recalculated>-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '</table>' .
      APPEND lv_text_concat TO et_task_desc.

    ENDLOOP.

  ENDMETHOD.


  METHOD set_fcaprovider_task_descr.

    DATA : lv_price     TYPE c LENGTH 50.
    DATA : lv_price_str TYPE string.
    DATA lv_text_concat        TYPE string.
    DATA lv_cost_decimal_2         TYPE p  DECIMALS 2.
    DATA lv_poper TYPE /esrcc/poper.

    APPEND '<h3>General Information</h3>' TO et_task_desc.

    IF it_leading_object IS NOT INITIAL.
      DATA(refpoper) = it_leading_object[ 1 ]-refpoper.
    ENDIF.

** Keys for CDS
    SELECT fplv,ryear,poper,refpoper,sysid,legalentity,ccode,costobject,costcenter,serviceproduct,
          receivingentity,
          receiversysid,
          receivercompanycode,
          receivercostobject,
          receivercostcenter,
          costbase~currency,
          totalchargeout,
          totalrecmarkup,
          reccostshare,
          recvalueadded,
          recpassthrough,
          costbase~legalentitydescription,
          costbase~ccodedescription,
          costbase~costobjectdescription,
          costbase~costcenterdescription,
          costbase~costdatasetdescription,
          receivingentitydescription,
          serviceproductdescription,
          receiverchargeout~ccodedescription AS recccodedescription,
          receiverchargeout~costobjectdescription AS reccostobejctdescription,
          receiverchargeout~costcenterdescription AS reccostcenterdescription
      FROM /esrcc/i_costbasestewardship AS costbase
           INNER JOIN /esrcc/i_serviceproductshare AS serviceproductshare
            ON costbase~uuid = serviceproductshare~parentuuid
            AND costbase~currencytype = serviceproductshare~currencytype
           INNER JOIN /esrcc/i_receiverchargeout AS receiverchargeout
            ON costbase~uuid = receiverchargeout~rootuuid
           AND serviceproductshare~uuid = receiverchargeout~parentuuid
           AND costbase~currencytype = receiverchargeout~currencytype
      FOR ALL ENTRIES IN @it_leading_object
      WHERE costbase~fplv          = @it_leading_object-fplv
        AND costbase~ryear         = @it_leading_object-ryear
        AND costbase~recalrefpoper = @it_leading_object-refpoper
        AND costbase~sysid         = @it_leading_object-sysid
        AND costbase~legalentity   = @it_leading_object-legalentity
        AND costbase~ccode         = @it_leading_object-ccode
        AND costbase~costobject    = @it_leading_object-costobject
        AND costbase~costcenter    = @it_leading_object-costcenter
        AND costbase~processtype   = @/esrcc/if_calculate_chargeout=>forecastprocesstype
        AND costbase~currencytype = 'L'
      INTO  TABLE @DATA(lt_rec_cost_row).

** Do sum
    SELECT fplv,ryear,refpoper,sysid,legalentity,ccode,costobject,costcenter,
          currency,
          SUM( totalchargeout ) AS chargeoutforservice  ,
          SUM( totalrecmarkup  ) AS totaludmarkupabs,
          SUM( reccostshare ) AS totalcostbaseabs,
          SUM( recvalueadded ) AS valuaddabs,
          SUM( recpassthrough ) AS passthruabs,
          legalentitydescription,
          ccodedescription,
          costobjectdescription,
          costcenterdescription,
          costdatasetdescription
        FROM @lt_rec_cost_row AS rec_cost
        GROUP BY fplv,ryear,refpoper,sysid,legalentity,ccode,costobject,costcenter,
          currency,
          legalentitydescription,
          ccodedescription,
          costobjectdescription,
          costcenterdescription,
          costdatasetdescription
        INTO TABLE @DATA(lt_prov_cost_sum).

    READ TABLE lt_prov_cost_sum INTO DATA(ls_prov_cost_sum) INDEX 1.
    IF sy-subrc = 0.
      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Cost Dataset</td> <td>  { ls_prov_cost_sum-costdatasetdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td> Year </td> <td>{ ls_prov_cost_sum-ryear }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_poper = ls_prov_cost_sum-refpoper + 001.
      lv_text_concat =   |<tr> <td>Forecast Period </td> <td>{  |{ lv_poper } - | && | 012| }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>System Id (Source) </td> <td> { ls_prov_cost_sum-sysid }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Legal Entity </td> <td>  { ls_prov_cost_sum-legalentity } ({ ls_prov_cost_sum-legalentitydescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Company Code</td> <td>  { ls_prov_cost_sum-ccode } ({ ls_prov_cost_sum-ccodedescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Type (Source) </td> <td>  { ls_prov_cost_sum-costobjectdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Number (Source) </td> <td>  { ls_prov_cost_sum-costcenter } ({ ls_prov_cost_sum-costcenterdescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

*          CLEAR lv_text_concat.
*          lv_text_concat =   |<tr><td>Service Product </td> <td>  { ls_prov_cost_sum-serviceproduct } ({ ls_prov_cost_sum-serviceproductdescription })</td></tr> | .
*          APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '</table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<h3>Charge-Out Details</h3> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-chargeoutforservice TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_prov_cost_sum-chargeoutforservice.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_prov_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Charge-Out Amount</td> <td> { lv_price_str  } | & | { ls_prov_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-totaludmarkupabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_prov_cost_sum-totaludmarkupabs.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_prov_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Mark-up</td> <td> { lv_price_str  } | & | { ls_prov_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-totalcostbaseabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_prov_cost_sum-totalcostbaseabs.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_prov_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Cost Remaining</td> <td> { lv_price_str  } | & | { ls_prov_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-valuaddabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_prov_cost_sum-valuaddabs.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_prov_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Thereof Value-Add</td> <td> { lv_price_str  } | & | { ls_prov_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-passthruabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_prov_cost_sum-passthruabs.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_prov_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Thereof Pass-Through</td> <td> { lv_price_str  } | & | { ls_prov_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '</table>' .
      APPEND lv_text_concat TO et_task_desc.

    ENDIF.

  ENDMETHOD.


  METHOD set_fcareceiver_task_descr.

    DATA : lv_price     TYPE c LENGTH 50.
    DATA : lv_price_str TYPE string.
    DATA lv_text_concat        TYPE string.
    DATA lv_cost_decimal_2         TYPE p  DECIMALS 2.
    DATA lv_poper TYPE /esrcc/poper.

    APPEND '<h3>General Information</h3>' TO et_task_desc.

    IF it_leading_object IS NOT INITIAL.
      DATA(refpoper) = it_leading_object[ 1 ]-refpoper.
    ENDIF.

** Keys for CDS
    SELECT fplv,ryear,poper,refpoper,sysid,legalentity,ccode,costobject,costcenter,serviceproduct,
          receivingentity,
          receiversysid,
          receivercompanycode,
          receivercostobject,
          receivercostcenter,
          costbase~currency,
          totalchargeout,
          totalrecmarkup,
          reccostshare,
          recvalueadded,
          recpassthrough,
          costbase~legalentitydescription,
          costbase~ccodedescription,
          costbase~costobjectdescription,
          costbase~costcenterdescription,
          costbase~costdatasetdescription,
          receivingentitydescription,
          serviceproductdescription,
          receiverchargeout~ccodedescription AS recccodedescription,
          receiverchargeout~costobjectdescription AS reccostobejctdescription,
          receiverchargeout~costcenterdescription AS reccostcenterdescription
      FROM /esrcc/i_costbasestewardship AS costbase
           INNER JOIN /esrcc/i_serviceproductshare AS serviceproductshare
            ON costbase~uuid = serviceproductshare~parentuuid
            AND costbase~currencytype = serviceproductshare~currencytype
           INNER JOIN /esrcc/i_receiverchargeout AS receiverchargeout
            ON costbase~uuid = receiverchargeout~rootuuid
           AND serviceproductshare~uuid = receiverchargeout~parentuuid
           AND costbase~currencytype = receiverchargeout~currencytype
      FOR ALL ENTRIES IN @it_leading_object
      WHERE costbase~fplv        = @it_leading_object-fplv
        AND costbase~ryear         = @it_leading_object-ryear
        AND costbase~recalrefpoper = @it_leading_object-refpoper
        AND costbase~sysid         = @it_leading_object-sysid
        AND costbase~legalentity   = @it_leading_object-legalentity
        AND costbase~ccode         = @it_leading_object-ccode
        AND costbase~costobject    = @it_leading_object-costobject
        AND costbase~costcenter    = @it_leading_object-costcenter
        AND costbase~processtype   = @/esrcc/if_calculate_chargeout=>forecastprocesstype
        AND costbase~currencytype = 'I'
        AND receiverchargeout~receiversysid       = @it_leading_object-recsysid
        AND receiverchargeout~receivercompanycode = @it_leading_object-recccode
        AND receiverchargeout~receivingentity     = @it_leading_object-receivingentity
        AND receiverchargeout~receivercostobject  = @it_leading_object-reccostobject
        AND receiverchargeout~receivercostcenter  = @it_leading_object-reccostcenter
      INTO  TABLE @DATA(lt_rec_cost_row).

** Do sum
    SELECT fplv,ryear,refpoper,sysid,legalentity,ccode,costobject,costcenter,serviceproduct,
          receivingentity,
          receiversysid,
          receivercompanycode,
          receivercostobject,
          receivercostcenter,
          currency,
          SUM( totalchargeout ) AS chargeoutforservice  ,
          SUM( totalrecmarkup  ) AS totaludmarkupabs,
          SUM( reccostshare ) AS totalcostbaseabs,
          SUM( recvalueadded ) AS valuaddabs,
          SUM( recpassthrough ) AS passthruabs,
          legalentitydescription,
          ccodedescription,
          costobjectdescription,
          costcenterdescription,
          costdatasetdescription,
          serviceproductdescription,
          receivingentitydescription,
          recccodedescription,
          reccostobejctdescription,
          reccostcenterdescription
        FROM @lt_rec_cost_row AS rec_cost
        GROUP BY fplv,ryear,refpoper,sysid,legalentity,ccode,costobject,costcenter,serviceproduct,
          receivingentity,
          receiversysid,
          receivercompanycode,
          receivercostobject,
          receivercostcenter,
          currency,
          legalentitydescription,
          ccodedescription,
          costobjectdescription,
          costcenterdescription,
          costdatasetdescription,
          serviceproductdescription,
          receivingentitydescription,
          recccodedescription,
          reccostobejctdescription,
          reccostcenterdescription
        INTO TABLE @DATA(lt_rec_cost_sum).

    READ TABLE lt_rec_cost_sum INTO DATA(ls_rec_cost_sum) INDEX 1.
    IF sy-subrc = 0.
      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Cost Dataset</td> <td>  { ls_rec_cost_sum-costdatasetdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td> Year </td> <td>{ ls_rec_cost_sum-ryear }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_poper = ls_rec_cost_sum-refpoper + 001.
      lv_text_concat =   |<tr> <td> Forecast Period </td> <td>{  |{ lv_poper } - | && | 012| }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>System Id (Source) </td> <td> { ls_rec_cost_sum-sysid }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Legal Entity </td> <td>  { ls_rec_cost_sum-legalentity } ({ ls_rec_cost_sum-legalentitydescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Company Code</td> <td>  { ls_rec_cost_sum-ccode } ({ ls_rec_cost_sum-ccodedescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Type (Source) </td> <td>  { ls_rec_cost_sum-costobjectdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Cost Object Number (Source) </td> <td>  { ls_rec_cost_sum-costcenter } ({ ls_rec_cost_sum-costcenterdescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Service Product </td> <td>  { ls_rec_cost_sum-serviceproduct } ({ ls_rec_cost_sum-serviceproductdescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Receiver System Id (Source) </td> <td> { ls_rec_cost_sum-receiversysid }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Receiving Entity </td> <td>  { ls_rec_cost_sum-receivingentity } ({ ls_rec_cost_sum-receivingentitydescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.


      CLEAR lv_text_concat.
      lv_text_concat =   |<tr> <td>Receiver Company Code</td> <td>  { ls_rec_cost_sum-receivercompanycode } ({ ls_rec_cost_sum-recccodedescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Receiver Cost Object Type (Source) </td> <td>  { ls_rec_cost_sum-reccostobejctdescription }</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   |<tr><td>Receiver Cost Object Number (Source) </td> <td>  { ls_rec_cost_sum-receivercostcenter } ({ ls_rec_cost_sum-reccostcenterdescription })</td></tr> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '</table>' .
      APPEND lv_text_concat TO et_task_desc.

*      LOOP AT lt_rec_cost_sum INTO ls_rec_cost_sum.

      CLEAR lv_text_concat.
      lv_text_concat =   |<h3>Charge-Out Details</h3> | .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '<table>' .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-chargeoutforservice TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_rec_cost_sum-chargeoutforservice.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_rec_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Charge-Out Received</td> <td> { lv_price_str  } | & | { ls_rec_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-totaludmarkupabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_rec_cost_sum-totaludmarkupabs.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_rec_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Mark-up</td> <td> { lv_price_str  } | & | { ls_rec_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-totalcostbaseabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_rec_cost_sum-totalcostbaseabs.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_rec_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Total Cost Remaining</td> <td> { lv_price_str  } | & | { ls_rec_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-valuaddabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_rec_cost_sum-valuaddabs.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_rec_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Thereof Value-Add</td> <td> { lv_price_str  } | & | { ls_rec_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
*      WRITE  ls_rec_cost_sum-passthruabs TO lv_price CURRENCY ls_rec_cost_sum-currency.
      lv_cost_decimal_2 = ls_rec_cost_sum-passthruabs.
      lv_price = |{ lv_cost_decimal_2 CURRENCY = ls_rec_cost_sum-currency }|.
      lv_price_str  = lv_price.
      lv_text_concat =   |<tr> <td>Thereof Pass-Through</td> <td> { lv_price_str  } | & | { ls_rec_cost_sum-currency } </td> </tr>| .
      APPEND lv_text_concat TO et_task_desc.

      CLEAR lv_text_concat.
      lv_text_concat =   '</table>' .
      APPEND lv_text_concat TO et_task_desc.

*      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD wf_application_category.
    category = SWITCH #( application_type
        WHEN c_app-bc_hierarchy_definition OR
             c_app-bc_allocation_key OR
             c_app-bc_royalty_base OR
             c_app-bc_cost_elem_char OR
             c_app-bc_hierarchy THEN c_wf_appl_category-business_configuration
        ELSE c_wf_appl_category-others ).
  ENDMETHOD.

ENDCLASS.
