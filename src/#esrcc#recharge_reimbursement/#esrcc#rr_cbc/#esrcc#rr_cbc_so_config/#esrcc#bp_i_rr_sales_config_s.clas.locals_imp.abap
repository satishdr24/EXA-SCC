CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_salesorder        TYPE STRUCTURE FOR READ RESULT /ESRCC/I_RR_Sales_Config_S\\RR_Sales_Config,
      tt_salesorder_create TYPE TABLE FOR CREATE /ESRCC/I_RR_Sales_Config_S\\RR_Sales_ConfigAll\_RR_Sales_Config,
      BEGIN OF ts_control,
        groupbykey TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_rr_salesorderconfig
        IMPORTING
          entity  TYPE ts_salesorder
          control TYPE ts_control.

    CLASS-METHODS:
      precheck_cba_rr_soconfig
        IMPORTING
          entities TYPE tt_salesorder_create
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

  METHOD validate_rr_salesorderconfig.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-groupbykey = if_abap_behv=>mk-on.
      APPEND VALUE #( fieldname = 'GROUPBYKEY' ) TO fields.
    ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD precheck_cba_rr_soconfig.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
EXPORTING
  paths         = VALUE #( ( path = 'RR_Sales_ConfigAll' ) )
  source_entity_name = '/ESRCC/C_RR_SALES_CONFIG'
  is_transition = abap_true
  CHANGING
    reported_entity = reported
    failed_entity = failed
     ) ).

    LOOP AT entities INTO DATA(entity).
      LOOP AT entity-%target INTO DATA(target).
        lo_validation->validate_rr_salesorderconfig(
          entity = CORRESPONDING #( target )
          control = VALUE #( groupbykey = if_abap_behv=>mk-on )
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
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = '/ESRCC/RR_SALES_CONFIG'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'RR_Sales_Config' table = '/ESRCC/RR_SOCONF' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_rr_sales_config_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR RR_Sales_ConfigAll
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION RR_Sales_ConfigAll~SelectCustomizingTransptReq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR RR_Sales_ConfigAll
        RESULT result,
      precheck_cba_Rr_sales_config FOR PRECHECK
        IMPORTING entities FOR CREATE RR_Sales_ConfigAll\_Rr_sales_config.
ENDCLASS.

CLASS lhc_/esrcc/i_rr_sales_config_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA(selecttransport_flag) = if_abap_behv=>fc-o-enabled.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /ESRCC/I_RR_Sales_Config_S IN LOCAL MODE
    ENTITY RR_Sales_ConfigAll
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(entities)
      FAILED failed.
    result = VALUE #( FOR row IN entities (
               %tky = row-%tky
               %action-edit = edit_flag
               %assoc-_RR_Sales_Config = edit_flag
               %action-SelectCustomizingTransptReq = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /ESRCC/I_RR_Sales_Config_S IN LOCAL MODE
      ENTITY RR_Sales_ConfigAll
        UPDATE FIELDS ( TransportRequestID HideTransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          TransportRequestID = key-%param-transportrequestid
                          HideTransport      = abap_false ) )
                          FAILED failed.

    READ ENTITIES OF /ESRCC/I_RR_Sales_Config_S IN LOCAL MODE
      ENTITY RR_Sales_ConfigAll
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_RR_SALES_CONFIG' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-Edit = is_authorized.
    result-%action-SelectCustomizingTransptReq = is_authorized.
  ENDMETHOD.

  METHOD precheck_cba_Rr_sales_config.
    lcl_custom_validation=>precheck_cba_rr_soconfig(
    EXPORTING
      entities = entities
    CHANGING
      failed = failed-rr_sales_config
      reported = reported-rr_sales_config
   ).
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_rr_sales_config_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_rr_sales_config_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-RR_Sales_ConfigAll INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_rr_sales_config DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR RR_Sales_Config~ValidateTransportRequest,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR RR_Sales_Config
        RESULT result,
      copyrr_sales_config FOR MODIFY
        IMPORTING
          keys FOR ACTION RR_Sales_Config~CopyRR_Sales_Config,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR RR_Sales_Config
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR RR_Sales_Config
        RESULT    result.

ENDCLASS.

CLASS lhc_/esrcc/i_rr_sales_config IMPLEMENTATION.
  METHOD validatetransportrequest.
    DATA change TYPE REQUEST FOR CHANGE /ESRCC/I_RR_Sales_Config_S.
    SELECT SINGLE TransportRequestID
      FROM /esrcc/d_rr_so_s
      WHERE SingletonID = 1
      INTO @DATA(TransportRequestID).
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = TransportRequestID
                                table             = '/ESRCC/RR_SOCONF'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-RR_Sales_Config ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA(edit_flag) = if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.
  METHOD copyrr_sales_config.
    DATA new_RR_Sales_Config TYPE TABLE FOR CREATE /ESRCC/I_RR_Sales_Config_S\_RR_Sales_Config.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-RR_Sales_Config = VALUE #( FOR fkey IN keys ( %tky = fkey-%tky ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF /ESRCC/I_RR_Sales_Config_S IN LOCAL MODE
      ENTITY RR_Sales_Config
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ref_RR_Sales_Config)
      FAILED DATA(read_failed).

    LOOP AT ref_RR_Sales_Config ASSIGNING FIELD-SYMBOL(<ref_RR_Sales_Config>).
      DATA(key) = keys[ KEY draft %tky = <ref_RR_Sales_Config>-%tky ].
      DATA(key_cid) = key-%cid.
      APPEND VALUE #(
        %tky-SingletonID = 1
        %is_draft = <ref_RR_Sales_Config>-%is_draft
        %target = VALUE #( (
          %cid = key_cid
          %is_draft = <ref_RR_Sales_Config>-%is_draft
          %data = CORRESPONDING #( <ref_RR_Sales_Config> EXCEPT
            CreatedAt
            CreatedBy
            GroupByKey
            LastChangedAt
            LastChangedBy
            LocalLastChangedAt
            SingletonID
        ) ) )
      ) TO new_RR_Sales_Config ASSIGNING FIELD-SYMBOL(<new_RR_Sales_Config>).
      <new_RR_Sales_Config>-%target[ 1 ]-GroupByKey = key-%param-GroupByKey.
    ENDLOOP.

    MODIFY ENTITIES OF /ESRCC/I_RR_Sales_Config_S IN LOCAL MODE
      ENTITY RR_Sales_ConfigAll CREATE BY \_RR_Sales_Config
      FIELDS (
               GroupByKey
               GroupBy
               GroupByItem
               ItemCount
             ) WITH new_RR_Sales_Config
      MAPPED DATA(mapped_create)
      FAILED failed
      REPORTED reported.

    mapped-RR_Sales_Config = mapped_create-RR_Sales_Config.
    INSERT LINES OF read_failed-RR_Sales_Config INTO TABLE failed-RR_Sales_Config.

    IF failed-RR_Sales_Config IS INITIAL.
      reported-RR_Sales_Config = VALUE #( FOR created IN mapped-RR_Sales_Config (
                                                 %cid = created-%cid
                                                 %action-CopyRR_Sales_Config = if_abap_behv=>mk-on
                                                 %msg = mbc_cp_api=>message( )->get_item_copied( )
                                                 %path-RR_Sales_ConfigAll-%is_draft = created-%is_draft
                                                 %path-RR_Sales_ConfigAll-SingletonID = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_RR_SALES_CONFIG' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%action-CopyRR_Sales_Config = is_authorized.
  ENDMETHOD.
  METHOD get_instance_features.
    result = VALUE #( FOR row IN keys ( %tky = row-%tky
                                        %action-CopyRR_Sales_Config = COND #( WHEN row-%is_draft = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
   ) ).
  ENDMETHOD.

ENDCLASS.
