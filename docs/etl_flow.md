# ETL Flow

1. RAW tables are loaded from source files.
2. CLEAN layer applies:
   - Null handling
   - Date sanity checks
   - Flag derivations
3. ANALYTICS layer:
   - Loads dimensions first
   - Loads facts after dimension resolution
   - Allocates payments correctly
   - Enforces grain consistency
