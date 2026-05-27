class lcl_custom_validation DEFINITION.
PUBLIC SECTION.
      TYPES:
          ts_rr_object TYPE STRUCTURE FOR read RESULT /esrcc/i_rr_objct_s\\Objct,
          tt_object_create type TABLE FOR CREATE /esrcc/i_rr_objct_s\\ObjctAll\_Objct,

          BEGIN OF ts_control,
            sysid       TYPE if_abap_behv=>t_xflag,
            legalentity TYPE if_abap_behv=>t_xflag,
            companycode TYPE if_abap_behv=>t_xflag,
            objecttype  TYPE  if_abap_behv=>t_xflag,
            objectnumber TYPE if_abap_behv=>t_xflag,
           END OF ts_control.

        METHODS:
        constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
        validate_rr_object
        IMPORTING
         entity type ts_rr_object
         control type ts_control.

   class-METHODS:
     precheck_cba_rr_object
      IMPORTING
        entities TYPE tt_object_create
      CHANGING
         reported type any
         failed type any.

   PRIVATE SECTION.
     DATA: config_util_ref type REF TO /esrcc/cl_config_util.

ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.

  METHOD constructor.
     me->config_util_ref = config_util_ref.
  ENDMETHOD.


  METHOD validate_rr_object.
      DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-sysid       = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'SYSID' ) TO fields. ENDIF.
    IF control-legalentity = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'LEGALENTITY' ) TO fields. ENDIF.
    IF control-companycode = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COMPANYCODE' ) TO fields. ENDIF.
    IF control-objecttype = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'OBJECTTYPE' ) TO fields. ENDIF.
    IF control-objectnumber = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'OBJECTNUMBER' ) TO fields. ENDIF.

    config_util_ref->validate_initial( fields = fields
                                       entity = entity ).

  ENDMETHOD.

  METHOD precheck_cba_rr_object.

      TYPES ts_rr_object TYPE STRUCTURE FOR READ RESULT /ESRCC/I_RR_OBJCT_S\\Objct.

    DATA(lo_rr_object) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ObjctAll' ) )
        source_entity_name = '/ESRCC/C_RR_OBJCT'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed
    ).

    DATA(lo_auth) = /esrcc/cl_authorization=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ObjctAll' ) )
        source_entity_name = '/ESRCC/C_RR_OBJCT'
      CHANGING
        reported_entity    = reported
        failed_entity      = failed
    ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_rr_object ).

    LOOP AT entities INTO DATA(entity).
      SELECT DISTINCT
             robj~systemid,
             robj~legalentity,
             robj~companycode,
             robj~objecttype,
             robj~objectnumber
          FROM /esrcc/d_rr_obj1 AS robj
          INNER JOIN @entity-%target AS tent
              ON  tent~systemid       = robj~systemid
              AND tent~legalentity = robj~legalentity
              AND tent~companycode = robj~companycode
              AND tent~objecttype  = robj~objecttype
              AND tent~objectnumber  = robj~objectnumber
          WHERE robj~draftentityoperationcode NOT IN ( 'D', 'L' )
          INTO TABLE @DATA(duplicate_entities).

      SELECT ccode~sysid, ccode~legalentity, ccode~ccode
        FROM /esrcc/le_ccode AS ccode
        INNER JOIN @entity-%target AS tent
          ON  tent~systemid       = ccode~sysid
          AND tent~legalentity = ccode~legalentity
          AND tent~companycode = ccode~ccode
        INTO TABLE @DATA(le_ccode).

      LOOP AT entity-%target INTO DATA(target) GROUP BY ( sysid       = target-systemid
                                                          legalentity = target-legalentity
                                                          companycode = target-companycode
                                                          objecttype  = target-objecttype
                                                          objectnumber  = target-objectnumber
                                                          size        = GROUP SIZE )
          ASCENDING REFERENCE INTO DATA(group_ref).
        lo_validation->validate_rr_object(
          entity  = CORRESPONDING #( group_ref->* )
          control = VALUE #( objectnumber = if_abap_behv=>mk-on
          ) ).

*       Validate combination
        IF NOT line_exists( le_ccode[ sysid = group_ref->sysid legalentity = group_ref->legalentity ccode = group_ref->companycode ] ).
          lo_rr_object->set_invalid_group_set(
            linked_fields = VALUE #( ( 'SYSID' )
                                     ( 'LEGALENTITY' )
                                     ( 'COMPANYCODE' ) )
            entity        = CORRESPONDING ts_rr_object( group_ref->* ) ).
        ENDIF.


        IF line_exists( duplicate_entities[ systemid       = group_ref->sysid
                                            legalentity = group_ref->legalentity
                                            companycode = group_ref->companycode
                                            objecttype  = group_ref->objecttype
                                            objectnumber  = group_ref->objectnumber ] ) OR group_ref->size > 1.
          lo_rr_object->set_duplicate_error( entity = CORRESPONDING ts_rr_object( group_ref->* ) ).
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

ENDCLASS.

CLASS lhc_rap_tdat_cts IMPLEMENTATION.
  METHOD get.
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/RR_OBJCT'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'Objct' table = '/ESRCC/RR_OBJCT' )
                                         ( entity = 'ObjctText' table = '/ESRCC/RR_OBJCTT' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_rr_objct_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR ObjctAll
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION ObjctAll~SelectCustomizingTransptReq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ObjctAll
        RESULT result,
      precheck_cba_Objct FOR PRECHECK
            IMPORTING entities FOR CREATE ObjctAll\_Objct.
ENDCLASS.

CLASS lhc_/esrcc/i_rr_objct_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(selecttransport_flag) = if_abap_behv=>fc-o-enabled.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /ESRCC/I_RR_Objct_S IN LOCAL MODE
    ENTITY ObjctAll
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.
    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_Objct = edit_flag
               %action-SelectCustomizingTransptReq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /ESRCC/I_RR_Objct_S IN LOCAL MODE
      ENTITY ObjctAll
        UPDATE FIELDS ( TransportRequestID HideTransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          TransportRequestID = key-%param-transportrequestid
                          HideTransport      = abap_false ) )
                          FAILED failed.

    READ ENTITIES OF /ESRCC/I_RR_Objct_S IN LOCAL MODE
      ENTITY ObjctAll
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_RR_OBJCT' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-Edit = is_authorized.
    result-%action-SelectCustomizingTransptReq = is_authorized.
  ENDMETHOD.

  METHOD precheck_cba_Objct.
   lcl_custom_validation=>precheck_cba_rr_object(
    EXPORTING
      entities = entities
    CHANGING
      failed = failed-objct
      reported = reported-objct
   ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_rr_objct_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_rr_objct_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-ObjctAll INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_rr_objct DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR Objct~ValidateTransportRequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR Objct
        RESULT result,

      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR Objct RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Objct RESULT result.

    METHODS CopyObject FOR MODIFY
      IMPORTING keys FOR ACTION Objct~CopyObject.
    METHODS ValidateData FOR VALIDATE ON SAVE
      IMPORTING keys FOR Objct~ValidateData.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE Objct.
ENDCLASS.

CLASS lhc_/esrcc/i_rr_objct IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /ESRCC/I_RR_Objct_S.
    SELECT SINGLE TransportRequestID
      FROM /esrcc/d_rr_o_s
      WHERE SingletonID = 1
      INTO @DATA(TransportRequestID).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = TransportRequestID
                                table             = '/ESRCC/RR_OBJCT'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-Objct ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
    result-%assoc-_ObjctText = edit_flag.
  ENDMETHOD.

  METHOD CopyObject.
    DATA new_Objct     TYPE TABLE FOR CREATE /ESRCC/I_RR_Objct_S\_Objct.
    DATA new_ObjctText TYPE TABLE FOR CREATE /ESRCC/I_RR_Objct_S\\Objct\_ObjctText.
    FIELD-SYMBOLS <new_ObjctText> LIKE LINE OF new_ObjctText.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-objct = VALUE #( FOR fkey IN keys
                              ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /ESRCC/I_RR_Objct_S IN LOCAL MODE
         ENTITY Objct
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(ref_Objct)
         FAILED DATA(read_failed).

    READ ENTITIES OF /ESRCC/I_RR_Objct_S IN LOCAL MODE
         ENTITY Objct BY \_ObjctText
         ALL FIELDS WITH CORRESPONDING #( ref_Objct )
         RESULT DATA(ref_ObjctText).

    LOOP AT ref_objct ASSIGNING FIELD-SYMBOL(<ref_Objct>).
      DATA(key) = keys[ KEY draft
                        %tky = <ref_Objct>-%tky ].
      DATA(key_cid) = key-%cid.

      APPEND VALUE #( %tky-SingletonID = 1
                      %is_draft        = <ref_Objct>-%is_draft
                      %target          = VALUE #( ( %cid         = key_cid
                                                    %is_draft    = <ref_Objct>-%is_draft
                                                    %data        = CORRESPONDING #( <ref_Objct>
                                                                       EXCEPT Uuid
                                                                              SystemId
                                                                              LegalEntity
                                                                              CompanyCode
                                                                              ObjectType
                                                                              ObjectNumber
                                                                              SingletonID )
                                                    SystemId     = key-%param-sysid
                                                    LegalEntity  = key-%param-LegalEntity
                                                    CompanyCode  = key-%param-CompanyCode
                                                    ObjectType   = key-%param-object_type
                                                    ObjectNumber = key-%param-object_number ) ) )
             TO new_Objct.

      UNASSIGN <new_ObjctText>.

      LOOP AT ref_ObjctText ASSIGNING FIELD-SYMBOL(<ref_ObjctText>) USING KEY draft WHERE     %tky-%is_draft = key-%tky-%is_draft
                                                                                          AND %tky-Uuid      = key-%tky-uuid.
        IF <new_ObjctText> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_ObjctText ASSIGNING <new_ObjctText>.
        ENDIF.

        INSERT VALUE #( %cid      = key_cid && <ref_ObjctText>-Spras
                        %is_draft = key-%is_draft
                        %data     = CORRESPONDING #( <ref_ObjctText> EXCEPT
                                                     SingletonID
                                                     Uuid ) )
               INTO TABLE <new_ObjctText>-%target.
      ENDLOOP.
    ENDLOOP.

* Pre-check before create.
lcl_custom_validation=>precheck_cba_rr_object(
   EXPORTING
     entities = new_Objct
   CHANGING
     failed  = failed-objct
     reported = reported-objct ).

IF failed-objct is INITIAL.
    MODIFY ENTITIES OF /ESRCC/I_RR_Objct_S IN LOCAL MODE
           ENTITY ObjctAll CREATE BY \_Objct
           FIELDS ( SystemId
                    LegalEntity
                    CompanyCode
                    ObjectType
                    ObjectNumber
                    ActiveFlag
                    FunctionalArea
                    ProfitCenter
                    BusinessDivision  )
           WITH new_Objct
           ENTITY Objct CREATE BY \_ObjctText
           FIELDS (
             Spras
             Description )
           WITH new_ObjctText
           MAPPED DATA(mapped_create)
           FAILED failed
           REPORTED reported.
ENDIF.
    mapped-Objct = mapped_create-Objct.
    INSERT LINES OF read_failed-Objct INTO TABLE failed-Objct.

    IF failed-Objct IS INITIAL.
      reported-Objct = VALUE #( FOR created IN mapped-Objct
                                ( %cid                       = created-%cid
                                  %action-CopyObject         = if_abap_behv=>mk-on
                                  %msg                       = mbc_cp_api=>message( )->get_item_copied( )
                                  %path-ObjctAll-%is_draft   = created-%is_draft
                                  %path-ObjctAll-SingletonID = 1 ) ).
    ENDIF.
  ENDMETHOD.

  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_RR_OBJCT' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%action-CopyObject = is_authorized.
  ENDMETHOD.
  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                         %action-CopyObject = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
    ) ).
  ENDMETHOD.


  METHOD ValidateData.
    READ ENTITIES OF /ESRCC/I_RR_Objct_S IN LOCAL MODE
        ENTITY objct
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ObjctAll' ) )
        source_entity_name = '/ESRCC/C_RR_OBJCT'
      CHANGING
        reported_entity    = reported-objct
        failed_entity      = failed-objct ) ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>) WHERE systemid IS INITIAL
                                                         OR legalentity IS INITIAL
                                                         OR companycode IS INITIAL
                                                         OR ObjectType IS INITIAL
                                                         OR ObjectNumber IS INITIAL.
      lo_validation->validate_rr_object(
        entity  = <entity>
        control = VALUE #( sysid         = if_abap_behv=>mk-on
                           legalentity   = if_abap_behv=>mk-on
                           companycode   = if_abap_behv=>mk-on
                           ObjectType   = if_abap_behv=>mk-on
                           ObjectNumber  = if_abap_behv=>mk-on
                              ) ).
      ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.

   DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
        EXPORTING
          paths              = VALUE #( ( path = 'ObjctAll' ) )
          source_entity_name = '/ESRCC/C_RR_OBJCT'
        CHANGING
          reported_entity    = reported-objct
          failed_entity      = failed-objct ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-systemid       = if_abap_behv=>mk-on
                                          OR %control-legalentity = if_abap_behv=>mk-on
                                          OR %control-companycode = if_abap_behv=>mk-on
                                          OR %control-ObjectType = if_abap_behv=>mk-on
                                          OR %control-ObjectNumber = if_abap_behv=>mk-on.

      lo_validation->validate_rr_object(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( sysid         = entity-%control-systemid
                           legalentity   = entity-%control-legalentity
                           companycode   = entity-%control-companycode
                           ObjectType   = entity-%control-ObjectType
                           ObjectNumber = entity-%control-ObjectNumber
                            )
      ).
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
CLASS lhc_/esrcc/i_rr_objcttext DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR ObjctText~ValidateTransportRequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR ObjctText
        RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_rr_objcttext IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /ESRCC/I_RR_Objct_S.
    SELECT SINGLE TransportRequestID
      FROM /esrcc/d_rr_o_s
      WHERE SingletonID = 1
      INTO @DATA(TransportRequestID).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = TransportRequestID
                                table             = '/ESRCC/RR_OBJCTT'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-ObjctText ) ).
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
