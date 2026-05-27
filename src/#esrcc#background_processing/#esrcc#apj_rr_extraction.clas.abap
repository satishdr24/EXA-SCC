CLASS /esrcc/apj_rr_extraction DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object.
    INTERFACES if_apj_rt_exec_object.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS /esrcc/apj_rr_extraction IMPLEMENTATION.
  METHOD if_apj_dt_exec_object~get_parameters.
    et_parameter_def = VALUE if_apj_dt_exec_object=>tt_templ_def(
                         changeable_ind = abap_true
                         ( selname        = 'EXT_OBJ'
                           kind           = if_apj_dt_exec_object=>parameter
                           length         = 6
                           component_type = '/ESRCC/EXTRACTION_OBJECT'
                           section_text   = 'Extraction Object'
                           group_text     = 'Filters'
                           param_text     = 'Extraction Object'
                           mandatory_ind  = abap_true
                         )
                         ( selname        = 'REP_YEAR'
                           kind           = if_apj_dt_exec_object=>parameter
                           length         = 4
                           component_type = '/ESRCC/RYEAR'
                           section_text   = 'Year'
                           group_text     = 'Filters'
                           param_text     = 'Year'
                           mandatory_ind  = abap_true

                         )
                         ( selname        = 'PERIOD'
                           kind           = if_apj_dt_exec_object=>select_option
                           length         = 3
                           component_type = '/ESRCC/POPER'
                           section_text   = 'Posting Period'
                           group_text     = 'Filters'
                           param_text     = 'Posting Period'

                         )
                         ( selname        = 'PST_DATE'
                           kind           = if_apj_dt_exec_object=>parameter
                           length         = 8
                           datatype       = 'D'
                           section_text   = 'Posting Date'
                           group_text     = 'Filters'
                           param_text     = 'Posting Date'
                         )
                          ( selname        = 'ENTITY'
                           kind           = if_apj_dt_exec_object=>select_option
                           length         = 4
                           component_type = '/ESRCC/LEGALENTITY'
                           section_text   = 'Legal Entity'
                           group_text     = 'Filters'
                           param_text     = 'Legal Entity'
                         )
                         ( selname        = 'PKG_CODE'
                           kind           = if_apj_dt_exec_object=>select_option
                           length         = 2
                           component_type = '/ESRCC/PACKAGE_CODE'
                           section_text   = 'Package Code'
                           group_text     = 'Filters'
                           param_text     = 'Package Code'
                         )

                          ( selname        = 'CSTCENTR'
                           kind           = if_apj_dt_exec_object=>select_option
                           length         = 24
                           component_type = '/ESRCC/RR_OBJECT_NUMBER'
                           section_text   = 'RR Object Number(s)'
                           group_text     = 'Filters'
                           param_text     = 'RR Object Number(s)'
                         )
                        ( selname        = 'PKG_SIZE'
                           kind           = if_apj_dt_exec_object=>parameter
                           datatype       = 'I'
                           length         = 5
                           section_text   = 'Package Size'
                           group_text     = 'Run Mode'
                           param_text     = 'Package Size'
                         )
                         ( selname        = 'SIMULATE'
                           kind           = if_apj_dt_exec_object=>parameter
                           datatype       = 'C'
                           length         = 1
                           section_text   = 'Simulation'
                           group_text     = 'Run Mode'
                           param_text     = 'Simulation'
                           checkbox_ind   = abap_true
) ).
    et_parameter_val = VALUE if_apj_dt_exec_object=>tt_templ_val(
                           ( selname = 'SIMULATE'
                             kind    = if_apj_dt_exec_object=>parameter
                             sign    = 'I'
                             option  = 'EQ'
                             low     = 'X'
                             high    = ''
                           )
                           ( selname = 'PKG_SIZE'
                             kind    = if_apj_dt_exec_object=>parameter
                             sign    = 'I'
                             option  = 'EQ'
                             low     = '100000'
                             high    = ''
                           )
                         ).

  ENDMETHOD.



  METHOD if_apj_rt_exec_object~execute.
    /esrcc/api=>extraction_service->filter(

       filters = VALUE #( FOR GROUPS <group> OF <parameter> IN it_parameters
                          GROUP BY
                          ( key = <parameter>-selname )
                          LET inputs = VALUE if_apj_rt_exec_object=>tt_templ_val( FOR <param> IN GROUP <group>
                                                                                  ( <param> ) ) IN
                          ( filter_name = <group>
                            filter_value = NEW if_apj_rt_exec_object=>tt_templ_val( inputs ) ) ) )->extract( ).
  ENDMETHOD.

 ENDCLASS.
