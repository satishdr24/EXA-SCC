CLASS lhc_/esrcc/i_rr_rule_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      augment FOR MODIFY
        IMPORTING
          entities_create FOR CREATE RuleAll\_Rule
          entities_update FOR UPDATE Rule.
ENDCLASS.

CLASS lhc_/esrcc/i_rr_rule_s IMPLEMENTATION.
  METHOD augment.
    DATA: text_for_new_entity      TYPE TABLE FOR CREATE /ESRCC/I_RR_Rule\_RuleText,
          text_for_existing_entity TYPE TABLE FOR CREATE /ESRCC/I_RR_Rule\_RuleText,
          text_update              TYPE TABLE FOR UPDATE /ESRCC/I_RR_RuleText.
    DATA: relates_create TYPE abp_behv_relating_tab,
          relates_update TYPE abp_behv_relating_tab,
          relates_cba    TYPE abp_behv_relating_tab.
    DATA: text_tky_link TYPE STRUCTURE FOR READ LINK /ESRCC/I_RR_Rule\_RuleText,
          text_tky      LIKE text_tky_link-target.

    READ TABLE entities_create INDEX 1 INTO DATA(entity).
    LOOP AT entity-%target ASSIGNING FIELD-SYMBOL(<target>).
      APPEND 1 TO relates_create.
      INSERT VALUE #( %cid_ref = <target>-%cid
                      %is_draft = <target>-%is_draft
                        %key-RuleId = <target>-%key-RuleId
                      %target = VALUE #( (
                        %cid = |CREATETEXTCID{ sy-tabix }|
                        %is_draft = <target>-%is_draft
                        Spras = sy-langu
                        Description = <target>-Description
                        %control-Spras = if_abap_behv=>mk-on
                        %control-Description = <target>-%control-Description ) ) )
                   INTO TABLE text_for_new_entity.
    ENDLOOP.
    MODIFY AUGMENTING ENTITIES OF /ESRCC/I_RR_Rule_S
      ENTITY Rule
        CREATE BY \_RuleText
        FROM text_for_new_entity
        RELATING TO entities_create BY relates_create.

    IF entities_update IS NOT INITIAL.
      READ ENTITIES OF /ESRCC/I_RR_Rule_S
        ENTITY Rule BY \_RuleText
          FROM CORRESPONDING #( entities_update )
          LINK DATA(link).
      LOOP AT entities_update INTO DATA(update) WHERE %control-Description = if_abap_behv=>mk-on.
        DATA(tabix) = sy-tabix.
        text_tky = CORRESPONDING #( update-%tky MAPPING
                                                        RuleId = RuleId
                                    ).
        text_tky-Spras = sy-langu.
        IF line_exists( link[ KEY draft source-%tky  = CORRESPONDING #( update-%tky )
                                        target-%tky  = CORRESPONDING #( text_tky ) ] ).
          APPEND tabix TO relates_update.
          APPEND VALUE #( %tky = text_tky
                          %cid_ref = update-%cid_ref
                          Description = update-Description
                          %control = VALUE #( Description = update-%control-Description )
          ) TO text_update.
        ELSEIF line_exists(  text_for_new_entity[ KEY cid %is_draft = update-%is_draft
                                                          %cid_ref  = update-%cid_ref ] ).
          APPEND tabix TO relates_update.
          APPEND VALUE #( %tky = text_tky
                          %cid_ref = text_for_new_entity[ %is_draft = update-%is_draft
                          %cid_ref = update-%cid_ref ]-%target[ 1 ]-%cid
                          Description = update-Description
                          %control = VALUE #( Description = update-%control-Description )
          ) TO text_update.
        ELSE.
          APPEND tabix TO relates_cba.
          APPEND VALUE #( %tky = CORRESPONDING #( update-%tky )
                          %cid_ref = update-%cid_ref
                          %target  = VALUE #( (
                            %cid = |UPDATETEXTCID{ tabix }|
                            Spras = sy-langu
                            %is_draft = text_tky-%is_draft
                            Description = update-Description
                            %control-Spras = if_abap_behv=>mk-on
                            %control-Description = update-%control-Description
                          ) )
          ) TO text_for_existing_entity.
        ENDIF.
      ENDLOOP.
      IF text_update IS NOT INITIAL.
        MODIFY AUGMENTING ENTITIES OF /ESRCC/I_RR_Rule_S
          ENTITY RuleText
            UPDATE FROM text_update
            RELATING TO entities_update BY relates_update.
      ENDIF.
      IF text_for_existing_entity IS NOT INITIAL.
        MODIFY AUGMENTING ENTITIES OF /ESRCC/I_RR_Rule_S
          ENTITY Rule
            CREATE BY \_RuleText
            FROM text_for_existing_entity
            RELATING TO entities_update BY relates_cba.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
