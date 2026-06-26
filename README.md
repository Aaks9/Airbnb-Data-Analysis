# Airbnb Paris Market Analysis

An end-to-end data analytics project on 51,000+ Airbnb listings in Paris — covering data ingestion, PostgreSQL modelling, exploratory analysis, statistical testing, and a Power BI dashboard.

---

## Tech Stack

![Python](https://img.shields.io/badge/Python-3.11-blue?logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?logo=powerbi&logoColor=black)
![pandas](https://img.shields.io/badge/pandas-2.x-150458?logo=pandas&logoColor=white)
![scipy](https://img.shields.io/badge/scipy-statistical%20testing-8CAAE6)

---

## Project Structure

```
airbnb-paris/
│
├── data_ingestion_and_cleaning.ipynb   # CSV → cleaning → PostgreSQL ingestion
├── airbnb_market_analysis.ipynb        # Full EDA, statistical tests, spatial analysis
├── paris_listings.sql                  # Exploratory SQL queries
├── views.sql                           # PostgreSQL views (cleaning + feature engineering)
├── Airbnb_Paris_Dashboard.pbix         # Power BI report
└── README.md
```

---

## Pipeline

### 1 · Ingestion & Cleaning &nbsp;(`data_ingestion_and_cleaning.ipynb`)

- Loaded raw CSV (`Listings.csv`) with `latin1` encoding; filtered to Paris-only records
- Handled nulls in `host_response_time`, dropped uninformative columns (`district`)
- Exported cleaned data to PostgreSQL via SQLAlchemy (`airbnb_project` database, `listings` table)

### 2 · SQL Layer &nbsp;(`views.sql`)

Two layered views replace manual filtering in every downstream query:

| View | Purpose |
|---|---|
| `clean_listings` | Filters: `price > 0`, `price ≤ 1000`, `bedrooms IS NOT NULL AND ≤ 5`, valid superhost and host_since |
| `listings_final` | Adds 8 engineered features on top of `clean_listings` |

**Engineered features in `listings_final`:**

- `is_luxury` — flag for listings priced ≥ £800
- `price_per_person` — price ÷ accommodates
- `accommodation_size` — binned: Solo / Couple / Family / Group
- `nights_bin` — binned: Short / Medium / Long / Very Long
- `host_experience` — years since host joined
- `host_exp_bins` — low / med / high experience tier
- `property_group` — Apartment / House / Hotel / Other
- `review_bin` — High / Medium / Low rating tier

**Analysis views built on `listings_final`:** `neighbourhood_price`, `neighbourhood_density`, `price_by_room_type`, `price_by_bedrooms`, `superhost_price`, `accommodates_price_analysis`, `top_hosts_top20`, and more.

### 3 · EDA &nbsp;(`airbnb_market_analysis.ipynb`)

Analysis across five dimensions:

**Distribution & Outlier Handling**
- Price capped at £1,000 (removes ~0.36% of data while preserving the luxury segment)
- `maximum_nights` dropped — placeholder values (e.g. 1,125,000) rendered it analytically unusable
- Log-transformed price used throughout for visual analysis

**Categorical Analysis**
- Room type × accommodation size crosstab: private rooms serve solo travellers (~85%), entire homes dominate family/group stays
- Superhost vs minimum nights: superhosts concentrate in short-stay listings, suggesting a review-maximisation strategy

**Numerical Analysis**
- Price scales with bedrooms and accommodates — but only within the non-luxury segment
- Luxury listings hold price constant regardless of size (market positioning > property size)
- Dual-axis time series: supply growth and average price move inversely — increasing supply applies downward pressure on nightly rates

**Spatial Analysis**
- Hexbin maps of listing density and log-transformed price reveal a clear central-Paris pricing premium
- High-density residential clusters (Buttes-Chaumont, Ménilmontant) show elevated supply but lower prices — supply concentration ≠ pricing power

**Statistical Testing**
- Kruskal-Wallis tests run for all 6 categorical variables against price (non-parametric, appropriate for skewed price data)
- Dunn's post-hoc tests with Bonferroni correction identify which specific neighbourhood and room type pairs differ significantly

---

## Key Findings

### Effect sizes reveal what actually drives price

All six variables are statistically significant (p ≈ 0), but η² separates meaningful drivers from noise:

| Variable | η² | Practical effect |
|---|---|---|
| `accommodation_size` | 0.2254 | Large |
| `property_type` | 0.1997 | Large |
| `neighbourhood` | 0.1420 | Large |
| `room_type` | 0.1252 | Medium–large |
| `instant_bookable` | 0.0142 | Small |
| `host_is_superhost` | 0.0090 | **Negligible** |

> **Statistical vs practical significance:** With n ≈ 51k, any real difference will reach p ≈ 0. Effect size (η²) is the meaningful metric. `accommodation_size` and `property_type` are the dominant pricing levers. Superhost status, despite p = 1.08e⁻¹⁰¹, explains less than 1% of price variance — a textbook example of the p-value trap in large datasets.

### Other findings

- **Luxury listings defy size-based pricing:** Non-luxury listings follow a clear bedroom → price staircase. Luxury listings maintain high prices across all bedroom counts — segment positioning outweighs property size.
- **Hotel-style rooms command the highest median prices** in every neighbourhood, often exceeding entire homes — service-based pricing rather than space-based.
- **Neighbourhood rankings are room-type-stable:** The top 5 neighbourhoods by price hold position regardless of room type, confirming location as a structural (not incidental) pricing factor.
- **Review scores are internally consistent:** Overall rating correlates most strongly with value (r ≈ 0.73) and cleanliness (r ≈ 0.70); location scores weakly (r ≈ 0.44), meaning hosts outside premium neighbourhoods can compete on ratings by delivering value and hygiene.

---

## Setup

### Prerequisites

- Python 3.9+
- PostgreSQL 14+ running locally
- Power BI Desktop (for the `.pbix` file)

### Python dependencies

```bash
pip install pandas numpy matplotlib seaborn scipy scikit-posthocs sqlalchemy psycopg2-binary
```

### Database setup

1. Create a PostgreSQL database named `airbnb_project`
2. Set your credentials as environment variables before running the ingestion notebook:

```bash
export DB_USER=your_username
export DB_PASSWORD=your_password
```

3. Run `data_ingestion_and_cleaning.ipynb` to load data into the `listings` table
4. Run all statements in `views.sql` to create the view layer

### Analysis

Open `airbnb_market_analysis.ipynb` — the notebook reads from the cleaned CSV directly and does not require a live database connection.

---

## Dataset

[Inside Airbnb — Paris Listings](http://insideairbnb.com/get-the-data/) · ~51,000 listings

---

## Author

**Aakanksha** · [GitHub](https://github.com/Aaks9) · [LinkedIn](https://linkedin.com/in/)
