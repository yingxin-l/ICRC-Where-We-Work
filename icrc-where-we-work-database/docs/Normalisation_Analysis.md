---
layout: default
---
Normalization

Case: ICRC -- "Where we Work"
Source Site: Explore our global reach | International Committee of the Red Cross

1. Introduction 
This part aims to perform a normalization analysis on the database design supporting the ICRC's "Where We Work" webpage. Normalization is a critical process in database design that aims to ensure data integrity and consistency by eliminating data redundancy and update anomalies. 
This analysis will be based on the selected ERD, progressively examining its compliance with the First (1NF: Requires that all attributes are atomic, meaning indivisible.), Second (2NF: Requires, on the basis of satisfying 1NF, that all non-primary key attributes must be fully functionally dependent on the entire primary key, eliminating partial functional dependencies.), and Third Normal Forms (3NF: Requires, on the basis of satisfying 2NF, that all non-primary key attributes must be directly dependent on the primary key, eliminating transitive functional dependencies.), and evaluating the rationale of the design.
  
2. Normalization Process Analysis 
Normalization optimizes database structure through a series of normal form rules: 
  
2.1 Entities at 1NF and Analysis
A. Judgement: 
Entities such as ARTICLE, USER, and COUNTRY_INFO satisfy the First Normal Form. The values stored in each field of these entities are atomic, representing the smallest, indivisible units of data. For instance, fields like article title and content in the ARTICLE entity each contain only a single value.  

B. Analysis and Limitations:  
Although they satisfy 1NF, these entities contain numerous JSON type fields (e.g., ARTICLE.article_tags, USER.page_img_list, COUNTRY_INFO.tabs). A JSON object itself has an atomic value, thus complying with 1NF. However, from a data modelling semantic perspective, these fields encapsulate structured data (such as tags, image lists, information tabs) that should ideally be modelled as separate entities and many-to-many relationships.   
This design choice leads to "non-atomicity" at the business logic level, consequently causing data Redundancy (The same tag might be redundantly stored within the JSON arrays of different articles.) and operational difficulties (It is difficult to perform efficient queries, updates, and ensure data consistency for specific elements within the JSON arrays using standard SQL.)  

C. Conclusion:  
In actual business, for data tables such as ARTICLE, USER, and country_info that may contain variable structures, high information density, or dynamically expanded attributes, using JSON format to store some fields can significantly improve flexibility (avoid frequent modifications to the table structure) and development efficiency. ARTICLE, USER, and country_info tables not only retain the query efficiency of core structured fields (such as user_id, article_id), but also flexibly respond to high-information-density and dynamically changing business scenarios through JSON fields, balancing flexibility, and performance. 
 
2.2 Entities at 3NF and Analysis 
A. Judgement: 
Entities such as CONTINENT, COUNTRY, ICRC, and IMAGE satisfy the Third Normal Form. 
  
B. Detailed Basis: 
All attributes are atomic values (Satisfy 1NF); the primary keys of these entities are all single columns (e.g., country_id); there are no composite primary keys, thus eliminating the possibility of partial dependencies of non-key attributes on the primary key (Satisfy 2NF); all non-primary key attributes are directly and fully dependent on the primary key, with no transitive dependencies (Satisfy 3NF).  
In the COUNTRY entity, both country_name and country_code are directly dependent on the primary key country_id, and there is no dependency relationship between them. 
  
C. Design Adequacy: 
This highly normalised design ensures high consistency and maintainability for fundamental data. This is crucial and efficient for core reference data. For instance, modifying a country's name requires only a single update in the COUNTRY entity, and all references to it via foreign keys will automatically remain consistent.  

3. Summary:  
Core dimension entities have reached 3NF. Their structure is robust, providing a reliable data foundation for the entire system. Core transaction entities incorporate unstructured JSON data on top of 1NF for flexibility. This simplifies development in the short term but sacrifices some data integrity and query performance. 
If the project is expected to evolve, with increasing data volume or more complex query requirements, prioritizing the refactoring related to the ARTICLE entity will yield the most significant improvements in performance and maintainability.