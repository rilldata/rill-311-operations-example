WITH  

OaklandNormalized AS 
(
SELECT
  'Oakland' AS city,
  'CA' AS state,
  DATETIMEINIT AS start_event_date,
  STRPTIME(DATETIMECLOSED::VARCHAR, '%Y-%m-%d %H:%M:%S') AS end_event_date,
  REPLACE(SPLIT(REQADDRESS,',')[1], '(','') AS longitude,
  REPLACE(SPLIT(REQADDRESS,',')[2], ')','') AS latitude,
  REQUESTID AS ticket_id,
  PROBADDRESS AS street_address,
  DESCRIPTION AS description, 
  LOWER(REQCATEGORY) AS category,
  NULL AS activity,
  STATUS AS status,
  SOURCE AS method,
  REFERREDTO AS outcome,
  COUNCILDISTRICT AS neighborhood,
FROM oakland
),


SanJoseNormalized AS 
(
SELECT
  'San Jose' AS city,
  'CA' AS state,
  "Date Created" AS start_event_date,
  "Date Last Updated" AS end_event_date,
  Longitude AS longitude,
  Latitude AS latitude,
  Incident_ID AS ticket_id,
  NULL AS street_address,
  "Service Type" AS description, 
  Category AS category,
  Department AS activity,
  Status AS status,
  Source AS method,
  null AS outcome,
  NULL AS neighborhood,
FROM sanjose
),

Together AS (
SELECT * FROM OaklandNormalized
  UNION ALL 
SELECT * FROM SanJoseNormalized

)


SELECT
  DATE_DIFF('HOUR', start_event_date, end_event_date) AS date_diff_in_hours,
  CASE 
    WHEN LOWER(status) IN ('open', 'new', 'in progress') THEN 'Active' 
    WHEN status IS NULL THEN 'Unknown' 
    ELSE 'Closed' 
    END AS status_type,
  CAST(ticket_id AS VARCHAR) AS ticket_id,
  LOWER(category) AS category,
NULL AS random,
  * exclude(ticket_id, category)
FROM Together 
WHERE start_event_date >= '2023-01-01'


