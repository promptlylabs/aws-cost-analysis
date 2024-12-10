## This was a first attempt using the AWS CLI. To better handle data, Python was used.

#!/bin/bash

# Need to be logged in as root using: aws sso login --profile <profile-name>

# Requirements:
# 1. Get the difference between the current month and the previous month, both in absolute and percentage terms. For each account.
# 2. Get the difference between the current month and the previous month, both in absolute and percentage terms. For each service, for each account. Top x
# 3. For each account/service, get the top usage types in cost

# Variables
profile_name="root"
month="11"

# Needs updates to accomodate end of year, jumping to next year or previous year
start_date="2024-$(($month - 1))-01"
mid_date="2024-$month-01"
end_date="2024-$(($month + 1))-01"

echo "Start date: $start_date"
echo "Mid date: $mid_date"
echo "End date: $end_date"

### Get costs per account
accounts=$(aws organizations list-accounts --profile $profile_name | jq -r '.Accounts[] | "\(.Id) \(.Name)"')

# # Print table header
# printf "%-15s %-25s %-20s %-20s %-20s %-20s\n" "Account ID" "Account Name" "Past Month" "Current Month" "Absolute Diff" "Relative Diff (%)"
#
# while IFS= read -r account; do
#   account_id=$(echo $account | cut -d' ' -f1)
#   account_name=$(echo $account | cut -d' ' -f2-)
#
#   cost_data=$(aws ce \
#     --profile $profile_name get-cost-and-usage \
#     --no-cli-pager \
#     --time-period Start=$start_date,End=$end_date \
#     --granularity MONTHLY \
#     --metrics AmortizedCost \
#     --filter '{
#       "And": [
#         {"Dimensions": {"Key": "LINKED_ACCOUNT", "Values": ["'"$account_id"'"]}},
#         {"Not": {"Dimensions": {"Key": "RECORD_TYPE", "Values": ["Tax"]}}}
#       ]
#     }')
#
#   amount1=$(echo "$cost_data" | jq -r '.ResultsByTime[0].Total.AmortizedCost.Amount')
#   amount2=$(echo "$cost_data" | jq -r '.ResultsByTime[1].Total.AmortizedCost.Amount')
#
#   # Check for negative values
#   if (( $(echo "$amount1 < 0" | bc -l) )) || (( $(echo "$amount2 < 0" | bc -l) )); then
#     echo "Error: Negative values detected for account $account_id ($account_name). Skipping..."
#     continue
#   fi
#
#   absolute_diff=$(echo "$amount2 - $amount1" | bc)
#   relative_diff=$(echo "scale=2; ($absolute_diff / $amount1) * 100" | bc)
#
#   printf "%-15s %-25s %-20.2f %-20.2f %-20.2f %-20.2f\n" "$account_id" "$account_name" $amount1 $amount2 $absolute_diff $relative_diff
# done <<< "$accounts"

### Get costs per service

services=$(aws ce \
  --profile $profile_name get-cost-and-usage \
  --no-cli-pager \
  --time-period Start=$start_date,End=$end_date \
  --granularity MONTHLY \
  --group-by Type=DIMENSION,Key=SERVICE \
  --metrics AmortizedCost \
  --filter '{
      "And": [
        {"Dimensions": {"Key": "LINKED_ACCOUNT", "Values": ["_______"]}},
        {"Not": {"Dimensions": {"Key": "RECORD_TYPE", "Values": ["Tax"]}}}
      ]
    }')

# save $services | jq to a file
echo $services | jq '.ResultsByTime[0].Groups[]' > services-0.json
echo $services | jq '.ResultsByTime[1].Groups[]' > services-1.json

echo $services | jq -r '.ResultsByTime[0].Groups[] | "\(.Keys[0]) | \(.Metrics.AmortizedCost.Amount)"' | sort -t "|" -k2,2 -n -r | head -n 10

previous_services= $(echo $services | jq -r '.ResultsByTime[0].Groups[] | "\(.Keys[0]) | \(.Metrics.AmortizedCost.Amount)"' | sort -t "|" -k2,2 -n -r | head -n 10)




# accounts=$(aws organizations list-accounts --profile $profile_name | jq -r '.Accounts[] | "\(.Id) \(.Name)"')
# 
# while IFS= read -r account; do
#   account_id=$(echo $account | cut -d' ' -f1)
#   account_name=$(echo $account | cut -d' ' -f2-)
# 
#   echo "Account ID: $account_id, Account Name: $account_name"
#   printf "%-25s %-20s %-20s %-20s %-20s\n" "Service" "Past Month" "Current Month" "Absolute Diff" "Relative Diff (%)"
# 
#   services=$(aws ce \
#     --profile $profile_name get-cost-and-usage \
#     --no-cli-pager \
#     --time-period Start=$start_date,End=$end_date \
#     --granularity MONTHLY \
#     --group-by Type=DIMENSION,Key=SERVICE \
#     --metrics AmortizedCost \
#     --filter '{
#       "And": [
#         {"Dimensions": {"Key": "LINKED_ACCOUNT", "Values": ["'"$account_id"'"]}},
#         {"Not": {"Dimensions": {"Key": "RECORD_TYPE", "Values": ["Tax"]}}}
#       ]
#     }' | jq -r '.ResultsByTime[0].Groups[] | "\(.Keys[0]) \(.Metrics.AmortizedCost.Amount)"' | sort -k2 -n -r | head -n 10)
# 
#   service_costs=()
# 
#   while IFS= read -r service; do
#     service_name=$(echo "$service" | rev | cut -d' ' -f2- | rev)
#     amount1=$(echo "$service" | awk '{print $NF}')
# 
#     cost_data=$(aws ce \
#       --profile $profile_name get-cost-and-usage \
#       --no-cli-pager \
#       --time-period Start=$start_date,End=$end_date \
#       --granularity MONTHLY \
#       --metrics AmortizedCost \
#       --filter '{
#         "And": [
#           {"Dimensions": {"Key": "LINKED_ACCOUNT", "Values": ["'"$account_id"'"]}},
#           {"Dimensions": {"Key": "SERVICE", "Values": ["'"$service_name"'"]}},
#           {"Not": {"Dimensions": {"Key": "RECORD_TYPE", "Values": ["Tax"]}}}
#         ]
#       }')
# 
#     amount2=$(echo "$cost_data" | jq -r '.ResultsByTime[1].Total.AmortizedCost.Amount')
# 
#     # Check for negative values
#     if (($(echo "$amount1 < 0" | bc -l))) || (($(echo "$amount2 < 0" | bc -l))); then
#       echo "Error: Negative values detected for service $service_name. Skipping..."
#       continue
#     fi
# 
#     absolute_diff=$(echo "$amount2 - $amount1" | bc)
#     relative_diff=$(echo "scale=2; ($absolute_diff / $amount1) * 100" | bc)
# 
#     service_costs+=("$service_name $amount1 $amount2 $absolute_diff $relative_diff")
#   done <<<"$services"
# 
#   # Sort services by past month cost in descending order
#   sorted_services=$(printf "%s\n" "${service_costs[@]}" | sort -k2 -n -r)
# 
#   # Print sorted services
#   while IFS= read -r sorted_service; do
#     service_name=$(echo "$sorted_service" | awk '{print $1}')
#     amount1=$(echo "$sorted_service" | awk '{print $2}')
#     amount2=$(echo "$sorted_service" | awk '{print $3}')
#     absolute_diff=$(echo "$sorted_service" | awk '{print $4}')
#     relative_diff=$(echo "$sorted_service" | awk '{print $5}')
# 
#     printf "%-25s %-20.2f %-20.2f %-20.2f %-20.2f\n" "$service_name" $amount1 $amount2 $absolute_diff $relative_diff
#   done <<<"$sorted_services"
# 
#   echo ""
# done <<<"$accounts"
