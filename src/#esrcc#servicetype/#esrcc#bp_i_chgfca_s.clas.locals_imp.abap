CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_rule        TYPE STRUCTURE FOR READ RESULT /esrcc/i_chgfca_s\\rule,
      tt_rule_create TYPE TABLE FOR CREATE /esrcc/i_chgfca_s\\ruleall\_rule,

      BEGIN OF ts_control_rule,
        chargeoutruleid TYPE if_abap_behv=>t_xflag,
        validfrom       TYPE if_abap_behv=>t_xflag,
        validto         TYPE if_abap_behv=>t_xflag,
      END OF ts_control_rule.

    METHODS:
      constructor
        IMPORTING
          config_util_ref TYPE REF TO /esrcc/cl_config_util,

      validate_rule
        IMPORTING
          entity  TYPE ts_rule
          control TYPE ts_control_rule.

    CLASS-METHODS:
      precheck_cba_rule
        IMPORTING
          entities TYPE tt_rule_create
        CHANGING
          reported TYPE any
          failed   TYPE any.

  PRIVATE SECTION.
    DATA:
      config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_rule.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-chargeoutruleid = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'CHARGEOUTRULEID' ) TO fields. ENDIF.
    IF control-validto         = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDTO' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).

    IF control-validfrom = if_abap_behv=>mk-on OR control-validto = if_abap_behv=>mk-on.
      config_util_ref->validate_validity(
        from   = entity-validfrom
        to     = entity-validto
        entity = entity
      ).

      DATA(lv_validfrom) = entity-validfrom.
      DATA(lv_validto) = entity-validto.

      config_util_ref->validate_start_end_of_month(
        EXPORTING
          entity     = entity
        CHANGING
          start_date = lv_validfrom
          end_date   = lv_validto
      ).
    ENDIF.
  ENDMETHOD.

  METHOD precheck_cba_rule.
    TYPES ts_rule TYPE STRUCTURE FOR READ RESULT /esrcc/i_chgfca_s\\rule.

    DATA(lo_trueup) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'Rule' ) )
        source_entity_name = '/ESRCC/C_CHGFCA'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed
    ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_trueup ).

    LOOP AT entities INTO DATA(entity).
      SELECT DISTINCT
             chrg~serviceproduct
          FROM /esrcc/d_chgfca AS chrg
          INNER JOIN @entity-%target AS tent
              ON  tent~serviceproduct = chrg~serviceproduct
              AND tent~validfrom      = chrg~validfrom
          WHERE chrg~draftentityoperationcode NOT IN ( 'D', 'L' )
          INTO TABLE @DATA(duplicate_entities).

      LOOP AT entity-%target INTO DATA(target) GROUP BY ( serviceproduct = target-serviceproduct
                                                          validfrom      = target-validfrom
                                                          size           = GROUP SIZE )
          ASCENDING REFERENCE INTO DATA(group_ref).
        lo_validation->validate_rule(
          entity  = CORRESPONDING #( group_ref->* )
          control = VALUE #( validfrom = if_abap_behv=>mk-on )
        ).

        IF line_exists( duplicate_entities[ serviceproduct = group_ref->serviceproduct ] ) OR group_ref->size > 1.
          lo_trueup->set_duplicate_error( entity = CORRESPONDING ts_rule( group_ref->* ) ).
        ENDIF.
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
        c_tech_id TYPE /esrcc/smbc_technical_id VALUE '/ESRCC/CHGFCA'.
ENDCLASS.

CLASS lhc_rap_tdat_cts IMPLEMENTATION.
  METHOD get.
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = c_tech_id
                                       table_entity_relations = VALUE #(
                                         ( entity = 'Rule' table = '/ESRCC/CHGFCA' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_chgfca_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR ruleall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION ruleall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ruleall
        RESULT result,
      precheck_cba_rule FOR PRECHECK
        IMPORTING entities FOR CREATE ruleall\_rule.
ENDCLASS.

CLASS lhc_/esrcc/i_chgfca_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(selecttransport_flag) = if_abap_behv=>fc-o-enabled.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false AND
                                   /esrcc/cl_config_util=>is_editable_in_production(
                                       tech_id = lhc_rap_tdat_cts=>c_tech_id ) = abap_false
                              THEN if_abap_behv=>fc-o-disabled
                              ELSE if_abap_behv=>fc-o-enabled ).

*    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
*      edit_flag = if_abap_behv=>fc-o-disabled.
*    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_chgfca_s IN LOCAL MODE
    ENTITY ruleall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.
    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_rule = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_chgfca_s IN LOCAL MODE
      ENTITY ruleall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) )
                          FAILED failed.

    READ ENTITIES OF /esrcc/i_chgfca_s IN LOCAL MODE
      ENTITY ruleall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_CHGFCA' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_rule.
    lcl_custom_validation=>precheck_cba_rule(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-rule
        reported = reported-rule ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_chgfca_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_chgfca_s IMPLEMENTATION.
  METHOD save_modified.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      READ TABLE update-ruleall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_chgfca DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR rule~validatetransportrequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR rule
        RESULT result,
      copy FOR MODIFY
        IMPORTING
          keys FOR ACTION rule~copy,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR rule
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR rule
        RESULT    result,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE rule.

    METHODS validatedata FOR VALIDATE ON SAVE
      IMPORTING keys FOR rule~validatedata.
ENDCLASS.

CLASS lhc_/esrcc/i_chgfca IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_chgfca_s.
    IF /esrcc/cl_config_util=>is_transport_mandatory( tech_id = lhc_rap_tdat_cts=>c_tech_id ) = abap_true AND
       lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      SELECT SINGLE transportrequestid
        FROM /esrcc/d_chgfc_s
        WHERE singletonid = 1
        INTO @DATA(transportrequestid).
      lhc_rap_tdat_cts=>get( )->validate_changes(
                                  transport_request = transportrequestid
                                  table             = '/ESRCC/CHGFCA'
                                  keys              = REF #( keys )
                                  reported          = REF #( reported )
                                  failed            = REF #( failed )
                                  change            = REF #( change-rule ) ).
    ENDIF.
  ENDMETHOD.
  METHOD get_global_features.
*    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.
*    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
*      edit_flag = if_abap_behv=>fc-o-disabled.
*    ENDIF.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false AND
                                   /esrcc/cl_config_util=>is_editable_in_production(
                                       tech_id = lhc_rap_tdat_cts=>c_tech_id ) = abap_false
                              THEN if_abap_behv=>fc-o-disabled
                              ELSE if_abap_behv=>fc-o-enabled ).
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.
  METHOD copy.
    DATA new_rule TYPE TABLE FOR CREATE /esrcc/i_chgfca_s\_rule.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-rule = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_chgfca_s IN LOCAL MODE
      ENTITY rule
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_rule)
      FAILED DATA(read_failed).

    LOOP AT ref_rule ASSIGNING FIELD-SYMBOL(<ref_rule>).
      DATA(key) = keys[ KEY draft %tky = <ref_rule>-%tky ].
      DATA(key_cid) = key-%cid.
      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_rule>-%is_draft
        %target = VALUE #( (
          %cid = key_cid
          %is_draft = <ref_rule>-%is_draft
          %data = CORRESPONDING #( <ref_rule> EXCEPT
            createdat
            createdby
            lastchangedat
            lastchangedby
            locallastchangedat
            singletonid
            uuid
        ) ) )
      ) TO new_rule ASSIGNING FIELD-SYMBOL(<new_rule>).
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_rule(
      EXPORTING
        entities = new_rule
      CHANGING
        failed   = failed-rule
        reported = reported-rule ).

    IF failed-rule IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_chgfca_s IN LOCAL MODE
        ENTITY ruleall CREATE BY \_rule
        FIELDS (
                 serviceproduct
                 validfrom
                 validto
                 chargeoutruleid
               ) WITH new_rule
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-rule = mapped_create-rule.
    INSERT LINES OF read_failed-rule INTO TABLE failed-rule.

    IF failed-rule IS INITIAL.
      reported-rule = VALUE #( FOR created IN mapped-rule (
                                                 %cid = created-%cid
                                                 %action-copy = if_abap_behv=>mk-on
                                                 %msg = mbc_cp_api=>message( )->get_item_copied( )
                                                 %path-ruleall-%is_draft = created-%is_draft
                                                 %path-ruleall-singletonid = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD get_global_authorizations.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_CHGFCA' ).
  ENDMETHOD.
  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-copy = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
   ) ).
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
       EXPORTING
         paths              = VALUE #( ( path = 'RuleAll' ) )
         source_entity_name = '/ESRCC/C_CHGFCA'
       CHANGING
         reported_entity    = reported-rule
         failed_entity      = failed-rule ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-chargeoutruleid = if_abap_behv=>mk-on
                                          OR %control-validto         = if_abap_behv=>mk-on.
      lo_validation->validate_rule(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( chargeoutruleid = entity-%control-chargeoutruleid
                           validto         = entity-%control-validto )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD validatedata.
    DATA:
      draft TYPE STRUCTURE FOR READ RESULT /esrcc/i_chgfca_s\\rule.

    READ ENTITIES OF /esrcc/i_chgfca_s IN LOCAL MODE
         ENTITY rule
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

*   To validate overlapping dates
    SELECT chrg~*
      FROM /esrcc/d_chgfca AS chrg
      INNER JOIN @entities AS ent
        ON  ent~serviceproduct = chrg~serviceproduct
      WHERE chrg~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO TABLE @DATA(overlapping_dates).

    DATA(lo_rule) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'RuleAll' ) )
        source_entity_name = '/ESRCC/C_CHGFCA'
      CHANGING
        reported_entity    = reported-rule
        failed_entity      = failed-rule ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_rule ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_rule( entity = entity control = VALUE #( chargeoutruleid = if_abap_behv=>mk-on
                                                                       validto         = if_abap_behv=>mk-on ) ).

      " Validate overlapping dates
      LOOP AT overlapping_dates INTO DATA(date) WHERE serviceproduct = entity-serviceproduct
                                                  AND uuid           <> entity-uuid.
        draft = CORRESPONDING #( date ).
        draft = CORRESPONDING #( BASE ( draft ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).
        lo_rule->validate_overlapping_validity( EXPORTING src_from    = draft-validfrom
                                                          src_to      = draft-validto
                                                          src_entity  = draft
                                                          curr_from   = entity-validfrom
                                                          curr_to     = entity-validto
                                                          curr_entity = entity ).
        EXIT.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
