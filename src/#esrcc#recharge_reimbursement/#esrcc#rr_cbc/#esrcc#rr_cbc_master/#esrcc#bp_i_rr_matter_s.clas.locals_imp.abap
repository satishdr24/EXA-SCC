CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES ts_rr_matter        TYPE STRUCTURE FOR READ RESULT /ESRCC/I_RR_Matter_S\\RRMatter.
    TYPES tt_rr_matter_create TYPE TABLE FOR CREATE /ESRCC/I_RR_Matter_S\\RRMatterAll\_RRMatter.
    TYPES: BEGIN OF ts_control,
             rrmatter TYPE if_abap_behv=>t_xflag,
           END OF ts_control.

    METHODS constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util.

    METHODS validate_rr_matter
      IMPORTING !entity  TYPE ts_rr_matter
                !control TYPE ts_control.

    CLASS-METHODS precheck_cba_rr_matter
      IMPORTING !entities TYPE tt_rr_matter_create
      CHANGING  !reported TYPE any
                !failed   TYPE any.

  PRIVATE SECTION.
    DATA: config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.

  METHOD constructor.
   me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_rr_matter.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-rrmatter = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'RRMATTER' ) TO fields. ENDIF.

    config_util_ref->validate_initial( fields = fields
                                       entity = entity ).
  ENDMETHOD.

  METHOD precheck_cba_rr_matter.
     DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'RRMatterAll' ) )
        source_entity_name = '/ESRCC/C_RR_MATTER'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_rr_matter(
          entity  = CORRESPONDING #( target )
          control = VALUE #( rrmatter = if_abap_behv=>mk-on )
        ).
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS LHC_RAP_TDAT_CTS DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      GET
        RETURNING
          VALUE(RESULT) TYPE REF TO IF_MBC_CP_RAP_TDAT_CTS.

ENDCLASS.

CLASS LHC_RAP_TDAT_CTS IMPLEMENTATION.
  METHOD GET.
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/RRMATTER'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'RRMatter' table = '/ESRCC/RRMATTER' )
                                         ( entity = 'RRMatterText' table = '/ESRCC/RRMATTERT' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS LHC_/ESRCC/I_RR_MATTER_S DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR RRMatterAll
        RESULT result,
      SELECTCUSTOMIZINGTRANSPTREQ FOR MODIFY
        IMPORTING
          KEYS FOR ACTION RRMatterAll~SelectCustomizingTransptReq
        RESULT result,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR RRMatterAll
        RESULT result,
      precheck_cba_Rrmatter FOR PRECHECK
            IMPORTING entities FOR CREATE RRMatterAll\_Rrmatter.
ENDCLASS.

CLASS LHC_/ESRCC/I_RR_MATTER_S IMPLEMENTATION.
  METHOD GET_INSTANCE_FEATURES.
    DATA(selecttransport_flag) = if_abap_behv=>fc-o-enabled.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /ESRCC/I_RR_Matter_S IN LOCAL MODE
    ENTITY RRMatterAll
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.
    result = VALUE #( FOR row IN entities (
               %TKY = row-%TKY
               %ACTION-edit = edit_flag
               %ASSOC-_RRMatter = edit_flag
               %ACTION-SelectCustomizingTransptReq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD SELECTCUSTOMIZINGTRANSPTREQ.
    MODIFY ENTITIES OF /ESRCC/I_RR_Matter_S IN LOCAL MODE
      ENTITY RRMatterAll
        UPDATE FIELDS ( TransportRequestID HideTransport )
        WITH VALUE #( FOR key IN keys
                        ( %TKY               = key-%TKY
                          TransportRequestID = key-%PARAM-transportrequestid
                          HideTransport      = abap_false ) )
                          FAILED failed.

    READ ENTITIES OF /ESRCC/I_RR_Matter_S IN LOCAL MODE
      ENTITY RRMatterAll
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %TKY   = entity-%TKY
                          %PARAM = entity ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_RR_MATTER' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%UPDATE      = is_authorized.
    result-%ACTION-Edit = is_authorized.
    result-%ACTION-SelectCustomizingTransptReq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_Rrmatter.
   lcl_custom_validation=>precheck_cba_rr_matter( EXPORTING entities = entities
                                                     CHANGING  failed   = failed-rrmatter
                                                               reported = reported-rrmatter ).
  ENDMETHOD.

ENDCLASS.
CLASS LSC_/ESRCC/I_RR_MATTER_S DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_SAVER.
  PROTECTED SECTION.
    METHODS:
      SAVE_MODIFIED REDEFINITION,
      CLEANUP_FINALIZE REDEFINITION.
ENDCLASS.

CLASS LSC_/ESRCC/I_RR_MATTER_S IMPLEMENTATION.
  METHOD SAVE_MODIFIED.
    READ TABLE update-RRMatterAll INDEX 1 INTO DATA(all).
    IF all-TransportRequestID IS NOT INITIAL.
      lhc_rap_tdat_cts=>get( )->record_changes(
                                  transport_request = all-TransportRequestID
                                  create            = REF #( create )
                                  update            = REF #( update )
                                  delete            = REF #( delete ) ).
    ENDIF.
  ENDMETHOD.
  METHOD CLEANUP_FINALIZE ##NEEDED.
  ENDMETHOD.
ENDCLASS.
CLASS LHC_/ESRCC/I_RR_MATTER DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      VALIDATETRANSPORTREQUEST FOR VALIDATE ON SAVE
        IMPORTING
          KEYS FOR RRMatter~ValidateTransportRequest,
      GET_GLOBAL_FEATURES FOR GLOBAL FEATURES
        IMPORTING
          REQUEST REQUESTED_FEATURES FOR RRMatter
        RESULT result,
      COPYRRMATTER FOR MODIFY
        IMPORTING
          KEYS FOR ACTION RRMatter~CopyRRMatter,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR RRMatter
        RESULT result,
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR RRMatter
        RESULT result.
ENDCLASS.

CLASS LHC_/ESRCC/I_RR_MATTER IMPLEMENTATION.
  METHOD VALIDATETRANSPORTREQUEST.
    DATA change TYPE REQUEST FOR CHANGE /ESRCC/I_RR_Matter_S.
    SELECT SINGLE TransportRequestID
      FROM /ESRCC/D_RRMAT_S
      WHERE SingletonID = 1
      INTO @DATA(TransportRequestID).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = TransportRequestID
                                table             = '/ESRCC/RRMATTER'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-RRMatter ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_FEATURES.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%UPDATE = edit_flag.
    result-%DELETE = edit_flag.
    result-%ASSOC-_RRMatterText = edit_flag.
  ENDMETHOD.
  METHOD COPYRRMATTER.
    DATA new_RRMatter TYPE TABLE FOR CREATE /ESRCC/I_RR_Matter_S\_RRMatter.
    DATA new_RRMatterText TYPE TABLE FOR CREATE /ESRCC/I_RR_Matter_S\\RRMatter\_RRMatterText.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-RRMatter = VALUE #( FOR fkey IN keys ( %TKY = fkey-%TKY ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /ESRCC/I_RR_Matter_S IN LOCAL MODE
      ENTITY RRMatter
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_RRMatter)
      FAILED DATA(read_failed).
    READ ENTITIES OF /ESRCC/I_RR_Matter_S IN LOCAL MODE
      ENTITY RRMatter BY \_RRMatterText
      ALL FIELDS WITH CORRESPONDING #( ref_RRMatter )
      RESULT DATA(ref_RRMatterText).

    LOOP AT ref_RRMatter ASSIGNING FIELD-SYMBOL(<ref_RRMatter>).
      DATA(key) = keys[ KEY draft %TKY = <ref_RRMatter>-%TKY ].
      DATA(key_cid) = key-%CID.
      APPEND VALUE #(
        %TKY-SingletonID = 1
        %IS_DRAFT = <ref_RRMatter>-%IS_DRAFT
        %TARGET = VALUE #( (
          %CID = key_cid
          %IS_DRAFT = <ref_RRMatter>-%IS_DRAFT
          %DATA = CORRESPONDING #( <ref_RRMatter> EXCEPT
            CreatedAt
            CreatedBy
            LastChangedAt
            LastChangedBy
            LocalLastChangedAt
            RrMatter
            SingletonID
        ) ) )
      ) TO new_RRMatter ASSIGNING FIELD-SYMBOL(<new_RRMatter>).
      <new_RRMatter>-%TARGET[ 1 ]-RrMatter = key-%PARAM-RrMatter.
      FIELD-SYMBOLS <new_RRMatterText> LIKE LINE OF new_RRMatterText.
      UNASSIGN <new_RRMatterText>.
      LOOP AT ref_RRMatterText ASSIGNING FIELD-SYMBOL(<ref_RRMatterText>) USING KEY draft WHERE %TKY-%IS_DRAFT = key-%TKY-%IS_DRAFT
              AND %TKY-RrMatter = key-%TKY-RrMatter.
        IF <new_RRMatterText> IS NOT ASSIGNED.
          INSERT VALUE #( %CID_REF  = key_cid
                          %IS_DRAFT = key-%IS_DRAFT ) INTO TABLE new_RRMatterText ASSIGNING <new_RRMatterText>.
        ENDIF.
        INSERT VALUE #( %CID = key_cid && <ref_RRMatterText>-Spras
                        %IS_DRAFT = key-%IS_DRAFT
                        %DATA = CORRESPONDING #( <ref_RRMatterText> EXCEPT
                                                 LocalLastChangedAt
                                                 RrMatter
                                                 SingletonID
        ) ) INTO TABLE <new_RRMatterText>-%TARGET ASSIGNING FIELD-SYMBOL(<target>).
        <target>-%KEY-RrMatter = key-%PARAM-RrMatter.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF /ESRCC/I_RR_Matter_S IN LOCAL MODE
      ENTITY RRMatterAll CREATE BY \_RRMatter
      FIELDS (
               RrMatter
             ) WITH new_RRMatter
      ENTITY RRMatter CREATE BY \_RRMatterText
      FIELDS (
               Spras
               RrMatter
               Description
             ) WITH new_RRMatterText
      MAPPED DATA(mapped_create)
      FAILED failed
      REPORTED reported.

    mapped-RRMatter = mapped_create-RRMatter.
    INSERT LINES OF read_failed-RRMatter INTO TABLE failed-RRMatter.

    IF failed-RRMatter IS INITIAL.
      reported-RRMatter = VALUE #( FOR created IN mapped-RRMatter (
                                                 %CID = created-%CID
                                                 %ACTION-CopyRRMatter = if_abap_behv=>mk-on
                                                 %MSG = mbc_cp_api=>message( )->get_item_copied( )
                                                 %PATH-RRMatterAll-%IS_DRAFT = created-%IS_DRAFT
                                                 %PATH-RRMatterAll-SingletonID = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_RR_MATTER' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%ACTION-CopyRRMatter = is_authorized.
  ENDMETHOD.
  METHOD GET_INSTANCE_FEATURES.
    result = VALUE #( FOR row IN keys ( %TKY = row-%TKY
                                        %ACTION-CopyRRMatter = COND #( WHEN row-%IS_DRAFT = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
   ) ).
  ENDMETHOD.
ENDCLASS.
CLASS LHC_/ESRCC/I_RR_MATTERTEXT DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      VALIDATETRANSPORTREQUEST FOR VALIDATE ON SAVE
        IMPORTING
          KEYS FOR RRMatterText~ValidateTransportRequest,
      GET_GLOBAL_FEATURES FOR GLOBAL FEATURES
        IMPORTING
          REQUEST REQUESTED_FEATURES FOR RRMatterText
        RESULT result.
ENDCLASS.

CLASS LHC_/ESRCC/I_RR_MATTERTEXT IMPLEMENTATION.
  METHOD VALIDATETRANSPORTREQUEST.
    DATA change TYPE REQUEST FOR CHANGE /ESRCC/I_RR_Matter_S.
    SELECT SINGLE TransportRequestID
      FROM /ESRCC/D_RRMAT_S
      WHERE SingletonID = 1
      INTO @DATA(TransportRequestID).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = TransportRequestID
                                table             = '/ESRCC/RRMATTERT'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-RRMatterText ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_FEATURES.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%UPDATE = edit_flag.
    result-%DELETE = edit_flag.
  ENDMETHOD.
ENDCLASS.
