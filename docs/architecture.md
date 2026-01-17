# Data Warehouse Architecture

The warehouse is organized into three layers:

## RAW Layer
- Stores source data as-is
- No business logic applied
- Preserves original grain and nulls

## CLEAN Layer
- Applies data cleansing rules
- Removes impossible dates
- Standardizes flags and statuses
- Prepares data for dimensional modeling

## ANALYTICS Layer
- Star schema design
- Fact and dimension tables
- Surrogate keys
- Analytics-ready measures
