-- Average delay per route — identifies routes most prone to delays
SELECT
    r.route_name,
    AVG(CAST(st.delay_minutes AS FLOAT)) AS avg_delay_minutes,
    COUNT(st.stop_id) AS total_stops
FROM stop_times st
JOIN routes r ON st.route_id = r.route_id
GROUP BY r.route_name
ORDER BY avg_delay_minutes DESC;
