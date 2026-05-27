INTERFACE /esrcc/if_amdp_cockpit
  PUBLIC .


  INTERFACES if_badi_interface .
  INTERFACES if_amdp_marker_hdb .

  METHODS get_cockpit_tree
    IMPORTING
      VALUE(year)             TYPE /esrcc/ryear
      VALUE(poper)            TYPE /esrcc/poper
      VALUE(validon)          TYPE /esrcc/validfrom
      VALUE(action)           TYPE /esrcc/actions
      VALUE(legalentity)      TYPE /esrcc/range_legalentity
      VALUE(Companycode)      TYPE /esrcc/range_ccode
      VALUE(costobject)       TYPE /esrcc/range_costobject
      VALUE(costcenter)       TYPE /esrcc/range_costcenter
      VALUE(filtervalues)     TYPE /esrcc/tt_cockpitvalues
    EXPORTING
      VALUE(results)          TYPE /esrcc/tt_executioncockpit.
ENDINTERFACE.
