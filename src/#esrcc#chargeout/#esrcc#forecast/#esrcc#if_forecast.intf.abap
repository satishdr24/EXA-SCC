INTERFACE /esrcc/if_forecast
  PUBLIC .


  INTERFACES if_badi_interface .

  CLASS-METHODS calculate_forecast
    IMPORTING
      !it_keys   TYPE /esrcc/tt_keys
    EXPORTING
      !ev_failed TYPE abap_boolean .

  CLASS-METHODS finalize_forecast
    IMPORTING
      !it_keys   TYPE /esrcc/tt_keys
    EXPORTING
      !ev_failed TYPE abap_boolean .

  CLASS-METHODS reopen_forecast
    IMPORTING
      !it_keys           TYPE /esrcc/tt_keys
    EXPORTING
      !ev_failed         TYPE abap_boolean .
ENDINTERFACE.
