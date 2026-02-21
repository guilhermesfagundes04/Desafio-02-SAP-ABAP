* Desafio 02 - Exercícios ABAP
" Mostrar nome da companhia aérea, número do voo, quantidade e valor classe ecônomica, executiva e 1° classe.

*Listar a quantidade de passagens aereas vendidas nas classes executiva (SBOOK-CLASS = C), economica (SBOOK-CLASS = Y) e 1ª classe (SBOOK-CLASS = F) de voos até a data atual.
*Agrupando por número de conexão. Somando os valores em dolares (SBOOK-LOCCURAM), para cada classe

* Exibir em ALV:
" SCARR-CARRNAME
" SFLIGHT-CONNID
" QTD_ECONOMICA
" VLR_ECONOMICA
" QTD_EXECUTIVA
" VLR_EXECUTIVA
" QTD_1CLASSE
" VLR_1CLASSE

REPORT zrgsf_desafio02.

* Declaro as tabelas que vão ser utilizadas no report *
TABLES: scarr, sbook.

* Declaro meus tipos internos que vão ser usados. *
* OBS: Sempre por como campo as chaves primárias das tabelas. *
TYPES: BEGIN OF ty_desafio2,
         carrname      TYPE scarr-carrname,
         connid        TYPE sbook-connid,
         fldate        TYPE sbook-fldate,
         qtd_economica TYPE i,
         vlr_economica TYPE sbook-loccuram,
         qtd_executiva TYPE i,
         vlr_executiva TYPE sbook-loccuram,
         qtd_1classe   TYPE i,
         vlr_1classe   TYPE sbook-loccuram,
       END OF ty_desafio2,
       BEGIN OF ty_scarr,
         carrid   TYPE scarr-carrid,
         carrname TYPE scarr-carrname,
       END OF ty_scarr,
       BEGIN OF ty_sbook,
         carrid   TYPE sbook-carrid,
         connid   TYPE sbook-connid,
         fldate   TYPE sbook-fldate,
         bookid   TYPE sbook-bookid,
         class    TYPE sbook-class,
         loccuram TYPE sbook-loccuram,
       END OF ty_sbook.

* Declaro minhas tabelas internas(globais) que vão ser utilizadas para os SELECTS *
DATA: gt_desafio2  TYPE TABLE OF ty_desafio2,
      gt_scarr     TYPE TABLE OF ty_scarr,
      gt_sbook_aux TYPE TABLE OF ty_sbook, "Auxiliar para fazer o tratamento das quantidades e dos valores
      gt_sbook     TYPE TABLE OF ty_sbook.

* Faço um SELECTION-SCREEN para por na tela as minhas seleções que vão ser utilizadas para filtrar os dados que vão ser pesquisados. *
SELECTION-SCREEN BEGIN OF BLOCK bc01 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS: s_carrid FOR sbook-carrid,
                  s_connid FOR sbook-connid.

SELECTION-SCREEN END OF BLOCK bc01.

* Faço um START-OF-SELECTION para chamar meu PERFORM de busca. *
START-OF-SELECTION.

  PERFORM zf_busca.

END-OF-SELECTION.

* Chamando os PERFORM's de tratamento e exibição. *
  PERFORM zf_tratamento.
  PERFORM zf_exibe.

* Faço meu formulário de busca (SELECTS) começar sempre do macro pro micro *
FORM zf_busca.

  SELECT carrid, connid, fldate, bookid, class, loccuram "SELECIONO esses atributos
    FROM sbook "DA tabela sbook
    INTO CORRESPONDING FIELDS OF TABLE @gt_sbook "EM CAMPOS CORRESPONDENTE DA TABELA gt_sbook
    WHERE carrid IN @s_carrid  "ONDE carrid está EM seleção s_carrid
    AND   connid IN @s_connid. "E connid está EM seleção s_connid

  IF sy-subrc IS INITIAL. "SE sy-subrc É INICIAL (está vazia = 0)

    SELECT carrid, carrname "SELECIONO esses atributos
      FROM scarr "DA tabela scarr
      INTO CORRESPONDING FIELDS OF TABLE @gt_scarr "EM CAMPOS CORRESPONDENTE DA TABELA gt_scarr
      FOR ALL ENTRIES IN @gt_sbook "PARA TODAS AS ENTRADAS EM gt_sbook
      WHERE carrid EQ @gt_sbook-carrid. "ONDE carrid IGUAL gt_sbook-carrid (chaves tem que ser iguais da tabela do for all entries)

    gt_sbook_aux = gt_sbook. "Atribuindo gt_sbook_aux IGUAL a gt_sbook

  ENDIF.

  PERFORM zf_ordenacao. "Chamo o PERFORM de ordenação.

ENDFORM.

* Faço meu formulário de ordenação (SORT) *
FORM zf_ordenacao.

  SORT: gt_sbook BY carrid ASCENDING connid ASCENDING fldate ASCENDING, "ORGANIZAR tabela gt_sbook POR chaves primárias em ordem CRESCENTE
        gt_sbook_aux BY carrid ASCENDING connid ASCENDING fldate ASCENDING, "ORGANIZAR tabela gt_sbook_aux POR chaves primárias em ordem CRESCENTE
        gt_scarr BY carrid ASCENDING. "ORGANIZAR tabela gt_scarr POR chaves primárias em ordem CRESCENTE (só ponho as chaves primárias que tem relação)

  DELETE ADJACENT DUPLICATES FROM gt_sbook COMPARING carrid connid fldate. "EXCLUIR DUPLICAÇÕES ADJACENTES DE gt_sbook COMPARANDO carrid, connid e fldate (sempre por chaves no DELETE, e não campos)

ENDFORM.

* Faço meu formulário de tratamento (LÓGICA) *
FORM zf_tratamento.

* Criação dos meus FIELD-SYMBOLS (SÍMBOLOS DE CAMPO)
  FIELD-SYMBOLS: <fs_desafio2>  TYPE ty_desafio2,
                 <fs_sbook>     TYPE ty_sbook,
                 <fs_sbook_aux> TYPE ty_sbook,
                 <fs_scarr>     TYPE ty_scarr.

  LOOP AT gt_sbook ASSIGNING <fs_sbook> WHERE fldate LE sy-datum.  "LAÇO EM gt_sbook ATRIBUINDO fs_sbook ONDE fldate é MENOR OU IGUAL a data atual (do macro pro micro)

    APPEND INITIAL LINE TO gt_desafio2 ASSIGNING <fs_desafio2>. "ANEXAR LINHA INICIAL A tabela gt_desafio2 ATRIBUINDO fs_desafio2
    <fs_desafio2>-connid = <fs_sbook>-connid. "Simbolo de campo_desafio2-connid IGUAL simbolo de campo_sbook-connid (É O QUE EU TENHO NA TABELA SBOOK E QUERO EXIBIR NA TELA)
    <fs_desafio2>-fldate = <fs_sbook>-fldate. "Simbolo de campo_desafio2-fldate IGUAL simbolo de campo_sbook-fldate (É O QUE EU TENHO NA TABELA SBOOK E QUERO EXIBIR NA TELA)

    READ TABLE gt_scarr ASSIGNING <fs_scarr> WITH KEY carrid = <fs_sbook>-carrid BINARY SEARCH. "LER TABELA gt_scarr ATRIBUINDO fs_scarr COM CHAVE carrid = fs_sbook-carrid BUSCA BINÁRIA
    IF sy-subrc IS INITIAL. "SE sy-subrc É INICIAL (está vazia = 0)

      <fs_desafio2>-carrname = <fs_scarr>-carrname. "Simbolo de campo_desafio2-carrname IGUAL simbolo de campo_scarr-carrname (É O QUE EU TENHO NA TABELA SCARR E QUERO EXIBIR NA TELA)

    ENDIF.


    READ TABLE gt_sbook_aux TRANSPORTING NO FIELDS WITH KEY carrid = <fs_sbook>-carrid connid = <fs_sbook>-connid fldate = <fs_sbook>-fldate BINARY SEARCH. "LER TABELA gt_sbook_aux TRANSPORTANDO CAMPOS SEM CHAVE (chaves primárias) BUSCA BINÁRIA
    IF sy-subrc IS INITIAL. "SE sy-subrc É INICIAL (está vazia = 0)

      LOOP AT gt_sbook_aux FROM sy-tabix ASSIGNING <fs_sbook_aux>.  "LAÇO EM gt_sbook_aux DE sy-tabix (cada iteração, indicando a linha atual) ATRIBUINDO fs_sbook_aux

        IF <fs_sbook_aux>-carrid NE <fs_sbook>-carrid "SE a chave de fs_sbook_aux-carrid NÃO FOR IGUAL a chave de fs_sbook-carrid
          OR "OU
          <fs_sbook_aux>-connid NE <fs_sbook>-connid "SE a chave de fs_sbook-aux-connid NÃO FOR IGUAL a chave de fs_sbook-carrid
          OR "OU
          <fs_sbook_aux>-fldate NE <fs_sbook>-fldate. "SE a chave de fs_sbook_aux-fldate NÃO FOR IGUAL a chave de fs_sbook-fldate

          EXIT. "SAÍDA do loop

        ENDIF.

        IF <fs_sbook_aux>-class EQ 'Y'. "SE fs_sbook_aux-class FOR IGUAL A 'Y'

          ADD 1 TO <fs_desafio2>-qtd_economica. "ADICIONAR 1 PARA fs_desafio2-qtd_economica
          ADD <fs_sbook_aux>-loccuram TO <fs_desafio2>-vlr_economica. "ADICIONAR fs_sbook_aux-loccuram PARA fs_desafio2-vlr_economica

        ELSEIF <fs_sbook_aux>-class EQ 'C'. "SENÃO SE fs_sbook_aux-class FOR IGUAL A 'C'

          ADD 1 TO <fs_desafio2>-qtd_executiva. "ADICIONAR 1 PARA fs_desafio2-qtd_executiva
          ADD <fs_sbook_aux>-loccuram TO <fs_desafio2>-vlr_executiva. "ADICIONAR fs_sbook_aux-loccuram PARA fs_desafio2-vlr_executiva

        ELSEIF <fs_sbook_aux>-class EQ 'F'. "SENÃO SE fs_sbook_aux-class FOR IGUAL A 'F'

          ADD 1 TO <fs_desafio2>-qtd_1classe. "ADICIONAR 1 PARA fs_desafio2-qtd_1classe
          ADD <fs_sbook_aux>-loccuram TO <fs_desafio2>-vlr_1classe. "ADICIONAR fs_sbook_aux-loccuram PARA fs_desafio2-vlr_1classe

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

ENDFORM.

* Faço meu formulário de exibição (MOSTRAR NA TELA)
FORM zf_exibe.
  DATA: lr_table     TYPE REF TO cl_salv_table,
        lr_functions TYPE REF TO cl_salv_functions,
        lr_columns   TYPE REF TO cl_salv_columns_table,
        lr_column    TYPE REF TO cl_salv_column.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lr_table
                              CHANGING  t_table      = gt_desafio2 ). "Aqui vai ser a minha tabela interna global principal

      lr_functions = lr_table->get_functions( ).
      lr_functions->set_all( abap_true ).

      lr_columns = lr_table->get_columns( ).
      lr_columns->set_optimize( abap_true ).

      lr_column ?= lr_columns->get_column( 'QTD_ECONOMICA' ).
      lr_column->set_short_text( 'Eco.' ).
      lr_column->set_medium_text( 'Qtd Econômica' ).
      lr_column->set_long_text( 'Quantidade Econômica' ).

      lr_column ?= lr_columns->get_column( 'VLR_ECONOMICA' ).
      lr_column->set_short_text( 'V. Eco.' ).
      lr_column->set_medium_text( 'Val. Econômica' ).
      lr_column->set_long_text( 'Valor total Econômica' ).

      lr_column ?= lr_columns->get_column( 'QTD_EXECUTIVA' ).
      lr_column->set_short_text( 'Exe.' ).
      lr_column->set_medium_text( 'Qtd Executiva' ).
      lr_column->set_long_text( 'Quantidade Executiva' ).

      lr_column ?= lr_columns->get_column( 'VLR_EXECUTIVA' ).
      lr_column->set_short_text( 'V. Exe.' ).
      lr_column->set_medium_text( 'Val. Executiva' ).
      lr_column->set_long_text( 'Valor total Executiva' ).

      lr_column ?= lr_columns->get_column( 'QTD_1CLASSE' ).
      lr_column->set_short_text( '1Cla.' ).
      lr_column->set_medium_text( 'Qtd 1° Classe' ).
      lr_column->set_long_text( 'Quantidade 1° Classe' ).

      lr_column ?= lr_columns->get_column( 'VLR_1CLASSE' ).
      lr_column->set_short_text( 'V. 1Cla.' ).
      lr_column->set_medium_text( 'Val. 1° Classe' ).
      lr_column->set_long_text( 'Valor total 1° Classe' ).

      lr_table->display( ).
    CATCH cx_salv_msg.
    CATCH cx_salv_not_found.
  ENDTRY.
ENDFORM.
