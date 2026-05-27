CLASS /esrcc/cl_badi_forecast DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /esrcc/if_forecast.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /esrcc/cl_badi_forecast IMPLEMENTATION.

 METHOD /esrcc/if_forecast~calculate_forecast.

    /esrcc/cl_calculate_forecast=>calculate_forecast(
      EXPORTING
        it_keys  = it_keys
      IMPORTING
        ev_failed = ev_failed
    ).

  ENDMETHOD.

  METHOD /esrcc/if_forecast~finalize_forecast.

    /esrcc/cl_calculate_forecast=>finalize_forecast(
      it_keys  = it_keys
    ).

  ENDMETHOD.

  METHOD /esrcc/if_forecast~reopen_forecast.

    /esrcc/cl_calculate_forecast=>reopen_forecast(
      it_keys  = it_keys
    ).

  ENDMETHOD.

ENDCLASS.
