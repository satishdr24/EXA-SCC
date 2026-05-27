CLASS /esrcc/cl_badi_trueuprecal DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /esrcc/if_trueuprecal.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /esrcc/cl_badi_trueuprecal IMPLEMENTATION.

  METHOD /esrcc/if_trueuprecal~calculate_recalchargeout.

    /esrcc/cl_calculate_trueup=>calculate_recalchargeout(
      EXPORTING
        it_keys  = it_keys
      IMPORTING
        ev_failed = ev_failed
    ).

  ENDMETHOD.

  METHOD /esrcc/if_trueuprecal~finalize_recalchargeout.

    /esrcc/cl_calculate_trueup=>finalize_recalchargeout(
      it_keys  = it_keys
    ).

  ENDMETHOD.

  METHOD /esrcc/if_trueuprecal~reopen_recalchargeout.

    /esrcc/cl_calculate_trueup=>reopen_recalchargeout(
      it_keys  = it_keys
    ).

  ENDMETHOD.

ENDCLASS.
