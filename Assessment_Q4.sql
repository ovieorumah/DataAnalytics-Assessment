SELECT
    u.id AS customer_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    -- Calculate how many full months the user has been active
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
    
    -- Total transaction volume in Naira
    ROUND(SUM(sa.confirmed_amount) / 100, 2) AS total_transactions,
    
    -- Estimate CLV: (monthly average txn) × 12 × profit per transaction (0.1%)
    ROUND(
        (SUM(sa.confirmed_amount) / 100) / 
        NULLIF(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 0) 
        * 12 * 0.001,
        2
    ) AS estimated_clv
FROM
    users_customuser u
JOIN
    savings_savingsaccount sa ON u.id = sa.owner_id
WHERE
    sa.confirmed_amount > 0
    and sa.transaction_status = 'success'
GROUP BY
    u.id, u.first_name, u.last_name, u.date_joined
ORDER BY
    estimated_clv DESC;
