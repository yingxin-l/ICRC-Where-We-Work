# ICRC "Where We Work" Database Design Project

A relational database design for the International Committee of the Red Cross's public "Where We Work" webpage. This project includes three alternative ERD designs, SQL scripts with complex queries, and a full normalization analysis.

**Technologies used:** MySQL/PostgreSQL-compatible SQL, JSON data types, Mermaid for ERD visualization

---

## Key Highlights

### ERD & Data Relationship Design

The Entity Relationship Diagram (ERD) features a network of interconnected entities (e.g., CONTINENT, COUNTRY, USER, ARTICLE) with clearly defined primary keys (PK) and foreign key (FK) relationships. This ensures data integrity and enables complex multi-table operations. Entities like COUNTRY_INFO and ARTICLE leverage JSON data types (e.g., `page_img_list`, `statistics`) to handle semi-structured data reflecting modern database engineering practices.

### Advanced SQL Query Proficiency

- Multi-Way Joins with Directional Control: Queries use LEFT/RIGHT JOIN (e.g., the country-related info query spanning six tables) to precisely manage result set inclusion, ensuring data completeness while accounting for missing relationships.

- Subqueries, Aggregations, and Ranking:
  - The "users with multiple articles" query combines subqueries, GROUP BY, and HAVING to filter and analyze user behavior.
  - Queries for "most articles" and "top image users" employ COUNT(), SUM(), and JSON_LENGTH() to aggregate and rank data.

- Modular View Design: The COUNTRY_CONTRIBUTE_USD_VIEW encapsulates complex logic (currency conversion, JSON extraction) into a reusable component, then powers downstream analysis of continental aid per capita—demonstrating best practices for maintainable, scalable SQL development.

- JSON & String Manipulation: Queries use JSON_EXTRACT, SUBSTRING_INDEX, and CASE statements to parse semi-structured data (e.g., extracting population/aid from COUNTRY_INFO.statistics) and transform formatted values (e.g., "10M USD" to numeric USD amounts)—exhibiting data wrangling expertise.

### ID Architecture

- **icrc_id**:
  - Global Uniqueness & Semantics: Follows an 8-digit structure where the first 3 digits are the country_id with zero-padding (e.g., country_id=1 → 001). The middle 2 digits represent the area code, and the last 3 digits are an incrementing serial number. This ensures global uniqueness and embeds country/region context directly into the ID.
  - Association Consistency: The first 3 digits of icrc_id strictly map to country_id (e.g., 301001 → country_id=3), and aligns perfectly with the icrc_list field in the COUNTRY table.

- **article_id**:
  - Follows a structured rule: 3-digit country code + 1-digit type code + 1-digit theme code + 7-digit timestamp segment + 7-digit random number. This balances uniqueness, business semantics (country, type, theme), and randomness to avoid predictability.

- **image_id**:
  - Uses a Snowflake-like algorithm with a truncated timestamp (only the last 8 bits of the millisecond timestamp), ensuring fast, local ID generation in high-concurrency scenarios.

- **user_id (Snowflake)**:
  - Uses a 64-bit Snowflake structure (41-bit timestamp, 5-bit data center ID, 5-bit machine ID, 12-bit serial number), enabling auditability and efficient time-based filtering.

- **article_list JSON Association**:
  - Stores user-article relationships as a JSON array (`[article_id1, article_id2]`), supporting flexible, dynamic associations and mirroring real-world scenarios (e.g., popular articles shared by multiple users). This avoids over-engineering while retaining adaptability.

---

## Repository Structure
