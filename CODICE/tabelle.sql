CREATE TABLE CLIENTE (
  IDCLIENTE NUMBER,
  NOME VARCHAR2(30) NOT NULL,
  COGNOME VARCHAR2(30) NOT NULL,
  EMAIL VARCHAR2(30) NOT NULL,
  TELEFONO NUMBER NOT NULL,
  VIA VARCHAR2(30) NOT NULL,
  CITTA VARCHAR2(30) NOT NULL,
  CAP NUMBER NOT NULL
  PRIMARY KEY (IDCLIENTE),
  CONSTRAINT UK_EMAIL UNIQUE (EMAIL),
  CONSTRAINT UK_TELEFONO UNIQUE (TELEFONO)
);

CREATE TABLE FATTURA (
  IDFATTURA NUMBER,
  DATAEMISSIONE DATE,
  TOTALE NUMBER NOT NULL,
  PRIMARY KEY (IDFATTURA)
);

CREATE TABLE SPEDIZIONE (
  IDSPEDIZIONE NUMBER PRIMARY KEY,
  TEL NUMBER NOT NULL,
  NOME VARCHAR2(30) NOT NULL,
  VIA VARCHAR2(30) NOT NULL,
  CITTA VARCHAR2(30) NOT NULL,
  CAP NUMBER NOT NULL
);

CREATE TABLE ORDINE (
  IDORDINE NUMBER NOT NULL,
  IDFATTURA NUMBER NOT NULL,
  IDCLIENTE NUMBER NOT NULL,
  IDSPEDIZIONE NUMBER NOT NULL,
  NUMEROPRODOTTI NUMBER NOT NULL,
  DATACREAZIONE DATE NOT NULL,
  PRIMARY KEY (IDORDINE),
  CONSTRAINT FK_ORDINE_FATTURA FOREIGN KEY (IDFATTURA) REFERENCES FATTURA(IDFATTURA),
  CONSTRAINT FK_ORDINE_CLIENTE FOREIGN KEY (IDCLIENTE) REFERENCES CLIENTE(IDCLIENTE),
  CONSTRAINT FK_ORDINE_SPEDIZIONE FOREIGN KEY (IDSPEDIZIONE) REFERENCES SPEDIZIONE(IDSPEDIZIONE)
);

CREATE TABLE COMPONENTE (
  EAN NUMBER,
  NOME VARCHAR2(30) NOT NULL,
  PREZZO NUMBER NOT NULL,
  PRIMARY KEY (EAN)
);

CREATE TABLE PROGETTO (
  IDPROG NUMBER,
  NOME VARCHAR2(30) NOT NULL,
  DATAINIZIO DATE,
  PRIMARY KEY (IDPROG),
  UNIQUE (NOME)
);

CREATE TABLE COMPONENTIPROGETTO (   /* è  l'associazione "è composto" */
  IDPROG NUMBER,
  EAN NUMBER,
  QUANTITA NUMBER(2,0),
  FOREIGN KEY (IDPROG) REFERENCES PROGETTO (IDPROG),
  FOREIGN KEY (EAN) REFERENCES COMPONENTE (EAN)
);

CREATE TABLE CONTIENE (
  IDPROG NUMBER,
  IDORDINE NUMBER,
  QUANTITA NUMBER,
  FOREIGN KEY (IDPROG) REFERENCES PROGETTO(IDPROG),
  FOREIGN KEY (IDORDINE) REFERENCES ORDINE(IDORDINE)
);

CREATE TABLE FORNITORE (
  PARTITAIVA CHAR(11),
  VIA VARCHAR2(30),
  CIVICO NUMBER ,
  CAP NUMBER,
  TEL NUMBER,
  PRIMARY KEY (PARTITAIVA),
  UNIQUE (TEL)
);
 
CREATE TABLE FORNITURA (
  PARTITAIVAFORNITORE CHAR(11) PRIMARY KEY,
  QUANTITA NUMBER(2,0) NOT NULL,
  EAN NUMBER,
  CONSTRAINT FK_FORNITURA_ESTERNA1 FOREIGN KEY (PARTITAIVAFORNITORE)  REFERENCES FORNITORE (PARTITAIVA),
  CONSTRAINT FK_FORNITURA_ESTERNA2 FOREIGN KEY (EAN) REFERENCES COMPONENTE (EAN)
);

CREATE TABLE REPARTO (
  IDREPARTO NUMBER PRIMARY KEY,
  TELEFONO CHAR(10) UNIQUE,
  DIPENDENTIMAX NUMBER NOT NULL
);

CREATE TABLE PROGETTAZIONE (
  IDREPARTO NUMBER PRIMARY KEY,
  STATOPROTOTIPO NUMBER(1),
  STIMATEMPO NUMBER,/*numero di giorni*/
  STIMAEFFORT NUMBER,/*quanto personale serve*/
  IDPROG NUMBER,
  CONSTRAINT FK_PROGETTAZIONE_PROGETTO FOREIGN KEY (IDPROG) REFERENCES PROGETTO(IDPROG),
  FOREIGN KEY (IDREPARTO) REFERENCES REPARTO(IDREPARTO),
  UNIQUE (IDPROG)
);

CREATE TABLE PRODUZIONE (
  IDREPARTO NUMBER PRIMARY KEY,
  IDPROG NUMBER,
  STATO NUMBER(1),
  NMACCHINE NUMBER NOT NULL,
  CONSTRAINT FK_PRODUZIONE_PROGETTO FOREIGN KEY (IDPROG) REFERENCES PROGETTO(IDPROG),
  FOREIGN KEY (IDREPARTO) REFERENCES REPARTO(IDREPARTO),
  UNIQUE (IDPROG)
);

CREATE TABLE COLLAUDO (
  IDREPARTO NUMBER PRIMARY KEY,
  ESITO NUMBER(1,0),
  NMACCHINE NUMBER NOT NULL,
  IDPROG NUMBER,
  CONSTRAINT UK_IDPROG UNIQUE (IDPROG),
  FOREIGN KEY (IDPROG) REFERENCES PROGETTO(IDPROG),
  FOREIGN KEY (IDREPARTO) REFERENCES REPARTO(IDREPARTO)
);

CREATE TABLE MAGAZZINO (
  IDREPARTO NUMBER PRIMARY KEY,
  SPAZIOTOT NUMBER NOT NULL,
  FOREIGN KEY (IDREPARTO) REFERENCES REPARTO(IDREPARTO)
);

CREATE TABLE IMMAGAZZINAMENTO (
  IDLOTTO number NOT NULL,
  ORARIO DATE NOT NULL,
  DATAIMM DATE NOT NULL,
  QUANTITA NUMBER NOT NULL,
  PARTITAIVA CHAR(11) NOT NULL,
  IDREPARTO NUMBER NOT NULL,
  PRIMARY KEY (IDLOTTO),
  CONSTRAINT FK_IMMAGAZZINAMENTO1 FOREIGN KEY (PARTITAIVA) REFERENCES FORNITORE (PARTITAIVA),
  CONSTRAINT FK_IMMAGAZZINAMENTO3 FOREIGN KEY (IDREPARTO) REFERENCES MAGAZZINO (IDREPARTO)
);

CREATE TABLE DIPENDENTE (
  IDDIPENDENTE NUMBER PRIMARY KEY,
  NOME VARCHAR2(30) NOT NULL,
  COGNOME VARCHAR2(30) NOT NULL,
  RAL NUMBER NOT NULL,
  TIPODIPENDENTE VARCHAR(20) NOT NULL 
);

CREATE TABLE TURNO (
  IDDIPENDENTE NUMBER NOT NULL,
  IDREPARTO NUMBER NOT NULL,
  ORAINIZIO DATE NOT NULL,
  ORAFINE DATE,
  CONSTRAINT FK_TURNO_DIPENDENTE FOREIGN KEY (IDDIPENDENTE)
    REFERENCES DIPENDENTE (IDDIPENDENTE),
  CONSTRAINT FK_TURNO_REPARTO FOREIGN KEY (IDREPARTO)
    REFERENCES REPARTO (IDREPARTO)
);