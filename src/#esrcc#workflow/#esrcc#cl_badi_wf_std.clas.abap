CLASS /esrcc/cl_badi_wf_std DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /esrcc/if_workflow_enh .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /esrcc/cl_badi_wf_std IMPLEMENTATION.


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
             WHERE application = @/esrcc/cl_wf_utility=>c_app-stdchargeout
             INTO @DATA(workflowswitch).

    CASE workflowswitch-workflowgroupby.
      WHEN /esrcc/cl_wf_utility=>c_groupby-provider.
        /esrcc/cl_wf_utility=>set_stdprovider_task_descr(
          EXPORTING
            it_leading_object = it_leading_object
          CHANGING
            et_task_desc      = et_task_desc
        ).
      WHEN /esrcc/cl_wf_utility=>c_groupby-receiver.
        /esrcc/cl_wf_utility=>set_stdreceiver_task_descr(
          EXPORTING
            it_leading_object = it_leading_object
          CHANGING
            et_task_desc      = et_task_desc
        ).
      WHEN OTHERS.
       /esrcc/cl_wf_utility=>set_stdprovider_task_descr(
          EXPORTING
            it_leading_object = it_leading_object
          CHANGING
            et_task_desc      = et_task_desc
        ).

    ENDCASE.

  ENDMETHOD.


  METHOD /esrcc/if_workflow_enh~set_wf_task_title.

    /esrcc/cl_wf_utility=>set_wf_task_title(
      EXPORTING
        iv_application    = /esrcc/cl_wf_utility=>c_app-stdchargeout
        it_leading_object = it_leading_object
      CHANGING
        ev_header         = ev_header
    ).

    CONCATENATE 'Standard Charge-out ||' ev_header
                      INTO  ev_header SEPARATED BY space .

  ENDMETHOD.


  METHOD /esrcc/if_workflow_enh~split_and_create_wf_data.

    /esrcc/cl_wf_utility=>split_and_create_wf_data(
      EXPORTING
        iv_application    = /esrcc/cl_wf_utility=>c_app-stdchargeout
        it_leading_object = it_leading_object
      CHANGING
        et_wf_split_data  = et_wf_split_data
    ).

  ENDMETHOD.
ENDCLASS.
