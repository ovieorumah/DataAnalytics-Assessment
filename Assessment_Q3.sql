SELECT
    p.id AS plan_id,
    p.owner_id,
    -- Categorize plan type
    CASE 
        WHEN p.is_regular_savings = 1 THEN 'savings'
        WHEN p.is_a_fund = 1 THEN 'investment'
        ELSE 'other'
    END AS type,
    -- Most recent inflow transaction date (if any)
    MAX(CASE WHEN sa.transaction_status = 'success' AND sa.confirmed_amount > 0 THEN sa.transaction_date END) AS last_transaction_date,
    -- Days since last transaction (if any)
    DATEDIFF(
        CURDATE(),
        MAX(CASE WHEN sa.transaction_status = 'success' AND sa.confirmed_amount > 0 THEN sa.transaction_date END)
    ) AS inactivity_days
FROM
    plans_plan p
LEFT JOIN
    savings_savingsaccount sa
    ON p.id = sa.plan_id
WHERE
    (p.is_regular_savings = 1 OR p.is_a_fund = 1)
    AND p.is_archived = 0
    AND p.is_deleted = 0
GROUP BY
    p.id, p.owner_id, type
HAVING
    last_transaction_date IS NULL OR inactivity_days > 365;
;
