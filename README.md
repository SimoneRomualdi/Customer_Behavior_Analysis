# Customer Shopping Behavior — Analisi e Dashboard

## Executive Summary

- **Business Problem**: Un e-commerce ha bisogno di capire quali segmenti di clientela generano più valore, se gli sconti attraggono clienti di qualità e quali prodotti performano meglio per categoria.
- **Soluzione**: Pipeline end-to-end da Python (data cleaning) a PostgreSQL (analisi SQL) fino a Power BI (dashboard interattiva) su 3.900 transazioni reali.
- **Risultati**: Identificata una quota significativa di clienti scontati che supera comunque la spesa media globale; segmentazione clienti per storico acquisti; top 3 prodotti per categoria con ranking automatico.
- **Prossimi Passi**: Aggiungere cohort analysis per misurare retention nel tempo; arricchire il dataset con dati di ritorno prodotto per analisi di soddisfazione più completa.

---

## Business Problem

Un cliente di e-commerce lascia tracce in ogni acquisto: cosa compra, quanto spende, con che frequenza torna, se risponde agli sconti. Il dataset grezzo però non era analizzabile direttamente: colonne non uniformi, valori mancanti nelle recensioni, frequenze d'acquisto espresse come testo, e una colonna duplicata che avrebbe inquinato qualsiasi analisi sugli sconti.

---

## Metodologia

1. **Data Cleaning (Python / Pandas)** → Normalizzazione nomi colonne, imputazione missing values con mediana per categoria, rimozione colonna ridondante, feature engineering.
2. **Feature Engineering** → Creazione di `age_groups` (segmentazione età tramite quantili) e `purchase_frequency_days` (conversione frequenza testuale in giorni numerici).
3. **Database Setup (SQL)** → Caricamento del dataset pulito su PostgreSQL con schema DDL dedicato.
4. **Analisi SQL** → Query su segmentazione clienti, ranking prodotti, analisi revenue per fascia demografica e impatto degli sconti.
5. **Dashboard (Power BI)** → Visualizzazione KPI principali con filtri interattivi per categoria, genere e stato abbonamento.

---

## Competenze

- **Python**: Pandas, Jupyter Notebook, `pd.qcut()`, `groupby().transform()`, `map()`
- **SQL**: CTE, Window Functions (`ROW_NUMBER OVER PARTITION BY`, `SUM OVER`), Subquery, `CASE WHEN`, `ROUND` con cast esplicito
- **Power BI**: Dashboard interattiva, filtri dinamici, KPI cards

---

## Risultati & Raccomandazioni

- **Sconti e spesa**: I clienti scontati non spendono necessariamente meno — una quota rilevante supera la spesa media globale. Gli sconti sembrano attrarre clienti con alta propensione alla spesa, non solo cacciatori di offerte. **Raccomandazione**: mantenere la strategia di sconto ma monitorare il margine per segmento, non solo il volume.
- **Segmentazione clienti**: La maggior parte dei clienti rientra nella categoria "Fedele" (più di 10 acquisti precedenti). **Raccomandazione**: investire in programmi di loyalty per questo segmento che genera la quota maggiore di revenue.
- **Missing values**: I 37 valori mancanti in `Review Rating` sono stati imputati con la mediana per categoria merceologica — scelta più accurata rispetto a una mediana globale perché rispetta le distribuzioni di voto diverse tra categorie.

---

## Prossimi Passi

1. Aggiungere cohort analysis per misurare la retention mensile dei clienti nel tempo.
2. Integrare dati di ritorno prodotto per correlare recensioni basse con comportamenti di reso.
3. Costruire un modello di segmentazione RFM completo (Recency, Frequency, Monetary) per affinare il targeting.

---

## Dashboard

![Dashboard](Screenshot_Dashboard.png)

---

## Struttura della Repository

```
├── script_python/
│   └── Customer_Shopping_Analisi_Comportamento.ipynb   # Cleaning e feature engineering
├── scripts_sql/
│   ├── 00_DDL_Database_SQL.sql                          # Schema PostgreSQL
│   └── SQL_Queries.sql                                  # Query di analisi
└── README.md
```

**Stack**: Python · PostgreSQL · SQL · Power BI
