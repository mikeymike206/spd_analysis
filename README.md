# SPD Resposnse Time Analysis in 2024
SPD response time analysis in 2024.

## Project Background and Analysis
This project analyzes Priority 1 incident response times from the Seattle Police Department (SPD), focusing on the department’s most urgent call category: Immediate/High Priority – Poses Threat to Life. These incidents represent the most severe types of emergencies, where rapid response is critical to public safety outcomes.

According to SPD, the department has faced persistent staffing shortages in recent years. In response, there has been a significant push to hire new officers and attract lateral transfers through aggressive financial incentives. Despite these efforts, response times remain a key performance indicator under scrutiny—especially given the department’s stated goal of a 7-minute response time for Priority 1 incidents.

The purpose of this project is twofold:

Evaluate each precinct’s performance against the 7-minute benchmark.

Identify operational factors (e.g., dispatch volume, unit availability, geography) that may be contributing to slower response times based on publicly available City of Seattle 2024 dispatch data.

To support this analysis, two interactive dashboards were developed:

The first dashboard compares Priority 1 and Priority 2 response times by precinct, providing context for both immediate and urgent-but-non-lethal incidents (Priority 2 calls are defined as “Could Escalate If Assistance Does Not Arrive”).

The second dashboard offers stakeholders a comprehensive view of 2024 incident patterns, including:

Geographic heat maps

Filterable visuals by precinct, neighborhood, and time of day

Metrics on unit response and dispatch delays

Together, these tools aim to provide actionable insights for SPD leadership, city officials, and community advocates working to improve emergency response efficiency and public safety outcomes citywide.

# Tools & Technologies
•	MySQL: Used for raw data ingestion, cleaning, time parsing, and transformation
•	Power BI: For interactive visualizations, filtering by hour, month, precinct, and priority level
•	RStudio: For advanced statistical analysis (ANOVA, regression, Tukey HSD)
•	DAX: For Power BI measures, KPIs, and custom time aggregations


## Data Structure

The filtered dataset used in this analysis focuses exclusively on Priority 1 incidents, representing the Seattle Police Department’s highest urgency calls—those involving immediate threats to life. The original dataset contained over 500,000 rows of raw dispatch records. After cleaning and filtering for relevant variables and valid entries, the final dataset included approximately 150,000 records spanning the period from January 1 to December 31, 2024.

Key variables used in the analysis include:

first_response_time: Time elapsed from dispatch to first unit arrival

dispatch_precinct: SPD precinct assigned to the incident

dispatch_neighborhood: Neighborhood in which the incident occurred

responding_units: Number of units dispatched to the call

CAD_Event_Original_Time_Queued: Timestamp of when the call entered the queue

incident_month and incident_hour: Extracted time components for temporal analysis

All data cleaning and transformation were conducted using MySQL, ensuring accuracy, consistency, and scalability of the data pipeline.

## Key Variables

## Executive Summary

## Key Findings

## Insight Deep Dive

## Recommendations

## Why This Matters
