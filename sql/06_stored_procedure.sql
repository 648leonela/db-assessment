-- ============================================================================
--  EcoMarket Riwi S.A.S. — Stored routine (extra points)
--  Query clients: if it receives a client id -> returns that client;
--                 if it receives NULL       -> returns ALL clients.
--  Implemented as a set-returning function (the idiomatic Postgres approach).
-- ============================================================================

CREATE OR REPLACE FUNCTION eco_get_clients(p_client_id INTEGER DEFAULT NULL)
RETURNS TABLE (
    client_id     INTEGER,
    client_name   VARCHAR,
    total_orders  BIGINT,
    total_spent   NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT cl.client_id,
           cl.client_name,
           COUNT(DISTINCT o.order_id)                  AS total_orders,
           COALESCE(SUM(d.quantity * p.unit_price), 0) AS total_spent
    FROM   eco_client cl
    LEFT   JOIN eco_order        o ON o.client_id  = cl.client_id
    LEFT   JOIN eco_order_detail d ON d.order_id   = o.order_id
    LEFT   JOIN eco_product      p ON p.product_id = d.product_id
    WHERE  p_client_id IS NULL OR cl.client_id = p_client_id
    GROUP  BY cl.client_id, cl.client_name
    ORDER  BY cl.client_id;
END;
$$;

-- Usage examples:
--   SELECT * FROM eco_get_clients();      -- all clients
--   SELECT * FROM eco_get_clients(1);     -- only client with id = 1
