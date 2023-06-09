/* TEAM 2 
IS620_Team2
Yogichandar Boppana(Member 2)
David Calderone
Sara Khanjani
Tolulope Ale
Will Bundesen
*/

/*
�	Member 2: Responsible for the Waiters table. Must create the table.
5.	Hire waiter: Given all pertinent information as parameters, hire a waiter at a restaurant.  The waiter name and restaurant ID must be input parameters. Use the function FIND_RESTAURANT_ID (see helper functions below) first to get the rID.
6.	Show list of waiters: Given a restaurant ID (you need to call the appropriate helper function), show all info about each employee
7.	Report tips:  Show total tips by each waiter. 
8.	Report tips by state: Show total tips earned by waiters per state.
*/

-- dropping all pre-existing sequences, tables,procedures and functions that are used in the code.
drop table waiter_t;
drop sequence waiter_id_seq;
drop function find_waiter_id;
drop procedure hire_a_waiter;
drop procedure details_of_waiter;

/
-- setting the server output on to view the results 
set serveroutput on;
--creating a new sequnce for assigning a waiter id in the waiter table 
create sequence waiter_id_seq start with 10 increment by 1;
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
insert into waiter_t values(waiter_id_seq.nextval,1,'riley');
insert into waiter_t values(waiter_id_seq.nextval,2,'rohan');
insert into waiter_t values(waiter_id_seq.nextval,1,'meghana');
insert into waiter_t values(waiter_id_seq.nextval,3,'ram');
insert into waiter_t values(waiter_id_seq.nextval,1,'mary');
insert into waiter_t values(waiter_id_seq.nextval,2,'john');
-- Getting what data pre exists before creation of procedures 
select * from waiter_t;

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
-- insertion of data using the procedures, a set of other data is also added.
exec hire_a_waiter('Jack','Ribs_R_US');
exec hire_a_waiter('Jill','Ribs_R_US');
exec hire_a_waiter('Wendy','Ribs_R_US');
exec hire_a_waiter('Hailey','Ribs_R_US');
exec hire_a_waiter('Mary','Bella Italia');
exec hire_a_waiter('Pat','Bella Italia');
exec hire_a_waiter('Michael','Bella Italia');
exec hire_a_waiter('Rakesh','Bella Italia');
exec hire_a_waiter('Verma','Bella Italia');
exec hire_a_waiter('yogi','Ribs_R_US');
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
commit;

