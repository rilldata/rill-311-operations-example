-- @materialize:true
WITH  

BerkeleyNormalized AS 
(
SELECT
  'Berkeley' AS city,
  'CA' AS state, 
  Date_Opened  AS start_event_date,
  STRPTIME(Date_Closed, '%M/%d/%Y %I:%M:%S %p') AS end_event_date,
  Longitude AS longitude,
  Latitude AS latitude,
  Case_ID AS ticket_id,
  Street_Address AS street_address,
  CONCAT(Request_Detail, ': ', Object_Type) AS description, 
  Request_Category AS category,
  Request_SubCategory AS activity,
  Case_Status AS status,
  NULL AS method,
  NULL AS outcome,
  Neighborhood AS neighborhood,
FROM berkeley
),


OaklandNormalized AS 
(
SELECT
  'Oakland' AS city,
  'CA' AS state,
  DATETIMEINIT AS start_event_date,
  STRPTIME(DATETIMECLOSED, '%M/%d/%Y %I:%M:%S %p') AS end_event_date,
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

SanFranciscoNormalized AS 
(
SELECT
  'San Francisco' AS city,
  'CA' AS state,
  Opened AS start_event_date,
  STRPTIME(Closed, '%m/%d/%Y %I:%M:%S %p') AS end_event_date,
  CASE WHEN Longitude = '0.0' THEN NULL ELSE Longitude END AS longitude,
  CASE WHEN Latitude = '0.0' THEN NULL ELSE Latitude END  AS latitude,
  CaseID AS ticket_id,
  Street AS street_address,
  CONCAT("Request Type", ': ', "Request Details") AS description, 
  Category AS category,
  "Media URL" AS activity,
  "Status" AS status,
  Source AS method,
  "Responsible Agency" AS outcome,
  Neighborhoods AS neighborhood,
FROM sanfrancisco
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
SELECT * FROM BerkeleyNormalized
  UNION ALL 
SELECT * FROM OaklandNormalized
  UNION ALL 
SELECT * FROM SanFranciscoNormalized
  UNION ALL 
SELECT * FROM SanJoseNormalized

)


SELECT
  DATE_DIFF('HOUR', start_event_date, end_event_date) AS date_diff_in_hours,
  CASE 
    WHEN LOWER(status) IN ('open', 'new') THEN 'Active' 
    WHEN LOWER(status) IN ('in progress') THEN 'In Progress'
    WHEN status IS NULL THEN 'Unknown' 
    ELSE 'Closed' 
    END AS status_type,
  CAST(ticket_id AS VARCHAR) AS ticket_id,
  LOWER(category) AS category,

  * exclude(ticket_id, category)
FROM Together 
WHERE start_event_date >= '2023-01-01'
