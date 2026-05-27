CLASS /esrcc/cl_badi_wf_tru DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /esrcc/if_workflow_enh .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /esrcc/cl_badi_wf_tru IMPLEMENTATION.


  METHOD /esrcc/if_workflow_enh~get_agents.
    /esrcc/cl_wf_agents=>get_agents(
      EXPORTING
        iv_wf_id          = iv_wf_id
        iv_approval_level = iv_approval_level
      IMPORTING
        et_agents         = et_agents
    ).
  ENDMETHOD.


  METHOD /esrcc/if_workflow_enh~set_wf_task_description.

    CLEAR: et_task_desc.
*check workflow config for group by
    SELECT SINGLE * FROM /esrcc/wf_switch
             WHERE application = @/esrcc/cl_wf_utility=>c_app-trueuprecal
             INTO @DATA(workflowswitch).

    CASE workflowswitch-workflowgroupby.
      WHEN /esrcc/cl_wf_utility=>c_groupby-provider.
        /esrcc/cl_wf_utility=>set_truprovider_task_descr(
          EXPORTING
            it_leading_object = it_leading_object
          CHANGING
            et_task_desc      = et_task_desc
        ).
      WHEN /esrcc/cl_wf_utility=>c_groupby-receiver.
        /esrcc/cl_wf_utility=>set_trureceiver_task_descr(
          EXPORTING
            it_leading_object = it_leading_object
          CHANGING
            et_task_desc      = et_task_desc
        ).
      WHEN OTHERS.
       /esrcc/cl_wf_utility=>set_truprovider_task_descr(
          EXPORTING
            it_leading_object = it_leading_object
          CHANGING
            et_task_desc      = et_task_desc
        ).

    ENDCASE.

  ENDMETHOD.


  METHOD /esrcc/if_workflow_enh~set_wf_task_title.

    DATA : lv_price              TYPE c LENGTH 50.
    DATA : lv_price_str          TYPE string.
    DATA : lv_text_concat        TYPE string.
    DATA : lv_header             TYPE string.
    DATA : lv_poper              TYPE /esrcc/poper.

*check workflow config for group by
    SELECT SINGLE * FROM /esrcc/wf_switch
             WHERE application = @/esrcc/cl_wf_utility=>c_app-trueuprecal
             INTO @DATA(workflowswitch).

    READ TABLE it_leading_object INTO DATA(ls_leading_object) INDEX 1.
    IF sy-subrc EQ 0.
      lv_poper = ls_leading_object-refpoper.
      DATA(lv_billing_period) =   |{ lv_poper }.| & |{ ls_leading_object-ryear }|.

* Description should be like
      CASE workflowswitch-workflowgroupby.
        WHEN /esrcc/cl_wf_utility=>c_groupby-provider.  "provider
          CONCATENATE lv_billing_period '|| from' ls_leading_object-legalentity ls_leading_object-costobject
                      ls_leading_object-costcenter 'to Receiver(s)'
                            INTO  lv_header SEPARATED BY space .
        WHEN /esrcc/cl_wf_utility=>c_groupby-receiver.
          CONCATENATE lv_billing_period '|| from'
                      ls_leading_object-legalentity ls_leading_object-costobject  ls_leading_object-costcenter
                      'to'
                      ls_leading_object-receivingentity ls_leading_object-reccostobject ls_leading_object-reccostcenter
                      INTO  lv_header SEPARATED BY space .
        WHEN OTHERS.
          CONCATENATE lv_billing_period '|| from' ls_leading_object-legalentity ls_leading_object-costobject
                      ls_leading_object-costcenter 'to Receiver(s)'
                            INTO  lv_header SEPARATED BY space .
      ENDCASE.


    ENDIF.

    CONCATENATE 'True-up Recalculation ||' lv_header
                      INTO  ev_header SEPARATED BY space .

  ENDMETHOD.


  METHOD /esrcc/if_workflow_enh~split_and_create_wf_data.

* Group based on Legal Entity and Cost Center Service Product and Receiving Entity
    DATA lt_leading_object_inp  TYPE /esrcc/tt_wf_leadingobject.
    DATA lt_leading_object_out  TYPE /esrcc/tt_wf_leadingobject.
    DATA ls_out_split_data      TYPE /esrcc/s_split_workflow.

*check workflow config for group by
    SELECT SINGLE * FROM /esrcc/wf_switch
             WHERE application = @/esrcc/cl_wf_utility=>c_app-trueuprecal
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

        SELECT DISTINCT
              fplv,
              ryear,
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
          FOR ALL ENTRIES IN @it_leading_object
               WHERE costbase~fplv        = @it_leading_object-fplv  AND
                   costbase~ryear         = @it_leading_object-ryear AND
                   costbase~recalrefpoper = @it_leading_object-refpoper AND
                   costbase~sysid         = @it_leading_object-sysid AND
                   costbase~legalentity   = @it_leading_object-legalentity AND
                   costbase~ccode         = @it_leading_object-ccode AND
                   costbase~costobject    = @it_leading_object-costobject  AND
                   costbase~costcenter    = @it_leading_object-costcenter AND
                   costbase~processtype   = @/esrcc/if_calculate_chargeout=>recalprocesstype AND
                   costbase~currencytype = 'L'
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

    SORT lt_leading_object_inp BY fplv ryear refpoper sysid ccode costobject costcenter legalentity serviceproduct receivingentity recsysid recccode reccostobject reccostcenter.

    DELETE ADJACENT DUPLICATES FROM lt_leading_object_inp COMPARING fplv ryear refpoper ccode costobject costcenter legalentity serviceproduct receivingentity recsysid recccode reccostobject reccostcenter.

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
ENDCLASS.
