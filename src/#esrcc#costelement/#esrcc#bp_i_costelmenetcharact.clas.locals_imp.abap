CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_ce_char                  TYPE STRUCTURE FOR READ RESULT /esrcc/i_costelmenetcharacte_s\\costelementchar,
      tt_cost_element_char_create TYPE TABLE FOR CREATE /esrcc/i_costelmenetcharacte_s\\costelementcharall\_costelementchar,
      BEGIN OF ts_control,
        validfrom      TYPE if_abap_behv=>t_xflag,
        validto        TYPE if_abap_behv=>t_xflag,
        cost_indicator TYPE if_abap_behv=>t_xflag,
        posting_type   TYPE if_abap_behv=>t_xflag,
        usage_type     TYPE if_abap_behv=>t_xflag,
        value_source   TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_ce_char
        IMPORTING
          entity  TYPE ts_ce_char
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_cost_element_char
        IMPORTING
          entities TYPE tt_cost_element_char_create
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

  METHOD validate_ce_char.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-validfrom      = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDFROM' ) TO fields. ENDIF.
    IF control-validto        = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDTO' ) TO fields. ENDIF.
    IF control-cost_indicator = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COSTINDICATOR' ) TO fields. ENDIF.
    IF control-posting_type   = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'POSTINGTYPE' ) TO fields. ENDIF.
    IF control-usage_type     = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'USAGETYPE' ) TO fields. ENDIF.
    IF control-value_source   = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALUESOURCE' ) TO fields. ENDIF.

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

  METHOD precheck_cba_cost_element_char.
    TYPES ts_ce_char TYPE STRUCTURE FOR READ RESULT /esrcc/i_costelmenetcharacte_s\\costelementchar.
    CONSTANTS c_vs_virtual TYPE /esrcc/value_source VALUE 'SCC'.

    DATA(lo_config_util) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'CostElementCharAll' ) )
        source_entity_name = '/ESRCC/C_COSTELMENETCHARACTE'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_config_util ).

    SELECT SINGLE text
      FROM /esrcc/i_valuesource
      WHERE valuesource = @c_vs_virtual
      INTO @DATA(value_source_text).

    LOOP AT entities INTO DATA(entity).
*     Identify duplicate entries
      SELECT DISTINCT
             celem~sysid,
             celem~legalentity,
             celem~companycode,
             celem~costobject,
             celem~costcenter,
             celem~costelementfrom,
             celem~costelementto
          FROM /esrcc/d_cstelmt AS celem
          INNER JOIN @entity-%target AS tent
              ON  tent~sysid           = celem~sysid
              AND tent~legalentity     = celem~legalentity
              AND tent~companycode     = celem~companycode
              AND tent~costobject      = celem~costobject
              AND tent~costcenter      = celem~costcenter
              AND tent~costelementfrom = celem~costelementfrom
              AND tent~costelementto   = celem~costelementto
              AND tent~validfrom       = celem~validfrom
          WHERE celem~draftentityoperationcode NOT IN ( 'D', 'L' )
          INTO TABLE @DATA(duplicate_entities).

*     Identify already assigned cost element entities
      SELECT DISTINCT
             tent~cstelmntcharuuid
          FROM /esrcc/d_cstelmt AS celem
          INNER JOIN @entity-%target AS tent
              ON  tent~sysid       = celem~sysid
              AND tent~legalentity = celem~legalentity
              AND tent~companycode = celem~companycode
              AND tent~costobject = celem~costobject
              AND tent~costcenter = celem~costcenter
              AND tent~costelementfrom = celem~costelementfrom
              AND tent~costelementto   = celem~costelementto
              AND tent~valuesource = celem~valuesource
              AND tent~validfrom   BETWEEN celem~validfrom AND celem~validto
          WHERE celem~draftentityoperationcode NOT IN ( 'D', 'L' )
            AND tent~valuesource  = @c_vs_virtual
            AND celem~valuesource = @c_vs_virtual
          INTO TABLE @DATA(assigned_entities).

      LOOP AT entity-%target INTO DATA(target) GROUP BY ( sysid           = target-sysid
                                                          legalentity     = target-legalentity
                                                          companycode     = target-companycode
                                                          costobject      = target-costobject
                                                          costcenter      = target-costcenter
                                                          costelementfrom = target-costelementfrom
                                                          costelementto   = target-costelementto
                                                          validfrom       = target-validfrom
                                                          size            = GROUP SIZE )
          ASCENDING REFERENCE INTO DATA(group_ref).
        READ TABLE entity-%target INTO DATA(t_entity) INDEX sy-tabix.

*       Validate mandatory fields
        " Sequence: Legal Entity, Company Code, Cost Object & Cost Center
        IF t_entity-costcenter IS NOT INITIAL AND
           ( t_entity-legalentity IS INITIAL OR
             t_entity-companycode IS INITIAL OR
             t_entity-costobject IS INITIAL ).
          DATA(mandatory_fields) = VALUE /esrcc/cl_config_util=>tt_fields( ( fieldname = 'LEGALENTITY' )
                                                                           ( fieldname = 'COMPANYCODE' )
                                                                           ( fieldname = 'COSTOBJECT' ) ).
          " Sequence: Legal Entity, Company Code & Cost Object
        ELSEIF t_entity-costobject IS NOT INITIAL AND
               ( t_entity-legalentity IS INITIAL OR
                 t_entity-companycode IS INITIAL ).
          mandatory_fields = VALUE /esrcc/cl_config_util=>tt_fields( ( fieldname = 'LEGALENTITY' )
                                                                     ( fieldname = 'COMPANYCODE' ) ).
          " Sequence: Legal Entity & Company Code
        ELSEIF t_entity-companycode IS NOT INITIAL AND
               t_entity-legalentity IS INITIAL.
          mandatory_fields = VALUE /esrcc/cl_config_util=>tt_fields( ( fieldname = 'LEGALENTITY' ) ).
        ELSEIF t_entity-legalentity IS NOT INITIAL AND
               t_entity-companycode IS INITIAL.
          mandatory_fields = VALUE /esrcc/cl_config_util=>tt_fields( ( fieldname = 'COMPANYCODE' ) ).
        ENDIF.

        lo_config_util->validate_initial(
          fields = mandatory_fields
          entity = t_entity
        ).

        lo_config_util->foreign_check_cost_element(
          sysid         = t_entity-sysid
          cost_element  = t_entity-costelementfrom
          linked_fields = VALUE #( ( 'SYSID' ) ( 'COSTELEMENTFROM' ) )
          entity        = t_entity
        ).

        lo_config_util->foreign_check_cost_element(
          sysid         = t_entity-sysid
          cost_element  = t_entity-costelementto
          linked_fields = VALUE #( ( 'SYSID' ) ( 'COSTELEMENTTO' ) )
          entity        = t_entity
        ).

*       Validate combination
        IF t_entity-legalentity IS NOT INITIAL AND t_entity-companycode IS NOT INITIAL.
          IF t_entity-costobject IS NOT INITIAL AND  t_entity-costcenter IS NOT INITIAL.
            " Validate Cost Number
            lo_config_util->foreign_check_cost_center(
              sysid         = t_entity-sysid
              ccode         = t_entity-companycode
              legal_entity  = t_entity-legalentity
              cost_object   = t_entity-costobject
              cost_center   = t_entity-costcenter
              linked_fields = VALUE #( ( 'SYSID' ) ( 'COMPANYCODE' ) ( 'LEGALENTITY' ) )
              entity        = t_entity
            ).
          ELSE.
            lo_config_util->foreign_check_ccode(
              sysid         = t_entity-sysid
              ccode         = t_entity-companycode
              legal_entity  = t_entity-legalentity
              linked_fields = VALUE #( ( 'SYSID' ) ( 'COMPANYCODE' ) ( 'LEGALENTITY' ) )
              entity        = t_entity
            ).
          ENDIF.
        ENDIF.

        " Validate duplicate entries
        IF line_exists( duplicate_entities[ sysid       = group_ref->sysid
                                            legalentity = group_ref->legalentity
                                            companycode = group_ref->companycode
                                            costobject  = group_ref->costobject
                                            costcenter  = group_ref->costcenter
                                            costelementfrom = group_ref->costelementfrom
                                            costelementto = group_ref->costelementto ] ) OR group_ref->size > 1.
          lo_config_util->set_state_message(
            entity     = CORRESPONDING ts_ce_char( target )
            msg        = /esrcc/cl_config_msg_handler=>duplicate_key( )
            state_area = CONV #( /esrcc/cl_config_util=>duplicate ) ).
        ELSEIF line_exists( assigned_entities[ cstelmntcharuuid = t_entity-cstelmntcharuuid ] ).
          " Validate cost element assignment
          lo_config_util->set_state_message(
            entity     = CORRESPONDING ts_ce_char( t_entity )
            msg        = /esrcc/cl_config_msg_handler=>duplicate_cost_element( v1 = value_source_text )
            state_area = CONV #( /esrcc/cl_config_util=>duplicate ) ).
        ENDIF.
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
        c_tech_id TYPE /esrcc/smbc_technical_id VALUE '/ESRCC/COSTELMENETCHARACTE'.

ENDCLASS.

CLASS lhc_rap_tdat_cts IMPLEMENTATION.
  METHOD get.
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = c_tech_id
                                       table_entity_relations = VALUE #( ( entity = 'CostElementChar' table = '/ESRCC/CSTELMTCH' ) ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_costelmenetcharac DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    TYPES: tt_ce_char TYPE TABLE FOR READ RESULT /esrcc/i_costelmenetcharacte_s\\costelementchar.

    CLASS-METHODS set_workflow_status
      IMPORTING
        entities                     TYPE tt_ce_char
        for_workflow_internal_status TYPE /esrcc/status_de
        to_workflow_status           TYPE /esrcc/status_de.

    CLASS-METHODS set_workflow_internal_status
      IMPORTING
        entities           TYPE tt_ce_char
        to_workflow_status TYPE /esrcc/status_de.

  PRIVATE SECTION.
    CONSTANTS c_source_entity TYPE sxco_cds_object_name VALUE '/ESRCC/C_COSTELMENETCHARACTE'.
    CONSTANTS c_path TYPE sxco_cds_association_name VALUE 'CostElementCharAll'.

    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR costelementcharall
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR costelementcharall
        RESULT result,
      precheck_cba_costelementchar FOR PRECHECK
        IMPORTING entities FOR CREATE costelementcharall\_costelementchar,
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR costelementchar~validatedata,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE costelementchar,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING keys FOR ACTION costelementcharall~selectcustomizingtransptreq RESULT result.

    METHODS copy FOR MODIFY
      IMPORTING keys FOR ACTION costelementchar~copy.

    METHODS validatetransportrequest FOR VALIDATE ON SAVE
      IMPORTING keys FOR costelementchar~validatetransportrequest.
    METHODS get_instance_features_1 FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR costelementchar RESULT result.

    METHODS get_global_authorizations_1 FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR costelementchar RESULT result.
    METHODS setuuid FOR DETERMINE ON SAVE
      IMPORTING keys FOR costelementchar~setuuid.
    METHODS finalize FOR MODIFY
      IMPORTING keys FOR ACTION costelementchar~finalize RESULT result.

    METHODS reopen FOR MODIFY
      IMPORTING keys FOR ACTION costelementchar~reopen RESULT result.

    METHODS submit FOR MODIFY
      IMPORTING keys FOR ACTION costelementchar~submit RESULT result.

    METHODS updateinternalworkflowstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR costelementchar~updateinternalworkflowstatus.

    METHODS triggerworkflow FOR DETERMINE ON SAVE
      IMPORTING keys FOR costelementchar~triggerworkflow.

    METHODS updatecomment FOR DETERMINE ON SAVE
      IMPORTING keys FOR costelementchar~updatecomment.

    METHODS updateworkflowstatus FOR DETERMINE ON SAVE
      IMPORTING keys FOR costelementchar~updateworkflowstatus.
ENDCLASS.

CLASS lhc_/esrcc/i_costelmenetcharac IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(edit_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false AND
                                   /esrcc/cl_config_util=>is_editable_in_production(
                                       tech_id = lhc_rap_tdat_cts=>c_tech_id ) = abap_false
                              THEN if_abap_behv=>fc-o-disabled
                              ELSE if_abap_behv=>fc-o-enabled ).
    DATA(selecttransport_flag) = COND #( WHEN lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ).

    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
    ENTITY costelementcharall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.

    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_costelementchar = edit_flag
               %action-selectcustomizingtransptreq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    DATA(is_authorized) = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_COSTELMENETCHARACTE' ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.

  METHOD precheck_cba_costelementchar.
    lcl_custom_validation=>precheck_cba_cost_element_char(
      EXPORTING
        entities = entities
      CHANGING
        failed   = failed-costelementchar
        reported = reported-costelementchar ).
  ENDMETHOD.

  METHOD validatedata.
    DATA: draft TYPE STRUCTURE FOR READ RESULT /esrcc/c_costelmenetcharacte_s\\costelementchar.
    CONSTANTS c_vs_virtual TYPE /esrcc/value_source VALUE 'SCC'.

    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
         ENTITY costelementchar
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

*   To validate overlapping dates
    SELECT ele~*
      FROM /esrcc/d_cstelmt AS ele
      INNER JOIN @entities AS ent
        ON  ent~sysid        = ele~sysid
        AND ent~legalentity  = ele~legalentity
        AND ent~companycode  = ele~companycode
*        AND ent~costelement  = ele~costelement
      WHERE ele~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO TABLE @DATA(overlapping_dates).

    DATA(lo_ce_char) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = c_path ) )
        source_entity_name = c_source_entity
      CHANGING
        reported_entity    = reported-costelementchar
        failed_entity      = failed-costelementchar ).

    SELECT SINGLE text
        FROM /esrcc/i_valuesource
        WHERE valuesource = @c_vs_virtual
        INTO @DATA(value_source_text).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_ce_char ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_ce_char(
        entity  = entity
        control = VALUE #( validto        = if_abap_behv=>mk-on
                           cost_indicator = if_abap_behv=>mk-on
                           posting_type   = if_abap_behv=>mk-on
                           usage_type     = if_abap_behv=>mk-on
                           value_source   = if_abap_behv=>mk-on )
      ).

      " Validate overlapping dates
      LOOP AT overlapping_dates INTO DATA(date)
           WHERE     sysid            = entity-sysid
                 AND legalentity      = entity-legalentity
                 AND companycode      = entity-companycode
                 AND costelementfrom  = entity-costelementfrom
                 AND costelementto    = entity-costelementto
                 AND cstelmntcharuuid <> entity-cstelmntcharuuid.
        draft = CORRESPONDING #( date ).
        draft = CORRESPONDING #( BASE ( draft ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).
        lo_ce_char->validate_overlapping_validity( EXPORTING src_from    = draft-validfrom
                                                             src_to      = draft-validto
                                                             src_entity  = draft
                                                             curr_from   = entity-validfrom
                                                             curr_to     = entity-validto
                                                             curr_entity = entity ).
      ENDLOOP.

*      IF entity-valuesource = c_vs_virtual.
*        LOOP AT overlapping_dates INTO date WHERE cstelmntcharuuid <> entity-cstelmntcharuuid
*                                              AND sysid            = entity-sysid
*                                              AND legalentity      = entity-legalentity
*                                              AND companycode      = entity-companycode
*                                              AND valuesource      = c_vs_virtual
*                                              AND ( validfrom      BETWEEN entity-validfrom AND entity-validto
*                                                OR  validto        BETWEEN entity-validfrom AND entity-validto ).
*          lo_ce_char->set_state_message(
*            entity     = entity
*            msg        = new_message(
*                           id       = /esrcc/cl_config_util=>c_config_msg
*                           number   = '030'
*                           severity = if_abap_behv_message=>severity-error
*                           v1       = value_source_text )
*            state_area = CONV #( /esrcc/cl_config_util=>duplicate )
*          ).
*          EXIT.
*        ENDLOOP.
*      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
        EXPORTING
          paths              = VALUE #( ( path = c_path ) )
          source_entity_name = c_source_entity
        CHANGING
          reported_entity    = reported-costelementchar
          failed_entity      = failed-costelementchar ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-costindicator = if_abap_behv=>mk-on
                                          OR %control-validto       = if_abap_behv=>mk-on
                                          OR %control-postingtype   = if_abap_behv=>mk-on
                                          OR %control-usagetype     = if_abap_behv=>mk-on
                                          OR %control-valuesource   = if_abap_behv=>mk-on.
      lo_validation->validate_ce_char(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( validto        = entity-%control-validto
                           cost_indicator = entity-%control-costindicator
                           posting_type   = entity-%control-postingtype
                           usage_type     = entity-%control-usagetype
                           value_source   = entity-%control-valuesource )
      ).
    ENDLOOP.
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
      ENTITY costelementcharall
        UPDATE FIELDS ( transportrequestid hidetransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                          hidetransport      = abap_false ) ).

    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
      ENTITY costelementcharall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.

  METHOD copy.
    DATA:
      new_main TYPE TABLE FOR CREATE /esrcc/i_costelmenetcharacte_s\_costelementchar.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-costelementchar = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
      ENTITY costelementchar
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_main)
      FAILED DATA(read_failed).

    LOOP AT ref_main ASSIGNING FIELD-SYMBOL(<ref_main>).
      DATA(key)     = keys[ KEY draft %tky = <ref_main>-%tky ].
      DATA(key_cid) = key-%cid.

      APPEND VALUE #(
        %tky-singletonid = 1
        %is_draft = <ref_main>-%is_draft
        %target = VALUE #( ( %cid            = key_cid
                             %is_draft       = <ref_main>-%is_draft
                             %data           = CORRESPONDING #( <ref_main> EXCEPT cstelmntcharuuid validfrom validto singletonid )
                             sysid           = key-%param-sysid
                             legalentity     = key-%param-legalentity
                             companycode     = key-%param-companycode
                             costobject      = key-%param-costobject
                             costcenter      = key-%param-costcenter
                             costelementfrom = key-%param-costelementfrom
                             costelementto   = key-%param-costelementto
                             validfrom       = key-%param-validfrom
                             validto         = key-%param-validto ) ) ) TO new_main.
    ENDLOOP.

*   Pre-check validation before create
    lcl_custom_validation=>precheck_cba_cost_element_char(
      EXPORTING
        entities = new_main
      CHANGING
        failed   = failed-costelementchar
        reported = reported-costelementchar ).

    IF failed-costelementchar IS INITIAL.
      MODIFY ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
        ENTITY costelementcharall CREATE BY \_costelementchar
        FIELDS (
                 sysid
                 legalentity
                 companycode
                 costobject
                 costcenter
                 costelementfrom
                 costelementto
                 validfrom
                 validto
                 costtype
                 postingtype
                 costindicator
                 usagetype
                 reasonid
                 valuesource
*                 costelementuuid
               ) WITH new_main
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.
    ENDIF.

    mapped-costelementchar = mapped_create-costelementchar.
    INSERT LINES OF read_failed-costelementchar INTO TABLE failed-costelementchar.

    IF failed-costelementchar IS INITIAL.
      reported-costelementchar = VALUE #( FOR created IN mapped-costelementchar (
                                     %cid            = created-%cid
                                     %action-copy    = if_abap_behv=>mk-on
                                     %msg            = mbc_cp_api=>message( )->get_item_copied( )
                                     %path-costelementcharall = VALUE #( %is_draft = created-%is_draft singletonid = 1 ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /esrcc/i_costelmenetcharacte_s.

    IF /esrcc/cl_config_util=>is_transport_mandatory( tech_id = lhc_rap_tdat_cts=>c_tech_id ) = abap_true AND
       lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      SELECT SINGLE transportrequestid FROM /esrcc/d_cstel_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
      lhc_rap_tdat_cts=>get( )->validate_changes(
                                  transport_request = transportrequestid
                                  table             = '/ESRCC/CSTELMTCH'
                                  keys              = REF #( keys )
                                  reported          = REF #( reported )
                                  failed            = REF #( failed )
                                  change            = REF #( change-costelementchar ) ).
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_features_1.
    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
        ENTITY costelementchar
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(lo_auth) = NEW /esrcc/cl_authorization( ).
    result = VALUE #( FOR wa IN entities
                      LET update = lo_auth->regulate_action_update( wf_status = wa-workflowstatus )
                      IN ( %tky             = wa-%tky
                           %action-copy     = lo_auth->regulate_action_copy( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %action-submit   = lo_auth->regulate_action_submit( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %action-finalize = lo_auth->regulate_action_finalize( is_draft = wa-%is_draft wf_status = wa-workflowstatus wf_internal_status = wa-workflowinternalstatus )
                           %action-reopen   = lo_auth->regulate_action_reopen( is_draft = wa-%is_draft wf_status = wa-workflowstatus )
                           %update          = update
                           %delete          = lo_auth->regulate_action_delete( is_draft = wa-%is_draft wf_status = wa-workflowstatus ) ) ).
  ENDMETHOD.

  METHOD get_global_authorizations_1.
    result-%action-copy = /esrcc/cl_authorization=>check_authorization_tabu( field_name = '/ESRCC/I_COSTELMENETCHARACTE' ).
  ENDMETHOD.

  METHOD setuuid.
*    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
*      ENTITY costelementchar
*      ALL FIELDS WITH CORRESPONDING #( keys )
*      RESULT DATA(entities).

*    MODIFY ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
*      ENTITY costelementchar
*      UPDATE FIELDS ( costelementuuid )
*      WITH VALUE #( FOR entity IN entities ( %tky = entity-%tky
*                                             costelementuuid = /esrcc/cl_uuid_finder=>cost_element_uuid( EXPORTING parameter = CORRESPONDING #( entity ) ) ) )
*      FAILED DATA(ufailed)
*      REPORTED DATA(ureported).

*    reported-costelementchar = CORRESPONDING #( ureported-costelementchar ).
  ENDMETHOD.

  METHOD finalize.
    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
        ENTITY costelementchar
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>c_wf_status-finalize_in_process ).

    MODIFY ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
        ENTITY costelementchar
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
    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
        ENTITY costelementchar
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>c_wf_status-reopen_in_process ).
    MODIFY ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
        ENTITY costelementchar
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
    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
        ENTITY costelementchar
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>c_wf_status-in_process ).
    TRY.
        MODIFY ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
            ENTITY costelementchar
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

  METHOD updateinternalworkflowstatus.
    CHECK keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.

    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
        ENTITY costelementchar
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    " Set internal status to "Draft" for modified entries
    set_workflow_internal_status(
      entities           = entities
      to_workflow_status = /esrcc/cl_wf_utility=>c_wf_status-draft
    ).
  ENDMETHOD.

  METHOD triggerworkflow.
    DATA leading_objects_failed TYPE /esrcc/tt_wf_leadingobject_err.

    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
        ENTITY costelementchar
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DELETE entities WHERE workflowinternalstatus <> /esrcc/cl_wf_utility=>c_wf_status-in_process.
    IF entities IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lo_wf_handler) = NEW /esrcc/cl_wf_handler_std( application_type = /esrcc/cl_wf_utility=>c_app-bc_cost_elem_char ).
    DATA(workflow_internal_status) = ''.
    IF lo_wf_handler->is_wf_on( ) = abap_true.

      lo_wf_handler->/esrcc/if_wf_handler~trigger_workflow_bc(
        EXPORTING
          leading_objects       = CORRESPONDING /esrcc/tt_wf_leadingobject_bc( entities MAPPING cost_element_char_uuid = cstelmntcharuuid EXCEPT * )
        IMPORTING
          leading_objects_error = leading_objects_failed
      ).

      " Update status of failed entities
      DATA(criticality) = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>c_wf_status-failed ).
      MODIFY ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
        ENTITY costelementchar
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality )
        WITH VALUE #( FOR failed IN leading_objects_failed
                        ( cstelmntcharuuid          = failed-leading_object_bc-cost_element_char_uuid
                          workflowstatus            = /esrcc/cl_wf_utility=>c_wf_status-failed
                          workflowstatuscriticality = criticality ) )
        FAILED DATA(failed_mod)
        MAPPED DATA(mapped_mod).

      " Reset internal status
      MODIFY ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
          ENTITY costelementchar
          UPDATE FIELDS ( workflowinternalstatus )
          WITH VALUE #( FOR entity IN entities
                          ( %tky                   = entity-%tky
                            workflowinternalstatus = workflow_internal_status ) )
          FAILED failed_mod
          MAPPED mapped_mod.

    ELSE.
      criticality = /esrcc/cl_wf_utility=>wf_status_criticality( status = /esrcc/cl_wf_utility=>c_wf_status-approved ).
      MODIFY ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
        ENTITY costelementchar
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
    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
        ENTITY costelementchar
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
    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
        ENTITY costelementchar
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
    MODIFY ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
        ENTITY costelementchar
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
    MODIFY ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
          ENTITY costelementchar
          UPDATE FIELDS ( workflowinternalstatus )
          WITH VALUE #( FOR entity IN entities WHERE ( workflowinternalstatus <> to_workflow_status )
                          ( %tky                      = entity-%tky
                            %is_draft                 = entity-%is_draft
                            workflowinternalstatus    = to_workflow_status
                            %control                  = VALUE #( workflowinternalstatus = if_abap_behv=>mk-on ) ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_/esrcc/i_costelmenetcharac DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_costelmenetcharac IMPLEMENTATION.
  METHOD save_modified.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_true.
      READ TABLE update-costelementcharall INDEX 1 INTO DATA(all).
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
