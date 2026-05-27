CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_royalty_key        TYPE STRUCTURE FOR READ RESULT /esrcc/i_roykey_s\\royaltykey,
      tt_royalty_key_create TYPE TABLE FOR CREATE /esrcc/i_roykey_s\\roykeyall\_royaltykey,
      BEGIN OF ts_control,
        royaltykey TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_royalty_key
        IMPORTING
          entity  TYPE ts_royalty_key
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_royalty_key
        IMPORTING
          entities TYPE tt_royalty_key_create
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

  METHOD validate_royalty_key.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-royaltykey = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'ROYALTYBASEKEY' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD precheck_cba_royalty_key.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'RoyaltyKeyAll' ) )
        source_entity_name = '/ESRCC/C_ROYKEY'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_royalty_key(
          entity  = CORRESPONDING #( target )
          control = VALUE #( royaltykey = if_abap_behv=>mk-on )
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
        c_tech_id TYPE /esrcc/smbc_technical_id VALUE '/ESRCC/RoyKey'.
ENDCLASS.

CLASS lhc_rap_tdat_cts IMPLEMENTATION.
  METHOD get.
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = c_tech_id
                                       table_entity_relations = VALUE #(
                                         ( entity = 'RoyaltyKey' table = '/ESRCC/ROYKEY' )
                                         ( entity = 'RoyaltyKeyText' table = '/ESRCC/ROYKEYT' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_roykey_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR roykeyall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION roykeyall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR roykeyall
        RESULT result,
      precheck_cba_royaltykey FOR PRECHECK
        IMPORTING entities FOR CREATE roykeyall\_royaltykey.
ENDCLASS.

CLASS lhc_/esrcc/i_roykey_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(selecttransport_flag) = if_abap_behv=>fc-o-enabled.
*    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.
*
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
    READ ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
    ENTITY roykeyall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.
    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_royaltykey = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
      ENTITY roykeyall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) )
                          FAILED failed.

    READ ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
      ENTITY roykeyall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_ROYKEY' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_royaltykey.
    lcl_custom_validation=>precheck_cba_royalty_key(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-royaltykey
        reported = reported-royaltykey ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_roykey_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_roykey_s IMPLEMENTATION.
  METHOD save_modified.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      READ TABLE update-roykeyall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_roykey DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  TYPES: tt_roy_key TYPE TABLE FOR READ RESULT /esrcc/i_roykey_s\\royaltykey.

  CLASS-METHODS set_workflow_status
    IMPORTING
      entities                     TYPE tt_roy_key
      for_workflow_internal_status TYPE /esrcc/status_de
      to_workflow_status           TYPE /esrcc/status_de.

  CLASS-METHODS set_workflow_internal_status
    IMPORTING
      entities           TYPE tt_roy_key
      to_workflow_status TYPE /esrcc/status_de.

  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR royaltykey~validatetransportrequest,
      copy FOR MODIFY
        IMPORTING
          keys FOR ACTION royaltykey~copy,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR royaltykey
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR royaltykey
        RESULT    result,
      finalize FOR MODIFY
        IMPORTING keys FOR ACTION royaltykey~finalize RESULT result.

    METHODS reopen FOR MODIFY
      IMPORTING keys FOR ACTION royaltykey~reopen RESULT result.

    METHODS submit FOR MODIFY
      IMPORTING keys FOR ACTION royaltykey~submit RESULT result.

    METHODS triggerworkflow FOR DETERMINE ON SAVE
      IMPORTING keys FOR royaltykey~triggerworkflow.

    METHODS updatecomment FOR DETERMINE ON SAVE
      IMPORTING keys FOR royaltykey~updatecomment.

    METHODS updateworkflowstatus FOR DETERMINE ON SAVE
      IMPORTING keys FOR royaltykey~updateworkflowstatus.
ENDCLASS.

CLASS lhc_/esrcc/i_roykey IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_roykey_s.
    IF /esrcc/cl_config_util=>is_transport_mandatory( tech_id = lhc_rap_tdat_cts=>c_tech_id ) = abap_true AND
       lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      SELECT SINGLE transportrequestid
        FROM /esrcc/d_royke_s
        WHERE singletonid = 1
        INTO @DATA(transportrequestid).
      lhc_rap_tdat_cts=>get( )->validate_changes(
                                  transport_request = transportrequestid
                                  table             = '/ESRCC/ROYKEY'
                                  keys              = REF #( keys )
                                  reported          = REF #( reported )
                                  failed            = REF #( failed )
                                  change            = REF #( change-royaltykey ) ).
    ENDIF.
  ENDMETHOD.

  METHOD copy.
    DATA new_royaltykey TYPE TABLE FOR CREATE /esrcc/i_roykey_s\_royaltykey.
    DATA new_royaltykeytext TYPE TABLE FOR CREATE /esrcc/i_roykey_s\\royaltykey\_royaltykeytext.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-royaltykey = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
      ENTITY royaltykey
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_royaltykey)
      FAILED DATA(read_failed).
    READ ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
      ENTITY royaltykey BY \_royaltykeytext
      ALL FIELDS WITH CORRESPONDING #( ref_royaltykey )
      RESULT DATA(ref_royaltykeytext).

    LOOP AT ref_royaltykey ASSIGNING FIELD-SYMBOL(<ref_royaltykey>).
      DATA(key) = keys[ KEY draft %tky = <ref_royaltykey>-%tky ].
      DATA(key_cid) = key-%cid.
      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_royaltykey>-%is_draft
        %target = VALUE #( (
          %cid = key_cid
          %is_draft = <ref_royaltykey>-%is_draft
          %data = CORRESPONDING #( <ref_royaltykey> EXCEPT
            createdat
            createdby
            lastchangedat
            lastchangedby
            locallastchangedat
            royaltybasekey
            singletonid
        ) ) )
      ) TO new_royaltykey ASSIGNING FIELD-SYMBOL(<new_royaltykey>).
      <new_royaltykey>-%target[ 1 ]-royaltybasekey = key-%param-royaltybasekey.
      FIELD-SYMBOLS <new_royaltykeytext> LIKE LINE OF new_royaltykeytext.
      UNASSIGN <new_royaltykeytext>.
      LOOP AT ref_royaltykeytext ASSIGNING FIELD-SYMBOL(<ref_royaltykeytext>) USING KEY draft WHERE %tky-%is_draft = key-%tky-%is_draft
              AND %tky-royaltybasekey = key-%tky-royaltybasekey.
        IF <new_royaltykeytext> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_royaltykeytext ASSIGNING <new_royaltykeytext>.
        ENDIF.
        INSERT VALUE #( %cid = key_cid && <ref_royaltykeytext>-spras
                        %is_draft = key-%is_draft
                        %data = CORRESPONDING #( <ref_royaltykeytext> EXCEPT
                                                 locallastchangedat
                                                 royaltybasekey
                                                 singletonid
        ) ) INTO TABLE <new_royaltykeytext>-%target ASSIGNING FIELD-SYMBOL(<target>).
        <target>-%key-royaltybasekey = key-%param-royaltybasekey.
      ENDLOOP.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_royalty_key(
      EXPORTING
        entities = new_royaltykey
      CHANGING
        failed   = failed-royaltykey
        reported = reported-royaltykey ).

    IF failed-royaltykey IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
        ENTITY roykeyall CREATE BY \_royaltykey
        FIELDS (
                 royaltybasekey
               ) WITH new_royaltykey
        ENTITY royaltykey CREATE BY \_royaltykeytext
        FIELDS (
                 spras
                 royaltybasekey
                 description
               ) WITH new_royaltykeytext
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-royaltykey = mapped_create-royaltykey.
    INSERT LINES OF read_failed-royaltykey INTO TABLE failed-royaltykey.

    IF failed-royaltykey IS INITIAL AND failed-royaltykeytext IS INITIAL.
      reported-royaltykey = VALUE #( FOR created IN mapped-royaltykey (
                                                 %cid = created-%cid
                                                 %action-copy = if_abap_behv=>mk-on
                                                 %msg = mbc_cp_api=>message( )->get_item_copied( )
                                                 %path-roykeyall-%is_draft = created-%is_draft
                                                 %path-roykeyall-singletonid = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_ROYKEY' ).
    result-%action-copy = is_authorized.
  ENDMETHOD.
  METHOD get_instance_features.
    READ ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
        ENTITY royaltykey
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(lo_auth) = NEW /esrcc/cl_authorization( ).
    result = VALUE #( FOR wa IN entities
                      LET update = lo_auth->regulate_action_update( wf_status = wa-workflowstatus )
                      IN ( %tky                   = wa-%tky
                           %action-copy           = lo_auth->regulate_action_copy( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %action-submit         = lo_auth->regulate_action_submit( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %action-finalize       = lo_auth->regulate_action_finalize( is_draft = wa-%is_draft wf_status = wa-workflowstatus wf_internal_status = wa-workflowinternalstatus )
                           %action-reopen         = lo_auth->regulate_action_reopen( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %update                = update
                           %delete                = lo_auth->regulate_action_delete( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %assoc-_royaltykeytext = update ) ).
  ENDMETHOD.

  METHOD finalize.
    READ ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
        ENTITY royaltykey
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>c_wf_status-finalize_in_process ).

    MODIFY ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
        ENTITY royaltykey
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
    READ ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
        ENTITY royaltykey
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>c_wf_status-reopen_in_process ).
    MODIFY ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
        ENTITY royaltykey
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
    READ ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
        ENTITY royaltykey
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>c_wf_status-in_process ).
    TRY.
        MODIFY ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
            ENTITY royaltykey
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

    READ ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
        ENTITY royaltykey
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DELETE entities WHERE workflowinternalstatus <> /esrcc/cl_wf_utility=>c_wf_status-in_process.
    IF entities IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lo_wf_handler) = NEW /esrcc/cl_wf_handler_std( application_type = /esrcc/cl_wf_utility=>c_app-bc_royalty_base ).
    DATA(workflow_internal_status) = ''.
    IF lo_wf_handler->is_wf_on( ) = abap_true.

      lo_wf_handler->/esrcc/if_wf_handler~trigger_workflow_bc(
        EXPORTING
          leading_objects       = CORRESPONDING /esrcc/tt_wf_leadingobject_bc( entities MAPPING royalty_base_key = royaltybasekey EXCEPT * )
        IMPORTING
          leading_objects_error = leading_objects_failed
      ).

      " Update status of failed entities
      DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>c_wf_status-failed ).
      MODIFY ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
        ENTITY royaltykey
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality )
        WITH VALUE #( FOR failed IN leading_objects_failed
                        ( royaltybasekey            = failed-leading_object_bc-royalty_base_key
                          workflowstatus            = /esrcc/cl_wf_utility=>c_wf_status-failed
                          workflowstatuscriticality = criticality ) )
        FAILED DATA(failed_mod)
        MAPPED DATA(mapped_mod).

      " Reset internal status
      MODIFY ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
          ENTITY royaltykey
          UPDATE FIELDS ( workflowinternalstatus )
          WITH VALUE #( FOR entity IN entities
                          ( %tky                   = entity-%tky
                            workflowinternalstatus = workflow_internal_status ) )
          FAILED failed_mod
          MAPPED mapped_mod.

    ELSE.
      criticality = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>c_wf_status-approved ).
      MODIFY ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
        ENTITY royaltykey
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
    READ ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
        ENTITY royaltykey
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
    READ ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
        ENTITY royaltykey
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
    MODIFY ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
        ENTITY royaltykey
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
    MODIFY ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
          ENTITY royaltykey
          UPDATE FIELDS ( workflowinternalstatus )
          WITH VALUE #( FOR entity IN entities WHERE ( workflowinternalstatus <> to_workflow_status )
                          ( %tky                      = entity-%tky
                            %is_draft                 = entity-%is_draft
                            workflowinternalstatus    = to_workflow_status
                            %control                  = VALUE #( workflowinternalstatus = if_abap_behv=>mk-on ) ) ).
  ENDMETHOD.

ENDCLASS.
CLASS lhc_/esrcc/i_roykeytext DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR royaltykeytext~validatetransportrequest,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR royaltykeytext RESULT result.

    METHODS updateinternalworkflowstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR royaltykeytext~updateinternalworkflowstatus.
ENDCLASS.

CLASS lhc_/esrcc/i_roykeytext IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_roykey_s.
    IF /esrcc/cl_config_util=>is_transport_mandatory( tech_id = lhc_rap_tdat_cts=>c_tech_id ) = abap_true AND
       lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      SELECT SINGLE transportrequestid
        FROM /esrcc/d_royke_s
        WHERE singletonid = 1
        INTO @DATA(transportrequestid).
      lhc_rap_tdat_cts=>get( )->validate_changes(
                                  transport_request = transportrequestid
                                  table             = '/ESRCC/ROYKEYT'
                                  keys              = REF #( keys )
                                  reported          = REF #( reported )
                                  failed            = REF #( failed )
                                  change            = REF #( change-royaltykeytext ) ).
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
        ENTITY royaltykeytext
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(text).

    SELECT SINGLE roy_key~workflowstatus
        FROM /esrcc/i_roykey AS roy_key
        INNER JOIN @text AS txt
            ON txt~royaltybasekey = roy_key~royaltybasekey
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

    READ ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
        ENTITY royaltykeytext
        BY \_royaltykey
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    IF entities IS INITIAL.     " When entry is deleted
      READ ENTITIES OF /esrcc/i_roykey_s IN LOCAL MODE
        ENTITY royaltykey
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT entities.
    ENDIF.

    lhc_/esrcc/i_roykey=>set_workflow_internal_status(
      entities           = entities
      to_workflow_status = /esrcc/cl_wf_utility=>c_wf_status-draft
    ).
  ENDMETHOD.

ENDCLASS.
