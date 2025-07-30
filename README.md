# SPD Resposnse Time Analysis in 2024

## Project Background and Analysis
This project analyzes Priority 1 incident response times from the Seattle Police Department (SPD), focusing on the department’s most urgent call category: Immediate/High Priority – Poses Threat to Life. These incidents represent the most severe types of emergencies, where rapid response is critical to public safety outcomes.

According to SPD, the department has faced persistent staffing shortages in recent years. In response, there has been a significant push to hire new officers and attract lateral transfers through aggressive financial incentives. Despite these efforts, response times remain a key performance indicator under scrutiny—especially given the department’s stated goal of a 7-minute response time for Priority 1 incidents.

### The purpose of this project is twofold:

- Evaluate each precinct’s performance against the 7-minute benchmark. https://shorturl.at/BCyiB

- Identify operational factors (e.g., dispatch volume, unit availability, geography) that may be contributing to slower response times based on publicly available City of Seattle 2024 dispatch data.

### To support this analysis, two interactive dashboards were developed:

The first dashboard compares Priority 1 and Priority 2 response times by precinct, providing context for both immediate and urgent-but-non-lethal incidents (Priority 2 calls are defined as “Could Escalate If Assistance Does Not Arrive”).

The second dashboard offers stakeholders a comprehensive view of 2024 incident patterns, including:

- Geographic heat maps

- Filterable visuals by precinct, neighborhood, and time of day

- Metrics on unit response and dispatch delays

Together, these tools aim to provide actionable insights for SPD leadership, city officials, and community advocates working to improve emergency response efficiency and public safety outcomes citywide.

# Tools & Technologies
- MySQL: Used for raw data ingestion, cleaning, time parsing, and transformation
- Power BI: For interactive visualizations, filtering by hour, month, precinct, and priority level
- RStudio: For advanced statistical analysis (ANOVA, regression, Tukey HSD)
- DAX: For Power BI measures, KPIs, and custom time aggregations


## Data Structure

The filtered dataset used in this analysis focuses exclusively on Priority 1 incidents, representing the Seattle Police Department’s highest urgency calls—those involving immediate threats to life. The original dataset contained over 500,000 rows of raw dispatch records. After cleaning and filtering for relevant variables and valid entries, the final dataset included approximately 150,000 records spanning the period from January 1 to December 31, 2024.

### Key variables used in the analysis include:

- first_response_time: Time elapsed from dispatch to first unit arrival

- dispatch_precinct: SPD precinct assigned to the incident

- dispatch_neighborhood: Neighborhood in which the incident occurred

- responding_units: Number of units dispatched to the call

- CAD_Event_Original_Time_Queued: Timestamp of when the call entered the queue

- incident_month and incident_hour: Extracted time components for temporal analysis

All data cleaning and transformation were conducted using MySQL, ensuring accuracy, consistency, and scalability of the data pipeline.

## Executive Summary

### Key Findings
- Total Priority 1 Incidents: 24,938 calls classified as immediate or high priority—posing a direct threat to life—were dispatched across Seattle in 2024.

- Average Response Time: The overall average response time for Priority 1 incidents was 9.97 minutes, which is above SPD’s stated goal of a 7-minute target.

- Best Performing Precincts:

  - West Precinct: Fastest average response time at 8.39 minutes

  - East Precinct: Second fastest with an average of 8.48 minutes

Area of Concern:

- North Precinct: Recorded the slowest average response time at 12.33 minutes, significantly lagging behind the SPD target and other precincts.

Call Volume:

- West and North Precincts each handled the highest call volumes, with approximately 7,000 Priority 1 incidents each.

Operational Metrics:

- Average Number of Responding Units: 3.12 units per incident

- Average Dispatch Delay: 2.17 minutes before units were deployed

Temporal Trends:

- Incident volume shows a gradual decline from January to December.

- The fastest response times occurred between 12:00 AM–3:00 AM and 5:00 AM–9:00 AM.

Geographic Variation:

- Belltown recorded the fastest neighborhood response time at 7.22 minutes.

### Dashboard

<img width="1326" height="749" alt="image" src="https://github.com/user-attachments/assets/81fefebc-0ebe-482a-9b39-30ce26457d9f" />

<img width="1340" height="750" alt="image" src="https://github.com/user-attachments/assets/87ddf7a3-fddc-48fc-abed-977433563071" />


## Insight Deep Dive

### Statistical Analysis 
Statistical Tests
1. Linear Regression – Response Time ~ Call Volume (by Precinct)

lm_model <- lm(avg_response_time_sec ~ call_volume, data = priority1_summary)
summary(lm_model)
Result:
- p = 0.71 | R² = 0.054
- Conclusion: No significant relationship between incident volume and response time. Suggests volume alone is not a driver of delays.
________________________________________
2. One-Way ANOVA – Response Time by Precinct

aov_model <- aov(first_response_time ~ dispatch_precinct, data = priority1_data)
summary(aov_model)
Result:
- F = 55.75 | p < 2e-16
- Conclusion: Strong evidence of different response times by precinct. Operational practices or geography may be contributing.
________________________________________
3. Tukey's HSD – Post-hoc by Precinct

TukeyHSD(aov_model)
Result:
- NORTH showed statistically longer response times vs EAST, WEST, and SOUTH.
- WEST vs EAST had no significant difference.
- Conclusion: Prioritize intervention in NORTH precinct; examine EAST/WEST processes as potential models.
________________________________________
4. Multiple Linear Regression – Response Time ~ Precinct + Responding Units

lm_model <- lm(first_response_time ~ dispatch_precinct + responding_units, data = priority1_data)
summary(lm_model)
Result:
- responding_units had a negative coefficient (≈ -24.6 seconds/unit) → More officers = faster response
- Precinct remained a significant predictor
- Conclusion: Both geography and officer count impact response time, though model fit was modest.


## Recommendations

This analysis underscores the urgent need to increase staffing levels within the Seattle Police Department, particularly to meet the 7-minute response time benchmark for Priority 1 incidents. While the current data does not include information on the number of active-duty officers per precinct or their distribution across shifts, response time trends suggest clear operational gaps.

### Key recommendations:

Replicate Effective Practices:
The East and West Precincts consistently achieve sub-10-minute response times. SPD leadership should investigate and replicate the operational strategies, staffing models, and dispatch practices used in these precincts across the city.

Address North Precinct Delays: The North Precinct, with an average response time of 12.33 minutes, represents a significant area of concern. Given its geographic location and the large service area it covers, SPD should consider:

- Increasing officer allocation to this precinct

- Enhancing dispatch coverage strategies during peak hours

- Improving protocols for resource reallocation across zones

Shift-Based Staffing Adjustments: Response time analysis reveals consistent delays during 8:00–11:00 AM and 4:00–6:00 PM. SPD should explore reallocating or increasing personnel during these windows, which may coincide with shift changes or peak call volumes.

While these recommendations are based on dispatch data and response time metrics, future analysis incorporating real-time officer availability, shift schedules, and unit-level resource allocation would provide a more comprehensive operational picture.

## Why This Matters
