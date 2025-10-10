#!/bin/bash

# Export data from staging database using curl and Supabase REST API
# Service role key đã được cung cấp

SUPABASE_URL="https://fvgjmfytzdnrdlluktdx.supabase.co"
SERVICE_ROLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ2Z2ptZnl0emRucmRsbHVrdGR4Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTI1NjUxMSwiZXhwIjoyMDc0ODMyNTExfQ.Mb_5J2etfHN-FqoTQ7FRfVPh9iTObUPCj_2FUHTuqSQ"

# Tạo thư mục data
mkdir -p data

echo "🚀 Exporting data from staging database..."
echo "📅 Date: $(date)"
echo "🔗 URL: $SUPABASE_URL"
echo "=========================================="

# Function để export một bảng
export_table() {
    local table_name=$1
    local description=$2

    echo ""
    echo "📊 Exporting: $table_name ($description)"

    # Gọi API để lấy data
    response=$(curl -s -w "\n%{http_code}" \
        -H "apikey: $SERVICE_ROLE_KEY" \
        -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
        -H "Content-Type: application/json" \
        "$SUPABASE_URL/rest/v1/$table_name?select=*&order=id.asc")

    # Tách response body và HTTP status
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)

    if [ "$http_code" -eq 200 ]; then
        # Kiểm tra có data không
        if [ "$body" = "[]" ]; then
            echo "⚠️  No data found"
        else
            # Đếm số records
            count=$(echo "$body" | jq '. | length' 2>/dev/null || echo "unknown")
            echo "✅ Found $count records"

            # Lưu file JSON
            echo "$body" | jq '.' > "data/${table_name}.json"
            echo "💾 Saved: data/${table_name}.json"

            # Convert sang CSV nếu có jq
            if command -v jq &> /dev/null; then
                echo "$body" | jq -r '(.[0] | keys_unsorted) as $keys | $keys, (map([.[ $keys[] ]]))[] | @csv' > "data/${table_name}.csv" 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo "📊 Saved: data/${table_name}.csv"
                fi
            fi
        fi
    else
        echo "❌ Error: HTTP $http_code"
        echo "Response: $body"
    fi
}

# Export các bảng quan trọng
export_table "attributes" "Game attributes and currency definitions"
export_table "currencies" "Currency types and configurations"
export_table "channels" "Sales channels configuration"
export_table "roles" "Role definitions"
export_table "permissions" "System permissions"
export_table "exchange_rates" "Exchange rate configurations"
export_table "trading_fee_chains" "Trading fee calculation chains"
export_table "profiles" "User profiles"
export_table "game_accounts" "Game account management"
export_table "currency_inventory" "Currency inventory tracking"

echo ""
echo "=========================================="
echo "✅ Export completed!"
echo "📁 Check the data/ directory for exported files"

# Show summary
echo ""
echo "📊 Export Summary:"
echo "------------------------------------------"

if [ -d "data" ]; then
    for file in data/*.json; do
        if [ -f "$file" ]; then
            filename=$(basename "$file" .json)
            size=$(du -h "$file" | cut -f1)
            if command -v jq &> /dev/null; then
                count=$(jq '. | length' "$file" 2>/dev/null || echo "unknown")
                echo "✅ $filename: $count records ($size)"
            else
                echo "✅ $filename: ($size)"
            fi
        fi
    done
fi

echo ""
echo "🎯 Done! All exported files are in the data/ directory"