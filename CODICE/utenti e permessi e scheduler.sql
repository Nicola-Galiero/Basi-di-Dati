--SCHEDULER
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
job_action: Questa è l'azione del job, ovvero il blocco di codice PL/SQL da eseguire. Nel caso specifico,
il blocco di codice esegue una query di eliminazione che cancella l'ordine dalla tabella ORDINE in base
all'ID dell'ordine fornito come parametro :order_id. Nota che :order_id è un segnaposto che dovrebbe essere
sostituito con il valore effettivo dell'ID dell'ordine da cancellare.
start_date: Specifica la data di inizio del job. In questo caso, viene utilizzata la funzione SYSTIMESTAMP
per impostare la data di inizio al momento corrente.
epeat_interval: Specifica l'intervallo di ripetizione del job. In questo caso, l'intervallo è impostato su
"freq=hourly; interval=5", il che significa che il job verrà eseguito ogni 5 ore.
enabled: Specifica se il job è abilitato o meno. Nel caso specifico, è impostato su TRUE, quindi il job sarà
abilitato dopo la sua creazione.
auto_drop: Specifica se il job verrà eliminato automaticamente dopo l'esecuzione. In questo caso,
è impostato su TRUE, quindi il job verrà eliminato automaticamente dopo aver eseguito la cancellazione dell'ordine.*/






--questi sono gli utenti che eseguono queste procedure
UTENTE                  TIPO               PERMESSI

db_fabbrica             amministratore     ALL

responsabile_DB            comune          UPDATE ON progettazione
                                                     produzione
                                           EXECUTE responsabile_aumenta_stato
                                           EXECUTE responsabile_inserisci_stime

cliente_DB                 comune          SELECT ON cliente
                                                     progetto
                                           INSERT ON cliente
                                                     ordine
                                           UPDATE ON ordine
 
                                           EXECUTE ordina_progetto
                                           EXECUTE cancella_progetto_ordine

fornitore_DB              comune           SELECT ON fornitore
                                           SELECT ON componente
                                           INSERT on fornitura

                                           EXECUTE inserisci_fornitura




                                     


--Creazione utenti 
CREATE USER proprietario_db_fabbrica    IDENTIFIED BY admin;
CREATE USER responsabile   IDENTIFIED BY responsabile;
CREATE USER cliente        IDENTIFIED BY cliente;
CREATE USER fornitore      IDENTIFIED BY fornitore;
 
--Do tutti i privilegi al proprietario del database
GRANT ALL PRIVILEGES TO proprietario_db_fabbrica;

/*Nel paragrafo DCL */
--CREATE USER proprietario_db_fabbrica    IDENTIFIED BY admin;

--CREATE USER responsabile_DB   IDENTIFIED BY pass_responsabile;
GRANT CONNECT, CREATE SESSION TO responsabile_DB;
GRANT UPDATE ON progettazione TO responsabile_DB;
GRANT UPDATE ON produzione TO responsabile_DB;
GRANT EXECUTE ON STIMA_CONSEGNA_PROGETTO TO responsabile_DB; 


--CREATE USER cliente_DB IDENTIFIED BY pass_cliente;
GRANT SELECT ON cliente TO cliente_DB;
GRANT SELECT ON progetto TO cliente_DB;
GRANT INSERT ON cliente TO cliente_DB;
GRANT INSERT ON ordine TO cliente_DB;
GRANT UPDATE ON ordine TO cliente_DB;
GRANT EXECUTE ON ordina_progetto TO cliente_DB;
GRANT EXECUTE ON cancella_progetto_ordine TO cliente_DB;


--CREATE USER fornitore_DB IDENTIFIED BY pass_fornitore;
GRANT CONNECT, CREATE SESSION TO fornitore_DB;
GRANT SELECT ON fornitore TO fornitore_DB;
GRANT SELECT ON componente TO fornitore_DB;
GRANT INSERT ON fornitura TO fornitore_DB;
GRANT EXECUTE ON inserisci_fornitura TO fornitore_DB;

