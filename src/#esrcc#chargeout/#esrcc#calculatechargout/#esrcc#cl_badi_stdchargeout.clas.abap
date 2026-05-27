CLASS /esrcc/cl_badi_stdchargeout DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /esrcc/if_stdchargeout .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS /esrcc/cl_badi_stdchargeout IMPLEMENTATION.

  METHOD /esrcc/if_stdchargeout~calculate_adhocchargeout.

    /esrcc/cl_calculate_chargeout=>calculate_adhocchargeout(
      it_cbli       = it_cbli
      is_parameters = is_parameters
      it_receivers  = it_receivers
    ).

  ENDMETHOD.

  METHOD /esrcc/if_stdchargeout~delete_adhoc_chargeout.

    /esrcc/cl_calculate_chargeout=>delete_adhoc_chargeout( id =  id ).

  ENDMETHOD.

  METHOD /esrcc/if_stdchargeout~calculate_stdchargeout.

    /esrcc/cl_calculate_chargeout=>calculate_stdchargeout(
      EXPORTING
        it_keys   = it_keys
      IMPORTING
        ev_failed = ev_failed
    ).

  ENDMETHOD.

  METHOD /esrcc/if_stdchargeout~finalize_stdchargeout.

    /esrcc/cl_calculate_chargeout=>finalize_stdchargeout(
      it_keys  = it_keys
    ).

  ENDMETHOD.

  METHOD /esrcc/if_stdchargeout~reopen_stdchargeout.

    /esrcc/cl_calculate_chargeout=>reopen_stdchargeout(
      it_keys  = it_keys
    ).

  ENDMETHOD.

ENDCLASS.
