SELECT * FROM listings;

SELECT 
    PERCENTILE_CONT(0.9964) WITHIN GROUP (ORDER BY price) AS p99_price
FROM listings;

CREATE OR REPLACE VIEW clean_listings AS
SELECT *
FROM listings
WHERE price>0 
  AND price<=1000
  AND bedrooms IS NOT NULL
  AND bedrooms<=5
  AND host_is_superhost IS NOT NULL
  AND host_since IS NOT NULL;

DROP VIEW clean_listings;

CREATE OR REPLACE VIEW listings_final AS
SELECT 
    *,
	-- Luxury flag
    CASE 
        WHEN price>=800 THEN 1
        ELSE 0
    END AS is_luxury,

    -- Price efficiency
    (price / NULLIF(accommodates, 0)) AS price_per_person,

    -- Accommodation size bins
    CASE 
	    WHEN accommodates <= 2 THEN 'Solo'
	    WHEN accommodates <= 4 THEN 'Couple'
	    WHEN accommodates <= 8 THEN 'Family'
	    ELSE 'Group'
	END AS accommodation_size,

    -- Minimum nights segmentation
    CASE 
	    WHEN minimum_nights <= 3 THEN 'Short (1-3)'
	    WHEN minimum_nights <= 7 THEN 'Medium (4-7)'
	    WHEN minimum_nights <= 30 THEN 'Long (8-30)'
	    ELSE 'Very Long (30+)'
	END AS nights_bin,

    -- Host experience (years)
    CASE 
	    WHEN host_since IS NOT NULL THEN 
	        EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM host_since::DATE)
	    ELSE NULL
	END AS host_experience,

    -- Host experience bins
    CASE 
	    WHEN EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM host_since::DATE) <= 10 THEN 'low'
	    WHEN EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM host_since::DATE) <= 15 THEN 'med'
	    ELSE 'high'
	END AS host_exp_bins,

    -- Property type grouping
    CASE 
        WHEN property_type ILIKE '%apartment%' THEN 'Apartment'
        WHEN property_type ILIKE '%house%' THEN 'House'
        WHEN property_type ILIKE '%hotel%' THEN 'Hotel'
        ELSE 'Other'
    END AS property_group,

    -- Review bins
    CASE 
        WHEN review_scores_rating >= 95 THEN 'High'
        WHEN review_scores_rating >= 90 THEN 'Medium'
        ELSE 'Low'
    END AS review_bin

FROM clean_listings;

CREATE OR REPLACE VIEW luxury_price_analysis AS
SELECT 
    is_luxury,
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(*) AS total_listings
FROM listings_final
GROUP BY is_luxury;

CREATE OR REPLACE VIEW price_by_room_type AS
SELECT 
    room_type,
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(*) AS total_listings
FROM listings_final
GROUP BY room_type
ORDER BY avg_price DESC;

CREATE OR REPLACE VIEW price_by_bedrooms AS
SELECT 
    bedrooms,
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(*) AS total_listings
FROM listings_final
GROUP BY bedrooms
ORDER BY bedrooms;

CREATE OR REPLACE VIEW neighbourhood_price AS
SELECT 
    neighbourhood,
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(*) AS total_listings
FROM listings_final
GROUP BY neighbourhood
ORDER BY avg_price DESC;

CREATE OR REPLACE VIEW neighbourhood_density AS
SELECT 
    neighbourhood,
    COUNT(*) AS total_listings
FROM listings_final
GROUP BY neighbourhood
ORDER BY total_listings DESC;

CREATE OR REPLACE VIEW superhost_price AS
SELECT 
    host_is_superhost,
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(*) AS total_listings
FROM listings_final
GROUP BY host_is_superhost;

CREATE OR REPLACE VIEW instant_bookable_analysis AS
SELECT 
    instant_bookable,
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(*) AS total_listings
FROM listings_final
GROUP BY instant_bookable;

CREATE OR REPLACE VIEW top_hosts_top20 AS
SELECT *
FROM (
    SELECT 
        host_id,
        COUNT(*) AS total_listings,
        RANK() OVER (ORDER BY COUNT(*) DESC) AS host_rank
    FROM listings_final
    GROUP BY host_id
) t
WHERE host_rank <= 20;

CREATE OR REPLACE VIEW nights_bin_price AS
SELECT 
    nights_bin,
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(*) AS total_listings
FROM listings_final
GROUP BY nights_bin
ORDER BY avg_price DESC;

CREATE OR REPLACE VIEW accommodates_price_analysis AS
SELECT 
    accommodates,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(price_per_person), 2) AS avg_price_per_person,
    COUNT(*) AS total_listings
FROM listings_final
GROUP BY accommodates
ORDER BY accommodates;

CREATE OR REPLACE VIEW accommodation_size_price AS
SELECT 
    accommodation_size,
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(*) AS total_listings
FROM listings_final
GROUP BY accommodation_size;

CREATE OR REPLACE VIEW property_group_price AS
SELECT 
    property_group,
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(*) AS total_listings
FROM listings_final
GROUP BY property_group;

SELECT viewname, definition
FROM pg_views
WHERE definition ILIKE '%listings%';



