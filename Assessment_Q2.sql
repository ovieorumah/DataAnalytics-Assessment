WITH monthly_transactions AS (
    -- Count successful transactions per user per month
    SELECT
        sa.owner_id,
        DATE_FORMAT(sa.transaction_date, '%Y-%m') AS txn_month,
        COUNT(*) AS txn_count
    FROM savings_savingsaccount sa
    WHERE sa.transaction_status = 'success'
    GROUP BY sa.owner_id, txn_month
),
avg_txn_per_user AS (
    -- Calculate average transactions per user per month
    SELECT
        owner_id,
        AVG(txn_count) AS avg_txn_per_month
    FROM monthly_transactions
    GROUP BY owner_id
),
users_with_avg AS (
    -- Include all users, assign 0 for those without transactions
    SELECT
        u.id AS owner_id,
        COALESCE(a.avg_txn_per_month, 0) AS avg_txn_per_month
    FROM users_customuser u
    LEFT JOIN avg_txn_per_user a ON u.id = a.owner_id
),
categorized_users AS (
    -- Categorize users by frequency based on average transactions
    SELECT
        owner_id,
        avg_txn_per_month,
        CASE
            WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txn_per_month >= 3 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM users_with_avg
)
SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_txn_per_month), 1) AS avg_transactions_per_month
FROM categorized_users
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
