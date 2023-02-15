--Cases Counts by Category 1988-2019
SELECT DISTINCT crime_category_description, (SELECT DISTINCT SUM(CASE WHEN EXTRACT(YEAR FROM date_occurred) >= '1988' AND EXTRACT(YEAR FROM date_occurred) < '1998'
		   THEN 1 ELSE 0 END)) AS cases_88_98,
		(SELECT DISTINCT SUM(CASE WHEN EXTRACT(YEAR FROM date_occurred) >='1998' AND EXTRACT(YEAR FROM date_occurred) < '2008'
		   THEN 1 ELSE 0 END)) AS cases_98_08,
		(SELECT DISTINCT SUM(CASE WHEN EXTRACT(YEAR FROM date_occurred) >='2008' AND EXTRACT(YEAR FROM date_occurred) < '2018'
		   THEN 1 ELSE 0 END)) AS cases_08_18,
		 (SELECT DISTINCT SUM(CASE WHEN EXTRACT(YEAR FROM date_occurred) >= '2018' AND EXTRACT(YEAR FROM date_occurred) <= '2019'
			THEN 1 ELSE 0 END)) AS cases_19 
FROM urbana_police_incidents
GROUP BY 1
ORDER BY 1;	
--Incidents that involve delayed reporting and/or arrival
WITH A AS
(SELECT date_occurred, date_reported, date_arrived, incident_key, AGE(date_reported,date_occurred) AS days_between_crime, (time_reported-time_occurred) AS hours_between_crime,
AGE(date_arrived, date_reported) AS arrivedate_bet_reportdate, house_number_with_block, mapping_address, crime_category_description,
crime_description, place_code_description
FROM urbana_police_incidents
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12
HAVING AGE(date_arrived, date_reported) > '00:00:00')

SELECT DISTINCT *
FROM A
WHERE days_between_crime >= '00:00:00' AND hours_between_crime >= '00:00:00'
ORDER BY date_occurred ASC, incident_key DESC, crime_category_description DESC;
--Jan 1999 Traffic Offenses and Non-Offenses
WITH A AS
(SELECT date_occurred, date_reported, EXTRACT(month FROM date_occurred) AS months, EXTRACT(year FROM date_occurred) AS years
 FROM urbana_police_incidents
 WHERE EXTRACT(year FROM date_occurred) = '1999' AND EXTRACT(month FROM date_occurred) = '01')
 
 SELECT  DISTINCT A.date_occurred, A.date_reported, date_arrived, time_arrived, incident_key, incident_and_crime_sequence, crime_category_description, crime_description, 
 mapping_address, place_code_description
 FROM A 
 LEFT JOIN urbana_police_incidents AS upi
 ON A.date_occurred = upi.date_occurred
 WHERE crime_category_description IN ('Traffic Offenses', 'Traffic Non-Offenses')
 ORDER BY A.date_occurred ASC, A.date_reported ASC, incident_key ASC, incident_and_crime_sequence ASC;
 
 --Criminal Sexual Assault Cases between Midnight and 6am
 WITH A AS 
(SELECT date_occurred, time_occurred
FROM urbana_police_incidents
WHERE time_occurred >= '00:00:00' AND time_occurred <= '06:00:00')

SELECT DISTINCT A.date_occurred, A.time_occurred, date_reported, time_reported, incident_key, incident_and_crime_sequence, crime_description, mapping_address
FROM A
LEFT JOIN urbana_police_incidents AS upi
ON A.date_occurred = upi.date_occurred
WHERE crime_category_description = 'Criminal Sexual Assault'
ORDER BY A.date_occurred ASC, A.time_occurred ASC;

--Count of Status Descriptions Minus Nulls
SELECT DISTINCT status_description, SUM(CASE WHEN status_description = 'ADMINISTRATIVELY CLOSED' THEN 1 
WHEN status_description = 'CHARGED BY SAO NO ARREST' THEN 1
WHEN status_description = 'CLEARED BY ADULT ARREST' THEN 1 
WHEN status_description = 'CLEARED BY JUVENILE ARREST' THEN 1 
WHEN status_description = 'CLEARED EXCEPTIONALLY BY DEATH OF OFFENDER' THEN 1
WHEN status_description = 'CLEARED EXCEPTIONALLY DENIED EXTRADITION' THEN 1 
WHEN status_description = 'CLEARED EXCEPTIONALLY JUVENILE NO CUSTODY' THEN 1 
WHEN status_description = 'CLEARED EXCEPTIONALLY PROSECUTION FILED TO FILE' THEN 1 
WHEN status_description = 'CLEARED EXCEPTIONALLY REFUSAL TO COOPERATE' THEN 1 
WHEN status_description = 'PENDING' THEN 1 
WHEN status_description = 'REFERRED TO OTHER JURISDICTION' THEN 1
WHEN status_description = 'TRAFFIC WARNING TICKET' THEN 1 
WHEN status_description = 'UNFOUNDED' THEN 1
WHEN status_description = NULL THEN 1 
WHEN status_description = 'REFERRED TO STUDENT DISCIPLINE' THEN 1 END) AS status_count
FROM urbana_police_incidents
GROUP BY 1
HAVING SUM(CASE WHEN status_description = 'ADMINISTRATIVELY CLOSED' THEN 1 
WHEN status_description = 'CHARGED BY SAO NO ARREST' THEN 1
WHEN status_description = 'CLEARED BY ADULT ARREST' THEN 1 
WHEN status_description = 'CLEARED BY JUVENILE ARREST' THEN 1 
WHEN status_description = 'CLEARED EXCEPTIONALLY BY DEATH OF OFFENDER' THEN 1
WHEN status_description = 'CLEARED EXCEPTIONALLY DENIED EXTRADITION' THEN 1 
WHEN status_description = 'CLEARED EXCEPTIONALLY JUVENILE NO CUSTODY' THEN 1 
WHEN status_description = 'CLEARED EXCEPTIONALLY PROSECUTION FILED TO FILE' THEN 1 
WHEN status_description = 'CLEARED EXCEPTIONALLY REFUSAL TO COOPERATE' THEN 1 
WHEN status_description = 'PENDING' THEN 1 
WHEN status_description = 'REFERRED TO OTHER JURISDICTION' THEN 1
WHEN status_description = 'TRAFFIC WARNING TICKET' THEN 1 
WHEN status_description = 'UNFOUNDED' THEN 1
WHEN status_description = NULL THEN 1 
WHEN status_description = 'REFERRED TO STUDENT DISCIPLINE' THEN 1 END) IS NOT NULL
ORDER BY status_count DESC;

--Percentage of weapons used in homicide cases including the null value percentage
SELECT ROUND((SUM(CASE WHEN weapon_1_description LIKE '%HANDGUN%' THEN 1 END)*100.0/COUNT(*)),2) AS homicide_handguns_perc,
ROUND((SUM (CASE WHEN weapon_1_description LIKE '%BLUNT OBJECT%' THEN 1 END)*100.0/COUNT(*)),2) AS homeicide_bluntobj_perc,
ROUND((SUM (CASE WHEN weapon_1_description LIKE '%DRUGS%' THEN 1 END)*100.0/COUNT(*)),2) AS homicide_drug_perc,
ROUND((SUM(CASE WHEN weapon_1_description LIKE '%FIRE/INCENDIARY DEVICE%' THEN 1 END)*100.0/COUNT(*)),2) AS homicide_fire_perc,
ROUND((SUM(CASE WHEN weapon_1_description LIKE '%FIREARM%' THEN 1 
		   WHEN weapon_3_description LIKE '%FIREARM%' THEN 1 END)*100.0/COUNT(*)),2) AS homicide_firearms_perc,
ROUND((SUM(CASE WHEN weapon_1_description LIKE '%SHOTGUN%' THEN 1
		   WHEN weapon_2_description LIKE '%SHOTGUN%' THEN 1 END)*100.0/COUNT(*)),2) AS homicide_shotgun_perc,
ROUND((SUM(CASE WHEN weapon_1_description LIKE '%HANDTOOL%' THEN 1 END)*100.0/COUNT(*)),2) AS homicide_handtool_perc,
ROUND((SUM(CASE WHEN weapon_1_description LIKE '%NONE%' THEN 1 END)*100.0/COUNT(*)),2) AS homicide_noweap_perc,
ROUND((SUM(CASE WHEN weapon_1_description LIKE '%OTHER WEAPON%' THEN 1 END)*100.0/COUNT(*)),2) AS homicide_otherweap_perc,
ROUND((SUM(CASE WHEN weapon_2_description LIKE '%CLUB%' THEN 1 END)*100.0/COUNT(*)),2) AS homicide_club_perc,
ROUND((SUM(CASE WHEN weapon_1_description LIKE '%PERSONAL WEAPONS%' THEN 1 END)*100.0/COUNT(*)),2) AS homicide_personal_perc,
ROUND((SUM(CASE WHEN weapon_1_description LIKE '%RIFLE%' THEN 1 END)*100.0/COUNT(*)),2) AS homicide_rifle_perc,
ROUND((SUM(CASE WHEN weapon_1_description LIKE '%SHARP OBJECT%' THEN 1 END)*100.0/COUNT(*)),2) AS homicide_sharp_perc,
ROUND((SUM(CASE WHEN weapon_1_description LIKE '%UNARMED%' THEN 1 END)*100.0/COUNT(*)),2) AS homicide_unarmed_perc,
ROUND((((SELECT SUM(CASE WHEN weapon_1_description IS NULL THEN 1
WHEN weapon_2_description IS NULL THEN 1
WHEN weapon_3_description IS NULL THEN 1 END)) - (SELECT SUM(CASE WHEN weapon_1_description IS NOT NULL THEN 1
WHEN weapon_2_description IS NOT NULL THEN 1
WHEN weapon_3_description IS NOT NULL THEN 1 END)))*100.0/COUNT(*)),2) AS weapon_columns_null_perc
FROM urbana_police_incidents
WHERE crime_category_description = 'Homicide';

--Incidents Ordered by Date and Grouped by Incident Sequentially 
SELECT date_occurred, incident_key, incident_and_crime_sequence, date_reported, crime_category_description, 
crime_description, mapping_address, place_code_description
FROM urbana_police_incidents
ORDER BY date_occurred ASC, incident_and_crime_sequence ASC;

--Incidents involving Sex Offenses against children in which incident reporting took place on or greater than a week
SELECT date_occurred, date_reported, AGE(date_reported,date_occurred) AS time_since_crime, date_arrived, 
incident_key, incident_and_crime_sequence, crime_category_description, crime_description, mapping_address, place_code_description
FROM urbana_police_incidents
WHERE crime_category_description = 'Sex Offenses' AND crime_description LIKE '%CHILD%'
GROUP BY 1,2,3,4,5,6,7,8,9,10
HAVING AGE(date_reported,date_occurred) >= '7 days'::interval
ORDER BY date_occurred ASC, incident_and_crime_sequence ASC, time_since_crime ASC;