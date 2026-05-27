INTERFACE /esrcc/if_stdchargeout
  PUBLIC .

  INTERFACES: if_badi_interface.

  CLASS-METHODS calculate_stdchargeout
    IMPORTING
      !it_keys   TYPE /esrcc/tt_keys
    EXPORTING
      !ev_failed TYPE abap_boolean .

  CLASS-METHODS finalize_stdchargeout
    IMPORTING
      !it_keys   TYPE /esrcc/tt_keys
    EXPORTING
      !ev_failed TYPE abap_boolean .

  CLASS-METHODS reopen_stdchargeout
    IMPORTING
      !it_keys   TYPE /esrcc/tt_keys
    EXPORTING
      !ev_failed TYPE abap_boolean .

  CLASS-METHODS calculate_adhocchargeout
    IMPORTING
      !it_cbli       TYPE /esrcc/tt_cbli
      !is_parameters TYPE /esrcc/c_adhocchargeout
      !it_receivers  TYPE /esrcc/tt_receivers
    EXPORTING
      !ev_failed     TYPE abap_boolean .

  CLASS-METHODS delete_adhoc_chargeout
    IMPORTING
      !id        TYPE sysuuid_x16
    EXPORTING
      !ev_failed TYPE abap_boolean .

ENDINTERFACE.
