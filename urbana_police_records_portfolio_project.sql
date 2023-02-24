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

--Crime Category Percentages divided between sexes
SELECT DISTINCT crime_category_description,
CASE WHEN crime_category_description = '.' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = '.')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Accident' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Accident')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Animal Investigation' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Animal Investigaton')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Animal Offenses' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Animal Offenses')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Arson' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Arson')*1.0/COUNT(*)),2) 
WHEN crime_category_description = 'Assault' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Assault')*1.0/COUNT(*)),2) 
WHEN crime_category_description LIKE 'Assist%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Assist%')*1.0/COUNT(*)),2) 
WHEN crime_category_description = 'Battery' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Battery')*1.0/COUNT(*)),2) 
WHEN crime_category_description = 'Bicycle Offenses' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Bicycle Offenses')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Burglary' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Burglary')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Burglary from%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Burglary from%')*1.0/COUNT(*)),2) 
WHEN crime_category_description = 'Burglary Tools' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Burglary Tools')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Cannabis Offenses' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Cannabis Offenses')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Controlled%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Controlled%')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Criminal Damage' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Criminal Damage')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Criminal Sexual%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Criminal Sexual%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Crisis%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Crisis%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Deception%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Deception%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Disorderly%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Disorderly%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Domestic -%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Domestic -%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Domestic D%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Domestic D%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Driving%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Driving%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Drug%' THEN ROUND(((SELECT COUNT (CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Drug%')*1.0/COUNT(*)),2) 
WHEN crime_category_description LIKE 'Fire%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Fire%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Gambling%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Gambling%')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Homicide' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Homicide')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Human%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Human%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Hypo%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Hypo%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Illegal%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Illegal%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Interfering%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Interfering%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Internal%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Internal%')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Intimidation' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Intimidation')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Investigate' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Investigate')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Kidnapping' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Kidnapping')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Library%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Library%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Liquor%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Liquor%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Lost%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Lost%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Meth%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Meth%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Military%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Military%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Motor%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Motor%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Noise%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Noise%')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'None' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'None')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Offender%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Offender%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Offenses%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Offenses%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Other Drug%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Other Drug')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Other Offenses' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Other Offenses')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Park D%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Park D%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Parking%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Parking%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Peddle%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Peddle%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Pedes%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Pedes%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Prob/%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Prob/%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Public%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Public%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Rob%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Rob%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Sex%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Sex%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Status%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Status%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Terror%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Terror%')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Theft' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Theft')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Traffic Non%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Traffic Non%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Traffic O%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Traffic O%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Tres%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Tres%')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Vehicles for Hire - Admin' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Vehicles for Hire - Admin')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Vehicles for Hire Violations' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Vehicles for Hire Violations')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Violation of Crim%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Violation of Crim%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Violation Ord%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Violation Ord%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Warrants%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Warrants%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Waste%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Waste%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Weapon%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Weapon%')*1.0/COUNT(*)),2)
WHEN crime_category_description IS NULL THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'MALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description IS NULL)*1.0/COUNT(*)),2) 
END AS male_crimes_perc,
CASE WHEN crime_category_description = '.' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = '.')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Accident' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Accident')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Animal Investigation' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Animal Investigaton')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Animal Offenses' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Animal Offenses')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Arson' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Arson')*1.0/COUNT(*)),2) 
WHEN crime_category_description = 'Assault' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Assault')*1.0/COUNT(*)),2) 
WHEN crime_category_description LIKE 'Assist%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Assist%')*1.0/COUNT(*)),2) 
WHEN crime_category_description = 'Battery' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Battery')*1.0/COUNT(*)),2) 
WHEN crime_category_description = 'Bicycle Offenses' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Bicycle Offenses')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Burglary' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Burglary')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Burglary from%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Burglary from%')*1.0/COUNT(*)),2) 
WHEN crime_category_description = 'Burglary Tools' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Burglary Tools')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Cannabis Offenses' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Cannabis Offenses')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Controlled%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Controlled%')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Criminal Damage' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Criminal Damage')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Criminal Sexual%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Criminal Sexual%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Crisis%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Crisis%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Deception%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Deception%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Disorderly%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Disorderly%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Domestic -%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Domestic -%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Domestic D%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Domestic D%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Driving%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Driving%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Drug%' THEN ROUND(((SELECT COUNT (CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Drug%')*1.0/COUNT(*)),2) 
WHEN crime_category_description LIKE 'Fire%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Fire%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Gambling%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Gambling%')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Homicide' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Homicide')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Human%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Human%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Hypo%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Hypo%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Illegal%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Illegal%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Interfering%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Interfering%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Internal%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Internal%')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Intimidation' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Intimidation')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Investigate' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Investigate')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Kidnapping' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Kidnapping')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Library%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Library%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Liquor%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Liquor%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Lost%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Lost%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Meth%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Meth%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Military%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Military%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Motor%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Motor%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Noise%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Noise%')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'None' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'None')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Offender%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Offender%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Offenses%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Offenses%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Other Drug%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Other Drug')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Other Offenses' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Other Offenses')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Park D%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Park D%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Parking%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Parking%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Peddle%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Peddle%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Pedes%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Pedes%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Prob/%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Prob/%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Public%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Public%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Rob%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Rob%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Sex%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Sex%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Status%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Status%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Terror%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Terror%')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Theft' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Theft')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Traffic Non%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Traffic Non%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Traffic O%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Traffic O%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Tres%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Tres%')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Vehicles for Hire - Admin' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Vehicles for Hire - Admin')*1.0/COUNT(*)),2)
WHEN crime_category_description = 'Vehicles for Hire Violations' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description = 'Vehicles for Hire Violations')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Violation of Crim%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Violation of Crim%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Violation Ord%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Violation Ord%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Warrants%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Warrants%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Waste%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Waste%')*1.0/COUNT(*)),2)
WHEN crime_category_description LIKE 'Weapon%' THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description LIKE 'Weapon%')*1.0/COUNT(*)),2)
WHEN crime_category_description IS NULL THEN ROUND(((SELECT COUNT(CASE WHEN arrestee_sex = 'FEMALE' THEN 1 END) FROM urbana_police_arrests WHERE crime_category_description IS NULL)*1.0/COUNT(*)),2)
END AS female_crime_perc
FROM urbana_police_arrests 
GROUP BY 1;

--Homicide cases with arrest where suspect is not African American
SELECT DISTINCT upa.incident_number, upa.arrest_number,upi.date_occurred, upi.date_reported, upa.date_of_arrest, AGE(upa.date_of_arrest, upi.date_reported) AS date_report_arrest,
upi.crime_description, upa.violation, upa.disposition_description, upi.place_code_description,
upa.age_at_arrest, upa.arrestee_sex, upa.arrestee_race, upi.weapon_1_description, upi.weapon_2_description, upi.weapon_3_description, upi.mapping_address
FROM urbana_police_arrests AS upa
LEFT JOIN urbana_police_incidents AS upi
ON upa.incident_number = upi.incident_key
WHERE upa.crime_category_description = 'Homicide' AND upi.crime_category_description = 'Homicide' AND arrestee_race != 'BLACK'
ORDER BY upi.date_occurred ASC;

--Percentage of arrests by race and sex (excluding NULLs and UNKNOWN race)
SELECT arrestee_sex, --nulls and unknowns are removed as they only appears as 100% of their respective categories
ROUND((SELECT COUNT(CASE WHEN arrestee_race LIKE 'AMERICAN%' THEN 1 END))*100.0/COUNT(*),2) AS american_alaskan_perc,
ROUND((SELECT COUNT(CASE WHEN arrestee_race = 'ASIAN' THEN 1 END))*100.0/COUNT(*),2) AS asian_crime_perc,
ROUND((SELECT COUNT(CASE WHEN arrestee_race = 'BLACK' THEN 1 END))*100.0/COUNT(*),2) AS black_crime_perc,
ROUND((SELECT COUNT(CASE WHEN arrestee_race = 'BUSIN%' THEN 1 END))*100.0/COUNT(*),2) AS business_crime_perc,
ROUND((SELECT COUNT(CASE WHEN arrestee_race = 'HISPANIC' THEN 1 END))*100.0/COUNT(*),2) AS hispanic_crime_perc,
ROUND((SELECT COUNT(CASE WHEN arrestee_race = 'WHITE' THEN 1 END))*100.0/COUNT(*),2) AS white_crime_perc
FROM urbana_police_arrests
GROUP BY 1;

--Counts of Crime Categories by Age Group (Bins of 10)
WITH A AS
(SELECT incident_number, CASE WHEN age_at_arrest >= 0 AND age_at_arrest <10 THEN 1 END AS children,
CASE WHEN age_at_arrest >=10 AND age_at_arrest < 20 THEN 1 END AS teens,
CASE WHEN age_at_arrest >=20 AND age_at_arrest < 30 THEN 1 END AS twenties,
CASE WHEN age_at_arrest >= 30 AND age_at_arrest < 40 THEN 1 END AS thirties,
CASE WHEN age_at_arrest >= 40 AND age_at_arrest < 50 THEN 1 END AS forties,
CASE WHEN age_at_arrest >= 50 AND age_at_arrest < 60 THEN 1 END AS fifties,
CASE WHEN age_at_arrest >= 60 AND age_at_arrest < 70 THEN 1 END AS sixties,
CASE WHEN age_at_arrest >= 70 AND age_at_arrest < 80 THEN 1 END AS seventies,
CASE WHEN age_at_arrest >= 80 AND age_at_arrest < 90 THEN 1 END AS eighties,
CASE WHEN age_at_arrest >=90 AND age_at_arrest < 100 THEN 1 END as ninties
FROM urbana_police_arrests)

SELECT crime_category_description, SUM(children) AS children, SUM(teens) AS teens, SUM(twenties) AS twenties, SUM(thirties) AS thirties,
SUM(forties) AS forties, SUM(fifties) AS fifties, SUM(sixties) AS sixties, SUM(seventies) AS seventies, SUM(eighties) AS eighties, SUM(ninties) AS ninties
FROM A
LEFT JOIN urbana_police_arrests AS upa
ON A.incident_number = upa.incident_number
GROUP BY 1
ORDER BY 1;
