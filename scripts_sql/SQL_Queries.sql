-- ============================================================
--  ANALISI COMPORTAMENTO CLIENTI
--  Dataset: customer_behavior
--  Descrizione: Query di analisi su vendite, prodotti, clienti
--               e segmentazione per età, genere e abbonamento.
-- ============================================================


-- ============================================================
-- 1. TOTALE VENDITE PER GENERE
--    Confronto del revenue totale generato da clienti
--    maschili e femminili.
-- ============================================================
SELECT
    gender,
    SUM(purchase_amount_usd) AS revenue
FROM
    customer_behavior
GROUP BY
    gender
ORDER BY
    revenue DESC;


-- ============================================================
-- 2. CLIENTI CON SCONTO CHE HANNO SPESO PIÙ DELLA MEDIA
--    Identifica i clienti che hanno usufruito dello sconto
--    ma hanno comunque superato la spesa media globale.
--    La subquery calcola la media generale come soglia.
-- ============================================================
SELECT
    customer_id,
    purchase_amount_usd
FROM
    customer_behavior
WHERE
    discount_applied = 'Yes'
    AND purchase_amount_usd >= (
        SELECT
            AVG(purchase_amount_usd)
        FROM
            customer_behavior
    );


-- ============================================================
-- 3. TOP 5 PRODOTTI PER MEDIA RECENSIONI
--    I 5 prodotti con la valutazione media più alta.
--    Cast a NUMERIC necessario perché ROUND() in PostgreSQL
--    non accetta direttamente il tipo DOUBLE PRECISION
--    restituito da AVG().
-- ============================================================
SELECT
    item_purchased,
    ROUND(AVG(review_rating)::NUMERIC, 2) AS avg_review
FROM
    customer_behavior
GROUP BY
    item_purchased
ORDER BY
    avg_review DESC
LIMIT 5;


-- ============================================================
-- 4. COMPARAZIONE SPESA MEDIA: SPEDIZIONE STANDARD VS EXPRESS
--    Confronta la spesa media degli ordini in base al tipo
--    di spedizione scelto dal cliente.
-- ============================================================
SELECT
    shipping_type,
    ROUND(AVG(purchase_amount_usd), 2) AS avg_acquisto
FROM
    customer_behavior
WHERE
    shipping_type IN ('Standard', 'Express')
GROUP BY
    shipping_type
ORDER BY
    avg_acquisto DESC;


-- ============================================================
-- 5. GLI ABBONATI SPENDONO DI PIÙ?
--    Confronto tra abbonati e non abbonati su:
--    numero totale di clienti, spesa media e spesa totale.
-- ============================================================
SELECT
    subscription_status,
    COUNT(customer_id) AS totale_clienti,
    ROUND(AVG(purchase_amount_usd), 2) AS avg_acquisto,
    SUM(purchase_amount_usd) AS totale_acquisto
FROM
    customer_behavior
GROUP BY
    subscription_status
ORDER BY
    avg_acquisto,
    totale_acquisto DESC;


-- ============================================================
-- 6. TOP 5 PRODOTTI PER PERCENTUALE DI SCONTO APPLICATO
--    Per ogni prodotto calcola la % di acquisti in cui è stato applicato uno sconto.
--    CASE WHEN conta gli acquisti scontati (1) vs non (0).
--    Moltiplichiamo per 100 prima della divisione per evitare che la divisione intera tronchi il risultato a 0.
-- ============================================================
SELECT
    item_purchased,
    ROUND(
        100 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*)::NUMERIC,
        2
    ) AS perc_sconto_applicato
FROM
    customer_behavior
GROUP BY
    item_purchased
ORDER BY
    perc_sconto_applicato DESC
LIMIT 5;


-- ============================================================
-- 7. SEGMENTAZIONE CLIENTI IN BASE AGLI ACQUISTI PRECEDENTI
--    I clienti vengono classificati in tre gruppi:
--      - Nuovo      → 1 acquisto precedente
--      - Di Ritorno → da 2 a 10 acquisti precedenti
--      - Fedele     → più di 10 acquisti precedenti
-- ============================================================
WITH customer_type AS (
    SELECT
        customer_id,
        previous_purchases,
        CASE
            WHEN previous_purchases = 1 THEN 'Nuovo'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Di Ritorno'
            ELSE 'Fedele'
        END AS gruppo_cliente
    FROM
        customer_behavior
)
SELECT
    gruppo_cliente,
    COUNT(*) AS conteggio
FROM
    customer_type
GROUP BY
    gruppo_cliente
ORDER BY
    conteggio DESC;


-- ============================================================
-- 8. TOP 3 PRODOTTI PIÙ ACQUISTATI PER OGNI CATEGORIA
--    ROW_NUMBER() assegna un rank per ogni categoria
--    (PARTITION BY category) ordinando dal prodotto più acquistato al meno. Il filtro WHERE rank <= 3 seleziona solo i primi 3 per ciascuna categoria.
-- ============================================================

WITH conteggio_prodotti AS (
    SELECT
        item_purchased,
        category,
        COUNT(customer_id) AS acquisti,
        ROW_NUMBER() OVER(
            PARTITION BY category ORDER BY COUNT(customer_id) DESC
        ) AS rank_prodotti
    FROM
        customer_behavior
    GROUP BY
        category,
        item_purchased
)

SELECT
    rank_prodotti,
    item_purchased,
    category,
    acquisti
FROM
    conteggio_prodotti
WHERE
    rank_prodotti <= 3;


-- ============================================================
-- 9. I CLIENTI CON PIÙ DI 5 ACQUISTI SONO ABBONATI?
--    Filtra i clienti con più di 5 acquisti precedenti
--    e li raggruppa per stato abbonamento.
-- ============================================================
SELECT
    subscription_status,
    COUNT(customer_id) AS clienti
FROM
    customer_behavior
WHERE
    previous_purchases > 5
GROUP BY
    subscription_status;


-- ============================================================
-- 10. CONTRIBUTO IN PROFITTO PER GRUPPO D'ETÀ
--     Calcola la spesa totale e la % sul totale globale per ogni fascia d'età.
--     La window function SUM(SUM(...)) OVER() somma tutti i subtotali di GROUP BY per ottenere il grand total, usato poi come denominatore per la percentuale.
-- ============================================================
SELECT
    age_groups,
    SUM(purchase_amount_usd) AS totale_spese,
    ROUND(
        100.0 * SUM(purchase_amount_usd)
        / SUM(SUM(purchase_amount_usd)) OVER(),
        2
    ) AS perc_contributo
FROM
    customer_behavior
GROUP BY
    age_groups
ORDER BY
    totale_spese DESC;