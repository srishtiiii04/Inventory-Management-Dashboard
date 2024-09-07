![alt text](https://ineuron.ai/images/ineuron-logo.png)

# Inventory Data Analysis

### Visual - 1 - Revenue Distribution

Highlight table showing Revenue Distribution

**Visualization**: Highlight Table Table

**Columns**: ABC Analysis

**Rows**: AYZ Analysis

**Marks Shelf**: 
        Color: Annual Revenue - Sum
        Text : Annual Revenue - Sum


### Visual - 2 - Inventory Turnover Ratio Matrix

Highlight table showing Revenue Distribution

**Visualization**: Highlight Table Table

**Columns**: ABC Analysis

**Rows**: AYZ Analysis

**Marks Shelf**: 
        Color: Inventory Turn over ratio - Agg
        Text : Inventory Turn over ratio - Agg

To calculate Inventory ratio,  Create a calculated field with the formula SUM([annual Revenue])/SUM([value in Inventory]).

### Visual - 3 - Value in inventory Distribution

Highlight table showing Revenue Distribution

**Visualization**: Highlight Table Table

**Columns**: ABC Analysis

**Rows**: AYZ Analysis

**Marks Shelf**: 
        Color: Value in inventory - Sum
        Text : Value in inventory - Sum

### Visual - 4 - Pereto Chart

Dual Bar and line chart showing Pereto principle

**Visualization**: Line and Bar graph

**Columns**: Product ID

**Rows**: Annual Revenue(Bar) and annual revenue(Line)

For the second annual revenue use edit table calculation and then for primary calculation use running total and sum with specific dimensions for compute using and sort order by specific dimensions.
add secondary calculation
For secondary calculation type use percent of total with specific dimensions for compute using and sort order by specific dimensions.

### Visual - 5 - Revenue Forecast

Line chart showing the revenue forecast

**Visualization**:Line Chart

**Rows**: Sales Amount

**Columns**: Date(Week)

**Marks Shelf**: 
        Color: Forecast Indicator - ATTR
        Text : Sales Amount - Sum

From Analysis tool bar add the forecast line for the next 2 weeks

### Visual - 6 - Safety Stock and Reorder Time

Text Table showing various columns

**Visualization**:Text Table

**Rows**: Product ID, Reorder Time, Avg Lead time in Days, In STock Quantity, Reorder Point, Safety Stock

**Columns**: Measure Names

**Marks Shelf**: 
        Color: Forecast Indicator - ATTR
        Text : Sales Amount - Sum

From Analysis tool bar add the forecast line for the next 2 weeks

## Dashboard:

Make Adjustments to each visual and set the dashboard accordingly.

### Headline Cards

1. **No. Of Products**: Count (Product ID) - Text Table

2. **Inventory Value**: Sum (Value In Inventory) - Text Table

3. **Items to Reorder**: Count(Reorder Point) - Text Table

4. **Inventory Turnover Ratio**: AGG(Inventort Turnover Ratio) - Text Table


### Heading

Insert a text object and then go to Format Visual to write the Title.

