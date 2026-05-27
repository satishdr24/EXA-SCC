CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES ts_acc_type        TYPE STRUCTURE FOR READ RESULT /ESRCC/I_AccountingType_S\\AccountingType.
    TYPES tt_acc_type_create TYPE TABLE FOR CREATE /ESRCC/I_AccountingType_S\\AccountingTypeAll\_AccountingType.
    TYPES: BEGIN OF ts_control,
             acc_type TYPE if_abap_behv=>t_xflag,
           END OF ts_control.

    METHODS constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util.

    METHODS validate_accounting_type
      IMPORTING !entity  TYPE ts_acc_type
                !control TYPE ts_control.

    CLASS-METHODS precheck_cba_accounting_type
      IMPORTING !entities TYPE tt_acc_type_create
      CHANGING  !reported TYPE any
                !failed   TYPE any.

  PRIVATE SECTION.
    DATA: config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.

  METHOD constructor.
   me->config_util_ref = config_util_ref.
  ENDMETHOD.

METHOD validate_accounting_type.
  DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-acc_type = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'ACCOUNTINGTYPE' ) TO fields. ENDIF.

    config_util_ref->validate_initial( fields = fields
                                       entity = entity ).
  ENDMETHOD.

  METHOD precheck_cba_accounting_type.
        DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'AccountingTypeAll' ) )
        source_entity_name = '/ESRCC/C_RR_ACCOUNTING_TYPE'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported
        failed_entity      = failed ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_accounting_type(
          entity  = CORRESPONDING #( target )
          control = VALUE #( acc_type = if_abap_behv=>mk-on )
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
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/ACCOUNTINGTYPE'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'AccountingType' table = '/ESRCC/RR_ACCTYP' )
                                         ( entity = 'AccountingTypeText' table = '/ESRCC/RR_ACCTYT' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_accountingtype_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR AccountingTypeAll
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION AccountingTypeAll~SelectCustomizingTransptReq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR AccountingTypeAll
        RESULT result,
      precheck_cba_Accountingtype FOR PRECHECK
            IMPORTING entities FOR CREATE AccountingTypeAll\_Accountingtype.
ENDCLASS.

CLASS lhc_/esrcc/i_accountingtype_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(selecttransport_flag) = if_abap_behv=>fc-o-enabled.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /ESRCC/I_AccountingType_S IN LOCAL MODE
    ENTITY AccountingTypeAll
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.
    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_AccountingType = edit_flag
               %action-SelectCustomizingTransptReq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /ESRCC/I_AccountingType_S IN LOCAL MODE
      ENTITY AccountingTypeAll
        UPDATE FIELDS ( TransportRequestID HideTransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          TransportRequestID = key-%param-transportrequestid
                          HideTransport      = abap_false ) )
                          FAILED failed.

    READ ENTITIES OF /ESRCC/I_AccountingType_S IN LOCAL MODE
      ENTITY AccountingTypeAll
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_RR_ACCOUNTING_TYPE' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-Edit = is_authorized.
    result-%action-SelectCustomizingTransptReq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_Accountingtype.
  lcl_custom_validation=>precheck_cba_Accounting_type( EXPORTING entities = entities
                                                     CHANGING  failed   = failed-accountingtype
                                                               reported = reported-accountingtype ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_accountingtype_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_accountingtype_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-AccountingTypeAll INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_rr_accounting_typ DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR AccountingType~ValidateTransportRequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR AccountingType
        RESULT result,
      copyaccountingtype FOR MODIFY
        IMPORTING
          keys FOR ACTION AccountingType~CopyAccountingType,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR AccountingType
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR AccountingType
        RESULT    result.
ENDCLASS.

CLASS lhc_/esrcc/i_rr_accounting_typ IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /ESRCC/I_AccountingType_S.
    SELECT SINGLE TransportRequestID
      FROM /esrcc/d_rr_ac_s
      WHERE SingletonID = 1
      INTO @DATA(TransportRequestID).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = TransportRequestID
                                table             = '/ESRCC/RR_ACCTYP'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-AccountingType ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
    result-%assoc-_AccountingTypeText = edit_flag.
  ENDMETHOD.
  METHOD copyaccountingtype.
    DATA new_AccountingType TYPE TABLE FOR CREATE /ESRCC/I_AccountingType_S\_AccountingType.
    DATA new_AccountingTypeText TYPE TABLE FOR CREATE /ESRCC/I_AccountingType_S\\AccountingType\_AccountingTypeText.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-AccountingType = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /ESRCC/I_AccountingType_S IN LOCAL MODE
      ENTITY AccountingType
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_AccountingType)
      FAILED DATA(read_failed).
    READ ENTITIES OF /ESRCC/I_AccountingType_S IN LOCAL MODE
      ENTITY AccountingType BY \_AccountingTypeText
      ALL FIELDS WITH CORRESPONDING #( ref_AccountingType )
      RESULT DATA(ref_AccountingTypeText).

    LOOP AT ref_AccountingType ASSIGNING FIELD-SYMBOL(<ref_AccountingType>).
      DATA(key) = keys[ KEY draft %tky = <ref_AccountingType>-%tky ].
      DATA(key_cid) = key-%cid.
      APPEND VALUE #(
        %tky-SingletonID = 1
        %is_draft = <ref_AccountingType>-%is_draft
        %target = VALUE #( (
          %cid = key_cid
          %is_draft = <ref_AccountingType>-%is_draft
          %data = CORRESPONDING #( <ref_AccountingType> EXCEPT
            AccountingType
            CreatedAt
            CreatedBy
            LastChangedAt
            LastChangedBy
            LocalLastChangedAt
            SingletonID
        ) ) )
      ) TO new_AccountingType ASSIGNING FIELD-SYMBOL(<new_AccountingType>).
      <new_AccountingType>-%target[ 1 ]-AccountingType = key-%param-AccountingType.
      FIELD-SYMBOLS <new_AccountingTypeText> LIKE LINE OF new_AccountingTypeText.
      UNASSIGN <new_AccountingTypeText>.
      LOOP AT ref_AccountingTypeText ASSIGNING FIELD-SYMBOL(<ref_AccountingTypeText>) USING KEY draft WHERE %tky-%is_draft = key-%tky-%is_draft
              AND %tky-AccountingType = key-%tky-AccountingType.
        IF <new_AccountingTypeText> IS NOT ASSIGNED.
          INSERT VALUE #( %cid_ref  = key_cid
                          %is_draft = key-%is_draft ) INTO TABLE new_AccountingTypeText ASSIGNING <new_AccountingTypeText>.
        ENDIF.
        INSERT VALUE #( %cid = key_cid && <ref_AccountingTypeText>-Spras
                        %is_draft = key-%is_draft
                        %data = CORRESPONDING #( <ref_AccountingTypeText> EXCEPT
                                                 AccountingType
                                                 LocalLastChangedAt
                                                 SingletonID
        ) ) INTO TABLE <new_AccountingTypeText>-%target ASSIGNING FIELD-SYMBOL(<target>).
        <target>-%key-AccountingType = key-%param-AccountingType.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF /ESRCC/I_AccountingType_S IN LOCAL MODE
      ENTITY AccountingTypeAll CREATE BY \_AccountingType
      FIELDS (
               AccountingType
               AccMeaningWithPlus
               AccMeaningWithMinus
             ) WITH new_AccountingType
      ENTITY AccountingType CREATE BY \_AccountingTypeText
      FIELDS (
               Spras
               AccountingType
               Description
             ) WITH new_AccountingTypeText
      MAPPED DATA(mapped_create)
      FAILED failed
      REPORTED reported.

    mapped-AccountingType = mapped_create-AccountingType.
    INSERT LINES OF read_failed-AccountingType INTO TABLE failed-AccountingType.

    IF failed-AccountingType IS INITIAL.
      reported-AccountingType = VALUE #( FOR created IN mapped-AccountingType (
                                                 %cid = created-%cid
                                                 %action-CopyAccountingType = if_abap_behv=>mk-on
                                                 %msg = mbc_cp_api=>message( )->get_item_copied( )
                                                 %path-AccountingTypeAll-%is_draft = created-%is_draft
                                                 %path-AccountingTypeAll-SingletonID = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_RR_ACCOUNTING_TYPE' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%action-CopyAccountingType = is_authorized.
  ENDMETHOD.
  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-CopyAccountingType = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
   ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_accountingtypetex DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR AccountingTypeText~ValidateTransportRequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR AccountingTypeText
        RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_accountingtypetex IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /ESRCC/I_AccountingType_S.
    SELECT SINGLE TransportRequestID
      FROM /esrcc/d_rr_ac_s
      WHERE SingletonID = 1
      INTO @DATA(TransportRequestID).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = TransportRequestID
                                table             = '/ESRCC/RR_ACCTYT'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-AccountingTypeText ) ).
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
