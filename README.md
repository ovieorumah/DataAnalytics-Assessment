# Data Analytics Assessment

## General Note: Kobo to Naira Conversion
All monetary values in the database are stored in **kobo**. To convert to **Naira**, values were divided by 100 and rounded where appropriate.

---

## 1. High-Value Customers with Multiple Products  
**Objective:**  
Identify users who have both a funded savings and investment plan, and rank them by total deposit value.

**Approach:**
- Used conditional aggregation to count funded savings (`is_regular_savings = 1` and `amount > 0`) and investment plans (`is_a_fund = 1` and `amount > 0`) per user.
- Filtered only confirmed and successful savings account transactions.
- Retained users who have at least one of both product types.
- Ranked users by total deposit value to highlight high-value clients.

---

## 2. Transaction Frequency Analysis  
**Objective:**  
Segment customers based on how frequently they transact per month.

**Approach:**
- Counted successful transactions per user per month.
- Averaged transaction count per user across all active months.
- Categorized users into:
  - **High Frequency:** ≥ 10 transactions/month
  - **Medium Frequency:** 3–9 transactions/month
  - **Low Frequency:** ≤ 2 transactions/month
- Aggregated user counts and average frequencies per segment.

---

## 3. Account Inactivity Alert  
**Objective:**  
Identify active plans (savings or investment) with no inflows for over a year.

**Approach:**
- Focused on plans that are **not archived** and **not deleted** (`is_archived = 0`, `is_deleted = 0`).
- Joined transactions to plans, filtering only for successful inflows.
- Identified latest transaction date per plan.
- Flagged plans with either no transaction history or inactivity for over 365 days.

---

## 4. Customer Lifetime Value (CLV) Estimation  
**Objective:**  
Estimate each customer’s CLV using transaction volume and account tenure.

**Approach:**
- Calculated account tenure in months using the user’s signup date.
- Summed all confirmed and successful inflow transactions.
- Applied CLV formula:
Assumes **0.1%** profit per transaction.
- Sorted customers by descending CLV to help prioritize marketing outreach.

---

## Challenges Faced

**Defining Active Plans:**  
There were three potential indicators of active plans: `status_id`, `is_deleted`, and `is_archived`.  
Initially relied on `status_id = 1`, but some plans marked as deleted also had this status.  
Ultimately resolved by using `is_deleted = 0` and `is_archived = 0` as the definitive criteria for plan activity.


