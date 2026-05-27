INTERFACE /esrcc/if_rr_create_so_badi
  PUBLIC.

  INTERFACES if_badi_interface.
  TYPES _line_item TYPE STANDARD TABLE OF /esrcc/rr_li.

  METHODS Create_SO IMPORTING grp_by_key TYPE /esrcc/rr_group_by_key
                    CHANGING  !log       TYPE REF TO if_bali_log.

  METHODS Update_SO IMPORTING so_detail       TYPE /esrcc/d_rr_update_so_no
                    RETURNING VALUE(response) TYPE /esrcc/api_response.


ENDINTERFACE.
