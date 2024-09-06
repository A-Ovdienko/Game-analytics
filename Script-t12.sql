
-- task 1 расчет пользователей по дням по платформам

WITH pinup_table AS 
-- создаем в СТЕ поле 'user_info1' c id пользователей (в БД в поле 'user_info'	информация о id хранится в разных форматах)
(SELECT DATE(created_at) AS Dates,
		CASE 
		  WHEN user_info LIKE '{%' THEN JSON_UNQUOTE(JSON_EXTRACT(user_info, "$.uuid"))
		  ELSE  user_info
		END AS user_info1,
-- создаем в CTE поле для классификации типов ОС устройств пользователей (все многообразие модификаций ОС сводим к четырем базовым платформам)
		CASE 
		  	WHEN JSON_EXTRACT(device_info, "$.os_name", "$.operatingSystem") LIKE '%macOS%' THEN 'MacOS'
		  	WHEN JSON_EXTRACT(device_info, "$.os_name", "$.operatingSystem") LIKE '%Mac OS%' THEN 'MacOS'
		  	WHEN JSON_EXTRACT(device_info, "$.os_name", "$.operatingSystem") LIKE '%OSX%' THEN 'MacOS'
		  	WHEN JSON_EXTRACT(device_info, "$.os_name", "$.operatingSystem") LIKE '%Android%' THEN 'AndroidOS'
		  	WHEN JSON_EXTRACT(device_info, "$.os_name", "$.operatingSystem") LIKE '%iOS%' THEN 'iOS'
		  	WHEN JSON_EXTRACT(device_info, "$.os_name", "$.operatingSystem") LIKE '%Windows%' THEN 'WindowsOS'
		  	ELSE 'Unknown'
		END AS platf_name
	FROM pinup_events pe)
SELECT 
	Dates,
	platf_name,
    COUNT(DISTINCT user_info1) AS count_pl	   
FROM pinup_table
-- исключаем записи с отсутствующей информацией об id пользователя
WHERE (user_info1 IS NOT NULL) AND (LENGTH(user_info1) > 1) 
GROUP BY Dates, platf_name 
-- исключаем записи с отсутствующей информацией об ОС устройства пользователя
HAVING platf_name IS NOT NULL 
ORDER BY Dates; 



-- task 2 расчет новых пользователей по дням по платформам
WITH users_per_day AS
-- создаем в СТЕ поле 'user_info1' c id пользователей (в БД в поле 'user_info'	информация о id хранится в разных форматах)
	(SELECT DATE(created_at) AS Dates,
		CASE 
		  WHEN user_info LIKE '{%' THEN JSON_UNQUOTE(JSON_EXTRACT(user_info, "$.uuid"))
		  ELSE user_info
		END AS user_info1,
-- создаем в CTE поле для классификации типов ОС устройств пользователей (все многообразие модификаций ОС сводим к четырем базовым платформам)
		CASE 
		  WHEN JSON_EXTRACT(device_info, "$.os_name", "$.operatingSystem") LIKE '%macOS%' THEN 'MacOS'
		  WHEN JSON_EXTRACT(device_info, "$.os_name", "$.operatingSystem") LIKE '%Mac OS%' THEN 'MacOS'
		  WHEN JSON_EXTRACT(device_info, "$.os_name", "$.operatingSystem") LIKE '%OSX%' THEN 'MacOS'
		  WHEN JSON_EXTRACT(device_info, "$.os_name", "$.operatingSystem") LIKE '%Android%' THEN 'AndroidOS'
		  WHEN JSON_EXTRACT(device_info, "$.os_name", "$.operatingSystem") LIKE '%iOS%' THEN 'iOS'
		  WHEN JSON_EXTRACT(device_info, "$.os_name", "$.operatingSystem") LIKE '%Windows%' THEN 'WindowsOS'
		  ELSE 'Unknown'
		END AS platf_name
	FROM pinup_events pe
	GROUP BY user_info1)
SELECT Dates, platf_name, COUNT(user_info1)  AS user_numb
   FROM users_per_day
-- исключаем записи с отсутствующей информацией об id пользователя
   WHERE (user_info1 IS NOT NULL) AND (LENGTH(user_info1) > 1)    
   GROUP BY Dates, platf_name
-- исключаем записи с отсутствующей информацией об ОС устройства пользователя
   HAVING platf_name IS NOT NULL    
   ORDER BY Dates;
  