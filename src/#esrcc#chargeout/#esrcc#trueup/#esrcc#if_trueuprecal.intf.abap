INTERFACE /esrcc/if_trueuprecal
  PUBLIC .

  INTERFACES: if_badi_interface.

  CLASS-METHODS calculate_recalchargeout
    IMPORTING
      !it_keys   TYPE /esrcc/tt_keys
    EXPORTING
      !ev_failed TYPE abap_boolean .

  CLASS-METHODS finalize_recalchargeout
    IMPORTING
      !it_keys   TYPE /esrcc/tt_keys
    EXPORTING
      !ev_failed TYPE abap_boolean .

  CLASS-METHODS reopen_recalchargeout
    IMPORTING
      !it_keys           TYPE /esrcc/tt_keys
    EXPORTING
      !ev_failed         TYPE abap_boolean .

ENDINTERFACE.
