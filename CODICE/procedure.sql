CREATE OR REPLACE FUNCTION ordina_progetto(
  p_nome_cliente IN CLIENTE.NOME%TYPE,
  p_cognome_cliente IN CLIENTE.COGNOME%TYPE,
  p_email_cliente IN CLIENTE.EMAIL%TYPE,
  p_telefono_cliente IN CLIENTE.TELEFONO%TYPE,
  p_via_cliente IN CLIENTE.VIA%TYPE,
  p_citta_cliente IN CLIENTE.CITTA%TYPE,
  p_cap_cliente IN CLIENTE.CAP%TYPE,
  p_nome_progetto IN PROGETTO.NOME%TYPE
) RETURN NUMBER
IS
  v_id_cliente CLIENTE.IDCLIENTE%TYPE;
  v_id_ordine ORDINE.IDORDINE%TYPE;
  v_id_progetto PROGETTO.IDPROG%TYPE;
BEGIN
  -- Verifica se il cliente esiste già o se deve essere creato
  SELECT IDCLIENTE INTO v_id_cliente
  FROM CLIENTE
  WHERE NOME = p_nome_cliente
    AND COGNOME = p_cognome_cliente
    AND EMAIL = p_email_cliente
    AND TELEFONO = p_telefono_cliente
    AND VIA = p_via_cliente
    AND CITTA = p_citta_cliente
    AND CAP = p_cap_cliente;

  -- Se il cliente non esiste, crealo
  IF v_id_cliente IS NULL THEN
    INSERT INTO CLIENTE (IDCLIENTE, NOME, COGNOME, EMAIL, TELEFONO, VIA, CITTA, CAP)
    VALUES (SEQ_CLIENTE.NEXTVAL, p_nome_cliente, p_cognome_cliente, p_email_cliente, p_telefono_cliente, p_via_cliente, p_citta_cliente, p_cap_cliente);

    v_id_cliente := SEQ_CLIENTE.CURRVAL;
  END IF;

  -- Ottieni l'ID del progetto
  SELECT IDPROG INTO v_id_progetto
  FROM PROGETTO
  WHERE NOME = p_nome_progetto;

  -- Crea un nuovo ordine
  INSERT INTO ORDINE (IDORDINE, IDFATTURA, IDCLIENTE, IDSPEDIZIONE, NUMEROPRODOTTI, DATACREAZIONE)
  VALUES (SEQ_ORDINE.NEXTVAL, NULL, v_id_cliente, NULL, 0, SYSDATE);

  v_id_ordine := SEQ_ORDINE.CURRVAL;

  -- Aggiorna l'ordine con l'ID del progetto
  UPDATE ORDINE
  SET IDPROG = v_id_progetto
  WHERE IDORDINE = v_id_ordine;

  COMMIT;

  RETURN v_id_ordine;
END;
/
/*Questa funzione accetta come parametri i dettagli del cliente (nome, cognome, email, telefono, via, città, CAP) e il nome del progetto.
La funzione verifica se il cliente esiste già nella tabella "Cliente" in base alle informazioni fornite. Se il cliente non esiste, viene
creato un nuovo record nella tabella "Cliente". Successivamente, viene recuperato l'ID del progetto dalla tabella "Progetto". Infine,
viene creato un nuovo ordine nella tabella "Ordine" con i dettagli del cliente e l'ID del progetto. La funzione restituisce l'ID dell'ordine creato.*/






CREATE OR REPLACE FUNCTION cancella_progetto_ordine(
  p_id_ordine IN ORDINE.IDORDINE%TYPE,
  p_id_progetto IN PROGETTO.IDPROG%TYPE
) RETURN BOOLEAN
IS
  v_num_progetti NUMBER;
BEGIN
  -- Controlla il numero di progetti presenti nell'ordine
  SELECT COUNT(*)
  INTO v_num_progetti
  FROM ORDINE o
  JOIN PROGETTO p ON o.IDPROG = p.IDPROG
  WHERE o.IDORDINE = p_id_ordine;

  -- Verifica se l'ordine esiste e contiene più di due progetti
  IF v_num_progetti > 2 THEN
    -- Cancella il progetto dall'ordine
    DELETE FROM ORDINE
    WHERE IDORDINE = p_id_ordine
    AND IDPROG = p_id_progetto;

    COMMIT;
    
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END;
/
/*Questa funzione accetta l'ID dell'ordine e l'ID del progetto come parametri. Utilizza una query per contare il numero
di progetti presenti nell'ordine specificato. Se il numero di progetti è maggiore di due, viene eliminato il progetto 
specificato dall'ordine. Viene restituito il valore TRUE se il progetto viene cancellato con successo, altrimenti viene
restituito il valore FALSE.*/







CREATE OR REPLACE PROCEDURE inserisci_fornitura(
    IN_PARTITAIVAFORNITORE IN VARCHAR2,
    IN_EANCOMPONENTE IN VARCHAR2,
    IN_QUANTITA IN NUMBER,
    IN_DATAACQUISTO IN DATE
)
AS
    V_EXISTE_FORNITORE NUMBER;
    V_EXISTE_COMPONENTE NUMBER;
BEGIN
    -- Verifica se il fornitore esiste nella tabella FORNITORE
    SELECT COUNT(*) INTO V_EXISTE_FORNITORE
    FROM FORNITORE
    WHERE PARTITAIVA = IN_PARTITAIVAFORNITORE;

    IF V_EXISTE_FORNITORE = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Il fornitore specificato non esiste.');
    END IF;

    -- Verifica se il componente esiste nella tabella COMPONENTE
    SELECT COUNT(*) INTO V_EXISTE_COMPONENTE
    FROM COMPONENTE
    WHERE EAN = IN_EANCOMPONENTE;

    IF V_EXISTE_COMPONENTE = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Il componente specificato non esiste.');
    END IF;

    -- Inserisce la nuova riga nella tabella FORNITURA
    INSERT INTO FORNITURA (PARTITAIVAFORNITORE, EANCOMPONENTE, QUANTITA, DATAACQUISTO)
    VALUES (IN_PARTITAIVAFORNITORE, IN_EANCOMPONENTE, IN_QUANTITA, IN_DATAACQUISTO);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
     RAISE;
END;
/
/*Viene verificato se il fornitore esiste nella tabella "FORNITORE" contando il numero di righe corrispondenti 
alla partita IVA specificata. Se il contatore è uguale a zero, viene sollevato un errore con un messaggio appropriato.
Viene verificato se il componente esiste nella tabella "COMPONENTE" contando il numero di righe corrispondenti
al codice EAN specificato. Se il contatore è uguale a zero, viene sollevato un errore con un messaggio appropriato.
Viene eseguita un'istruzione di inserimento nella tabella "FORNITURA" con i valori passati come parametri.
Viene eseguito un commit per confermare la transazione.
In caso di errori durante l'esecuzione della procedura, viene eseguito un rollback per annullare la transazione
e viene sollevata un'eccezione per segnalare l'errore.
In sostanza, la procedura consente di inserire una nuova riga nella tabella "FORNITURA" dopo aver verificato che
il fornitore e il componente specificati esistano nelle rispettive tabelle.*/




 CREATE OR REPLACE FUNCTION stima_consegna_progetto(
    IN_IDCLIENTE IN NUMBER,
    IN_IDORDINE IN NUMBER,
    IN_IDPROGETTO IN NUMBER
) RETURN DATE
IS
    V_DATAINIZIO PROGETTO.DATAINIZIO%TYPE;
    V_STIMA_GIORNI ORDINE.NUMEROPRODOTTI%TYPE;
    V_CONSEGNA_EFFETTIVA DATE;
BEGIN
    -- Recupera la data di inizio del progetto
    SELECT DATAINIZIO INTO V_DATAINIZIO
    FROM PROGETTO
    WHERE IDPROG = IN_IDPROGETTO;

    -- Calcola la stima dei giorni di consegna in base al numero di prodotti nell'ordine
    SELECT NUMEROPRODOTTI INTO V_STIMA_GIORNI
    FROM ORDINE
    WHERE IDORDINE = IN_IDORDINE;

    -- Calcola la consegna effettiva aggiungendo la stima dei giorni alla data di inizio del progetto
    V_CONSEGNA_EFFETTIVA := V_DATAINIZIO + V_STIMA_GIORNI;

    RETURN V_CONSEGNA_EFFETTIVA;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/
/*La funzione STIMA_CONSEGNA_PROGETTO prende in input l'ID del cliente, l'ID dell'ordine e l'ID del progetto.
Recupera la data di inizio del progetto e calcola la stima dei giorni di consegna basata sul numero di prodotti
nell'ordine. Successivamente, calcola la data di consegna effettiva aggiungendo la stima dei giorni alla data
di inizio del progetto. Infine, restituisce la data di consegna effettiva.*/






