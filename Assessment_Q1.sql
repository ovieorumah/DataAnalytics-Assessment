SELECT
    u.id AS owner_id,
    -- Format the customer's full name with first letter uppercase and rest lowercase
    CONCAT(
        UPPER(LEFT(u.first_name, 1)), LOWER(SUBSTRING(u.first_name, 2)), ' ',
        UPPER(LEFT(u.last_name, 1)), LOWER(SUBSTRING(u.last_name, 2))
    ) AS name,

    -- Count of funded regular savings plans per user (or 0 if none)
    COALESCE(plans.savings_count, 0) AS savings_count,

    -- Count of funded investment plans (funds) per user (or 0 if none)
    COALESCE(plans.investment_count, 0) AS investment_count,

    -- Total deposits stored in kobo converted to main currency unit (Naira)
    ROUND(COALESCE(deposits.total_deposits, 0) / 100.0, 2) AS total_deposits

FROM users_customuser u

-- Subquery to get counts of savings and investment plans per user
LEFT JOIN (
    SELECT
        owner_id,
        -- Count savings plans: plans marked as regular savings with positive amount - showing funded
        COUNT(CASE WHEN is_regular_savings = 1 AND amount > 0 THEN 1 END) AS savings_count,

        -- Count investment plans: plans marked as funds with positive amount - showing funded
        COUNT(CASE WHEN is_a_fund = 1 AND amount > 0 THEN 1 END) AS investment_count
    FROM plans_plan
    where is_archived = 0
    AND is_deleted = 0
    GROUP BY owner_id
) plans ON u.id = plans.owner_id

-- Subquery to sum deposits from savings_savingsaccount for each user
LEFT JOIN (
    SELECT
        owner_id,
        -- Sum of confirmed deposit amounts (only successful transactions), amounts are in kobo
        SUM(confirmed_amount) AS total_deposits
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0
      AND transaction_status = 'success'
    GROUP BY owner_id
) deposits ON u.id = deposits.owner_id

-- Filter to only include users who have at least one savings plan AND one investment plan
WHERE
    COALESCE(plans.savings_count, 0) > 0
    AND COALESCE(plans.investment_count, 0) > 0

-- Sort users by total deposits in descending order to prioritize highest value customers
ORDER BY total_deposits DESC;
