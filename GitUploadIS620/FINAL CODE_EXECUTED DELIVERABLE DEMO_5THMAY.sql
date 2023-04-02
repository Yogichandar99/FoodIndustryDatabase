/* 
IS620_Team2
Will_Bundesen
Sara_Khanjani
Tolulope_Ale
Yogichandar_Boppana
David_Calderone
*/
SET SERVEROUTPUT ON;
--#####FOR THE PRESENTATION the DROPs will need to be commented out, says Prof  -Will#####
DROP SEQUENCE seq_cusine;
DROP SEQUENCE seq_Res;
DROP SEQUENCE menuID_seq;
DROP SEQUENCE seq_customers;
DROP SEQUENCE waiter_id_seq;
DROP SEQUENCE orderID_seq;

DROP FUNCTION FIND_MENU_ITEM_ID;
DROP FUNCTION FIND_CUISINE_TYPE_ID;
DROP FUNCTION FIND_RESTAURANT_ID;
DROP FUNCTION FIND_WAITER_ID;
DROP FUNCTION FIND_CUSTOMER_ID;

--dropping all the PROCEDUREs that are used in the code as part of waiter’s table
DROP PROCEDURE details_of_waiter;
DROP PROCEDURE hire_a_waiter;
DROP PROCEDURE tip_by_state;
DROP PROCEDURE tip_of_waiter;

DROP PROCEDURE menu_items_insert;
DROP PROCEDURE RESTAURANT_INVENTORY_Insert;

DROP TABLE ORDERS_T;
DROP TABLE RESTAURANT_INVENTORY_T;
DROP TABLE Waiter_T;
DROP TABLE Customers_T;
DROP TABLE MENU_ITEMS_T;
DROP TABLE RESTAURANT_T;
DROP TABLE CUISINE_TYPE_T;

--SELECT table_name FROM user_tables; --is this necessary? 

--Team Member 1 Sara_Khanjani
CREATE SEQUENCE seq_cusine
MINVALUE 1
START WITH 1
INCREMENT BY 1;
CREATE SEQUENCE seq_Res
MINVALUE 1
START WITH 1
INCREMENT BY 1;

CREATE TABLE CUISINE_TYPE_T(
    cuisineID INT,
    cuisineName VARCHAR(100) NOT NULL,
    PRIMARY KEY (cuisineID));
CREATE TABLE RESTAURANT_T(
    Rest_ID INT,
    Rest_Name VARCHAR(100) NOT NULL,
    Rest_StrAddress VARCHAR(100) NOT NULL,
    Rest_City VARCHAR(100) NOT NULL,
    Rest_State VARCHAR(100) NOT NULL,
    R_Zip CHAR(5),
    cuisineID INT,
    PRIMARY KEY (Rest_ID),
    FOREIGN KEY (cuisineID) REFERENCES CUISINE_TYPE_T(cuisineID));

INSERT INTO CUISINE_TYPE_T VALUES (seq_cusine.nextval,'American');
INSERT INTO CUISINE_TYPE_T VALUES (seq_cusine.nextval,'BBQ');
INSERT INTO CUISINE_TYPE_T VALUES (seq_cusine.nextval,'Ethiopian');
INSERT INTO CUISINE_TYPE_T VALUES (seq_cusine.nextval,'Italian');
INSERT INTO CUISINE_TYPE_T VALUES (seq_cusine.nextval,'Indian');

INSERT INTO RESTAURANT_T VALUES (seq_Res.nextval,'Ribs_R_US','801 Pleasant Dr', 'Rockville', 'MD',  21250, 1);
INSERT INTO RESTAURANT_T VALUES (seq_Res.nextval,'Bella Italia','128 Ellington Blvd', 'Gaithersburg', 'MD',  21043, 4);
INSERT INTO RESTAURANT_T VALUES (seq_Res.nextval,'Roma','46300 Run Plaza', 'Sterling', 'VA',  21043, 4);
INSERT INTO RESTAURANT_T VALUES (seq_Res.nextval,'Bull Roast','194 Left Road', 'Bronx', 'NY',  10013, 2);
INSERT INTO RESTAURANT_T VALUES (seq_Res.nextval,'Taj Mahal','239 Right Road', 'Bronx', 'NY',  10013, 5);
INSERT INTO RESTAURANT_T VALUES (seq_Res.nextval,'Selasie','1900 Central', 'Pittsburg', 'PA',  16822, 3);
INSERT INTO RESTAURANT_T VALUES (seq_Res.nextval,'Ethiop','2159 West', 'Pittsburg', 'PA',  16822, 3);

--Run a query to show all information about all restaurants that were added to the DB
BEGIN
dbms_output.put_line('
~~~~~Full Restaurant Table After Insertion of Data~~~~~');
END;
/
SELECT * FROM Restaurant_t;

--Display restaurant by cuisine: Italian
BEGIN
dbms_output.put_line('
~~~~~Italian Restaurants~~~~~');
END;
/
SELECT * FROM Restaurant_t WHERE cuisineID = 4;

--Display restaurant by cuisine: Ethiopian
BEGIN
dbms_output.put_line('

~~~~~Ethiopian Restaurants~~~~~');
END;
/
SELECT * FROM Restaurant_t WHERE cuisineID = 3;

--TEAM MEMBER 4 Tolulope Ale
--Function to call the restaurant ID from the restaurant table
CREATE OR REPLACE FUNCTION FIND_RESTAURANT_ID (resNAME varchar2) 
RETURN INT
AS
resID INT;
BEGIN
    SELECT Rest_ID
    INTO resID
    FROM restaurant_T
    WHERE Rest_Name = resNAME;
    RETURN resID;
 EXCEPTION
    WHEN no_data_found THEN
    DBMS_output.put_line('no such Restaurant');
 RETURN -1;
END;
/


--Member 2 Yogichandar Boppana
--creating a sequence to automatically update the waiter id in the waiter table
create sequence waiter_id_seq start with 10 increment by 1;

--creation of waiter table with Waiter_ID,Rest_ID and Waiter_Name as attributes to the table MEMBER 2 TASKS
CREATE TABLE Waiter_T(
Waiter_ID INT,
Rest_ID INT,
Waiter_Name VARCHAR(100),
PRIMARY KEY(Waiter_ID),
FOREIGN KEY (Rest_ID) REFERENCES restaurant_t (Rest_ID));


-- creating a new function find_waiter_id as a helper function. name of the waiter is passed as input for the function.
CREATE OR REPLACE FUNCTION find_waiter_id(wname IN VARCHAR) /*wname is passed as input parameter to get waiter id*/
RETURN INT 
IS 
w_id INT;/* waiter id is stored in the local variable called as w_id*/
BEGIN
SELECT Waiter_ID INTO w_id FROM waiter_t WHERE Waiter_Name = wname; /* implicit cursor to get the waiter id*/
RETURN w_id;
EXCEPTION 
WHEN no_data_found THEN
dbms_output.put_line('no such waiter exists');
RETURN -1;
END;
/

CREATE OR REPLACE PROCEDURE hire_a_waiter(wname_insert in varchar,rname_insert in varchar)
IS
restid INT :=-1; -- initially restaurant id is declared as -1 to avoid any errors. if -1 is set as default in case of no restaurant it directly writes no such restaurant from find_restaurant_id function
 BEGIN
 restid:=find_restaurant_id (rname_insert);
  insert INTo waiter_t values (waiter_id_seq.nextval,restid,wname_insert); -- data insertion INTo waiters table.
  dbms_output.put_line ('A new waiter was added to the database.'); -- Acknowledging that a new waiter is added to the waiter
 exception 
  when others THEN 
   dbms_output.put_line ('waiter could not be inserted'); -- handling the errors
 END;
/
--creating a new PROCEDURE to show the details of the waiter, restaurant name is passed as --an input parameter

CREATE OR REPLACE PROCEDURE details_of_waiter(rname in varchar)
is
r_id INT := find_restaurant_id(rname);-- finding restaurant id for the given name of restaurant.
BEGIN
for i in (SELECT Waiter_ID,Rest_ID,Waiter_Name from waiter_t where  Rest_ID = r_id)-- the query specifies the range where the i is valid.
    loop
   dbms_output.put_line('Waiter Name: ' || i.Waiter_Name || '   Waiter ID: ' || i.Waiter_ID || '   Restaurant ID: ' || i.Rest_ID);-- handling the output values
    END loop;
exception 
when others THEN
dbms_output.put_line('no records found, please re enter the data');-- handling the output.
END;
/

-- insertion of data INTo waiter table using the PROCEDURE created.
EXEC hire_a_waiter('Jack','Ribs_R_US');
EXEC hire_a_waiter('Jill','Ribs_R_US');
EXEC hire_a_waiter('Wendy','Ribs_R_US');
EXEC hire_a_waiter('Hailey','Ribs_R_US');
EXEC hire_a_waiter('Mary','Bella Italia');
EXEC hire_a_waiter('Pat','Bella Italia');
EXEC hire_a_waiter('Michael','Bella Italia');
EXEC hire_a_waiter('Rakesh','Bella Italia');
EXEC hire_a_waiter('Verma','Bella Italia');
EXEC hire_a_waiter('Mike','Roma');
EXEC hire_a_waiter('Judy','Roma');
EXEC hire_a_waiter('Trevor','Selasie');
EXEC hire_a_waiter('Chap','Taj Mahal');
EXEC hire_a_waiter('Hannah','Bull Roast');
EXEC hire_a_waiter('Trudy','Ethiop');
EXEC hire_a_waiter('Trisha','Ethiop');
EXEC hire_a_waiter('Tariq','Ethiop');

--Show all information about waiters who work at the Ethiop restaurant
BEGIN
dbms_output.put_line('
~~~~~Data on All the Waiters Working at Ethiop~~~~~');
END;
/
SELECT * FROM waiter_t WHERE Rest_ID = 7;

--TEAM MEMBER 3 David Calderone
--creating a SEQUENCE to create menuID
CREATE SEQUENCE menuID_seq START WITH 1 MINVALUE 1
INCREMENT BY 1;

CREATE TABLE MENU_ITEMS_T(
	menuID INT,
	menuName varchar(100),
	menuPrice DECIMAL (10,2),
	cuisineID INT,
	primary key (menuID),
	FOREIGN KEY (cuisineID) references CUISINE_TYPE_T(cuisineID));
CREATE TABLE RESTAURANT_INVENTORY_T(
	restaurantQuantity INT,
	restaurantMenuName varchar(100),
	menuID INT,
	restaurantInvID INT,
	FOREIGN KEY (menuID) references MENU_ITEMS_T(menuID),
	FOREIGN KEY (restaurantInvID) references RESTAURANT_T (Rest_ID));

--END of Team Member 3 - David Calderone

--TEAM MEMBER 4 Tolulope Ale
--function to call the menu ID from the menu table
CREATE OR REPLACE FUNCTION FIND_MENU_ITEM_ID (meNAME varchar2) 
RETURN INT
AS
meID INT;
BEGIN
    SELECT menuID
    INTO meID
    FROM menu_items_T
    WHERE menuName = meNAME;
    RETURN meID;
 EXCEPTION
    WHEN no_data_found THEN
    DBMS_output.put_line('no such Menu');
 RETURN -1;
END;
/

/*TEAM MEMBER 3 David Calderone*/
/*finding the cuisine ID by taking in a cuisine Name and returning the ID */
CREATE OR REPLACE FUNCTION FIND_CUISINE_TYPE_ID(cuisineLook varchar) return INT
AS
returnCuisine INT;
BEGIN
	SELECT cuisineID /*pulling cuisineID attribute*/
	INTo returnCuisine /*placing return value INTo declared variable*/
	from CUISINE_TYPE_T /* from cuisinetypet table*/
	where cuisineName = cuisineLook; /*where cuisineName matches the passed parameter*/
	return returnCuisine; /*return the declared variable, passing the ID back to call*/
exception
	when no_data_found THEN
	dbms_output.put_line('no such cuisine'); /*in the event name is incorrect, output failure*/
	return -1; /*return an invalid cuisineID*/
END;
/
/*finding the cuisine ID by taking in a cuisine Name and returning the ID*/
/*PROCEDURE to INSERT INTO the menu_item tables by passing insert parameter*/
CREATE OR REPLACE PROCEDURE menu_items_insert(menuNameInsert varchar, menuPriceInsert decimal, cuisineNameInsert varchar)
AS
BEGIN
	INSERT INTO MENU_ITEMS_T values(menuID_seq.nextval, menuNameInsert, menuPriceInsert, FIND_CUISINE_TYPE_ID(cuisineNameInsert)); /* SQL statement to insert passed values*/
END;
/

EXEC menu_items_insert('burger', 10, 'American');
EXEC menu_items_insert('fries', 5, 'American');
EXEC menu_items_insert('pasta', 15, 'American');
EXEC menu_items_insert('salad', 10, 'American');
EXEC menu_items_insert('salmon', 20, 'American');

EXEC menu_items_insert('steak', 25, 'BBQ');
/*EXEC menu_items_insert('burger', 10, 'BBQ');*/
EXEC menu_items_insert('pork loin', 15, 'BBQ');
EXEC menu_items_insert('filet mignon', 30, 'BBQ');

EXEC menu_items_insert('dal soup', 10, 'Indian');
EXEC menu_items_insert('rice', 5, 'Indian');
EXEC menu_items_insert('tandoori chicken', 10, 'Indian');
EXEC menu_items_insert('samosa', 8, 'Indian');

EXEC menu_items_insert('lasagna', 15, 'Italian');
EXEC menu_items_insert('meatballs', 10, 'Italian');
EXEC menu_items_insert('spaghetti', 15, 'Italian');
EXEC menu_items_insert('pizza', 20, 'Italian');

EXEC menu_items_insert('meat chunks', 12, 'Ethiopian');
EXEC menu_items_insert('legume stew', 10, 'Ethiopian');
EXEC menu_items_insert('flatbread', 3, 'Ethiopian');

/*MORE TEAM MEMBER 3 David Calderone*/
/*PROCEDURE to INSERT INTO the RESTAURANT_INVENTORY_T tables by passing insert parameter*/
CREATE OR REPLACE PROCEDURE RESTAURANT_INVENTORY_Insert(restaurantQuantityInsert INT, menuNameInsert varchar, Rest_NameCheck varchar)
AS
Rest_ID INT;
menu_Item_ID INT;
BEGIN
	Rest_ID := FIND_RESTAURANT_ID(Rest_NameCheck);
	menu_item_ID := FIND_MENU_ITEM_ID(menuNameInsert);
	INSERT INTO RESTAURANT_INVENTORY_T values(restaurantQuantityInsert, menuNameInsert, menu_item_ID, Rest_ID); /* SQL statement to insert passed values*/
END;
/

EXEC RESTAURANT_INVENTORY_Insert(50, 'burger', 'Ribs_R_US');
EXEC RESTAURANT_INVENTORY_Insert(150, 'fries', 'Ribs_R_US');

EXEC RESTAURANT_INVENTORY_Insert(10, 'lasagna', 'Bella Italia');

EXEC RESTAURANT_INVENTORY_Insert(15, 'steak', 'Bull Roast');
EXEC RESTAURANT_INVENTORY_Insert(50, 'pork loin', 'Bull Roast');
EXEC RESTAURANT_INVENTORY_Insert(5, 'filet mignon', 'Bull Roast');

EXEC RESTAURANT_INVENTORY_Insert(50, 'dal soup', 'Taj Mahal');
EXEC RESTAURANT_INVENTORY_Insert(500, 'rice', 'Taj Mahal');
EXEC RESTAURANT_INVENTORY_Insert(150, 'samosa', 'Taj Mahal');

EXEC RESTAURANT_INVENTORY_Insert(150, 'meat chunks', 'Selasie');
EXEC RESTAURANT_INVENTORY_Insert(150, 'legume stew', 'Selasie');
EXEC RESTAURANT_INVENTORY_Insert(500, 'flatbread', 'Selasie');

EXEC RESTAURANT_INVENTORY_Insert(150, 'meat chunks', 'Ethiop');
EXEC RESTAURANT_INVENTORY_Insert(150, 'legume stew', 'Ethiop');
EXEC RESTAURANT_INVENTORY_Insert(500, 'flatbread', 'Ethiop');


--END of Team Member 3 - David Calderone

--Team Member 5 Will Bundesen
CREATE SEQUENCE seq_customers
MINVALUE 1
INCREMENT BY 1;

--create the Customers Table
CREATE TABLE Customers_T (
   Customer_ID        INT     NOT NULL,
    Customer_Name       VARCHAR(30),
    Email               VARCHAR(30),
    Street_Address      VARCHAR(50),
    City                VARCHAR(30),
    State1              CHAR(2),
    Zip                 VARCHAR(10),
    Credit_Card         VARCHAR(16), 
PRIMARY KEY (Customer_ID));

INSERT INTO Customers_T VALUES (seq_customers.nextval, 'Cust1', 'kmacneil@gmail.com', '543 NE. WINTergreen Rd', 'Jacksonville Beach', 'FL', 21045, 4485446110928919);
INSERT INTO Customers_T VALUES (seq_customers.nextval, 'Cust11', 'zsvensson@verizon.net', '788 Valley Dr.', 'Anaheim', 'CA', 21045, 5456984657180975);
INSERT INTO Customers_T VALUES (seq_customers.nextval, 'Cust3', 'rwang@outlook.com', '326 Country Ave', 'Elizabethtown', 'NC', 21046, 6011846746604610);
INSERT INTO Customers_T VALUES (seq_customers.nextval, 'Cust111', 'mewart@hotmail.com', '244 Miller Dr', 'Middleburg', 'FL', 21045, 340005289560995);
INSERT INTO Customers_T VALUES (seq_customers.nextval, 'CustNY1', 'pahearn@yahoo.com', '27 6th Dr', 'Pikesville', 'NY', 10045, 4532273360463121);
INSERT INTO Customers_T VALUES (seq_customers.nextval, 'CustNY2', 'kmacneil@gmail.com', '7942 Miramar Rd', 'San Diego', 'FL', 10045, 5242547177568836);
INSERT INTO Customers_T VALUES (seq_customers.nextval, 'CustNY3', 'zsvensson@verizon.net', '2801 Market St', 'Pittsburgh', 'CA', 10045, 5598377348641431);
INSERT INTO Customers_T VALUES (seq_customers.nextval, 'CustPA1', 'kmacneil@gmail.com', '4125 S Archer Ave', 'Galveston', 'PA', 16822, 2149507322066319);
INSERT INTO Customers_T VALUES (seq_customers.nextval, 'CustPA2', 'zsvensson@verizon.net', '3147 Banksville Rd', 'Salinas', 'PA', 16822, 3539261873882544);
INSERT INTO Customers_T VALUES (seq_customers.nextval, 'CustPA3', 'rwang@outlook.com', '66 W Alisal St', 'Keller', 'PA', 16822, 6201456823494214);
INSERT INTO Customers_T VALUES (seq_customers.nextval, 'CustPA4', 'rwang@outlook.com', '2041 Rufe Snow Dr', 'Flemington', 'PA', 16822, 4556987146564891);
INSERT INTO Customers_T VALUES (seq_customers.nextval, 'CustPA5', 'mewart@hotmail.com', '6 Sand Hill Rd', 'Minneapolis', 'PA', 16822, 8699172031701283);
INSERT INTO Customers_T VALUES (seq_customers.nextval, 'CustPA6', 'pahearn@yahoo.com', '1601 Nicollet Ave', 'Bellevue', 'PA', 16822, 3598902434108253);


--TEAM MEMBER 4 Tolulope Ale
--function to call the customer ID from the customers table
CREATE OR REPLACE FUNCTION FIND_CUSTOMER_ID (custNAME varchar2) 
RETURN INT
AS
custID INT;
BEGIN
    SELECT customer_ID
    INTO custID
    FROM customers_T
    WHERE customer_Name = custNAME;
    RETURN custID;
 EXCEPTION
    WHEN no_data_found THEN
    DBMS_output.put_line('no such Customer');
 RETURN -1;
END;
/

--create orders table with the primary keys and corresponding FOREIGN KEYs
CREATE TABLE ORDERS_T ( 
    Order_ID INT,
    Rest_ID INT,
    Customer_ID INT,
    MenuID INT,
    Waiter_ID INT,
    Order_Date Date,
    Amount_Paid Decimal(10,2),
    Tip Decimal(10,2),
    PRIMARY KEY (Order_ID), -- unique and notnull
    -- FOREIGN KEYs to join the tables with the parent table
    FOREIGN KEY (Rest_ID) REFERENCES RESTAURANT_T (Rest_ID),
    FOREIGN KEY (Customer_ID) REFERENCES CUSTOMERS_T (Customer_ID),
    FOREIGN KEY (MenuID) REFERENCES MENU_ITEMS_T (MenuID),
    FOREIGN KEY (Waiter_ID) REFERENCES WAITER_T (Waiter_ID)
    );
	
CREATE SEQUENCE orderID_seq START WITH 1 INCREMENT BY 1; 

INSERT INTO ORDERS_T VALUES(orderID_seq.nextval, FIND_RESTAURANT_ID('Bella Italia'), FIND_CUSTOMER_ID('Cust1'), FIND_MENU_ITEM_ID('pizza'), FIND_WAITER_ID('Mary'), date '2022-03-10', 20.00, 4.00);
INSERT INTO ORDERS_T VALUES(orderID_seq.nextval, FIND_RESTAURANT_ID('Bella Italia'), FIND_CUSTOMER_ID('Cust11'), FIND_MENU_ITEM_ID('spaghetti'), FIND_WAITER_ID('Mary'), date '2022-03-15', 30.00, 6.00);
INSERT INTO ORDERS_T VALUES(orderID_seq.nextval, FIND_RESTAURANT_ID('Bella Italia'), FIND_CUSTOMER_ID('Cust11'), FIND_MENU_ITEM_ID('pizza'), FIND_WAITER_ID('Mary'), date '2022-03-15', 20.00, 4.00);  
INSERT INTO ORDERS_T VALUES(orderID_seq.nextval, FIND_RESTAURANT_ID('Bull Roast'), FIND_CUSTOMER_ID('CustNY1'), FIND_MENU_ITEM_ID('filet mignon'), FIND_WAITER_ID('Hannah'), date '2022-04-01', 60.00, 12.00);  
INSERT INTO ORDERS_T VALUES(orderID_seq.nextval, FIND_RESTAURANT_ID('Bull Roast'), FIND_CUSTOMER_ID('CustNY1'), FIND_MENU_ITEM_ID('filet mignon'), FIND_WAITER_ID('Hannah'), date '2022-04-02', 60.00, 12.00); 
INSERT INTO ORDERS_T VALUES(orderID_seq.nextval, FIND_RESTAURANT_ID('Bull Roast'), FIND_CUSTOMER_ID('CustNY2'), FIND_MENU_ITEM_ID('pork loin'), FIND_WAITER_ID('Hannah'), date '2022-04-01', 15.00, 3.00); 
INSERT INTO ORDERS_T VALUES(orderID_seq.nextval, FIND_RESTAURANT_ID('Ethiop'), FIND_CUSTOMER_ID('CustPA1'), FIND_MENU_ITEM_ID('meat chunks'), FIND_WAITER_ID('Trisha'), date '2022-04-01', 120.00, 24.00); 
INSERT INTO ORDERS_T VALUES(orderID_seq.nextval, FIND_RESTAURANT_ID('Ethiop'), FIND_CUSTOMER_ID('CustPA1'), FIND_MENU_ITEM_ID('meat chunks'), FIND_WAITER_ID('Trisha'), date '2022-05-01', 120.00, 24.00); 
INSERT INTO ORDERS_T VALUES(orderID_seq.nextval, FIND_RESTAURANT_ID('Ethiop'), FIND_CUSTOMER_ID('CustPA1'), FIND_MENU_ITEM_ID('meat chunks'), FIND_WAITER_ID('Trisha'), date '2022-05-10', 120.00, 24.00); 
INSERT INTO ORDERS_T VALUES(orderID_seq.nextval, FIND_RESTAURANT_ID('Ethiop'), FIND_CUSTOMER_ID('CustPA2'), FIND_MENU_ITEM_ID('legume stew'), FIND_WAITER_ID('Trevor'), date '2022-05-01', 100.00, 20.00);  
INSERT INTO ORDERS_T VALUES(orderID_seq.nextval, FIND_RESTAURANT_ID('Ethiop'), FIND_CUSTOMER_ID('CustPA2'), FIND_MENU_ITEM_ID('legume stew'), FIND_WAITER_ID('Trevor'), date '2022-05-11', 100.00, 20.00);    

--Team Member 3 - David Calderone
--PROCEDURE to Update Menu Item Inventory
--Takes in restaurant ID, menu item ID, and how much to reduce it by

CREATE OR REPLACE PROCEDURE UPDATE_MENU_QUANTITY(Rest_IDQuantity INT, menuIDQuantity INT, quantityReduce INT)
AS
BEGIN
	Update RESTAURANT_INVENTORY_T set restaurantQuantity = restaurantQuantity - quantityReduce where restaurantInvID = Rest_IDQuantity AND menuID = menuIDQuantity;
END;
/
--Excuting menu update quantity procedures
EXEC UPDATE_MENU_QUANTITY(FIND_RESTAURANT_ID('Taj Mahal'),FIND_MENU_ITEM_ID('rice'),25);
EXEC UPDATE_MENU_QUANTITY(FIND_RESTAURANT_ID('Selasie'),FIND_MENU_ITEM_ID('meat chunks'),50);
EXEC UPDATE_MENU_QUANTITY(FIND_RESTAURANT_ID('Bull Roast'),FIND_MENU_ITEM_ID('filet mignon'),2);
EXEC UPDATE_MENU_QUANTITY(FIND_RESTAURANT_ID('Bull Roast'),FIND_MENU_ITEM_ID('filet mignon'),2);

--write on the output initial inventory for ethiop
--run a query to show all information from restaurant inventory for ethiopia
BEGIN
dbms_output.put_line('
~~~~~Initial Inventory for Ethiop Restaurant~~~~~');
END;
/
--	Run a query to show all information from restaurant_inventory for the Ethiop restaurant
SELECT * from RESTAURANT_INVENTORY_T where restaurantInvID = FIND_RESTAURANT_ID('Ethiop');

EXEC UPDATE_MENU_QUANTITY(FIND_RESTAURANT_ID('Ethiop'),FIND_MENU_ITEM_ID('meat chunks'),30);
EXEC UPDATE_MENU_QUANTITY(FIND_RESTAURANT_ID('Ethiop'),FIND_MENU_ITEM_ID('meat chunks'),30);
EXEC UPDATE_MENU_QUANTITY(FIND_RESTAURANT_ID('Ethiop'),FIND_MENU_ITEM_ID('legume stew'),20);
--write on the output final inventory for ethiop
--run a query to show all information from restaurant inventory for ethiopia
BEGIN
dbms_output.put_line('
~~~~~Final Inventory for Ethiop Restaurant~~~~~');
END;
/
SELECT * from RESTAURANT_INVENTORY_T where restaurantInvID = FIND_RESTAURANT_ID('Ethiop');


--END of Team Member 3 - David Calderone

BEGIN
dbms_output.put_line('----------------------------R E P O R T S   below ----------------------------');
END;
/



--Team Member 1
BEGIN
dbms_output.put_line('
------------------------ REPORT BY MEMBER 1 (Sara_Khanjani) --------------------
');
END;
/
CREATE OR REPLACE PROCEDURE income_report IS
restaurant_State varchar(100);
Cuisine_name varchar(100);
Sum_Income INT;
cursor c1 is  SELECT  RESTAURANT_T.Rest_State , CUISINE_TYPE_T.cuisineName  , sum(Amount_Paid)
from ORDERS_T, RESTAURANT_T, CUISINE_TYPE_T where RESTAURANT_T.Rest_ID= ORDERS_T.Rest_ID and RESTAURANT_T.cuisineID= CUISINE_TYPE_T.cuisineID 
group by RESTAURANT_T.Rest_State, RESTAURANT_T.cuisineID, CUISINE_TYPE_T.cuisineName;

BEGIN

open c1;
loop
fetch c1 INTo restaurant_State , Cuisine_name, Sum_Income;
exit when c1%NOTFOUND;
dbms_output.put_line(restaurant_State ||' $'|| Sum_Income);
END Loop;
close c1;
END;
/
BEGIN
dbms_output.put_line('
~~~~~REPORT: Income By State~~~~~
');
END;
/
EXEC income_report;

--Team Member 2
BEGIN
dbms_output.put_line('
--------------------- REPORTS BY MEMBER 2 (Yogichandar_Boppana) ----------------
');
END;
/

--DELIVERABLE D3 MEBMER 2 TASKS --Will moved these from earlier in the code since they
--were creating an error.
-- New PROCEDURE To compute the tips of the waiter 

CREATE OR REPLACE PROCEDURE tip_of_waiter
is 
-- an explicit cursor is used to store the details of waiter such as Waiter_ID,waiter name,Total tip
-- an aggregation sum(tips) is used to compute the tip of waiter.
cursor c1 is 
SELECT waiter_t.Waiter_ID,waiter_t.Waiter_Name, sum(orders_t.tip) AS total_tip 
from orders_t,waiter_t 
where orders_t.Waiter_ID=waiter_t.Waiter_ID 
group by waiter_t.Waiter_ID,waiter_t.Waiter_Name; 
-- group by statement is used to display the waiter id,waiter name along with the tip of waiter.
BEGIN
dbms_output.put_line('Waiter ID'||'   '||'Waiter Name'||'   '||'Total Tips Collected by this Waiter');
-- fetching the values INTo x from cursor using the for loop.
FOR x in C1
loop
dbms_output.put_line(x.Waiter_ID||'          '|| x.Waiter_Name||'           $'|| x.Total_tip    ); -- handling the outputs.
exit when C1%notfound; -- exit condition for the loop.
END loop;
Exception
when no_data_found THEN -- handling the exceptions
dbms_output.put_line('No data found');
when others THEN
dbms_output.put_line('please check back');
END;
/

-- creating new PROCEDURE tip_by_state which returns the tips of each state
CREATE OR REPLACE PROCEDURE tip_by_state 
is
-- created an explicit cursor to store the details of sum of tips for each state and state information
cursor c1 is
SELECT sum(orders_t.tip),restaurant_t.Rest_State from orders_t,restaurant_t
where orders_t.Rest_ID=restaurant_t.Rest_ID 
group by restaurant_t.Rest_State;
-- to group the data using the state.
-- two local variables total_tip and state_name are declared to store the information from the cursor.
total_tip number;
state_name varchar(100);
BEGIN
dbms_output.put_line('State'||'   '||'Total Tip Amount');-- handling the output. This statement is used to display the output in a organised manner.
open c1;
loop
-- Fetching the data from cursor c1 INTo loacal variables total_tip and state_name
fetch c1 INTo total_tip,state_name;
exit when c1%NOTFOUND; -- exit condition for the loop.
dbms_output.put_line(state_name||'       $' ||total_tip);-- Handling the output.
END loop;
exception
when no_data_found THEN
dbms_output.put_line('No data found');
when others THEN
dbms_output.put_line('please check back');
close c1;-- close the cursor c1.
END;
/

/* Output operations for member 2 */
--To view the waiters that are working the restaurant Ethiop .(Final scenario Member 2 Responsibilities)
--Trudy,Trsiha and Tariq are obtained as output.
BEGIN
dbms_output.put_line('
~~~~~REPORT: All Information About the Waiters at Ethiop Restaurant~~~~~
');
END;
/
EXEC details_of_waiter('Ethiop');


-- calling the PROCEDURE tip_of_waiter to report the tips of each individual waiter working.
BEGIN
dbms_output.put_line('
~~~~~REPORT: Tips By Waiter~~~~~');
END;
/
EXEC tip_of_waiter;

-- calling the PROCEDURE tip_by_state to report the tips state wise.
BEGIN
dbms_output.put_line('
~~~~~REPORT: Tips Earned By State~~~~~');
END;
/
EXEC tip_by_state;
-- END of Member 2 tasks


--Team Member 3 David_Calderone
BEGIN
dbms_output.put_line('
--------------------- REPORT BY MEMBER 3 (David_Calderone) ---------------------
');
END;
/

/* across all restaurants, with the same cuisine type/ Sum the number of each menu item across all restaurants. 
PrINT out Cuisine Type, Menu item name, and sum of menu item

Of a Specific Cuisine type
PrINT out different menu items
Sum(restaurantQuantity) across all restaurants
*/
CREATE OR REPLACE PROCEDURE Report_Menu_Items(cuisineType varchar)
AS
	o_cuisineName CUISINE_TYPE_T.cuisineName%type;
	o_menuName MENU_ITEMS_T.menuName%type;
	o_sum RESTAURANT_INVENTORY_T.restaurantQuantity%type;
	counter int :=0;
	cursor c1 is SELECT CUISINE_TYPE_T.cuisineName, MENU_ITEMS_T.menuName, sum(RESTAURANT_INVENTORY_T.restaurantQuantity)
	from CUISINE_TYPE_T, MENU_ITEMS_T, RESTAURANT_INVENTORY_T
	where CUISINE_TYPE_T.cuisineName = cuisineType
	AND MENU_ITEMS_T.cuisineID = CUISINE_TYPE_T.cuisineID
	AND RESTAURANT_INVENTORY_T.restaurantMenuName = MENU_ITEMS_T.menuName
	group by CUISINE_TYPE_T.cuisineName, MENU_ITEMS_T.menuName;
BEGIN
	open c1;
	Loop
	FETCH c1 INTo o_cuisineName, o_menuName, o_sum;
	exit when C1%NOTFOUND;
	dbms_output.put_line('Cuisine Name: ' || o_cuisineName || '     Menu Name: ' || o_menuName || '     Total Products: ' || o_sum);
	counter := counter + 1;
	--dbms_output.put_line(o_menuName);
	--dbms_output.put_line(o_sum);
	END loop;
	close c1;
	if counter = 0 then
		dbms_output.put_line('No Menu Items Found, check Cuisine Name');
	end if;
END;
/

--checking report for cuisine types
BEGIN
dbms_output.put_line('~~~~~MENU REPORT: American~~~~~');
END;
/
EXEC Report_Menu_Items('American'); 

BEGIN
dbms_output.put_line('~~~~~MENU REPORT: BBQ~~~~~');
END;
/
EXEC Report_Menu_Items('BBQ');

BEGIN
dbms_output.put_line('~~~~~MENU REPORT: Ethiopian~~~~~');
END;
/
EXEC Report_Menu_Items('Ethiopian');

BEGIN
dbms_output.put_line('~~~~~MENU REPORT: Italian~~~~~');
END;
/
EXEC Report_Menu_Items('Italian');

BEGIN
dbms_output.put_line('~~~~~MENU REPORT: Indian~~~~~');
END;
/
EXEC Report_Menu_Items('Indian');

--END of David's code
--Team Member 4 TOLULOPE_ALE
BEGIN
dbms_output.put_line('
--------------------- REPORT BY MEMBER 4 (Tolulope_Ale) ------------------------
');
END;
/


--List the most popular menu item ordered for each cuisine type

CREATE OR REPLACE PROCEDURE list_pop_menu(cuisineOrder in varchar) --PROCEDURE name and input parameter
AS
    menuCount orders_t.menuid%type; --declaring variables to accept the values
    menutype menu_items_t.menuname%type;
    cuisineType cuisine_type_t.cuisinename%type; 
Cursor c1 is SELECT count(orders_t.menuid), menuname, cuisinename --cursor within the PROCEDURE
    INTo menuCount, menuType, cuisineType
    from orders_t, menu_items_t, cuisine_type_t 
    where cuisinename = cuisineOrder and --condition for the input parameter
          orders_t.menuid = menu_items_t.menuid and --the join condition
          menu_items_t.cuisineid = cuisine_type_t.cuisineid
    group by cuisinename, menuname; --grouping by values in the SELECT statement
BEGIN
    Open c1; --opens the cursor
Loop --creating a loop to iterate through the tables
    fetch c1 INTo menuCount,menutype,cuisineType; 
    exit when c1%NOTFOUND; --exit condition
    -- prINT out statement
    dbms_output.put_line(menutype || ' of ' || cuisineType || ' cuisine was ordered ' || menuCount || ' time(s).');
    END loop;
    Close c1;
END;    
/
--Report of most popular menu item ordered for each cuisine type
BEGIN
dbms_output.put_line('~~~~~REPORT: The Most Popular Menu Item: Indian~~~~~');
END;
/
EXEC list_pop_menu('Indian');

BEGIN
dbms_output.put_line('~~~~~REPORT: The Most Popular Menu Item: Italian~~~~~');
END;
/
EXEC list_pop_menu('Italian');

BEGIN
dbms_output.put_line('~~~~~REPORT: The Most Popular Menu Item: Ethiopian~~~~~');
END;
/
EXEC list_pop_menu('Ethiopian');

BEGIN
dbms_output.put_line('~~~~~REPORT: The Most Popular Menu Item: American~~~~~');
END;
/
EXEC list_pop_menu('American');

BEGIN
dbms_output.put_line('~~~~~REPORT: The Most Popular Menu Item: BBQ~~~~~');
END;
/
EXEC list_pop_menu('BBQ');

--Report showing the top 3 restaurants of each state. 
--The ranking is based on the total of ‘amount paid’ per restaurant per state. 

CREATE OR REPLACE PROCEDURE restState(reState in varchar) --PROCEDURE name and input parameter
AS
    resName restaurant_t.Rest_Name%type; --declaring variables to accept the values
    sumpaid orders_t.amount_paid%type;
Cursor c1 is SELECT restaurant_t.Rest_Name, sum(amount_paid) --cursor within the PROCEDURE
      from restaurant_t, orders_t 
      where restaurant_t.Rest_State = reState and --condition for the input parameter
            orders_t.Rest_ID = restaurant_t.Rest_ID
      group by restaurant_t.Rest_Name; --grouping by the value in the SELECT statement
BEGIN
    Open c1;  --opens the cursor
Loop   --creating a loop to iterate through the tables
    fetch c1 INTo resName, sumpaid;
    exit when c1%NOTFOUND;  --exit condition
    -- prINT out statement
    dbms_output.put_line(resName ||' in ' || reState || ' has a total income of $' || sumpaid);
END loop;
    close c1;
END;  
/ 

--Report on top 3 restaurants in each state.
BEGIN
dbms_output.put_line('~~~~~REPORT: Top 3 Restaurants in Maryland~~~~~');
END;
/
EXEC restState('MD');

BEGIN
dbms_output.put_line('~~~~~REPORT: Top 3 Restaurants in Virginia~~~~~');
END;
/
EXEC restState('VA');

BEGIN
dbms_output.put_line('~~~~~REPORT: Top 3 Restaurants in New York~~~~~');
END;
/
EXEC restState('NY');

BEGIN
dbms_output.put_line('~~~~~REPORT: Top 3 Restaurants in Pennsylvania~~~~~');
END;
/
EXEC restState('PA');

--TEAM MEMBER 4 ENDS


--Team Member 5 Will_Bundesen
BEGIN
dbms_output.put_line('
--------------------- REPORT BY MEMBER 5 (Will_Bundesen) -----------------------
');
END;
/
--OPERATION 19 - Report: Generate a report with the names of customers who spent 
--the most money (top 3) and also the names of the most frugal customers (bottom 3)
--###This report displays the TOP 3 spenders###
DECLARE
    counter1 int :=0; --utilized a counter to address the exception: if there are no customer entries
    CURSOR top_spenders IS 
    SELECT customer_name, sum(amount_paid)
    FROM customers_t, orders_t
    WHERE customers_t.Customer_ID = orders_t.Customer_ID
    GROUP BY customer_name
    ORDER BY sum(amount_paid) DESC;
    custName customers_t.Customer_Name%TYPE;
    amt_paid orders_t.Amount_Paid%TYPE;
    i INT;
    total INT;
BEGIN
    dbms_output.put_line('~~~~~REPORT: Top 3 Spenders from Most to Least~~~~~');
    i := 1;
    total := 0;
    counter1 :=0;
    OPEN top_spenders; 
    LOOP
    total := total + i;
    i := i + 1; --how the loop is incremented by 1
    FETCH top_spenders INTO custName, amt_paid;
   EXIT WHEN i > 4 OR counter1 = 0;
        dbms_output.put_line(custName); 
        counter1 := counter1 + 1;
    END LOOP;
CLOSE top_spenders;           
 IF counter1 = 0 THEN
		dbms_output.put_line('There is no customer data in the database.');
	END IF;
END;
/
--###This report displays the BOTTOM 3 spenders###
DECLARE
    counter2 int :=0; --utilized a counter to address the exception: if there are no customer entries
    CURSOR bottom_spenders IS 
    SELECT customer_name, sum(amount_paid)
    FROM customers_t, orders_t
    WHERE customers_t.Customer_ID = orders_t.Customer_ID
    GROUP BY customer_name
    ORDER BY sum(amount_paid);
    custName customers_t.Customer_Name%TYPE;
    amt_paid orders_t.Amount_Paid%TYPE;
    i INT;
    total INT;
BEGIN
    dbms_output.put_line('~~~~~REPORT: Bottom 3 Spenders from Least to Most~~~~~');
    i := 1;
    total := 0;
    counter2 :=0; 
    OPEN bottom_spenders; 
    LOOP
    total := total + i;
    i := i + 1; --how the loop is incremented by 1
    FETCH bottom_spenders INTO custName, amt_paid;
   EXIT WHEN i > 4 OR counter2 = 0;
        dbms_output.put_line(custName); 
    counter2 := counter2 + 1;
    END LOOP;
CLOSE bottom_spenders; 
    IF counter2 = 0 THEN
		dbms_output.put_line('There is no customer data in the database.');
	END IF;
END;
/

--OPERATION 20 - Report: States of generous customers. Generate a report that 
--lists the states based on customers who tip generously. Show the total amount of 
--tips by state in descending order of tip amount. 
DECLARE
    counter3 int :=0; --utilized a counter to address the exception: if there are no customer entries
    CURSOR high_tip_states IS 
    SELECT state1, SUM(tip)
    FROM customers_t, orders_t
    WHERE customers_t.Customer_ID = orders_t.Customer_ID
    GROUP BY state1
    ORDER BY SUM(amount_paid) DESC;
    tipping_states customers_t.state1%TYPE;
    amt_tipped orders_t.tip%TYPE;
BEGIN
    dbms_output.put_line('~~~~~REPORT: List of Best Tipping States from Most to Least~~~~~');
    OPEN high_tip_states; 
    LOOP
    FETCH high_tip_states INTO tipping_states, amt_tipped;
    EXIT WHEN high_tip_states%notfound;
        dbms_output.put_line(tipping_states ||'    $'|| amt_tipped); 
    counter3 := counter3 + 1;
    END LOOP;
CLOSE high_tip_states;   
        IF counter3 = 0 THEN
		dbms_output.put_line('There is no customer data in the database.');
	END IF;
END;
/
COMMIT;




