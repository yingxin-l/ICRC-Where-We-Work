---
layout: default
---
# Design Flexibility Analysis
**Case: ICRC – "Where we Work"**  
**Source Site:** [Explore our global reach | International Committee of the Red Cross](https://www.icrc.org/en/where-we-work)

---

## 1. Assumptions

While designing the ICRC "Where We Work" database, a few working assumptions were made to translate what appears on the public website into a relational data model. These assumptions shaped how the entities, attributes, and relationships developed across ERD 1, ERD 2, and ERD 3.

1. Each region or continent contains multiple countries, and each country can have one or more ICRC offices and humanitarian activities. This led to a clear parent-child structure between Region, Country, and ICRC Office, so that geographic information stays consistent and can scale.
2. Each ICRC office is responsible for running operations, maintaining contact details, and producing updates or public-facing information. Because of this, ICRC Office, Contact, and Article were modelled as separate entities that stay linked through foreign keys.
3. Content for different countries is created and maintained by different staff or contributors. A User table was included to identify the author or editor of each Article. This supports accountability and ownership of published information.
4. Each country record contains descriptive and operational details such as address, coordinates, and how long ICRC has been active there. This is why attributes like latitude, longitude, and presence_since were included, so the data can support location context and reporting.
5. The organization may later want to track more information, such as local partners, media assets, or funding sources. This assumption pushed the designs toward a modular structure, so that new entities can be attached later without breaking what already exists.

Taken together, these assumptions guided the progression from these ERDs and helped keep the design consistent, practical, and future-ready.

---

## 2. Comparative Advantages and Disadvantages

### ERD 1 – Content-Rich Model

**Strengths:**
- **Modularization and Clear Responsibility:** Each table focuses on a single business domain (articles, users, countries, etc.), making it easy to maintain.
- **Strong Data Integrity:** Foreign key associations ensure referential integrity and avoid dirty data.
- **Low Redundancy and High Normalization:** Tables are split according to database normalization rules, reducing data duplication and update anomalies.
- **Flexibility of JSON Fields:** Adapt to semi-structured data (tags, image lists, etc.) without frequent table structure changes.
- **Complete Audit Capability:** Timestamps support tracking of data creation and modification for traceability.

**Limitations:**
- **Poor Performance with Multi-table JOINs:** Dense table associations lead to low query efficiency when data volume is large.
- **Inefficient JSON Queries:** Querying and indexing JSON fields are difficult to optimize.
- **Overhead of Foreign Keys and Transactions:** Foreign key constraints increase the cost of insert, delete, and update operations, and maintaining transaction consistency across multiple tables is complex.
- **Limited Structural Scalability:** When business changes significantly, the flexibility of JSON may be insufficient, and table structures still need to be adjusted.

### ERD 2 – Lean Core Model

**Strengths:**
- **Low Data Redundancy:** It follows the 3rd Normal Form (3NF). Through the association of primary keys and foreign keys, it avoids the repeated storage of information such as regions and countries.
- **Clear Business Logic:** The hierarchy (region-country) and multi-scenario (articles, offices, information) associations are precise, matching the actual business requirements.
- **Flexible Query:** It supports cross-table association and can realize multi-dimensional analysis of region-country-resources/information.

**Limitations:**
- **Potential Query Performance Issues:** Cross-table associations may slow down when dealing with large amounts of data, such as complex cross-table statistics.
- **High Expansion Cost:** When adding regional-level information or modifying the table structure, the schema needs to be adjusted, increasing the maintenance cost.
- **Tedious Write Constraints:** The integrity check of foreign keys increases the complexity of write logic and may affect write efficiency.

### ERD 3 – Balanced Model

**Strengths:**
- **Clear Business Division:** Each table focuses on a single domain (continent, country, article, etc.), making the structure easy to understand and maintain.
- **Strong Data Integrity:** Foreign key relationships ensure referential integrity and prevent invalid data.
- **Low Redundancy:** Tables are split by business (e.g., continent and country info are separated), reducing data duplication and update anomalies.
- **Intuitive Relationship Mapping:** Entity associations are clear and logical.

**Limitations:**
- **Performance Overhead from Multi-table JOINs:** Querying across related tables (e.g., retrieving an article with its country and continent details) requires multiple JOINs, which is inefficient when data volume is large.
- **Insufficient Flexibility for Dynamic Data:** Adding new attributes (e.g., new fields for ICRC) requires modifying table structures, which is inflexible.
- **Complex Maintenance for Cross-table Changes:** Adjusting interconnected tables and their relationships when business rules change is costly.

---

## 3. Design Flexibility

### (a) Before Rollout

Before the database goes live, the design can still be adjusted with relatively low effort.  
New entities such as Video, Volunteer, or Exchange_rates can be added and linked using existing keys like country_id or icrc_id without disturbing the rest of the model.  
At this stage, attributes can also be refined (for example, adding extra contact fields or improving office location detail).

### (b) After Rollout

Once the database is live, the structure still supports controlled change.  
Because Country, ICRC Office, Article, and Contact are separated into their own entities with clear relationships, it is possible to add new fields, rename attributes, or bring in external data sources while keeping existing links intact.  
For example, if geospatial analytics or richer media need to be attached to each office, new tables (e.g. a Location Analytics table or a Media Record table) can be added beside the main schema instead of rewriting it.

### (c) Future Growth Scenario

The final model is designed to grow over time.  
If the organization later wants to track field missions, local partners, or country-level impact reporting, those can be introduced as new entities (for example, Field Mission, Partner Organization, Impact Report) and linked back through country_id or icrc_id.  
The structure can also integrate with dashboards or external systems later, such as APIs for live humanitarian statistics or mapping layers, without redesigning the core tables.  
This means the database can evolve alongside ICRC's needs instead of being rebuilt.

---

## 4. Sociotechnical Considerations

### (a) Stakeholders and Sensemaking

The database is intended to serve different groups (field teams, regional coordinators, communications staff, donors, researchers) who all need a clear view of where ICRC is active and what it is doing. Linking Country, ICRC Office, Key Operation, and Article helps those groups make sense of the organization's presence and activities in each location, and supports transparent communication.

### (b) Organizational Silos and Boundary Spanning

Before this design, different information (contacts, operations, public statements) could live in different places such as spreadsheets, inboxes, or web CMS tools. Bringing these into one structure and joining them by country_id and icrc_id helps break those silos and makes it easier for different teams to coordinate.

### (c) Time and Temporality

Dates such as presence_since for an office and publish_date for an article allow the organization to see how long it has operated in a place and how frequently updates are being published. This supports planning, reporting, and donor communication over time.

### (d) Upgrading with Care

Database upgrades are complex processes that involve many aspects, such as data migration, service interruptions, and user impact. If upgrades are not handled carefully, they can easily lead to data loss, service anomalies, and user dissatisfaction.  
Other issues can be addressed during the design phase or subsequent data warehouse processing, but changes to the database in the service have a larger impact area and need to be handled with caution.

### (e) Corroboration and Entity Resolution

Consistent identifiers (for example country_id, icrc_id) and standard naming help prevent duplicate records and make it easier to cross-check information coming from different sources. This is important for accuracy, especially when data is coming from multiple teams in different locations.