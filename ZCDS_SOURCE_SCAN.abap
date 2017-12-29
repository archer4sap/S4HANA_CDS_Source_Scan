*&---------------------------------------------------------------------*
*& Report ZCDS_SOURCE_SCAN
*&---------------------------------------------------------------------*
*& Author : archer4sap
*&---------------------------------------------------------------------*
REPORT zcds_source_scan.


CLASS demo DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS main.
ENDCLASS.

CLASS demo IMPLEMENTATION.
  METHOD main.
    DATA : lv_search_term TYPE string, " Search Term
           lt_ddls_result TYPE TABLE OF acm_ddlstbviw_1r-ddls_name,
           wa_ddls_result TYPE acm_ddlstbviw_1r-ddls_name.

    " Get Search Term from User
    cl_demo_input=>request( EXPORTING text = `Search Term for DDL Source lookup(No Wild-card)`
                            CHANGING field = lv_search_term ).

    " Select DDLS
    SELECT DISTINCT ddls_name FROM
           acm_ddlstbviw_1r
           INTO TABLE @DATA(lt_ddls_list).
    IF sy-subrc IS INITIAL.
      LOOP AT lt_ddls_list ASSIGNING FIELD-SYMBOL(<lfs_ddls>).
        TRY.
            cl_dd_ddl_handler_factory=>create( )->read(
                  EXPORTING
                    name         = CONV ddlname( to_upper( <lfs_ddls>-ddls_name ) )
                  IMPORTING
                    ddddlsrcv_wa = DATA(ddlsrcv_wa) ).
          CATCH cx_dd_ddl_read INTO DATA(exc).
            "cl_demo_output=>display( exc->get_text( ) ).
        ENDTRY.

        IF ddlsrcv_wa-source IS INITIAL.
          CONTINUE.
        ELSE.
          " Search
          SEARCH ddlsrcv_wa-source FOR lv_search_term.
          IF sy-subrc IS INITIAL.
            " Append result
            wa_ddls_result = <lfs_ddls>-ddls_name.
            APPEND wa_ddls_result TO lt_ddls_result.
          ELSE.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF lt_ddls_result IS NOT INITIAL.
        cl_demo_output=>display( lt_ddls_result ).
      ELSE.
        cl_demo_output=>display( 'OOPs... No fish!' ).
      ENDIF.

    ELSE.
      cl_demo_output=>display( 'OOPs... No fish!' ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  demo=>main( ).
