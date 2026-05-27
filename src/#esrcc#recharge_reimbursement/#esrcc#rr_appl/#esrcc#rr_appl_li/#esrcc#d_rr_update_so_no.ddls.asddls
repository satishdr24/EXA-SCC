@EndUserText.label: 'Update Sales Order No'
@Metadata.allowExtensions: true
define root abstract entity /ESRCC/D_RR_Update_SO_No

{
  salesorder_reference : /esrcc/so_reference_no;
  salesorder_number    : /esrcc/so_number;
  so_created_by        : abp_creation_user;
  timestamp            : abp_creation_tstmpl;
}
