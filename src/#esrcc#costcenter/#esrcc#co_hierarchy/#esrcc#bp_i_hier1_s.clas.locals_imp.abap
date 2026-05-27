CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_hierarchy        TYPE STRUCTURE FOR READ RESULT /esrcc/i_hier1_s\\hierarchy,
      tt_hierarchy_create TYPE TABLE FOR CREATE /esrcc/i_hier1_s\\hierarchyall\_hierarchy,
      BEGIN OF ts_control,
        hierarchy TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_hierarchy
        IMPORTING
          entity  TYPE ts_hierarchy
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_hierarchy
        IMPORTING
          entities TYPE tt_hierarchy_create
        CHANGING
          reported TYPE any
          failed   TYPE any.

  PRIVATE SECTION.
    DATA: config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_hierarchy.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-hierarchy = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'HIERARCHY' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD precheck_cba_hierarchy.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'HierarchyAll' ) )
        source_entity_name = '/ESRCC/C_HIER1'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_hierarchy(
          entity  = CORRESPONDING #( target )
          control = VALUE #( hierarchy = if_abap_behv=>mk-on )
        ).
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_rap_tdat_cts DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      get
        RETURNING
          VALUE(result) TYPE REF TO if_mbc_cp_rap_tdat_cts.

    CLASS-DATA:
        c_tech_id TYPE /esrcc/smbc_technical_id VALUE '/ESRCC/HIER1'.
ENDCLASS.

CLASS lhc_rap_tdat_cts IMPLEMENTATION.
  METHOD get.
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = c_tech_id
                                       table_entity_relations = VALUE #(
                                         ( entity = 'Hierarchy' table = '/ESRCC/HIER1' )
                                         ( entity = 'HierarchyText' table = '/ESRCC/HIER1_T' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_hier1_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR hierarchyall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION hierarchyall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR hierarchyall
        RESULT result,
      precheck_cba_hierarchy FOR PRECHECK
        IMPORTING entities FOR CREATE hierarchyall\_hierarchy.
ENDCLASS.

CLASS lhc_/esrcc/i_hier1_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(selecttransport_flag) = if_abap_behv=>fc-o-enabled.
*    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.

*    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
*      edit_flag = if_abap_behv=>fc-o-disabled.
*    ENDIF.

    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false AND
                                   /esrcc/cl_config_util=>is_editable_in_production(
                                       tech_id = lhc_rap_tdat_cts=>c_tech_id ) = abap_false
                              THEN if_abap_behv=>fc-o-disabled
                              ELSE if_abap_behv=>fc-o-enabled ).
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
    ENTITY hierarchyall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.
    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_hierarchy = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
      ENTITY hierarchyall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) )
                          FAILED failed.

    READ ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
      ENTITY hierarchyall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_HIER1' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_hierarchy.
    lcl_custom_validation=>precheck_cba_hierarchy(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-hierarchy
        reported = reported-hierarchy ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_hier1_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_hier1_s IMPLEMENTATION.
  METHOD save_modified.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      READ TABLE update-hierarchyall INDEX 1 INTO DATA(all).
      IF all-transportrequestid IS NOT INITIAL.
        lhc_rap_tdat_cts=>get( )->record_changes(
                                    transport_request = all-transportrequestid
                                    create            = REF #( create )
                                    update            = REF #( update )
                                    delete            = REF #( delete ) ).
      ENDIF.
    ENDIF.
  ENDMETHOD.
  METHOD cleanup_finalize ##NEEDED.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_hier1 DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    TYPES: tt_hier TYPE TABLE FOR READ RESULT /esrcc/i_hier1_s\\hierarchy.

    CLASS-METHODS set_workflow_status
      IMPORTING
        entities                     TYPE tt_hier
        for_workflow_internal_status TYPE /esrcc/status_de
        to_workflow_status           TYPE /esrcc/status_de.

    CLASS-METHODS set_workflow_internal_status
      IMPORTING
        entities           TYPE tt_hier
        to_workflow_status TYPE /esrcc/status_de.

  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR hierarchy~validatetransportrequest,
      copy FOR MODIFY
        IMPORTING
          keys FOR ACTION hierarchy~copy,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR hierarchy
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR hierarchy
        RESULT    result,
      finalize FOR MODIFY
        IMPORTING keys FOR ACTION hierarchy~finalize RESULT result.

    METHODS reopen FOR MODIFY
      IMPORTING keys FOR ACTION hierarchy~reopen RESULT result.

    METHODS submit FOR MODIFY
      IMPORTING keys FOR ACTION hierarchy~submit RESULT result.

    METHODS triggerworkflow FOR DETERMINE ON SAVE
      IMPORTING keys FOR hierarchy~triggerworkflow.

    METHODS updatecomment FOR DETERMINE ON SAVE
      IMPORTING keys FOR hierarchy~updatecomment.

    METHODS updateworkflowstatus FOR DETERMINE ON SAVE
      IMPORTING keys FOR hierarchy~updateworkflowstatus.
ENDCLASS.

CLASS lhc_/esrcc/i_hier1 IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_hier1_s.

    IF /esrcc/cl_config_util=>is_transport_mandatory( tech_id = lhc_rap_tdat_cts=>c_tech_id ) = abap_true AND
       lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      SELECT SINGLE transportrequestid
        FROM /esrcc/d_hier1_s
        WHERE singletonid = 1
        INTO @DATA(transportrequestid).
      lhc_rap_tdat_cts=>get( )->validate_changes(
                                  transport_request = transportrequestid
                                  table             = '/ESRCC/HIER1'
                                  keys              = REF #( keys )
                                  reported          = REF #( reported )
                                  failed            = REF #( failed )
                                  change            = REF #( change-hierarchy ) ).
    ENDIF.
  ENDMETHOD.

  METHOD copy.
    DATA new_hierarchy TYPE TABLE FOR CREATE /esrcc/i_hier1_s\_hierarchy.
    DATA new_hierarchytext TYPE TABLE FOR CREATE /esrcc/i_hier1_s\\hierarchy\_hierarchytext.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-hierarchy = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
      ENTITY hierarchy
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_hierarchy)
      FAILED DATA(read_failed).
    READ ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
      ENTITY hierarchy BY \_hierarchytext
      ALL FIELDS WITH CORRESPONDING #( ref_hierarchy )
      RESULT DATA(ref_hierarchytext).

    LOOP AT ref_hierarchy ASSIGNING FIELD-SYMBOL(<ref_hierarchy>).
      DATA(key) = keys[ KEY draft %tky = <ref_hierarchy>-%tky ].
      DATA(key_cid) = key-%cid.
      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_hierarchy>-%is_draft
        %target = VALUE #( (
          %cid = key_cid
          %is_draft = <ref_hierarchy>-%is_draft
          %data = CORRESPONDING #( <ref_hierarchy> EXCEPT
            createdat
            createdby
            hierarchy
            lastchangedat
            lastchangedby
            locallastchangedat
            singletonid
        ) ) )
      ) TO new_hierarchy ASSIGNING FIELD-SYMBOL(<new_hierarchy>).
      <new_hierarchy>-%target[ 1 ]-hierarchy = key-%param-hierarchy.
      FIELD-SYMBOLS <new_hierarchytext> LIKE LINE OF new_hierarchytext.
      UNASSIGN <new_hierarchytext>.
      LOOP AT ref_hierarchytext ASSIGNING FIELD-SYMBOL(<ref_hierarchytext>) USING KEY draft WHERE %tky-%is_draft = key-%tky-%is_draft
              AND %tky-hierarchy = key-%tky-hierarchy.
        IF <new_hierarchytext> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_hierarchytext ASSIGNING <new_hierarchytext>.
        ENDIF.
        INSERT VALUE #( %cid = key_cid && <ref_hierarchytext>-spras
                        %is_draft = key-%is_draft
                        %data = CORRESPONDING #( <ref_hierarchytext> EXCEPT
                                                 hierarchy
                                                 locallastchangedat
                                                 singletonid
        ) ) INTO TABLE <new_hierarchytext>-%target ASSIGNING FIELD-SYMBOL(<target>).
        <target>-%key-hierarchy = key-%param-hierarchy.
      ENDLOOP.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_hierarchy(
      EXPORTING
        entities = new_hierarchy
      CHANGING
        failed   = failed-hierarchy
        reported = reported-hierarchy ).

    IF failed-hierarchy IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
        ENTITY hierarchyall CREATE BY \_hierarchy
        FIELDS (
                 hierarchy
               ) WITH new_hierarchy
        ENTITY hierarchy CREATE BY \_hierarchytext
        FIELDS (
                 spras
                 hierarchy
                 description
               ) WITH new_hierarchytext
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-hierarchy = mapped_create-hierarchy.
    INSERT LINES OF read_failed-hierarchy INTO TABLE failed-hierarchy.

    IF failed-hierarchy IS INITIAL AND failed-hierarchytext IS INITIAL.
      reported-hierarchy = VALUE #( FOR created IN mapped-hierarchy (
                                                 %cid = created-%cid
                                                 %action-copy = if_abap_behv=>mk-on
                                                 %msg = mbc_cp_api=>message( )->get_item_copied( )
                                                 %path-hierarchyall-%is_draft = created-%is_draft
                                                 %path-hierarchyall-singletonid = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_HIER1' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%action-copy = is_authorized.
  ENDMETHOD.
  METHOD get_instance_features.
    READ ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
        ENTITY hierarchy
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(lo_auth) = NEW /esrcc/cl_authorization( ).
    result = VALUE #( FOR wa IN entities
                      LET update = lo_auth->regulate_action_update( wf_status = wa-workflowstatus )
                      IN ( %tky                  = wa-%tky
                           %action-copy          = lo_auth->regulate_action_copy( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %action-submit        = lo_auth->regulate_action_submit( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %action-finalize      = lo_auth->regulate_action_finalize( is_draft = wa-%is_draft wf_status = wa-workflowstatus wf_internal_status = wa-workflowinternalstatus )
                           %action-reopen        = lo_auth->regulate_action_reopen( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %update               = update
                           %delete               = lo_auth->regulate_action_delete( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %assoc-_hierarchytext = update ) ).
  ENDMETHOD.

  METHOD finalize.
    READ ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
        ENTITY hierarchy
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>c_wf_status-finalize_in_process ).

    MODIFY ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
        ENTITY hierarchy
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality workflowinternalstatus )
        WITH VALUE #( FOR entity IN entities
                        ( %tky                      = entity-%tky
                          workflowinternalstatus    = /esrcc/cl_wf_utility=>c_wf_status-finalize_in_process
                          workflowstatus            = /esrcc/cl_wf_utility=>c_wf_status-finalize_in_process
                          workflowstatuscriticality = criticality ) )
        FAILED failed
        REPORTED reported
        MAPPED mapped.

    result = VALUE #( FOR entity IN entities ( %tky = entity-%tky %param = entity ) ).
    reported-%other = VALUE #( ( /esrcc/cl_config_msg_handler=>inform_on_action( ) ) ).
  ENDMETHOD.

  METHOD reopen.
    READ ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
        ENTITY hierarchy
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>c_wf_status-reopen_in_process ).
    MODIFY ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
        ENTITY hierarchy
        UPDATE FIELDS ( comments workflowid workflowstatus workflowstatuscriticality workflowinternalstatus )
        WITH VALUE #( FOR entity IN entities
                        ( %tky                      = entity-%tky
                          workflowid                = ''
                          workflowstatus            = /esrcc/cl_wf_utility=>c_wf_status-reopen_in_process
                          workflowstatuscriticality = criticality
                          workflowinternalstatus    = /esrcc/cl_wf_utility=>c_wf_status-reopen_in_process ) )
        FAILED failed
        REPORTED reported
        MAPPED mapped.

    result = VALUE #( FOR entity IN entities ( %tky = entity-%tky
                                               %is_draft = entity-%is_draft
                                               %param-%tky = entity-%tky ) ).

    reported-%other = VALUE #( ( /esrcc/cl_config_msg_handler=>inform_on_action( ) ) ).
  ENDMETHOD.

  METHOD submit.
    READ ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
        ENTITY hierarchy
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>c_wf_status-in_process ).
    TRY.
        MODIFY ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
            ENTITY hierarchy
            UPDATE FIELDS ( commentid comments workflowid workflowstatus workflowstatuscriticality workflowinternalstatus )
            WITH VALUE #( FOR entity IN entities
                            ( %tky                      = entity-%tky
                              workflowid                = ''
                              commentid                 = COND #( WHEN entity-commentid IS INITIAL THEN
                                                                  cl_uuid_factory=>create_system_uuid( )->create_uuid_c32( )
                                                                  ELSE entity-commentid )
                              comments                  = VALUE #( keys[ KEY draft %tky = entity-%tky ]-%param-comments OPTIONAL )
                              workflowstatus            = /esrcc/cl_wf_utility=>c_wf_status-in_process
                              workflowstatuscriticality = criticality
                              workflowinternalstatus    = /esrcc/cl_wf_utility=>c_wf_status-in_process ) )
            FAILED failed
            REPORTED reported
            MAPPED mapped.
      CATCH cx_uuid_error.
        "handle exception
    ENDTRY.

    result = VALUE #( FOR entity IN entities ( %tky = entity-%tky
                                               %is_draft = entity-%is_draft
                                               %param-comments = entity-comments ) ).

    reported-%other = VALUE #( ( /esrcc/cl_config_msg_handler=>inform_on_action( ) ) ).
  ENDMETHOD.

  METHOD triggerworkflow.
    DATA leading_objects_failed TYPE /esrcc/tt_wf_leadingobject_err.

    READ ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
        ENTITY hierarchy
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DELETE entities WHERE workflowinternalstatus <> /esrcc/cl_wf_utility=>c_wf_status-in_process.
    IF entities IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lo_wf_handler) = NEW /esrcc/cl_wf_handler_std( application_type = /esrcc/cl_wf_utility=>c_app-bc_hierarchy ).
    DATA(workflow_internal_status) = ''.
    IF lo_wf_handler->is_wf_on( ) = abap_true.

      lo_wf_handler->/esrcc/if_wf_handler~trigger_workflow_bc(
        EXPORTING
          leading_objects       = CORRESPONDING /esrcc/tt_wf_leadingobject_bc( entities MAPPING hierarchy1 = hierarchy EXCEPT * )
        IMPORTING
          leading_objects_error = leading_objects_failed
      ).

      " Update status of failed entities
      DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>c_wf_status-failed ).
      MODIFY ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
        ENTITY hierarchy
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality )
        WITH VALUE #( FOR failed IN leading_objects_failed
                        ( hierarchy                    = failed-leading_object_bc-hierarchy1
                          workflowstatus            = /esrcc/cl_wf_utility=>c_wf_status-failed
                          workflowstatuscriticality = criticality ) )
        FAILED DATA(failed_mod)
        MAPPED DATA(mapped_mod).

      " Reset internal status
      MODIFY ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
          ENTITY hierarchy
          UPDATE FIELDS ( workflowinternalstatus )
          WITH VALUE #( FOR entity IN entities
                          ( %tky                   = entity-%tky
                            workflowinternalstatus = workflow_internal_status ) )
          FAILED failed_mod
          MAPPED mapped_mod.

    ELSE.
      criticality = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>c_wf_status-approved ).
      MODIFY ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
        ENTITY hierarchy
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality workflowinternalstatus )
        WITH VALUE #( FOR entity IN entities
                        ( %tky                      = entity-%tky
                          workflowstatus            = /esrcc/cl_wf_utility=>c_wf_status-approved
                          workflowstatuscriticality = criticality
                          workflowinternalstatus    = workflow_internal_status ) )
        FAILED failed_mod
        MAPPED mapped_mod.
    ENDIF.
  ENDMETHOD.

  METHOD updatecomment.
    READ ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
        ENTITY hierarchy
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    LOOP AT entities INTO DATA(entity) WHERE commentid IS NOT INITIAL.
      /esrcc/cl_comments_util=>modify_comments(
        comments    = VALUE #( instanceid = entity-commentid )
        iv_comments = entity-comments
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD updateworkflowstatus.
    READ ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
        ENTITY hierarchy
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    " Set workflow status to "Draft"
    set_workflow_status(
      entities                     = entities
      for_workflow_internal_status = /esrcc/cl_wf_utility=>c_wf_status-draft
      to_workflow_status           = /esrcc/cl_wf_utility=>c_wf_status-draft
    ).

    " Set workflow status to "Finalized"
    set_workflow_status(
      entities                     = entities
      for_workflow_internal_status = /esrcc/cl_wf_utility=>c_wf_status-finalize_in_process
      to_workflow_status           = /esrcc/cl_wf_utility=>c_wf_status-finalized
    ).

    " Set workflow status to "Approved"
    set_workflow_status(
      entities                     = entities
      for_workflow_internal_status = /esrcc/cl_wf_utility=>c_wf_status-reopen_in_process
      to_workflow_status           = /esrcc/cl_wf_utility=>c_wf_status-approved
    ).
  ENDMETHOD.

  METHOD set_workflow_status.
    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = to_workflow_status ).
    MODIFY ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
        ENTITY hierarchy
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality )
        WITH VALUE #( FOR entity IN entities WHERE ( workflowinternalstatus = for_workflow_internal_status )
                        ( %tky                      = entity-%tky
                          %is_draft                 = entity-%is_draft
                          workflowstatus            = to_workflow_status
                          workflowstatuscriticality = criticality
                          %control                  = VALUE #( workflowstatus            = if_abap_behv=>mk-on
                                                               workflowstatuscriticality = if_abap_behv=>mk-on ) ) ).
  ENDMETHOD.


  METHOD set_workflow_internal_status.
    MODIFY ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
          ENTITY hierarchy
          UPDATE FIELDS ( workflowinternalstatus )
          WITH VALUE #( FOR entity IN entities WHERE ( workflowinternalstatus <> to_workflow_status )
                          ( %tky                      = entity-%tky
                            %is_draft                 = entity-%is_draft
                            workflowinternalstatus    = to_workflow_status
                            %control                  = VALUE #( workflowinternalstatus = if_abap_behv=>mk-on ) ) ).
  ENDMETHOD.

ENDCLASS.
CLASS lhc_/esrcc/i_hier1text DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR hierarchytext~validatetransportrequest,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR hierarchytext RESULT result.

    METHODS updateinternalworkflowstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR hierarchytext~updateinternalworkflowstatus.
ENDCLASS.

CLASS lhc_/esrcc/i_hier1text IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_hier1_s.

    IF /esrcc/cl_config_util=>is_transport_mandatory( tech_id = lhc_rap_tdat_cts=>c_tech_id ) = abap_true AND
       lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      SELECT SINGLE transportrequestid
        FROM /esrcc/d_hier1_s
        WHERE singletonid = 1
        INTO @DATA(transportrequestid).
      lhc_rap_tdat_cts=>get( )->validate_changes(
                                  transport_request = transportrequestid
                                  table             = '/ESRCC/HIER1_T'
                                  keys              = REF #( keys )
                                  reported          = REF #( reported )
                                  failed            = REF #( failed )
                                  change            = REF #( change-hierarchytext ) ).
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
        ENTITY hierarchytext
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(text).

    SELECT SINGLE hier~workflowstatus
        FROM /esrcc/i_hier1 AS hier
        INNER JOIN @text AS txt
            ON txt~hierarchy = hier~hierarchy
        INTO @DATA(wf_status).

    DATA(lo_auth) = NEW /esrcc/cl_authorization( ).
    DATA(regulate_update) = lo_auth->regulate_action_update( wf_status = wf_status ).
    DATA(regulate_delete) = lo_auth->regulate_action_delete( wf_status = wf_status ).

    result = VALUE #( FOR wa IN text ( %tky    = wa-%tky
                                       %update = regulate_update
                                       %delete = regulate_delete ) ).
  ENDMETHOD.

  METHOD updateinternalworkflowstatus.
    CHECK keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.

    READ ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
        ENTITY hierarchytext
        BY \_hierarchy
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    IF entities IS INITIAL.     " When entry is deleted
      READ ENTITIES OF /esrcc/i_hier1_s IN LOCAL MODE
        ENTITY hierarchy
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT entities.
    ENDIF.

    lhc_/esrcc/i_hier1=>set_workflow_internal_status(
      entities           = entities
      to_workflow_status = /esrcc/cl_wf_utility=>c_wf_status-draft
    ).
  ENDMETHOD.

ENDCLASS.
