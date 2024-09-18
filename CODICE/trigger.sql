--TRIGGER • Un progetto deve essere al più 15 giorni nei reparti di progettazione e produzione.
CREATE OR REPLACE TRIGGER controllo_durata_progetto
BEFORE INSERT OR UPDATE ON PROGETTO
FOR EACH ROW
DECLARE
    durata_progettazione NUMBER;
    durata_produzione NUMBER;
BEGIN
    -- Calcola la durata del progetto nei reparti di progettazione e produzione
    SELECT STIMATEMPO INTO durata_progettazione
    FROM PROGETTAZIONE
    WHERE IDPROG = :NEW.IDPROG;

    SELECT SUM(NMACCHINE) INTO durata_produzione
    FROM PRODUZIONE
    WHERE IDPROG = :NEW.IDPROG;

    -- Controlla se la durata supera i 15 giorni
    IF durata_progettazione + durata_produzione > 15 THEN
        RAISE_APPLICATION_ERROR(-20001, 'La durata del progetto nei reparti di progettazione e produzione supera i 15 giorni.');
    END IF;
END;
/
/*Il trigger viene eseguito prima di ogni operazione di inserimento o aggiornamento
sulla tabella "PROGETTO" (BEFORE INSERT OR UPDATE ON PROGETTO) per ogni riga coinvolta (FOR EACH ROW).
Nella sezione dichiarativa del trigger, vengono definiti due variabili: "durata_progettazione" e
"durata_produzione" di tipo NUMBER. Queste variabili verranno utilizzate per memorizzare la durata
del progetto nei reparti di progettazione e produzione.
Nella sezione esecutiva del trigger, vengono effettuate due query per recuperare 
le informazioni sulla durata del progetto. La prima query utilizza la tabella "PROGETTAZIONE"
per ottenere il valore della colonna "STIMATEMPO" corrispondente all'IDPROG del nuovo progetto 
che viene inserito o aggiornato. La seconda query utilizza la tabella "PRODUZIONE" per calcolare la somma della
colonna "NMACCHINE" corrispondente all'IDPROG del nuovo progetto.
successivamente, viene effettuato un controllo sulla durata totale del progetto sommando
la durata di progettazione e produzione. Se questa durata supera i 15 giorni, viene generato
un errore utilizzando la procedura RAISE_APPLICATION_ERROR. L'errore ha un codice (-20001) e un
 messaggio associato ("La durata del progetto nei reparti di progettazione e produzione supera i 15 giorni.").*/


















 --TRIGGER: • I dipendenti specializzati non possono lavorare pi`u di 8 ore al giorno.
CREATE OR REPLACE TRIGGER controllo_ore_giornaliere
BEFORE INSERT OR UPDATE ON TURNO
FOR EACH ROW
DECLARE
    tipo_dipendente VARCHAR2(20);
    ore_lavorate NUMBER;
BEGIN
    -- Ottieni il tipo di dipendente dal dipendente associato al turno
    SELECT TIPODIPENDENTE INTO tipo_dipendente
    FROM DIPENDENTE
    WHERE IDDIPENDENTE = :NEW.IDDIPENDENTE;

    -- Calcola il numero di ore lavorate nel turno corrente
    ore_lavorate := (:NEW.ORAFINE - :NEW.ORAINIZIO) * 24;

    -- Controlla se il dipendente è specializzato e ha superato le 8 ore giornaliere
    IF tipo_dipendente = 'Specializzato' AND ore_lavorate > 8 THEN
        RAISE_APPLICATION_ERROR(-20001, 'I dipendenti specializzati non possono lavorare più di 8 ore al giorno.');
    END IF;
END;
/
/*Questo trigger viene attivato prima di ogni operazione di inserimento o aggiornamento
sulla tabella "TURNO" e per ogni riga coinvolta (FOR EACH ROW).
All'interno del trigger, viene recuperato il tipo di dipendente associato al turno tramite
una query sulla tabella "DIPENDENTE". Successivamente, viene calcolato il numero di ore
lavorate nel turno corrente sottraendo l'orario di inizio dall'orario di fine del turno e moltiplicando per 24.
Infine, viene effettuato il controllo se il dipendente è specializzato e ha superato le 8
ore giornaliere. In caso affermativo, viene generato un errore tramite la procedura RAISE_APPLICATION_ERROR.*/


















--TRIGGER: • Un fornitore non deve impiegare più di 2 giorni nel consegnare la merce.
CREATE OR REPLACE TRIGGER controllo_tempi_consegna
BEFORE INSERT OR UPDATE ON FORNITURA
FOR EACH ROW
DECLARE
    giorni_diff NUMBER;
BEGIN
    -- Calcola la differenza di giorni tra la data di inserimento della fornitura e la data corrente
    giorni_diff := TRUNC(SYSDATE) - TRUNC(:NEW.DATAINSERIMENTO);

    -- Controlla se la differenza di giorni supera 2
    IF giorni_diff > 2 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Il fornitore non può impiegare più di 2 giorni nel consegnare la merce.');
    END IF;
END;
/
/*Il trigger viene eseguito prima di ogni operazione di inserimento o aggiornamento sulla tabella "Fornitura"
(BEFORE INSERT OR UPDATE ON FORNITURA).
Per ogni riga coinvolta nell'operazione (FOR EACH ROW), vengono eseguite le istruzioni all'interno del blocco PL/SQL.
Viene dichiarata una variabile "giorni_diff" di tipo NUMBER per memorizzare la differenza di giorni tra la data
di inserimento della fornitura e la data corrente.
Viene calcolata la differenza di giorni utilizzando la funzione TRUNC per ottenere solo la parte della data senza l'orario.
Si verifica se la differenza di giorni (giorni_diff) supera il limite di 2 giorni.
Se la condizione è verificata, viene generato un errore tramite la procedura RAISE_APPLICATION_ERROR
con il codice di errore -20001 e il messaggio di errore specificato ('Il fornitore non può impiegare
più di 2 giorni nel consegnare la merce.').
Il trigger viene compilato e creato o sostituito se già esistente nella base di dati.*/














--TRIGGER: Il prezzo di un progetto `e determinato dal prezzo dei singoli componenti elettronici coinvolti
--più una percentuale del 200%
CREATE OR REPLACE TRIGGER calcola_prezzo_progetto
BEFORE INSERT OR UPDATE ON COMPONENTIPROGETTO
FOR EACH ROW
DECLARE
  prezzo_componenti NUMBER;
BEGIN
  -- Calcola il prezzo totale dei componenti del progetto
  SELECT SUM(COMPONENTE.PREZZO * COMPONENTIPROGETTO.QUANTITA)
  INTO prezzo_componenti
  FROM COMPONENTE
  INNER JOIN COMPONENTIPROGETTO ON COMPONENTE.EAN = COMPONENTIPROGETTO.EAN
  WHERE COMPONENTIPROGETTO.IDPROG = :NEW.IDPROG;
  
  -- Calcola il nuovo prezzo del progetto
  :NEW.PREZZO := prezzo_componenti + (prezzo_componenti * 2); -- Aggiunge il 200%
END;
/
/*Quando viene inserita o aggiornata una riga nella tabella COMPONENTIPROGETTO, il trigger viene attivato.
Viene dichiarata una variabile prezzo_componenti di tipo NUMBER per memorizzare il prezzo totale dei componenti del progetto.
Viene eseguita una query che calcola la somma del prezzo dei componenti (COMPONENTE.PREZZO)
moltiplicato per la quantità (COMPONENTIPROGETTO.QUANTITA) di ciascun componente coinvolto nel progetto.
La query utilizza una clausola JOIN per collegare la tabella COMPONENTE alla tabella COMPONENTIPROGETTO
utilizzando la corrispondenza tra le colonne EAN.
Il risultato della query viene memorizzato nella variabile prezzo_componenti.
Viene calcolato il nuovo prezzo del progetto assegnando a :NEW.PREZZO il valore di prezzo_componenti
incrementato del 200% (moltiplicando per 2).
Il trigger viene completato e l'inserimento o l'aggiornamento nella tabella COMPONENTIPROGETTO può procedere.*/















--TRIGGER: In magazzino si verifica lo spazio residuo tramite la differenza tra i componenti gi`a immagazzinati e lo spazio totale.
CREATE OR REPLACE TRIGGER verifica_spazio_magazzino
AFTER INSERT OR UPDATE OR DELETE ON IMMAGAZZINAMENTO
FOR EACH ROW
DECLARE
  spazio_totale NUMBER;
  spazio_utilizzato NUMBER;
  spazio_residuo NUMBER;
BEGIN
  -- Calcola lo spazio totale disponibile nel magazzino
  SELECT SPAZIOTOT INTO spazio_totale FROM MAGAZZINO WHERE IDREPARTO = :NEW.IDREPARTO;
  
  -- Calcola lo spazio utilizzato nel magazzino
  SELECT SUM(QUANTITA) INTO spazio_utilizzato FROM IMMAGAZZINAMENTO WHERE IDREPARTO = :NEW.IDREPARTO;
  
  -- Calcola lo spazio residuo nel magazzino
  spazio_residuo := spazio_totale - spazio_utilizzato;
  
  -- Aggiorna il valore dello spazio residuo nel magazzino
  UPDATE MAGAZZINO SET SPAZIOTOT = spazio_residuo WHERE IDREPARTO = :NEW.IDREPARTO;
END;
/
/*Il trigger verifica_spazio_magazzino viene attivato dopo l'inserimento, l'aggiornamento o la cancellazione di una riga nella tabella IMMAGAZZINAMENTO.
Vengono dichiarate le variabili spazio_totale, spazio_utilizzato e spazio_residuo di tipo NUMBER per memorizzare rispettivamente lo spazio totale disponibile nel magazzino, lo spazio utilizzato attualmente e lo spazio residuo.
Viene eseguita una query per recuperare lo spazio totale disponibile nel magazzino dalla tabella MAGAZZINO in base all'IDREPARTO specificato nella riga inserita o aggiornata nella tabella IMMAGAZZINAMENTO.
Viene eseguita una query per calcolare lo spazio utilizzato nel magazzino sommando la quantità di tutti i componenti immagazzinati nella tabella IMMAGAZZINAMENTO per l'IDREPARTO specificato.
Viene calcolato lo spazio residuo sottraendo lo spazio utilizzato dallo spazio totale.
Viene eseguita un'istruzione di aggiornamento per aggiornare il valore dello spazio residuo nella tabella MAGAZZINO per l'IDREPARTO specificato.
Il trigger viene completato e l'operazione di inserimento, aggiornamento o cancellazione può procedere.*/













--TRIGGER: Un ordine da parte di un cliente può essere cancellato al più dopo 5 ore.
CREATE OR REPLACE TRIGGER cancella_ordine
AFTER INSERT ON ORDINE
FOR EACH ROW
DECLARE
  v_ordine_id ORDINE.IDORDINE%TYPE;
BEGIN
  -- Ottieni l'ID dell'ordine appena inserito
  v_ordine_id := :new.IDORDINE;

  -- Crea un job per la cancellazione dell'ordine dopo 5 ore
  DBMS_SCHEDULER.CREATE_JOB(
    job_name        => 'CANCELLA_ORDINE_' || v_ordine_id,
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN
                          DELETE FROM ORDINE
                          WHERE IDORDINE = ' || v_ordine_id || ';
                        END;',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'freq=hourly; interval=5',
    enabled         => TRUE,
    auto_drop       => TRUE
  );
END;
/
/*La clausola AFTER INSERT ON ORDINE indica che il trigger verrà eseguito dopo l'inserimento di una riga nella tabella ORDINE.
Il trigger è dichiarato come FOR EACH ROW, il che significa che il trigger viene eseguito una volta
 per ogni riga inserita nella tabella ORDINE.
La variabile v_ordine_id viene dichiarata con il tipo di dato corrispondente alla colonna IDORDINE
della tabella ORDINE. Questa variabile conterrà l'ID dell'ordine appena inserito.
Successivamente, il codice ottiene l'ID dell'ordine appena inserito assegnando il valore della colonna
IDORDINE della riga appena inserita alla variabile v_ordine_id utilizzando :new.IDORDINE. La sintassi :new si riferisce alla riga appena inserita.
Viene creato un job utilizzando DBMS_SCHEDULER.CREATE_JOB. Un job è un'attività pianificata che verrà
eseguita in un momento specifico o in base a una pianificazione predefinita. In questo caso, viene creato un job per cancellare l'ordine dopo 5 ore.
Il job viene denominato 'CANCELLA_ORDINE_' || v_ordine_id per renderlo univoco per ogni ordine.
Ad esempio, se l'ID dell'ordine è 1, il nome del job sarà 'CANCELLA_ORDINE_1'.
Il tipo di job viene impostato su 'PLSQL_BLOCK', che significa che il job eseguirà un blocco di codice PL/SQL.
Il blocco PL/SQL specificato come job_action contiene l'istruzione DELETE per cancellare l'ordine
corrispondente utilizzando l'ID dell'ordine appena inserito (WHERE IDORDINE = ' || v_ordine_id || ';').
La data di inizio del job viene impostata su SYSTIMESTAMP, il che significa che il job inizierà
immediatamente dopo la creazione del trigger.
La frequenza di ripetizione del job viene impostata su 'freq=hourly; interval=5', il che significa
che il job verrà ripetuto ogni 5 ore.
Il job viene abilitato (enabled => TRUE) in modo che venga eseguito secondo la pianificazione specificata.
auto_drop => TRUE indica che il job verrà eliminato automaticamente dopo l'esecuzione.
*/











--SCHEDULER:
BEGIN
  DBMS_SCHEDULER.CREATE_JOB(
    job_name        => 'CANCELLA_ORDINE',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN
                          DELETE FROM ORDINE
                          WHERE IDORDINE = :order_id;
                        END;',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'freq=hourly; interval=5',
    enabled         => TRUE,
    auto_drop       => TRUE
  );
END;
/
/*DBMS_SCHEDULER.CREATE_JOB: Questa procedura crea un nuovo job scheduler con i parametri specificati.
job_name: Specifica il nome del job. In questo caso, il nome del job è "CANCELLA_ORDINE".
job_type: Specifica il tipo di job come "PLSQL_BLOCK". Indica che il job eseguirà un blocco di codice PL/SQL.
job_action: Questa è l'azione del job, ovvero il blocco di codice PL/SQL da eseguire.
Nel caso specifico, il blocco di codice esegue una query di eliminazione che cancella
l'ordine dalla tabella ORDINE in base all'ID dell'ordine fornito come parametro :order_id.
Nota che :order_id è un segnaposto che dovrebbe essere sostituito con il valore effettivo dell'ID dell'ordine da cancellare.
start_date: Specifica la data di inizio del job. In questo caso, viene utilizzata la funzione
SYSTIMESTAMP per impostare la data di inizio al momento corrente.
repeat_interval: Specifica l'intervallo di ripetizione del job. In questo caso,
l'intervallo è impostato su "freq=hourly; interval=5", il che significa che il job verrà eseguito ogni 5 ore.
enabled: Specifica se il job è abilitato o meno. Nel caso specifico, è impostato su TRUE,
quindi il job sarà abilitato dopo la sua creazione.
auto_drop: Specifica se il job verrà eliminato automaticamente dopo l'esecuzione.
In questo caso, è impostato su TRUE, quindi il job verrà eliminato automaticamente dopo aver eseguito la cancellazione dell'ordine.*/


