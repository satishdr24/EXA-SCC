INTERFACE /esrcc/if_dyn_table_generator PUBLIC.
  TYPES:
    BEGIN OF ddic_field_info,
      tabname   TYPE tabname,
      fieldname TYPE /esrcc/field_name,
      langu     TYPE /esrcc/actions,
      domname   TYPE /esrcc/domain_name,
      rollname  TYPE /esrcc/domain_name,
      convexit  TYPE /esrcc/conversion_exit,
    END OF ddic_field_info,

    ddic_field_info_list TYPE SORTED TABLE OF ddic_field_info WITH UNIQUE KEY tabname fieldname langu.

  METHODS:
    get_table_components      RETURNING VALUE(components)         TYPE cl_abap_structdescr=>component_table,
    override_table_components IMPORTING !components               TYPE cl_abap_structdescr=>component_table,
    get_dynamic_table         RETURNING VALUE(dynamic_table)      TYPE REF TO data,
    get_dynamic_table_line    RETURNING VALUE(dynamic_table_line) TYPE REF TO data,

    get_field_list IMPORTING table_name        TYPE tabname
                             field_name        TYPE /esrcc/field_name
                   RETURNING VALUE(field_list) TYPE ddic_field_info,

    generate IMPORTING table_name                 TYPE tabname
             RETURNING VALUE(is_exception_raised) TYPE xsdboolean,

    destroy.

ENDINTERFACE.
