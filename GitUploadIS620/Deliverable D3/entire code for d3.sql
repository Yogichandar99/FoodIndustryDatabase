SET SERVEROUTPUT ON;
show errors;
-- deleting all the pre existing data.
delete from orders_t;
delete from restaurant_inventory_t;
delete from menu_items_t;
delete from customers_t;
delete from waiter_t;
delete from restaurant_t;
delete from cuisine_type_t;

--deleting all existing sequences 

drop SEQUENCE cuisine_id_seq;
drop sequence seq_customers;
drop sequence orderID_seq;
drop sequence rest_id_seq;
drop sequence waiter_id_seq;
drop SEQUENCE menuID_seq;

-- deleting all the pre existing functions and procedures used in the code
drop function find_cuisine_type_id;
drop function find_restaurant_id;
drop function find_waiter_id;
drop function find_customer_id;
drop function FIND_MENU_ITEM_ID;
drop procedure add_new_cuisine;
drop procedure add_new_restaurant;
drop procedure details_of_waiter;
drop procedure insertcustomer;
drop procedure menu_items_insert;
drop procedure RESTAURANT_INVENTORY_Insert;
drop procedure hire_a_waiter;
drop procedure tip_by_state;
drop procedure tip_of_waiter;


-- deleting all the tables in the reverse order of creation that are used for the code.
drop table orders_t;
drop table restaurant_inventory_t;
drop table menu_items_t;
drop table customers_t;
drop table waiter_t;
drop table restaurant_t;
drop table cuisine_type_t;

/
--creating sequiences that are used in the tables
CREATE SEQUENCE cuisine_id_seq start with 1;
CREATE SEQUENCE rest_id_seq start with 1;
create sequence waiter_id_seq start with 10 increment by 1;

CREATE TABLE CUISINE_TYPE_T (cuisineid   int NOT NULL,cuisinename  varchar(30),Primary key (cuisineid));

CREATE TABLE RESTAURANT_T (restaurantid  int NOT NULL,restaurantidname varchar(30),cuisineid  int,restaurantstraddress varchar(50),
restaurantcity Varchar(50),restaurantstate varchar(50),restaurantzip  varchar(20), PRIMARY KEY (restaurantid),
FOREIGN KEY (cuisineid) REFERENCES CUISINE_TYPE_T (cuisineid));

/

CREATE OR REPLACE FUNCTION find_cuisine_type_id( cuisine_name IN varchar) 
RETURN number IS
cuisine_id number;
BEGIN

        SELECT cuisineid INTO cuisine_id FROM cuisine_type_T 
        WHERE  cuisinename = cuisine_name;
        RETURN cuisine_id;
        -- EXECPTIONS---------------
            EXCEPTION
                WHEN NO_DATA_FOUND then 
                DBMS_OUTPUT.PUT_LINE('No data found');
            RETURN -1;
    END; 
/
Create or replace function find_restaurant_id(r_name in varchar)
return number
IS
r_id number;
BEGIN
	select  restaurantid  into r_id from restaurant_t
    where   restaurantidname  = r_name;
	return r_id;
exception
	when no_data_found then
	dbms_output.put_line('no such restaurants');
	return -1;
End;
/

CREATE OR REPLACE PROCEDURE Add_new_Cuisine(cuisine_name IN varchar) 
AS
BEGIN
INSERT INTO CUISINE_TYPE_T VALUES (cuisine_id_seq.nextval,cuisine_name);
            -- EXECPTIONS---------------
            EXCEPTION
                WHEN NO_DATA_FOUND then 
                DBMS_OUTPUT.PUT_LINE('No data found');

    END; 
/

CREATE OR REPLACE PROCEDURE Add_new_Restaurant (rest_name    IN   varchar, cuisine     IN   varchar,str_address IN   varchar,rest_city      IN   Varchar,
rest_state    IN   varchar,rest_zip       IN   varchar) 
AS                                               
BEGIN                                
INSERT INTO RESTAURANT_T VALUES (rest_id_seq.nextval,rest_name,cuisine,str_address,rest_city,rest_state,rest_zip);
            -- EXECPTIONS---------------
EXCEPTION
WHEN NO_DATA_FOUND then 
DBMS_OUTPUT.PUT_LINE('No data found');
END;
/

exec Add_new_Cuisine('American');
exec Add_new_Cuisine('Italian');
exec Add_new_Cuisine('BBQ');
exec Add_new_Cuisine('Indian');
exec Add_new_Cuisine('Ethiopian');


EXEC Add_new_Restaurant('Ribs_R_US',find_cuisine_type_id('American'),'1000 Hilltop Circle','Baltimore','MD','21250');
EXEC Add_new_Restaurant('Bella Italia',find_cuisine_type_id('Italian'),'214 Garden','Catonsville','MD','21043');
EXEC Add_new_Restaurant('Roma', find_cuisine_type_id('Italian'),'Route 40','Catonsville','MD','21043');
EXEC Add_new_Restaurant('Bull Roast',find_cuisine_type_id('BBQ'),'Mount view drive','Rockville','NY','10013');
EXEC Add_new_Restaurant('Taj Mahal', find_cuisine_type_id('Indian'),'Route 40','Downtown','NY','10013');
EXEC Add_new_Restaurant('selasie', find_cuisine_type_id('Ethiopian'),'Walker ave','Downtown','PA','16822');
/


--creation of waiter table with waiterid,restaurantid and waiter_name as attributes to the table
create table Waiter_T(
WaiterID int,
restaurantID int,
waiter_name varchar(100),
primary key(waiterID),
foreign key (restaurantID) references restaurant_t (restaurantID));
/

-- deleting every record in the waiters table just to ensure the table doesn't contain any data.
delete from waiter_t;

--Selecting the data from waiter befoer we populate the table with inserts using the procedures.
select * from waiter_t;

--manual insertion of data to check working of sequnce
/*
insert into waiter_t values(waiter_id_seq.nextval,1,'riley');
insert into waiter_t values(waiter_id_seq.nextval,2,'rohan');
insert into waiter_t values(waiter_id_seq.nextval,1,'meghana');
insert into waiter_t values(waiter_id_seq.nextval,3,'ram');
insert into waiter_t values(waiter_id_seq.nextval,1,'mary');
insert into waiter_t values(waiter_id_seq.nextval,2,'john');
-- Getting what data pre exists before creation of procedures 
select * from waiter_t;
*/
--creation of a procedure to hire a waiter(for insertion of data) waiter name(wname_insert) and restaurant name(rname_insert) are passed as input parameters for the function.

create or replace procedure hire_a_waiter(wname_insert in varchar,rname_insert in varchar)
IS
restid int :=-1; -- initially restaurant id is decalred as -1 to avoid any errors. if -1 is set as default in case of no restaurant it directly writes no such restaurant from find_restaurant_id function
 BEGIN
 restid:=find_restaurant_id (rname_insert);
  insert into waiter_t values (waiter_id_seq.nextval,restid,wname_insert); -- data insertion into waiters table.
  dbms_output.put_line ('a new waiter is added into the data base'); -- Acknowleding that a new waiter is added to the waiter
 exception 
  when others then 
   dbms_output.put_line ('waiter could not be inserted'); -- handling the errors
 END;
/
--creating a new procedure to show the details of the waiter, restaurant name is passed as an input paramater

create or replace procedure details_of_waiter(rname in varchar)
is
r_id int := find_restaurant_id(rname);-- finding restaurant id for the given name of restaurant.
Begin
for i in (select waiterid,restaurantid,waiter_name from waiter_t where  restaurantid = r_id)-- the query specifies the range where the i is valid.
    loop
   dbms_output.put_line('wid :' || i.waiterid || '  rid :' || i.restaurantid|| 'waitername :  ' || i.waiter_name);-- handling the output values
    end loop;
exception 
when others then
dbms_output.put_line('no records found, please re enter the data');-- handling the output.
END;

/
-- insertion of data using procedure 
exec hire_a_waiter('Jack','Ribs_R_US');
exec hire_a_waiter('Jill','Ribs_R_US');
exec hire_a_waiter('Wendy','Ribs_R_US');
exec hire_a_waiter('Hailey','Ribs_R_US');
exec hire_a_waiter('Mary','Bella Italia');
exec hire_a_waiter('Pat','Bella Italia');
exec hire_a_waiter('Michael','Bella Italia');
exec hire_a_waiter('Rakesh','Bella Italia');
exec hire_a_waiter('Verma','Bella Italia');
exec hire_a_waiter('Mike','Roma');
exec hire_a_waiter('judy','Roma');
exec hire_a_waiter('trevor','selasie');
exec hire_a_waiter('chap','Taj Mahal');
exec hire_a_waiter('hannah','Bull Roast');
exec details_of_waiter('Bella Italia');
/
-- printing the data after populating the data using the procedures
select * from waiter_t;
/
-- creating a new function find_waiter_id as a helper function. name of the waiter is passed as input for the function.

create or replace function find_waiter_id(wname in varchar) /*wname is passed as input parameter to get waiter id*/
return int 
is 
w_id int;/* waiter id is stored in the local variable called as w_id*/
begin
select waiterid into w_id from waiter_t where waiter_name= wname; /* implicit cursor to get the waiter id*/
return w_id;
exception 
when no_data_found then
dbms_output.put_line('no such waiter exists');
return -1;
end;

/
-- a test example to check whether the function is able to retrieve the data or not.

declare 
INFO int;
begin
INFO :=find_waiter_id('yogi');-- function call, the id is stored in the local variable info.
dbms_output.put_line('waiter id is'||INFO);
end;
/


select * from cuisine_type_t;
select * from restaurant_t;
select * from waiter_t;

/




--create the sequence for the Customer ID / primary key
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
/

CREATE OR REPLACE FUNCTION FIND_Customer_ID(custLook IN VARCHAR) return int
AS returnCustomer int;
BEGIN
	select Customer_ID                       
	into returnCustomer                     
	from Customers_T                         
	where Customer_Name = custLook;                       
	return returnCustomer;                       
exception
	when no_data_found then
	dbms_output.put_line('no such customer');                        
	return -1;                                          
END;
/

create or replace PROCEDURE insertCustomer(
    new_custID IN customers_t.customer_id%type,
    new_custName IN customers_t.customer_name%type,
    new_custEmail IN customers_t.email%type,
    new_custStreet IN customers_t.street_address%type,
    new_custCity IN customers_t.city%type,
    new_custState1 IN customers_t.state1%type,
    new_custZip IN customers_t.zip%type,
    new_custCC IN customers_t.credit_card%type)

IS 
BEGIN
INSERT INTO CUSTOMERS_T (customer_id, customer_name, email, street_address, city, state1, zip, credit_card)
VALUES (new_custID, new_custName, new_custEmail, new_custStreet, new_custCity, new_custState1, new_custZip, new_custCC);
END;
/

create table MENU_ITEMS_T(
	menuID int,
	menuName varchar(100),
	menuPrice DECIMAL (10,2),
	cuisineID int,
	primary key (menuID),
	foreign key (cuisineID) references CUISINE_TYPE_T(cuisineID)
	);

create table RESTAURANT_INVENTORY_T(
	restaurantQuantity int,
	restaurantMenuName varchar(100),
	menuID int,
	restaurantInvID int,
	foreign key (menuID) references MENU_ITEMS_T(menuID),
	foreign key (restaurantInvID) references RESTAURANT_T (restaurantID)
	);
/

CREATE SEQUENCE menuID_seq START WITH 1 MINVALUE 1
increment by 1;


/* CODE FROM TEAM MEMBER 4 */
CREATE OR REPLACE function FIND_MENU_ITEM_ID (meNAME varchar2) 
RETURN int
as
meID int;
BEGIN
    SELECT menuID
    INTO meID
    FROM menu_items_T
    WHERE menuName = meNAME;
    RETURN meID;
 EXCEPTION
    WHEN no_data_found then
    DBMS_output.put_line('no such Menu');
 RETURN -1;
END;
/


create or replace procedure menu_items_insert(menuNameInsert varchar, menuPriceInsert decimal, cuisineNameInsert varchar)
as
begin
	insert into MENU_ITEMS_T values(menuID_seq.nextval, menuNameInsert, menuPriceInsert, FIND_CUISINE_TYPE_ID(cuisineNameInsert)); /* SQL statement to insert passed values*/
end;
/

create or replace procedure RESTAURANT_INVENTORY_Insert(restaurantQuantityInsert int, menuNameInsert varchar, restaurantNameCheck varchar)
as
restaurantID int;
menu_Item_ID int;
begin
	restaurantID := FIND_RESTAURANT_ID(restaurantNameCheck);
	menu_item_ID := FIND_MENU_ITEM_ID(menuNameInsert);
	insert into RESTAURANT_INVENTORY_T values(restaurantQuantityInsert, menuNameInsert, menu_item_ID, restaurantID); /* SQL statement to insert passed values*/
end;
/
CREATE table ORDERS_T ( 
    Order_ID INT,
    RestaurantID INT,
    Customer_ID INT,
    MenuID INT,
    WaiterID INT,
    Order_Date Date,
    Amount_Paid Decimal(10,2),
    Tip Decimal(10,2),
    PRIMARY KEY (Order_ID), -- unique and notnull
    -- foreign keys to join the tables with the parent table
    FOREIGN KEY (RestaurantID) REFERENCES RESTAURANT_T (RestaurantID),
    FOREIGN KEY (Customer_ID) REFERENCES CUSTOMERS_T (Customer_ID),
    FOREIGN KEY (MenuID) REFERENCES MENU_ITEMS_T (MenuID),
    FOREIGN KEY (WaiterID) REFERENCES WAITER_T (WaiterID)
    );
/

CREATE SEQUENCE orderID_seq START WITH 1
INCREMENT BY 1;

/
-- insertion of data using the procedures 


create or replace procedure tip_of_waiter
is 
cursor c1 is select waiter_t.waiterid,waiter_t.waiter_name, sum(orders_t.tip) as total_tip from orders_t,waiter_t where orders_t.waiterid=waiter_t.waiterid group by waiter_t.waiterid,waiter_t.waiter_name; 
BEGIN
FOR x in C1
loop
dbms_output.put_line(x.waiterid || x.waiter_name || x.Total_tip);
exit when C1%notfound;
END loop;
Exception
when no_data_found then
dbms_output.put_line('No data found');
END;

/
exec insertcustomer(seq_customers.nextval,'yogi','yogichb1@umbc.edu','4702 aldgate grn','Baltimore','MD','21227','1234345656787890');
exec insertcustomer(seq_customers.nextval,'cust1','cust1@umbc.edu','4712 aldgate grn','Baltimore','MD','21045','3456456756787890');
exec insertcustomer(seq_customers.nextval,'cust11','cust11@umbc.edu','4720 aldgate grn','Baltimore','MD','21045','1234456756787890');
exec insertcustomer(seq_customers.nextval,'cust3','cust3@umbc.edu','4721 aldgate grn','Baltimore','MD','21046','1234456756787812');
exec insertcustomer(seq_customers.nextval,'cust111','cust111@umbc.edu','4722 aldgate grn','Baltimore','MD','21045','1234456656787812');
exec insertcustomer(seq_customers.nextval,'custNY1','custNY1@umbc.edu','4711 aldgate grn','Times sqaure','NY','10045','2235546756787812');
exec insertcustomer(seq_customers.nextval,'custNY2','custNY2@umbc.edu','4821 aldgate grn','Times sqaure','NY','10045','4567456756787812');
exec insertcustomer(seq_customers.nextval,'custNY3','custNY3@umbc.edu','4822 aldgate grn','Times square','NY','10045','1234456756123412');
exec insertcustomer(seq_customers.nextval,'cust3','custPA1@umbc.edu','4812 aldgate grn','Fairless hills','PA','16822','4534456756787812');
exec insertcustomer(seq_customers.nextval,'cust3','custPA2@umbc.edu','4134 aldgate grn','Fairless hills','PA','16822','3434456756787812');
exec insertcustomer(seq_customers.nextval,'cust3','custPA3@umbc.edu','4817 aldgate grn','Fairless hills','PA','16822','5634456756787812');

exec menu_items_insert('burger', 10, 'American');
exec menu_items_insert('fries',5,'American');
exec menu_items_insert('pasta', 15, 'American');
exec menu_items_insert('salad', 10, 'American');
exec menu_items_insert('salmon', 20, 'American');

exec menu_items_insert('steak', 25, 'BBQ');
exec menu_items_insert('burger', 10, 'BBQ');
exec menu_items_insert('pork loin', 15, 'BBQ');
exec menu_items_insert('fillet mignon', 30, 'BBQ');

exec menu_items_insert('dal soup', 10, 'Indian');
exec menu_items_insert('rice', 5, 'Indian');
exec menu_items_insert('tandoori chicken', 10, 'Indian');
exec menu_items_insert('samosa', 8, 'Indian');

exec menu_items_insert('lasagna', 15, 'Italian');
exec menu_items_insert('meatballs', 10, 'Italian');
exec menu_items_insert('spaghetti', 15, 'Italian');
exec menu_items_insert('pizza', 20, 'Italian');

exec menu_items_insert('meat chunks', 12, 'Ethiopian');
exec menu_items_insert('legume stew', 10, 'Ethiopian');
exec menu_items_insert('flatbread', 3, 'Ethiopian');

Delete from restaurant_inventory_t;

--exec RESTAURANT_INVENTORY_Insert(150, 'burger', 'Ribs_R_US');
exec RESTAURANT_INVENTORY_Insert(150, 'fries', 'Ribs_R_US');
exec RESTAURANT_INVENTORY_Insert(10, 'lasagna', 'Bella Italia');
exec RESTAURANT_INVENTORY_Insert(15, 'steak', 'Bull Roast');
--exec RESTAURANT_INVENTORY_Insert(50, 'Pork lion', 'Bull Roast');
exec RESTAURANT_INVENTORY_Insert(50, 'fillet mignon', 'Bull Roast');
exec RESTAURANT_INVENTORY_Insert(50, 'dal soup', 'Taj Mahal');
exec RESTAURANT_INVENTORY_Insert(500, 'rice', 'Taj Mahal');
exec RESTAURANT_INVENTORY_Insert(150, 'samosa', 'Taj Mahal');
exec RESTAURANT_INVENTORY_Insert(150, 'meat chunks', 'selasie');
exec Restaurant_inventory_insert(150, 'legume stew','selasie');
--exec RESTAURANT_INVENTORY_Insert(500, 'flatbread', 'Selasie');

select * from cuisine_type_t;
select * from restaurant_t;
select * from waiter_t;
select * from customers_t;
select * from menu_items_t;
select * from restaurant_inventory_t;



delete from orders_t;
insert into orders_t values(orderid_seq.nextval,2,2,17,14,date'2022-03-10',20,4);
insert into orders_t values(orderid_seq.nextval,2,3,16,14,date'2022-03-15',30,6);
insert into orders_t values(orderid_seq.nextval,2,3,17,14,date'2022-03-15',20,4);
insert into orders_t values(orderid_seq.nextval,4,6,9,23,date'2022-04-01',60,12);
insert into orders_t values(orderid_seq.nextval,4,6,9,23,date'2022-04-02',60,12);
insert into orders_t values(orderid_seq.nextval,4,7,8,23,date'2022-04-01',15,3);


exec tip_of_waiter;
/
create or replace procedure tip_by_state 
is
cursor c1 is
select sum(orders_t.tip),restaurant_t.restaurantstate from orders_t,restaurant_t
where orders_t.restaurantid=restaurant_t.restaurantid 
group by restaurant_t.restaurantstate;
total_tip number;
state_name varchar(100);
begin
open c1;
loop
fetch c1 into total_tip,state_name;
exit when c1%NOTFOUND;
dbms_output.put_line(total_tip||state_name);
end loop;
close c1;
end;
/

exec tip_by_state;
/
commit;

exit;
quit;