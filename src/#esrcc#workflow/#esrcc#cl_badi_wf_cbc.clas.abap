class /ESRCC/CL_BADI_WF_CBC definition
  public
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces /ESRCC/IF_BADI_WORKFLOW_BC .
protected section.
private section.
ENDCLASS.



CLASS /ESRCC/CL_BADI_WF_CBC IMPLEMENTATION.


  METHOD /esrcc/if_badi_workflow_bc~get_agents.
    /esrcc/cl_wf_agents=>get_agents_bc(
      EXPORTING
        iv_wf_id          = iv_wf_id
        iv_approval_level = iv_approval_level
      IMPORTING
        et_agents         = et_agents
    ).
  ENDMETHOD.


  method /ESRCC/IF_BADI_WORKFLOW_BC~SET_WF_TASK_TITLE.
  endmethod.


  method /ESRCC/IF_BADI_WORKFLOW_BC~SPLIT_AND_CREATE_WF_DATA.
    LOOP AT it_leading_object INTO DATA(ls_leading_object).
      APPEND INITIAL LINE TO et_wf_split_data ASSIGNING FIELD-SYMBOL(<fs_split_data>).
      APPEND ls_leading_object TO <fs_split_data>-segment.
    ENDLOOP.
  endmethod.


  METHOD /esrcc/if_badi_workflow_bc~set_wf_task_description.
  ENDMETHOD.
ENDCLASS.
