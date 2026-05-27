CLASS /esrcc/cl_uuid_finder DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_company_code_param,
        sysid       TYPE /esrcc/sysid,
        legalentity TYPE /esrcc/legalentity,
        companycode TYPE /esrcc/ccode_de,
      END OF ty_company_code_param.

    TYPES:
      BEGIN OF ty_cost_center_param.
        INCLUDE TYPE ty_company_code_param.
    TYPES:
        costobject TYPE /esrcc/costobject_de,
        costcenter TYPE /esrcc/costcenter,
      END OF ty_cost_center_param.

    CLASS-METHODS:
      cost_center_uuid
        IMPORTING
          parameter   TYPE ty_cost_center_param
        RETURNING
          VALUE(uuid) TYPE sysuuid_x16,

      cost_element_uuid
        IMPORTING
          parameter   TYPE ty_company_code_param
        RETURNING
          VALUE(uuid) TYPE sysuuid_x16.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /esrcc/cl_uuid_finder IMPLEMENTATION.

  METHOD cost_center_uuid.
    SELECT SINGLE FROM /esrcc/cst_objct
      FIELDS cost_object_uuid
      WHERE sysid        = @parameter-sysid
        AND legal_entity = @parameter-legalentity
        AND company_code = @parameter-companycode
        AND cost_object  = @parameter-costobject
        AND cost_center  = @parameter-costcenter
      INTO @uuid.
  ENDMETHOD.

  METHOD cost_element_uuid.
*    SELECT SINGLE FROM /esrcc/cst_elmnt
*      FIELDS cost_element_uuid
*      WHERE sysid        = @parameter-sysid
*        AND legal_entity = @parameter-legalentity
*        AND company_code = @parameter-companycode
*      INTO @uuid.
  ENDMETHOD.

ENDCLASS.
