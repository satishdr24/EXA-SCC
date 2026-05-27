class /ESRCC/API definition
  public
  final
  create public .

public section.

  class-data DOCUMENT_SERVICE type ref to /ESRCC/IF_WRITE_BACK .
  class-data EXTRACTION_SERVICE type ref to /ESRCC/IF_EXTRACT_DATA .
  class-data EXTRACTION_BW_SERVICE type ref to /ESRCC/IF_EXTRACT_DATA .

  class-methods CLASS_CONSTRUCTOR .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/API IMPLEMENTATION.


  METHOD class_constructor.
    document_service = /esrcc/write_back=>create( ).
    extraction_service = /esrcc/extract_data=>create( ).
    extraction_bw_service = /esrcc/extract_data_bw=>create( ).

  ENDMETHOD.
ENDCLASS.
