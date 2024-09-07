![alt text](https://ineuron.ai/images/ineuron-logo.png)

# Inventory Dashboard

## SQL

Once the SQl file is complete we are left with a Master table with all the required columns and data namely

1. Inventory
2. Orders
3. Products
4. Date
5. Weekly Demand

We will be using only the Weekly demand and the Inventory table for the visualization as we have created the Master table using the other tables.

## Loading the Data

I will be giving 2 Methods to load the data where in the first Method, you will be directly connecting the data from MySQL to Tableau. Incase if you face any problems while connectlg Mysql to Tableau then use the second Method which uses the data that is saved into CSV.

**Method 1: MySQl to Tableau**

    We have an option to load the data directly from the Mysql Database. to do so follow the below steps

    1. As you open Tableau Desktop, You will see a blue pane on the left which connects to various data sources. Go to 'To a Server' Section and select 'MySQL'

    2. A dialogue box will appearAsking for the detals of the MySQL Server like

        a. **Server** : You have to give the IP address here. (It is usually 127.0.0.1)
        b. **Port** : You have to give the Port number in which your MySQL is installed.(It is usually 3306)
        c. **Database** : Give the Database name. For this project we have created the database with Name 'inventory_management_project'
        d. **Username** : You have to give the username of MySQL, which usually appers on the screen when you try to open workbench.
        e. **Password** : You have to give the password which you use to open MySQL workbench.

    3. Click on Sign In

    **Note**: Servername, Port number, Username and Password will change for each individual based on your System settings. Please make sure you use your credentials Correctly. Database name given here is what i have created in MySQl. If you have used a different name Please use that name instead of what I have given above.
    All the credentials have to be correct in order for you to load the data correctly into tableau.

**Method 2: CSV to Tableau**

    1. As you open Tableau Desktop, You will see a blue pane on the left which connects to various data sources. Go to 'To a File' Section and select 'Text file'

    2. Click and drag the 2 sheets that apper on the left pane into the white space to activate the sheet. Connect both the sheets using Product ID.

