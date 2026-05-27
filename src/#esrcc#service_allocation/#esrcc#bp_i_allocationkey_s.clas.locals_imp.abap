CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_alloc_key        TYPE STRUCTURE FOR READ RESULT /esrcc/i_allocationkey_s\\allocationkey,
      tt_alloc_key_create TYPE TABLE FOR CREATE /esrcc/i_allocationkey_s\\allocationkeyall\_allocationkey,
      BEGIN OF ts_control,
        allocationkey TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_allocation_key
        IMPORTING
          entity  TYPE ts_alloc_key
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_allocation_key
        IMPORTING
          entities TYPE tt_alloc_key_create
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

  METHOD validate_allocation_key.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-allocationkey = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'ALLOCATIONKEY' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD precheck_cba_allocation_key.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'AllocationKeyAll' ) )
        source_entity_name = '/ESRCC/C_ALLOCATIONKEY'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_allocation_key(
          entity  = CORRESPONDING #( target )
          control = VALUE #( allocationkey = if_abap_behv=>mk-on )
        ).
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_rap_tdat_cts DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      get
        RETURNING
          VALUE(result) TYPE REF TO if_mbc_cp_rap_tdat_cts.

    CLASS-DATA:
        c_tech_id TYPE /esrcc/smbc_technical_id VALUE '/ESRCC/ALLOCKEYS'.

ENDCLASS.

CLASS lhc_rap_tdat_cts IMPLEMENTATION.
  METHOD get.
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = c_tech_id
                                       table_entity_relations = VALUE #( ( entity = 'AllocationKey' table = '/ESRCC/ALLOCKEYS' )
                                                                         ( entity = 'AllocationKeyText' table = '/ESRCC/ALLOCKEYT' ) ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_allocationkey_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR allocationkeyall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION allocationkeyall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR allocationkeyall
        RESULT result,
      precheck_cba_allocationkey FOR PRECHECK
        IMPORTING entities FOR CREATE allocationkeyall\_allocationkey.
ENDCLASS.

CLASS lhc_/esrcc/i_allocationkey_s IMPLEMENTATION.
  METHOD get_instance_features.
*    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false AND
                                   /esrcc/cl_config_util=>is_editable_in_production(
                                       tech_id = lhc_rap_tdat_cts=>c_tech_id ) = abap_false
                              THEN if_abap_behv=>fc-o-disabled
                              ELSE if_abap_behv=>fc-o-enabled ).
    DATA(selecttransport_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).

    READ ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
    ENTITY allocationkeyall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.

    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_allocationkey = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
      ENTITY allocationkeyall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) ).

    READ ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
      ENTITY allocationkeyall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_ALLOCATIONKEY' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_allocationkey.
    lcl_custom_validation=>precheck_cba_allocation_key(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-allocationkey
        reported = reported-allocationkey ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_allocationkey_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_allocationkey_s IMPLEMENTATION.
  METHOD save_modified.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      READ TABLE update-allocationkeyall INDEX 1 INTO DATA(all).
      IF all-transportrequestid IS NOT INITIAL.
        lhc_rap_tdat_cts=>get( )->record_changes(
                                    transport_request = all-transportrequestid
                                    create            = REF #( create )
                                    update            = REF #( update )
                                    delete            = REF #( delete ) ).
      ENDIF.
    ENDIF.
  ENDMETHOD.
  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_allocationkey DEFINITION INHERITING FROM cl_abap_behavior_handler.
  TYPES: tt_allocation_key TYPE TABLE FOR READ RESULT /esrcc/i_allocationkey_s\\allocationkey.

  CLASS-METHODS set_workflow_status
    IMPORTING
      entities                     TYPE tt_allocation_key
      for_workflow_internal_status TYPE /esrcc/status_de
      to_workflow_status           TYPE /esrcc/status_de.

  CLASS-METHODS set_workflow_internal_status
    IMPORTING
      entities           TYPE tt_allocation_key
      to_workflow_status TYPE /esrcc/status_de.

  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR allocationkey~validatetransportrequest,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR allocationkey RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR allocationkey RESULT result.

    METHODS copy FOR MODIFY
      IMPORTING keys FOR ACTION allocationkey~copy.
    METHODS finalize FOR MODIFY
      IMPORTING keys FOR ACTION allocationkey~finalize RESULT result.

    METHODS reopen FOR MODIFY
      IMPORTING keys FOR ACTION allocationkey~reopen RESULT result.

    METHODS submit FOR MODIFY
      IMPORTING keys FOR ACTION allocationkey~submit RESULT result.

    METHODS triggerworkflow FOR DETERMINE ON SAVE
      IMPORTING keys FOR allocationkey~triggerworkflow.

    METHODS updatecomment FOR DETERMINE ON SAVE
      IMPORTING keys FOR allocationkey~updatecomment.

    METHODS updateworkflowstatus FOR DETERMINE ON SAVE
      IMPORTING keys FOR allocationkey~updateworkflowstatus.
ENDCLASS.

CLASS lhc_/esrcc/i_allocationkey IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_allocationkey_s.

    IF /esrcc/cl_config_util=>is_transport_mandatory( tech_id = lhc_rap_tdat_cts=>c_tech_id ) = abap_true AND
       lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      SELECT SINGLE transportrequestid FROM /esrcc/d_alloc_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
      lhc_rap_tdat_cts=>get( )->validate_changes(
                                  transport_request = transportrequestid
                                  table             = '/ESRCC/ALLOCKEYS'
                                  keys              = REF #( keys )
                                  reported          = REF #( reported )
                                  failed            = REF #( failed )
                                  change            = REF #( change-allocationkey ) ).
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
        ENTITY allocationkey
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(lo_auth) = NEW /esrcc/cl_authorization( ).
    result = VALUE #( FOR wa IN entities
                      LET update = lo_auth->regulate_action_update( wf_status = wa-workflowstatus )
                      IN ( %tky                      = wa-%tky
                           %action-copy              = lo_auth->regulate_action_copy( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %action-submit            = lo_auth->regulate_action_submit( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %action-finalize          = lo_auth->regulate_action_finalize( is_draft = wa-%is_draft wf_status = wa-workflowstatus wf_internal_status = wa-workflowinternalstatus )
                           %action-reopen            = lo_auth->regulate_action_reopen( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %update                   = update
                           %delete                   = lo_auth->regulate_action_delete( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %assoc-_allocationkeytext = update ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_REASON' ).
  ENDMETHOD.

  METHOD copy.
    DATA:
      new_main TYPE TABLE FOR CREATE /esrcc/i_allocationkey_s\_allocationkey,
      new_text TYPE TABLE FOR CREATE /esrcc/i_allocationkey_s\\allocationkey\_allocationkeytext.

    FIELD-SYMBOLS <new_text> LIKE LINE OF new_text.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-allocationkey = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
      ENTITY allocationkey
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_main)
      FAILED DATA(read_failed).

    READ ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
      ENTITY allocationkey BY \_allocationkeytext
      ALL FIELDS WITH CORRESPONDING #( ref_main )
      RESULT DATA(ref_text).

    LOOP AT ref_main ASSIGNING FIELD-SYMBOL(<ref_main>).
      DATA(key)     = keys[ KEY draft %tky = <ref_main>-%tky ].
      DATA(key_cid) = key-%cid.

      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_main>-%is_draft
        %target = VALUE #( ( %cid          = key_cid
                             %is_draft     = <ref_main>-%is_draft
                             %data         = CORRESPONDING #( <ref_main> EXCEPT allocationkey singletonid )
                             allocationkey = key-%param-allocationkey ) ) ) TO new_main.

      UNASSIGN <new_text>.
      LOOP AT ref_text ASSIGNING FIELD-SYMBOL(<ref_text>) USING KEY draft WHERE %tky-%is_draft     = key-%tky-%is_draft
                                                                            AND %tky-allocationkey = key-%tky-allocationkey.
        IF <new_text> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_text ASSIGNING <new_text>.
        ENDIF.

        INSERT VALUE #( %cid          = key_cid && <ref_text>-spras
                        %is_draft     = key-%is_draft
                        %data         = CORRESPONDING #( <ref_text> EXCEPT allocationkey singletonid )
                        allocationkey = key-%param-allocationkey ) INTO TABLE <new_text>-%target.
      ENDLOOP.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_allocation_key(
      EXPORTING
        entities = new_main
      CHANGING
        failed   = failed-allocationkey
        reported = reported-allocationkey ).

    IF failed-allocationkey IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
        ENTITY allocationkeyall CREATE BY \_allocationkey
        FIELDS (
                 allocationkey
               ) WITH new_main
        ENTITY allocationkey CREATE BY \_allocationkeytext
        FIELDS (
                 spras
                 allocationkey
                 description
               ) WITH new_text
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-allocationkey = mapped_create-allocationkey.
    INSERT LINES OF read_failed-allocationkey INTO TABLE failed-allocationkey.

    IF failed-allocationkey IS INITIAL AND failed-allocationkeytext IS INITIAL.
      reported-allocationkey = VALUE #( FOR created IN mapped-allocationkey (
                                     %cid            = created-%cid
                                     %action-copy    = if_abap_behv=>mk-on
                                     %msg            = mbc_cp_api=>message( )->get_item_copied( )
                                     %path-allocationkeyall = VALUE #( %is_draft = created-%is_draft singletonid = 1 ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD finalize.
    READ ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
        ENTITY allocationkey
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>c_wf_status-finalize_in_process ).

    MODIFY ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
        ENTITY allocationkey
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
    READ ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
        ENTITY allocationkey
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>c_wf_status-reopen_in_process ).
    MODIFY ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
        ENTITY allocationkey
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
    READ ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
        ENTITY allocationkey
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>c_wf_status-in_process ).
    TRY.
        MODIFY ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
            ENTITY allocationkey
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

    READ ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
        ENTITY allocationkey
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DELETE entities WHERE workflowinternalstatus <> /esrcc/cl_wf_utility=>c_wf_status-in_process.
    IF entities IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lo_wf_handler) = NEW /esrcc/cl_wf_handler_std( application_type = /esrcc/cl_wf_utility=>c_app-bc_allocation_key ).
    DATA(workflow_internal_status) = ''.
    IF lo_wf_handler->is_wf_on( ) = abap_true.

      lo_wf_handler->/esrcc/if_wf_handler~trigger_workflow_bc(
        EXPORTING
          leading_objects       = CORRESPONDING /esrcc/tt_wf_leadingobject_bc( entities MAPPING allocation_key = allocationkey EXCEPT * )
        IMPORTING
          leading_objects_error = leading_objects_failed
      ).

      " Update status of failed entities
      DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>c_wf_status-failed ).
      MODIFY ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
        ENTITY allocationkey
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality )
        WITH VALUE #( FOR failed IN leading_objects_failed
                        ( allocationkey             = failed-leading_object_bc-allocation_key
                          workflowstatus            = /esrcc/cl_wf_utility=>c_wf_status-failed
                          workflowstatuscriticality = criticality ) )
        FAILED DATA(failed_mod)
        MAPPED DATA(mapped_mod).

      " Reset internal status
      MODIFY ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
          ENTITY allocationkey
          UPDATE FIELDS ( workflowinternalstatus )
          WITH VALUE #( FOR entity IN entities
                          ( %tky                   = entity-%tky
                            workflowinternalstatus = workflow_internal_status ) )
          FAILED failed_mod
          MAPPED mapped_mod.

    ELSE.
      criticality = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>c_wf_status-approved ).
      MODIFY ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
        ENTITY allocationkey
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
    READ ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
        ENTITY allocationkey
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
    READ ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
        ENTITY allocationkey
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
    MODIFY ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
        ENTITY allocationkey
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
    MODIFY ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
          ENTITY allocationkey
          UPDATE FIELDS ( workflowinternalstatus )
          WITH VALUE #( FOR entity IN entities WHERE ( workflowinternalstatus <> to_workflow_status )
                          ( %tky                      = entity-%tky
                            %is_draft                 = entity-%is_draft
                            workflowinternalstatus    = to_workflow_status
                            %control                  = VALUE #( workflowinternalstatus = if_abap_behv=>mk-on ) ) ).
  ENDMETHOD.

ENDCLASS.
CLASS lhc_/esrcc/i_allocationkeytext DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR allocationkeytext~validatetransportrequest,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR allocationkeytext RESULT result.

    METHODS updateinternalworkflowstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR allocationkeytext~updateinternalworkflowstatus.
ENDCLASS.

CLASS lhc_/esrcc/i_allocationkeytext IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_allocationkey_s.

    IF /esrcc/cl_config_util=>is_transport_mandatory( tech_id = lhc_rap_tdat_cts=>c_tech_id ) = abap_true AND
       lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      SELECT SINGLE transportrequestid FROM /esrcc/d_alloc_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
      lhc_rap_tdat_cts=>get( )->validate_changes(
                                  transport_request = transportrequestid
                                  table             = '/ESRCC/ALLOCKEYT'
                                  keys              = REF #( keys )
                                  reported          = REF #( reported )
                                  failed            = REF #( failed )
                                  change            = REF #( change-allocationkeytext ) ).
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
        ENTITY allocationkeytext
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(text).

    SELECT SINGLE alloc_key~workflowstatus
        FROM /esrcc/i_allocationkey AS alloc_key
        INNER JOIN @text AS txt
            ON txt~allocationkey = alloc_key~allocationkey
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

    READ ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
        ENTITY allocationkeytext
        BY \_allocationkey
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    IF entities IS INITIAL.     " When entry is deleted
      READ ENTITIES OF /esrcc/i_allocationkey_s IN LOCAL MODE
        ENTITY allocationkey
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT entities.
    ENDIF.

    lhc_/esrcc/i_allocationkey=>set_workflow_internal_status(
      entities           = entities
      to_workflow_status = /esrcc/cl_wf_utility=>c_wf_status-draft
    ).
  ENDMETHOD.

ENDCLASS.
