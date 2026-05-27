CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES ts_object_type        TYPE STRUCTURE FOR READ RESULT /ESRCC/I_RR_ObjectType_S\\ObjectType.
    TYPES tt_object_type_create TYPE TABLE FOR CREATE /esrcc/i_rr_objecttype_s\\ObjectTypeAll\_objecttype.
    TYPES: BEGIN OF ts_control,
             object_type TYPE if_abap_behv=>t_xflag,
           END OF ts_control.

    METHODS constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util.

    METHODS validate_object_type
      IMPORTING !entity  TYPE ts_object_type
                !control TYPE ts_control.

    CLASS-METHODS precheck_cba_object_type
      IMPORTING !entities TYPE tt_object_type_create
      CHANGING  !reported TYPE any
                !failed   TYPE any.

  PRIVATE SECTION.
    DATA: config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_object_type.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-object_type = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'OBJECTTYPE' ) TO fields. ENDIF.

    config_util_ref->validate_initial( fields = fields
                                       entity = entity ).
  ENDMETHOD.

  METHOD precheck_cba_object_type.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ObjectTypeAll' ) )
        source_entity_name = '/ESRCC/C_RR_OBJECTTYPE'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_object_type(
          entity  = CORRESPONDING #( target )
          control = VALUE #( object_type = if_abap_behv=>mk-on )
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

ENDCLASS.

CLASS lhc_rap_tdat_cts IMPLEMENTATION.
  METHOD get.
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/RR_OBJECTTYPE'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'ObjectType' table = '/ESRCC/RR_OBJTYP' )
                                         ( entity = 'ObjectTypeText' table = '/ESRCC/RR_OBTYPT' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_rr_objecttype_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR ObjectTypeAll
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION ObjectTypeAll~SelectCustomizingTransptReq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ObjectTypeAll
        RESULT result,
      precheck_cba_Objecttype FOR PRECHECK
        IMPORTING entities FOR CREATE ObjectTypeAll\_Objecttype.
ENDCLASS.

CLASS lhc_/esrcc/i_rr_objecttype_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(selecttransport_flag) = if_abap_behv=>fc-o-enabled.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /ESRCC/I_RR_ObjectType_S IN LOCAL MODE
    ENTITY ObjectTypeAll
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.
    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_ObjectType = edit_flag
               %action-SelectCustomizingTransptReq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /ESRCC/I_RR_ObjectType_S IN LOCAL MODE
      ENTITY ObjectTypeAll
        UPDATE FIELDS ( TransportRequestID HideTransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          TransportRequestID = key-%param-transportrequestid
                          HideTransport      = abap_false ) )
                          FAILED failed.

    READ ENTITIES OF /ESRCC/I_RR_ObjectType_S IN LOCAL MODE
      ENTITY ObjectTypeAll
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_RR_OBJECTTYPE' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-Edit = is_authorized.
    result-%action-SelectCustomizingTransptReq = is_authorized.
  ENDMETHOD.

  METHOD precheck_cba_Objecttype.
    lcl_custom_validation=>precheck_cba_object_type( EXPORTING entities = entities
                                                     CHANGING  failed   = failed-objecttype
                                                               reported = reported-objecttype ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_rr_objecttype_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_rr_objecttype_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-ObjectTypeAll INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_rr_objecttype DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR ObjectType~ValidateTransportRequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR ObjectType
        RESULT result,
      copyobjecttype FOR MODIFY
        IMPORTING
          keys FOR ACTION ObjectType~CopyObjectType,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ObjectType
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR ObjectType
        RESULT    result.
ENDCLASS.

CLASS lhc_/esrcc/i_rr_objecttype IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /ESRCC/I_RR_ObjectType_S.
    SELECT SINGLE TransportRequestID
      FROM /esrcc/d_rr_ob_s
      WHERE SingletonID = 1
      INTO @DATA(TransportRequestID).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = TransportRequestID
                                table             = '/ESRCC/RR_OBJTYP'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-ObjectType ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
    result-%assoc-_ObjectTypeText = edit_flag.
  ENDMETHOD.

  METHOD copyobjecttype.
    DATA new_ObjectType     TYPE TABLE FOR CREATE /ESRCC/I_RR_ObjectType_S\_ObjectType.
    DATA new_ObjectTypeText TYPE TABLE FOR CREATE /ESRCC/I_RR_ObjectType_S\\ObjectType\_ObjectTypeText.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-ObjectType = VALUE #( FOR fkey IN keys
                                   ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /ESRCC/I_RR_ObjectType_S IN LOCAL MODE
         ENTITY ObjectType
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(ref_ObjectType)
         FAILED DATA(read_failed).
    READ ENTITIES OF /ESRCC/I_RR_ObjectType_S IN LOCAL MODE
         ENTITY ObjectType BY \_ObjectTypeText
         ALL FIELDS WITH CORRESPONDING #( ref_ObjectType )
         RESULT DATA(ref_ObjectTypeText).

    LOOP AT ref_ObjectType ASSIGNING FIELD-SYMBOL(<ref_ObjectType>).
      DATA(key) = keys[ KEY draft
                        %tky = <ref_ObjectType>-%tky ].
      DATA(key_cid) = key-%cid.
      APPEND VALUE #( %tky-SingletonID = 1
                      %is_draft        = <ref_ObjectType>-%is_draft
                      %target          = VALUE #( ( %cid      = key_cid
                                                    %is_draft = <ref_ObjectType>-%is_draft
                                                    %data     = CORRESPONDING #( <ref_ObjectType> EXCEPT
                                                          CreatedAt
                                                          CreatedBy
                                                          LastChangedAt
                                                          LastChangedBy
                                                          LocalLastChangedAt
                                                          ObjectType
                                                          SingletonID ) ) ) )
             TO new_ObjectType ASSIGNING FIELD-SYMBOL(<new_ObjectType>).
      <new_ObjectType>-%target[ 1 ]-ObjectType = key-%param-ObjectType.
      FIELD-SYMBOLS <new_ObjectTypeText> LIKE LINE OF new_ObjectTypeText.
      UNASSIGN <new_ObjectTypeText>.
      LOOP AT ref_ObjectTypeText ASSIGNING FIELD-SYMBOL(<ref_ObjectTypeText>) USING KEY draft WHERE     %tky-%is_draft  = key-%tky-%is_draft
                                                                                                    AND %tky-ObjectType = key-%tky-ObjectType.
        IF <new_ObjectTypeText> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_ObjectTypeText ASSIGNING <new_ObjectTypeText>.
        ENDIF.
        INSERT VALUE #( %cid      = key_cid && <ref_ObjectTypeText>-Spras
                        %is_draft = key-%is_draft
                        %data     = CORRESPONDING #( <ref_ObjectTypeText> EXCEPT
                                                     LocalLastChangedAt
                                                     ObjectType
                                                     SingletonID ) )
               INTO TABLE <new_ObjectTypeText>-%target ASSIGNING FIELD-SYMBOL(<target>).
        <target>-%key-ObjectType = key-%param-ObjectType.
      ENDLOOP.
    ENDLOOP.

    " To prevent keys being populated with spaces
    lcl_custom_validation=>precheck_cba_object_type( EXPORTING entities = new_ObjectType
                                                     CHANGING  failed   = failed-objecttype
                                                               reported = reported-objecttype ).

    IF failed-objecttype IS INITIAL.
      MODIFY ENTITIES OF /ESRCC/I_RR_ObjectType_S IN LOCAL MODE
             ENTITY ObjectTypeAll CREATE BY \_ObjectType
             FIELDS (
                      ObjectType )
             WITH new_ObjectType
             ENTITY ObjectType CREATE BY \_ObjectTypeText
             FIELDS (
               Spras
               ObjectType
               Description )
             WITH new_ObjectTypeText
             MAPPED DATA(mapped_create)
             FAILED failed
             REPORTED reported.
    ENDIF.

    mapped-ObjectType = mapped_create-ObjectType.
    INSERT LINES OF read_failed-ObjectType INTO TABLE failed-ObjectType.

    IF failed-ObjectType IS INITIAL.
      reported-ObjectType = VALUE #( FOR created IN mapped-ObjectType
                                     ( %cid                            = created-%cid
                                       %action-CopyObjectType          = if_abap_behv=>mk-on
                                       %msg                            = mbc_cp_api=>message( )->get_item_copied( )
                                       %path-ObjectTypeAll-%is_draft   = created-%is_draft
                                       %path-ObjectTypeAll-SingletonID = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_RR_OBJECTTYPE' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%action-CopyObjectType = is_authorized.
  ENDMETHOD.
  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-CopyObjectType = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
   ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_rr_objecttypetext DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR ObjectTypeText~ValidateTransportRequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR ObjectTypeText
        RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_rr_objecttypetext IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /ESRCC/I_RR_ObjectType_S.
    SELECT SINGLE TransportRequestID
      FROM /esrcc/d_rr_ob_s
      WHERE SingletonID = 1
      INTO @DATA(TransportRequestID).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = TransportRequestID
                                table             = '/ESRCC/RR_OBTYPT'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-ObjectTypeText ) ).
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
