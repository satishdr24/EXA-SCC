CLASS /esrcc/cl_c_executioncockpit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.

ENDCLASS.



CLASS /esrcc/cl_c_executioncockpit IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    TRY.
**filter
        DATA(lv_sql_filter) = io_request->get_filter( )->get_as_sql_string( ).
        TRY.
            DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).
          CATCH cx_rap_query_filter_no_range.
            "handle exception
        ENDTRY.

        DATA lt_result        TYPE STANDARD TABLE OF /esrcc/c_execution_cockpit.
        DATA ls_result        TYPE /esrcc/c_execution_cockpit.
        DATA authorized_values TYPE /esrcc/tt_cockpitvalues.
        DATA _sysid           TYPE RANGE OF /esrcc/sysid.
        DATA _ryear           TYPE RANGE OF /esrcc/ryear.
        DATA _poper           TYPE RANGE OF poper.
        DATA _legalentity     TYPE RANGE OF /esrcc/legalentity.
        DATA _ccode           TYPE RANGE OF /esrcc/ccode_de.
        DATA _costobject      TYPE RANGE OF /esrcc/costobject_de.
        DATA _costcenter      TYPE RANGE OF /esrcc/costcenter.
        DATA _serviceproduct  TYPE RANGE OF /esrcc/srvproduct.
        DATA _validon         TYPE /esrcc/validfrom.
        DATA _action          TYPE /esrcc/actions.
        DATA _oecd            TYPE RANGE OF /esrcc/oecdtpg_de.
        DATA _chainid         TYPE RANGE OF /esrcc/chain_id.
        DATA _tpprofile       TYPE RANGE OF /esrcc/tpprofile.
        DATA _profitcenter    TYPE RANGE OF /esrcc/profit_center.
        DATA _functionalarea  TYPE RANGE OF /esrcc/functional_area.
        DATA _businessdivision TYPE RANGE OF /esrcc/businessdivision.
        DATA lo_badi           TYPE REF TO /esrcc/badi_amdp_cockpit.

*   filters
        LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<ls_filter>).

          CASE <ls_filter>-name.
            WHEN 'SYSID'.
              _sysid = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'RYEAR'.
              _ryear = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'POPER'.
              _poper = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'LEGALENTITY'.
              _legalentity = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'CCODE'.
              _ccode = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'COSTOBJECT'.
              _costobject = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'COSTCENTER'.
              _costcenter = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'SERVICEPRODUCT'.
              _serviceproduct = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'ACTION'.
              _action = <ls_filter>-range[ 1 ]-low.
            WHEN 'OECD'.
              _oecd = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'CHAIN_ID'.
              _chainid = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'TPPROFILE'.
              _tpprofile = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'PROFITCENTER'.
              _profitcenter = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'FUNCTIONALAREA'.
              _functionalarea = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'BUSINESSDIVISION'.
              _businessdivision = CORRESPONDING #( <ls_filter>-range ).
            WHEN OTHERS.
          ENDCASE.

        ENDLOOP.
*
** get master data
        DATA(lv_year) = _ryear[ 1 ]-low.
        DATA(lv_poper) = _poper[ 1 ]-low.

        CONCATENATE lv_year lv_poper+1(2) '01' INTO _validon.

*        Read legal entity & Company Code from stewardship customizing as root node
        SELECT DISTINCT
                srv~CostObjectUuid,
                srv~StewardshipUuid,
                srv~ServiceProductUuid,
                srv~chain_id,
                srv~chain_sequence
        FROM  /esrcc/i_stw_serviceproduct_2 AS srv
               INNER JOIN /esrcc/le AS le
               ON le~legalentity = srv~legalentity
               INNER JOIN /esrcc/le_ccode AS leccode
                ON leccode~active      = @abap_true
               AND leccode~legalentity = srv~legalentity
               AND leccode~ccode       = srv~CompanyCode
               INNER JOIN /esrcc/srvpro AS srvpro
               ON srvpro~Serviceproduct = srv~Serviceproduct
       WHERE srv~legalentity        IN @_legalentity
         AND srv~sysid              IN @_sysid
         AND srv~CompanyCode        IN @_ccode
         AND srv~costobject         IN @_costobject
         AND srv~costcenter         IN @_costcenter
         AND srv~serviceproduct     IN @_serviceproduct
         AND srv~validfrom          <= @_validon
         AND srv~validto            >= @_validon
         AND srvpro~OecdTpg         IN @_oecd
         AND srv~chain_id           IN @_chainid
         AND le~tpprofile           IN @_tpprofile
         AND srv~ProfitCenter       IN @_profitcenter
         AND srv~FunctionalArea     IN @_functionalarea
         AND srv~BusinessDivision   IN @_businessdivision
         AND srv~workflow_status    = @/esrcc/if_calculate_chargeout=>finalized
         APPENDING CORRESPONDING FIELDS OF TABLE @authorized_values.

**********************************************************************************************************
**        Create Cockpit Status Tree
**********************************************************************************************************
        IF lo_badi IS NOT BOUND.
          TRY.
              GET BADI lo_badi.
            CATCH cx_badi_not_implemented cx_badi_unknown_error.
          ENDTRY.
        ENDIF.

        CALL BADI lo_badi->get_cockpit_tree
          EXPORTING
            year             = lv_year
            poper            = lv_poper
            validon          = _validon
            action           = _action
            legalentity      = _legalentity
            CompanyCode      = _ccode
            costobject       = _costobject
            costcenter       = _costcenter
            filtervalues     = authorized_values
          IMPORTING
            results          = DATA(results).

        LOOP AT results ASSIGNING FIELD-SYMBOL(<ls_result>) WHERE stdmsgno <> ''
                                                               OR trumsgno <> ''.

          IF <ls_result>-stdmsgno <> ''.
            MESSAGE ID '/ESRCC/EXECCOCKPIT' TYPE 'E' NUMBER <ls_result>-stdmsgno INTO <ls_result>-messagestdchargeout.
            <ls_result>-messagetypestdchargeout = 'I'.
          ELSEIF <ls_result>-trumsgno <> ''.
            MESSAGE ID '/ESRCC/EXECCOCKPIT' TYPE 'E' NUMBER <ls_result>-trumsgno INTO <ls_result>-messagerecalculation.
            <ls_result>-messagetyperecalculation = 'I'.
          ELSEIF <ls_result>-fcamsgno <> ''.
            MESSAGE ID '/ESRCC/EXECCOCKPIT' TYPE 'E' NUMBER <ls_result>-fcamsgno INTO <ls_result>-messageforecast.
            <ls_result>-messagetypeforecast = 'I'.
          ENDIF.
        ENDLOOP.

        lt_result = CORRESPONDING #( results ).

**************************************************************************************************************************************
        SORT lt_result BY sysid Legalentity ccode Costobject Costcenter ServiceProduct.
***fill response
        io_response->set_data( lt_result ).
*        ENDIF.
**request count
        IF io_request->is_total_numb_of_rec_requested( ).
**select count
**fill response
          io_response->set_total_number_of_records( lines( lt_result ) ).
        ENDIF.

      CATCH cx_rap_query_provider.

    ENDTRY.
  ENDMETHOD.

ENDCLASS.
