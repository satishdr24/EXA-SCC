CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES ts_rule        TYPE STRUCTURE FOR READ RESULT /esrcc/i_rr_rule_s\\Rule.
    TYPES tt_rule_create TYPE TABLE FOR CREATE /esrcc/i_rr_rule_s\\ruleall\_rule.
    TYPES: BEGIN OF ts_control,
             ruleID              TYPE if_abap_behv=>t_xflag,
             validfrom           TYPE if_abap_behv=>t_xflag,
             validto             TYPE if_abap_behv=>t_xflag,
             PartnerSystemId     TYPE if_abap_behv=>t_xflag,
             PartnerLegalEntity  TYPE if_abap_behv=>t_xflag,
             PartnerCompanyCode  TYPE if_abap_behv=>t_xflag,
             PartnerObjectType   TYPE if_abap_behv=>t_xflag,
             PartnerObjectNumber TYPE if_abap_behv=>t_xflag,
             salesordercreation  TYPE if_abap_behv=>t_xflag,
             keyfield            TYPE if_abap_behv=>t_xflag,
             uuid                TYPE if_abap_behv=>t_xflag,
           END OF ts_control.

    METHODS constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util.

    METHODS validate_rule
      IMPORTING !entity  TYPE ts_rule
                !control TYPE ts_control.

    CLASS-METHODS precheck_cba_rule
      IMPORTING !entities TYPE tt_rule_create
      CHANGING  !reported TYPE any
                !failed   TYPE any.

  PRIVATE SECTION.
    DATA: config_util_ref TYPE REF TO /esrcc/cl_config_util.
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

    IF control-validfrom = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDFROM' ) TO fields. ENDIF.
    IF control-validto = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDTO' ) TO fields. ENDIF.
    IF control-ruleID = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'RULEID' ) TO fields. ENDIF.
    IF control-PartnerSystemId = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'PARTNERSYSTEMID' ) TO fields. ENDIF.
    IF control-partnerlegalentity = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'PARTNERLEGALENTITY' ) TO fields. ENDIF.
    IF control-partnercompanycode = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'PARTNERCOMPANYCODE' ) TO fields. ENDIF.
    IF control-partnerobjecttype = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'PARTNEROBJECTTYPE' ) TO fields. ENDIF.
    IF control-partnerobjectnumber = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'PARTNEROBJECTNUMBER' ) TO fields. ENDIF.
    IF control-salesordercreation = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'SALESORDERCREATION' ) TO fields. ENDIF.
    IF control-keyfield = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'KEYFIELD' ) TO fields. ENDIF.

    IF fields IS NOT INITIAL.
      config_util_ref->validate_initial( fields = fields
                                         entity = entity ).
    ENDIF.

    IF control-uuid = if_abap_behv=>mk-on.
      config_util_ref->validate_initial( fields     = VALUE #( (  fieldname = 'PARTNERUUID' ) )
                                         entity     = entity
                                         message_no = '037' ).
    ENDIF.


    IF control-validfrom = if_abap_behv=>mk-on OR control-validto = if_abap_behv=>mk-on.

      config_util_ref->validate_validity( from   = entity-validfrom
                                          to     = entity-validto
                                          entity = entity ).

      DATA(validfrom) = entity-validfrom.
      DATA(validto) = entity-validto.

      config_util_ref->validate_start_end_of_month( EXPORTING entity     = entity
                                                    CHANGING  start_date = validfrom
                                                              end_date   = validto ).
    ENDIF.
  ENDMETHOD.

  METHOD precheck_cba_rule.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
                                                       EXPORTING paths              = VALUE #( ( path = 'RuleAll' ) )
                                                                 source_entity_name = '/ESRCC/C_RR_RULE'
                                                                 is_transition      = abap_true
                                                       CHANGING  reported_entity    = reported
                                                                 failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_rule( entity  = CORRESPONDING #( target )
                                         control = VALUE #( ruleID = if_abap_behv=>mk-on
                                                             ) ).
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

ENDCLASS.

CLASS lhc_rap_tdat_cts IMPLEMENTATION.
  METHOD get.
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/RR_RULE'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'Rule' table = '/ESRCC/RR_RULE' )
                                         ( entity = 'RuleText' table = '/ESRCC/RR_RULET' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_rr_rule_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR RuleAll
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION RuleAll~SelectCustomizingTransptReq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR RuleAll
        RESULT result,
      precheck_cba_Rule FOR PRECHECK
        IMPORTING entities FOR CREATE RuleAll\_Rule.
ENDCLASS.

CLASS lhc_/esrcc/i_rr_rule_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(selecttransport_flag) = if_abap_behv=>fc-o-enabled.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /ESRCC/I_RR_Rule_S IN LOCAL MODE
    ENTITY RuleAll
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.
    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_Rule = edit_flag
               %action-SelectCustomizingTransptReq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /ESRCC/I_RR_Rule_S IN LOCAL MODE
      ENTITY RuleAll
        UPDATE FIELDS ( TransportRequestID HideTransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          TransportRequestID = key-%param-transportrequestid
                          HideTransport      = abap_false ) )
                          FAILED failed.

    READ ENTITIES OF /ESRCC/I_RR_Rule_S IN LOCAL MODE
      ENTITY RuleAll
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_RR_RULE' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-Edit = is_authorized.
    result-%action-SelectCustomizingTransptReq = is_authorized.
  ENDMETHOD.

  METHOD precheck_cba_Rule.
    " To prevent keys being populated with spaces
    lcl_custom_validation=>precheck_cba_rule( EXPORTING entities = entities
                                              CHANGING  failed   = failed-rule
                                                        reported = reported-rule ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_rr_rule_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_rr_rule_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-RuleAll INDEX 1 INTO DATA(all).
    IF all-TransportRequestID IS NOT INITIAL.
      lhc_rap_tdat_cts=>get( )->record_changes(
                                  transport_request = all-TransportRequestID
                                  create            = REF #( create )
                                  update            = REF #( update )
                                  delete            = REF #( delete ) ).
    ENDIF.
  ENDMETHOD.
  METHOD cleanup_finalize ##NEEDED.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_rr_rule DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    DATA c_source_entity TYPE sxco_cds_object_name      VALUE '/ESRCC/C_RR_RULE'.
    DATA c_path          TYPE sxco_cds_association_name VALUE 'RuleAll'.

    METHODS validatetransportrequest FOR VALIDATE ON SAVE
      IMPORTING
        keys FOR Rule~ValidateTransportRequest.
    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING
      REQUEST requested_features FOR Rule
      RESULT result.
    METHODS copyrule FOR MODIFY
      IMPORTING
        keys FOR ACTION Rule~CopyRule.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING
      REQUEST requested_authorizations FOR Rule
      RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING
                keys   REQUEST requested_features FOR Rule
      RESULT    result.
    METHODS ValidateData FOR VALIDATE ON SAVE
      IMPORTING keys FOR Rule~ValidateData.
    METHODS SetUUID FOR DETERMINE ON SAVE
      IMPORTING keys FOR Rule~SetUUID.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE Rule.
ENDCLASS.

CLASS lhc_/esrcc/i_rr_rule IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /ESRCC/I_RR_Rule_S.

    SELECT SINGLE TransportRequestID
      FROM /esrcc/d_rr_ru_s
      WHERE SingletonID = 1
      INTO @DATA(TransportRequestID).
    lhc_rap_tdat_cts=>get( )->validate_changes( transport_request = TransportRequestID
                                                table             = '/ESRCC/RR_RULE'
                                                keys              = REF #( keys )
                                                reported          = REF #( reported )
                                                failed            = REF #( failed )
                                                change            = REF #( change-Rule ) ).
  ENDMETHOD.

  METHOD get_global_features.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
*    result-%update = edit_flag.
    result-%delete = edit_flag.
    result-%assoc-_RuleText    = edit_flag.
  ENDMETHOD.

  METHOD copyrule.
    DATA new_Rule     TYPE TABLE FOR CREATE /ESRCC/I_RR_Rule_S\_Rule.
    DATA new_RuleText TYPE TABLE FOR CREATE /ESRCC/I_RR_Rule_S\\Rule\_RuleText.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-Rule = VALUE #( FOR fkey IN keys
                             ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /ESRCC/I_RR_Rule_S IN LOCAL MODE
         ENTITY Rule
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(ref_Rule)
         FAILED DATA(read_failed).
    READ ENTITIES OF /ESRCC/I_RR_Rule_S IN LOCAL MODE
         ENTITY Rule BY \_RuleText
         ALL FIELDS WITH CORRESPONDING #( ref_Rule )
         RESULT DATA(ref_RuleText).

    LOOP AT ref_Rule ASSIGNING FIELD-SYMBOL(<ref_Rule>).
      DATA(key) = keys[ KEY draft
                        %tky = <ref_Rule>-%tky ].
      DATA(key_cid) = key-%cid.
      APPEND VALUE #( %tky-SingletonID = 1
                      %is_draft        = <ref_Rule>-%is_draft
                      %target          = VALUE #( ( %cid      = key_cid
                                                    %is_draft = <ref_Rule>-%is_draft
                                                    %data     = CORRESPONDING #( <ref_Rule> EXCEPT
                                                          CreatedAt
                                                          CreatedBy
                                                          LastChangedAt
                                                          LastChangedBy
                                                          LocalLastChangedAt
                                                          RuleId
                                                          SingletonID ) ) ) )
             TO new_Rule ASSIGNING FIELD-SYMBOL(<new_Rule>).
      <new_Rule>-%target[ 1 ]-RuleId = key-%param-RuleId.
      FIELD-SYMBOLS <new_RuleText> LIKE LINE OF new_RuleText.
      UNASSIGN <new_RuleText>.
      LOOP AT ref_RuleText ASSIGNING FIELD-SYMBOL(<ref_RuleText>) USING KEY draft WHERE     %tky-%is_draft = key-%tky-%is_draft
                                                                                        AND %tky-RuleId    = key-%tky-RuleId.
        IF <new_RuleText> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_RuleText ASSIGNING <new_RuleText>.
        ENDIF.
        INSERT VALUE #( %cid      = key_cid && <ref_RuleText>-Spras
                        %is_draft = key-%is_draft
                        %data     = CORRESPONDING #( <ref_RuleText> EXCEPT
                                                     LocalLastChangedAt
                                                     RuleId
                                                     SingletonID ) )
               INTO TABLE <new_RuleText>-%target ASSIGNING FIELD-SYMBOL(<target>).
        <target>-%key-RuleId = key-%param-RuleId.
      ENDLOOP.

      UNASSIGN <new_RuleText>.
    ENDLOOP.

    " To prevent keys being populated with spaces
    lcl_custom_validation=>precheck_cba_rule( EXPORTING entities = new_rule
                                              CHANGING  failed   = failed-rule
                                                        reported = reported-rule ).

    IF failed-rule IS INITIAL.
      MODIFY ENTITIES OF /ESRCC/I_RR_Rule_S IN LOCAL MODE
             ENTITY RuleAll CREATE BY \_Rule
             FIELDS (
                      RuleId
                      SystemId
                      LegalEntity
                      CompanyCode
                      ObjectType
                      ObjectNumber
                      KeyField
                      FunctionalArea
                      ProfitCenter
                      BusinessDivision
                      RelatedMaterial
                      Validfrom
                      Validto
                      ActiveFlag
                      PartnerUuid
                      SalesOrderCreation
                      PartnerSystemId
                      PartnerLegalEntity
                      PartnerCompanyCode
                      PartnerObjectType
                      PartnerObjectNumber
                      PartnerFunctionalArea
                      PartnerProfitCenter
                      PartnerBusinessDivision )
             WITH new_Rule
             ENTITY Rule CREATE BY \_RuleText
             FIELDS (
               Spras
               RuleId
               Description )
             WITH new_RuleText
             MAPPED DATA(mapped_create)
             FAILED failed
             REPORTED reported.
    ENDIF.

    mapped-Rule = mapped_create-Rule.
    INSERT LINES OF read_failed-Rule INTO TABLE failed-Rule.

    IF failed-Rule IS INITIAL.
      reported-Rule = VALUE #( FOR created IN mapped-Rule
                               ( %cid                      = created-%cid
                                 %action-CopyRule          = if_abap_behv=>mk-on
                                 %msg                      = mbc_cp_api=>message( )->get_item_copied( )
                                 %path-RuleAll-%is_draft   = created-%is_draft
                                 %path-RuleAll-SingletonID = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_RR_RULE' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%action-CopyRule = is_authorized.
  ENDMETHOD.

  METHOD get_instance_features.
    result = VALUE #(
        FOR row IN keys
        ( %tky             = row-%tky
          %action-CopyRule = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off
                                     THEN if_abap_behv=>fc-o-disabled
                                     ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.



  METHOD SetUUID.
    READ ENTITIES OF /ESRCC/I_RR_Rule_S IN LOCAL MODE
         ENTITY Rule
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).
    IF entities IS INITIAL.
      RETURN.
    ENDIF.

    SELECT system_id,
           legal_entity,
           company_code,
           object_type,
           object_number,
           uuid
      FROM /esrcc/rr_objct
      FOR ALL ENTRIES IN @entities
      WHERE system_id     = @entities-PartnerSystemId
        AND legal_entity  = @entities-PartnerLegalEntity
        AND company_code  = @entities-PartnerCompanyCode
        AND object_type   = @entities-PartnerObjectType
        AND object_number = @entities-PartnerObjectNumber
        AND active_flag = 'X'
      INTO TABLE @DATA(uuids).


    MODIFY ENTITIES OF /ESRCC/I_RR_Rule_S IN LOCAL MODE
           ENTITY Rule
           UPDATE FIELDS ( PartnerUuid )
           WITH VALUE #( FOR entity IN entities
                         ( %tky        = entity-%tky
                           PartnerUUID = VALUE #( uuids[ system_id     = entity-PartnerSystemId
                                                         legal_entity  = entity-PartnerLegalEntity
                                                         company_code  = entity-PartnerCompanyCode
                                                         object_type   = entity-PartnerObjectType
                                                         object_number = entity-PartnerObjectNumber ]-uuid OPTIONAL ) ) )
           REPORTED DATA(reported_tmp).
    reported-rule = CORRESPONDING #( reported_tmp-rule ).
  ENDMETHOD.

  METHOD ValidateData.
    TYPES ts_rule TYPE STRUCTURE FOR READ RESULT /ESRCC/I_RR_Rule_S\\Rule.

    READ ENTITIES OF /ESRCC/I_RR_Rule_S IN LOCAL MODE
         ENTITY Rule
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

    IF entities IS INITIAL.
      RETURN.
    ENDIF.

    SELECT Sysid,
           LegalEntity,
           CompanyCode,
           ObjectType,
           ObjectNumber
      FROM /ESRCC/I_RR_ObjctRec_F4
      FOR ALL ENTRIES IN @entities
      WHERE Sysid        = @entities-PartnerSystemId
        AND LegalEntity  = @entities-PartnerLegalEntity
        AND CompanyCode  = @entities-PartnerCompanyCode
        AND ObjectType   = @entities-PartnerObjectType
        AND ObjectNumber = @entities-PartnerObjectNumber
        AND ActiveFlag = @abap_true
      INTO TABLE @DATA(valid_rr_partners).

    SELECT Sysid,
           LegalEntity,
           CompanyCode,
           ObjectType,
           ObjectNumber
      FROM /ESRCC/I_RR_ObjctPr_F4
      FOR ALL ENTRIES IN @entities
      WHERE Sysid        = @entities-SystemId
        AND LegalEntity  = @entities-LegalEntity
        AND CompanyCode  = @entities-CompanyCode
        AND ObjectType   = @entities-ObjectType
        AND ObjectNumber = @entities-ObjectNumber
        AND ActiveFlag = @abap_true
      INTO TABLE @DATA(valid_rr_sources).

    SELECT Sysid,
           LegalEntity,
           Ccode
      FROM /esrcc/i_companycodes_pr_f4
      FOR ALL ENTRIES IN @entities
      WHERE Sysid       = @entities-SystemId
        AND LegalEntity = @entities-LegalEntity
        AND Ccode       = @entities-CompanyCode
      INTO TABLE @DATA(valid_source_companies).

    DATA(lo_validate_line) = /esrcc/cl_config_util=>create( EXPORTING paths              = VALUE #( ( path = c_path ) )
                                                                      source_entity_name = c_source_entity
                                                            CHANGING  reported_entity    = reported-rule
                                                                      failed_entity      = failed-rule ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_validate_line ).
    DATA(lo_rule) = /esrcc/cl_config_util=>create( EXPORTING paths              = VALUE #( ( path = c_path ) )
                                                             source_entity_name = c_source_entity
                                                   CHANGING  reported_entity    = reported-rule
                                                             failed_entity      = failed-rule ).

    LOOP AT entities INTO DATA(entity).
      lo_rule->reset_state_area( entity     = entity
                                 state_area = CONV #( /esrcc/cl_config_util=>invalid_uuid ) ).
      lo_rule->reset_state_area( entity     = entity
                                 state_area = CONV #( /esrcc/cl_config_util=>mandatory ) ).
      lo_rule->reset_state_area( entity     = entity
                                 state_area = CONV #( /esrcc/cl_config_util=>validity ) ).
      lo_rule->reset_state_area( entity     = entity
                                 state_area = CONV #( /esrcc/cl_config_util=>start_end_of_month ) ).

      " Validate Partner
      IF NOT line_exists( valid_rr_partners[ Sysid        = entity-PartnerSystemId
                                             LegalEntity  = entity-PartnerLegalEntity
                                             CompanyCode  = entity-PartnerCompanyCode
                                             ObjectType   = entity-PartnerObjectType
                                             ObjectNumber = entity-PartnerObjectNumber ] ).
        lo_validate_line->set_invalid_group_set( linked_fields = VALUE #( ( 'PARTNERSYSTEMID' )
                                                                          ( 'PARTNERLEGALENTITY' )
                                                                          ( 'PARTNERCOMPANYCODE' )
                                                                          ( 'PARTNEROBJECTTYPE' )
                                                                          ( 'PARTNEROBJECTNUMBER' ) )
                                                 entity        = CORRESPONDING ts_rule( entity ) ).

      ENDIF.
      " Validate source - Object key fields
      IF     entity-SystemId     IS NOT INITIAL
         AND entity-LegalEntity  IS NOT INITIAL
         AND entity-CompanyCode  IS NOT INITIAL
         AND entity-ObjectType   IS NOT INITIAL
         AND entity-ObjectNumber IS NOT INITIAL.

        IF NOT line_exists( valid_rr_sources[ Sysid        = entity-SystemId
                                              LegalEntity  = entity-LegalEntity
                                              CompanyCode  = entity-CompanyCode
                                              ObjectType   = entity-ObjectType
                                              ObjectNumber = entity-ObjectNumber ] ).
          lo_validate_line->set_invalid_group_set( linked_fields = VALUE #( ( 'SYSTEMID' )
                                                                            ( 'LEGALENTITY' )
                                                                            ( 'COMPANYCODE' )
                                                                            ( 'OBJECTTYPE' )
                                                                            ( 'OBJECTNUMBER' ) )
                                                   entity        = CORRESPONDING ts_rule( entity ) ).
        ENDIF.

      " Validate source- Company code fields
      ELSEIF     entity-SystemId    IS NOT INITIAL
             AND entity-LegalEntity IS NOT INITIAL
             AND entity-CompanyCode IS NOT INITIAL.

        IF NOT line_exists( valid_source_companies[ Sysid       = entity-SystemId
                                                    LegalEntity = entity-LegalEntity
                                                    Ccode       = entity-CompanyCode ] ).
          lo_validate_line->set_invalid_group_set( linked_fields = VALUE #( ( 'SYSTEMID' )
                                                                            ( 'LEGALENTITY' )
                                                                            ( 'COMPANYCODE' ) )
                                                   entity        = CORRESPONDING ts_rule( entity ) ).
        ENDIF.
      ENDIF.

      " Validate initial fields and Dates

      lo_validation->validate_rule( entity  = CORRESPONDING #( entity )
                                    control = VALUE #( validfrom           = if_abap_behv=>mk-on
                                                       validto             = if_abap_behv=>mk-on
                                                       PartnerSystemId     = if_abap_behv=>mk-on
                                                       PartnerLegalEntity  = if_abap_behv=>mk-on
                                                       PartnerCompanyCode  = if_abap_behv=>mk-on
                                                       PartnerObjectType   = if_abap_behv=>mk-on
                                                       PartnerObjectNumber = if_abap_behv=>mk-on
                                                       salesordercreation  = if_abap_behv=>mk-on
                                                       keyfield            = if_abap_behv=>mk-on ) ).

    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validate_date) = /esrcc/cl_config_util=>create( EXPORTING paths              = VALUE #( ( path = c_path ) )
                                                                      source_entity_name = c_source_entity
                                                            CHANGING  reported_entity    = reported-rule
                                                                      failed_entity      = failed-rule ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_validate_date ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_rule( entity  = CORRESPONDING #( entity )
                                    control = VALUE #( validfrom           = entity-%control-Validfrom
                                                       validto             = entity-%control-Validto
                                                       PartnerSystemId     = entity-%control-PartnerSystemId
                                                       PartnerLegalEntity  = entity-%control-PartnerLegalEntity
                                                       PartnerCompanyCode  = entity-%control-PartnerCompanyCode
                                                       PartnerObjectType   = entity-%control-PartnerObjectType
                                                       PartnerObjectNumber = entity-%control-PartnerObjectNumber
                                                       salesordercreation  = entity-%control-salesordercreation
                                                       keyfield            = entity-%control-keyfield ) ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.


CLASS lhc_/esrcc/i_rr_ruletext DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR RuleText~ValidateTransportRequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR RuleText
        RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_rr_ruletext IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /ESRCC/I_RR_Rule_S.

    SELECT SINGLE TransportRequestID
      FROM /esrcc/d_rr_ru_s
      WHERE SingletonID = 1
      INTO @DATA(TransportRequestID).
    lhc_rap_tdat_cts=>get( )->validate_changes( transport_request = TransportRequestID
                                                table             = '/ESRCC/RR_RULET'
                                                keys              = REF #( keys )
                                                reported          = REF #( reported )
                                                failed            = REF #( failed )
                                                change            = REF #( change-RuleText ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.
ENDCLASS.
