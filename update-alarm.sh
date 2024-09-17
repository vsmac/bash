#!/bin/bash

# Set AWS Region (you can modify this or set it via AWS CLI config)
AWS_REGION="us-east-1"

# Fetch alarms with "INSUFFICIENT_DATA" state
INSUFFICIENT_DATA_ALARMS=$(aws cloudwatch describe-alarms --state-value INSUFFICIENT_DATA --query "MetricAlarms[?StateValue=='INSUFFICIENT_DATA'].AlarmName" --output text --region $AWS_REGION)

# Check if any alarms are returned
if [ -z "$INSUFFICIENT_DATA_ALARMS" ]; then
  echo "No alarms with 'INSUFFICIENT_DATA' state found."
  exit 0
fi

echo "Found the following alarms with 'INSUFFICIENT_DATA' state:"
echo "$INSUFFICIENT_DATA_ALARMS"

# Loop through each alarm and update its missing data treatment policy
for ALARM_NAME in $INSUFFICIENT_DATA_ALARMS; do
  echo "Updating missing data treatment for alarm: $ALARM_NAME"

  # Update alarm with missing data treatment as 'ignore'
  aws cloudwatch put-metric-alarm \
    --alarm-name "$ALARM_NAME" \
    --missing-data-treatment "ignore" \
    --region $AWS_REGION

  if [ $? -eq 0 ]; then
    echo "Successfully updated alarm: $ALARM_NAME"
  else
    echo "Failed to update alarm: $ALARM_NAME"
  fi
done
