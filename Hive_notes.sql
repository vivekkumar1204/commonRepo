=========================Hive Notes=======================*****************
#Write the Hive query to wordcount taking textfile as input.
Step:1- Craete table table_name(sentence string);
Step:2- Load data local inpath 'word.txt' overwrite into table table_name;
step:3- select word,count(1) as count from (select explode(split(sentence,' ')) as word from table-name) temp group by word;

#Write script to execute the bunch of hive queries in one time.
>select * from table_name; --> save in a script file like 'script.q'.
>To run script --> hive -f script.q
>select * from ${hiveconf:tablename} limit ${hiveconf:number} -- This is for dynamic parameter script.
>To run script --> hive -hiveconf tablename=users -hiveconf number=10 -f script.q

#Set custom location for logs
>hive -hiveconf hive.log.dir=/home/vivekyadav/hive_logs

#Create external table with comma delimited file
>create external table stocks_eod_external (
  stockticker string,
  tradedate int,
  openprice float,
  highprice float,
  lowprice float,
  closeprice float,
  volume bigint) 
  row format delimited
  fields terminated by ','
  location '/user/vivekyadav/nyse';
  
#Create managed table in the given location not in default warehouse directory
>create table stocks_eod_managed (
  stockticker string,
  tradedate int,
  openprice float,
  highprice float,
  lowprice float,
  closeprice float,
  volume bigint) 
  row format delimited
  fields terminated by ','
  location '/user/vivekyadav/nyse';
  
#We can create manged and external tables on specified location. 
#The main difference b/w both is the coupling between metastore and HDFS:
1- If we drop external table then only table schema will be removed from the metastore and no impact on associated dataset.
2- If we drop managed table then schema from metastore along with associated dataset will be removed.
3- This main difference is because of coupling b/w the defferent application with dataset i.e if there is one dataset in shared location and associated with different application like hive,pig,spark. So in this case if anyone drop the table, dataset also will be dropped and other application will be impacted due to application with the same dataset.
4- And in future if any table need changes so we can change frequntly without touching the dataset.

#To get the created tables ddl form:
>show create table <tablename>;

#Types of partitioning in HIVE: 1- List Partitioning(using 'partitioned by') 2- Hash partitioning(clustered by)

#Creating the table with partitioned by:
>create table stocks_eod_list (
  stockticker string,
  tradedate int,
  openprice float,
  highprice float,
  lowprice float,
  closeprice float,
  volume bigint)
  partitioned by (tradeyear int)
  row format delimited
  fields terminated by ','
  lines terminated by '\n';
  
#Alter table for adding partitioning in table:
alter table stocks_eod_list add partition (tradeyear=2004);

#Loading data to partitioned table:
load data local inpath '/data/nyse/NYSE_2001.txt' into table stocks_eod_list partition(tradeyear=2001);
load data local inpath '/data/nyse/NYSE_2001.txt' into table stocks_eod_list partition(tradeyear=2002);
load data local inpath '/data/nyse/NYSE_2001.txt' into table stocks_eod_list partition(tradeyear=2003);
load data local inpath '/data/nyse/NYSE_2001.txt' into table stocks_eod_list partition(tradeyear=2004);
load data local inpath '/data/nyse/NYSE_2001.txt' into table stocks_eod_list partition(tradeyear=2005);

#To load the data from normal managed table to partitioned table
>insert into table stocks_eod_list partition(tradeyear) select t.*,cast(substr(tradedate, 1, 4) as int) tradeyear from stocks_eod_managed t;

#Difference b/w load and insert(when to use what):
>If any type of transformation involved while load data, so we have to use insert command.
>If we are loading data from local system then need to use load command.
>In case of loading data from table we can use insert.
>Performence wise load is better, because it used to load data without any transformation and just splitting the data into blocks and storing there.


#Write the Hive query to wordcount taking textfile as input.
Step:1- Craete table table_name(sentence string);
Step:2- Load data local inpath 'word.txt' overwrite into table table_name;
step:3- select word,count(1) as count from (select explode(split(sentence,' ')) as word from table-name) temp group by word;

#Write script to execute the bunch of hive queries in one time.
>select * from table_name; --> save in a script file like 'script.q'.
>To run script --> hive -f script.q
>select * from ${hiveconf:tablename} limit ${hiveconf:number} -- This is for dynamic parameter script.
>To run script --> hive -hiveconf tablename=users -hiveconf number=10 -f script.q

#To get the metadata about the file in hdfs
>hdfs fsck hdfs://nn01.itversity.com:8020/apps/hive/warehouse/vivekyadav.db/orders_another -files -locations -blocks;


#To create table with sequence file:
CREATE TABLE `orders_sequence`(
  `order_id` int,
  `order_date` string,
  `order_customer_id` int,
  `order_status` string)
ROW FORMAT DELIMITED
  FIELDS TERMINATED BY '|'
STORED AS sequencefile;

#To get compressed data while loading into hive tables, need to set below parameters(and to get compression need sequence file format as storage format):
set hive.exec.compress.output;
set hive.exec.compress.output=true;
set mapreduce.output.fileoutputformat.compress.codec;
set mapreduce.output.fileoutputformat.compress.codec=org.apache.hadoop.io.compress.SnappyCodec;

#To create bucketed(hash partitoning) table:
CREATE TABLE `orders_bucketed`(
  `order_id` int,
  `order_date` string,
  `order_customer_id` int,
  `order_status` string)
clustered by (order_id) into 16 buckets
ROW FORMAT DELIMITED
  FIELDS TERMINATED BY '|'
STORED AS textfile;

#To overwrite a table
>insert overwrite table table_name select * from table_name2;

#Insert the data into file from the table
>insert overwrite local( to insert in local machine) directory '/home/vivekyadav/hive_data/products' select * from products; 
>insert overwrite local directory '/home/vivekyadav/hive_data/products' select * from products;

#Create all retail_db tables in vivekyadav_final as managed tables and load data using gzip compression

#Exercise 14 : creating external table on given path:
>create external table vivekyadav_stage.categories (category_id int,category_department_id int,category_name string) row format delimited fields terminated by ',' lines terminated by '\n' location '/user/vivekyadav/exercise/categories';

>create external table vivekyadav_stage.customers (customer_id int,customer_fname string,customer_lname string,customer_email string,customer_password string,customer_street string,customer_city string,customer_state string,customer_zipcode string) row format delimited fields terminated by ',' lines terminated by '\n' location '/user/vivekyadav/exercise/categories';

>create external table vivekyadav_stage.departments (department_id int,department_name string) row format delimited fields terminated by ',' lines terminated by '\n' location '/user/vivekyadav/exercise/departments';

>create external table vivekyadav_stage.order_items (order_item_id int,order_item_order_id int,order_item_product_id int,order_item_quantity smallint,order_item_subtotal float,order_item_product_price float) row format delimited fields terminated by ',' lines terminated by '\n' location '/user/vivekyadav/exercise/order_items';

>create external table vivekyadav_stage.orders (order_id int,order_date date,order_customer_id int,order_status varchar(45)) row format delimited fields terminated by ',' lines terminated by '\n' location '/user/vivekyadav/exercise/orders';

>Alter table vivekyadav_stage.orders change order_date timestamp;

>create external table vivekyadav_stage.products (product_id int,product_category_id int,product_name varchar(45),product_description varchar(255),product_price float,product_image varchar(255)) row format delimited fields terminated by ',' lines terminated by '\n' location '/user/vivekyadav/exercise/products';

#Atleast one table on different location
>create external table vivekyadav_stage.departments_diff (department_id int,department_name string) row format delimited fields terminated by ',' lines terminated by '\n' location '/user/vivekyadav/exercise';

>load data local inpath '/home/vivekyadav/data/retail_db/departments/part-00000' overwrite into table departments_diff;

#Create all 6 managed table with compression
set hive.exec.compress.output=true;
set mapred.output.compression.codec=org.apache.hadoop.io.compress.GzipCodec;

>create table vivekyadav_final.categories (category_id int,category_department_id int,category_name string) row format delimited fields terminated by '|' lines terminated by '\n' stored as sequencefile;

>insert into table vivekyadav_final.categories select * from vivekyadav_stage.categories;

>create table vivekyadav_final.customers (customer_id int,customer_fname string,customer_lname string,customer_email string,customer_password string,customer_street string,customer_city string,customer_state string,customer_zipcode string) row format delimited fields terminated by '|' lines terminated by '\n'stored as sequencefile;

>insert overwrite table vivekyadav_final.customers select * from vivekyadav_stage.customers;

>create table vivekyadav_final.departments (department_id int,department_name string) row format delimited fields terminated by '|' lines terminated by '\n' stored as sequencefile;

>insert overwrite table vivekyadav_final.departments select * from vivekyadav_stage.departments;

>create table vivekyadav_final.order_items (order_item_id int,order_item_order_id int,order_item_product_id int,order_item_quantity smallint,order_item_subtotal float,order_item_product_price float) row format delimited fields terminated by '|' lines terminated by '\n' stored as sequencefile;

>insert overwrite table vivekyadav_final.order_items select * from vivekyadav_stage.order_items;

>create table vivekyadav_final.orders (order_id int,order_date date,order_customer_id int,order_status varchar(45)) row format delimited fields terminated by '|' lines terminated by '\n' stored as sequencefile;

>insert overwrite table vivekyadav_final.orders select * from vivekyadav_stage.orders;

>create table vivekyadav_final.products (product_id int,product_category_id int,product_name varchar(45),product_description varchar(255),product_price float,product_image varchar(255)) row format delimited fields terminated by '|' lines terminated by '\n' stored as sequencefile;

>insert overwrite table vivekyadav_final.products select * from vivekyadav_stage.products;

#Create two tables orders_bucketed and orders_items_bucketed with bucketing with order_id:
>create table vivekyadav_final.orders_bucketed (order_id int,order_date date,order_customer_id int,order_status varchar(45)) clustered by(order_id) into 16 buckets row format delimited fields terminated by '|' lines terminated by '\n' stored as sequencefile;

>set hive.enforce.bucketing = true;(This property need to make true before bucketing)
>insert overwrite table vivekyadav_final.orders_bucketed select * from vivekyadav_stage.orders;
>Bucket parts will be in file format

>create table vivekyadav_final.order_items_bucketed (order_item_id int,order_item_order_id int,order_item_product_id int,order_item_quantity smallint,order_item_subtotal float,order_item_product_price float) clustered by (order_item_id) into 16 buckets row format delimited fields terminated by '|' lines terminated by '\n' stored as sequencefile;

>insert overwrite table vivekyadav_final.order_items_bucketed select * from vivekyadav_stage.order_items;


#Create a table with partition: orders_partioned
>create table vivekyadav_final.orders_partitioned (order_id int,order_date date,order_customer_id int,order_status varchar(45)) partitioned by (order_month int) row format delimited fields terminated by '|' lines terminated by '\n' stored as sequencefile;

>set hive.exec.dynamic.partition=true;
>set hive.exec.dynamic.partition.mode=nonstrict;
>insert overwrite table vivekyadav_final.orders_partitioned partition(order_month) select t.*,month(order_date) as order_month from vivekyadav_stage.orders t;
>In partitioning parts stores like directories.
>Inside directory, data file will be exist and we can apply bucketing again inside the partitioned data file.

#Refresh the hive metadata after the new partition added, new data files added etc.
>msck repair table <table_name>;

#Type of UDFs --> 1: General User Defined Function, 2: UDAF(User Defined Aggregate Function), 3: UDTF(User Defined Tabular Function)
Step 1: Create java class along with required logic
Step 2: create jar file of java code
Step 3: Add jar file in .hiverc file or in hive terminal using below command-
add jar <Fully qualified path of jar file>
Ex: add jar /home/vivekyadav/maxMarks_UDF_jar.jar;
Step 4: create temporary function using below syntax-
Ex: 
create temporary function <function_name> as 'absolute class path i.e package_name.classname';
hive (vivekyadav)> create temporary function custom_max as 'lab.UDFs.Custom_Max';


Example: Regular UDF
create table student(id int,name string,math double,eng double,physics double,social double);

insert into student values(1,'a',12.4,23.3,85.1,44.3);
insert into student values(2,'b',13.4,93.3,82.1,04.3);
insert into student values(3,'c',14.4,23.3,80.1,24.3);
insert into student values(4,'d',10.4,73.3,83.1,74.3);
insert into student values(5,'e',17.4,43.3,86.1,24.3);

Output:
1       a       85.1
2       b       93.3
3       c       80.1
4       d       83.1
5       e       86.1

Real ex: While implementing one senario from business i found out that, business need maximum spend across the spend categories
cm11   travel       entertain       groceries      transport
1        5              2              4              9
2         3             5              10             8
3        11              2              1              3
4          6             15              5            7

output:
1   9
2   10
3   11
4   15
 

Example: User Defined Aggregation Function
 
Complex Data Types: Array
--------------------------
 DDL:
 
drop table if exists array_test; 
create table array_test(id int,name string,marks array<double>) row format delimited fields terminated by ',' collection items terminated by '|';

Data set:

1,'a',12.4|23.3|85.1|44.3
2,'b',13.4|93.3|82.1|04.3
3,'c',14.4|23.3|80.1|24.3
4,'d',10.4|73.3|83.1|74.3
5,'e',17.4|43.3|86.1|24.3

select id, marks[1] from array_test;
1       23.3
2       93.3
3       23.3
4       73.3
5       43.3

Example:
create table table1(
a string,
b string,
c int,
table2 array<struct<id:int,name:string>>),
table3 array<struct<id:int,address:string>>)
stored as parquet;

Complex Data Types: Map
-----------------------
DDL:

drop table if exists map_test;
create table map_test(school string, state string, gender string, total map<int,int>) row format delimited fields terminated by '\t' collection items terminated by ',' map keys terminated by ':';

Data set:

sec school	up	M	2015:62543,2016:35343,2017:35343
pri school	mp	F	2015:62543,2016:35343,2017:35343
sr sec school	up	M	2015:62543,2016:35343,2017:35343
jnr school	br	F	2015:62543,2016:35343,2017:35343
sec school	uk	M	2015:62543,2016:35343,2017:35343
hr school	tn	F	2015:62543,2016:35343,2017:35343
snr school	jk	M	2015:62543,2016:35343,2017:35343
sec school	gj	F	2015:62543,2016:35343,2017:35343

select school, total[2015] from map_test;
sec school      62543
pri school      62543
sr sec school   62543
jnr school      62543
sec school      62543
hr school       62543
snr school      62543
sec school      62543


Complex Data Types: Struct
--------------------------

drop table if exists struct_test;
create table struct_test (bike_name string, features struct<eng_type:string,power:float>) row format delimited fields terminated by '\t' collection items terminated by ',' ;

royal	dow,63.3
hero	eng,56.3
moto	sup,54.3
hero	white,54.3
bajaj	mold,54.3
harle	layer,54.3

select features.eng_type;
dow
eng
sup
white
mold
layer


Hive tables for json file formats:
----------------------------------
1: JSON format

Dataset:
--------
{"one":true,"three":["red","yellow","orange"],"two":19.5,"four":"poop"}
{"one":false,"three":["red","yellow","black"],"two":129.5,"four":"stars"}
{"one":false,"three":["pink","gold"],"two":222.56,"four":"fiat"}

DDL:
----
create table if not exists josn_test(
one string
,three array<string>
,two double, four string
) row format serde 'org.apache.hive.hcatalog.data.JsonSerDe' 
stored as textfile;

Load dataset into table:
------------------------
load data local inpath '/home/vivekyadav/input/json_test/json_test.json' into table josn_test;


Hive tables for sequence file formats:
--------------------------------------
2; SEQUENCE file format

Dataset:
--------


DDL:
----


Load dataset into table:
------------------------

Hive file formats
https://acadgild.com/blog/apache-hive-file-formats
https://acadgild.com/blog/parquet-file-format-hadoop
https://acadgild.com/blog/avro-hive
> Text, RC, ORC, SEQUENCE are build in formats
> Avro, parquet: Stores binary data in column oriented format, good for column specific read
Custom SerDe
UDFs
Analytic functions
PARTITIONing and bucketing


UDAF & UDTF:
------------
Command to execute UDF:
-----------------------
add jar /home/vivekyadav/mrjars/mr-unit-test.jar;
create temporary function udf_strip as 'udf.UDF_STRIP';

Dataset:

269.6
174.6
235.6
723.6
334.6
506.6
406.6
133.6

create table if exists udaf_test(num int);
create temporary function udaf_max as 'udf.UDAF_Maximum';

create table if not exists udafmean_test(num_double double);
load data local inpath '/home/vivekyadav/input/udf/udaf_mean.txt' into table udafmean_test;
udaf_mean.txt
create temporary function udaf_mean as 'udf.UDAF_Mean';



Analytical function:
-------------------- 

PAT_ID | INS_AMT | DEPT_ID 
--------+---------+--------- 
create table patient(pat_id int, ins_amt int, dept_id int) row format delimited fields terminated by ',';
 
load data local inpath '/home/vivekyadav/input/ana_win/patient.txt' into table patient;
 
1,100000,111
3,150000,222
5,50000,111
5,890000,222
7,110000,333
2,150000,111
4,250000,222
6,90000,111
8,10000,444


select pat_id, dept_id, sum(ins_amt) over (partition by dept_id order by dept_id) as tot_am from patient;
6       111     390000
2       111     390000
5       111     390000
1       111     390000
4       222     1290000
5       222     1290000
3       222     1290000
7       333     110000
8       444     10000

select dept_id, sum(ins_amt) over (partition by dept_id order by dept_id) as tot_am from patient;
111     390000
111     390000
111     390000
111     390000
222     1290000
222     1290000
222     1290000
333     110000
444     10000


select 
pat_id,
dept_id
,min(ins_amt) over (partition by dept_id order by dept_id asc) as min_amt
,max(ins_amt) over (partition by dept_id order by dept_id asc) as max_amt
from patient;

6       111     50000   150000
2       111     50000   150000
5       111     50000   150000
1       111     50000   150000
4       222     150000  890000
5       222     150000  890000
3       222     150000  890000
7       333     110000  110000
8       444     10000   10000

--lead & lag

select pat_id, dept_id,
ins_amt, 
lead(ins_amt,1,0) over (partition by dept_id) as lead_amt, 
lag(ins_amt,1,0) over (partition by dept_id) as lag_amt 
from patient;

6       111     90000   150000  0
2       111     150000  50000   90000
5       111     50000   100000  150000
1       111     100000  0       50000
4       222     250000  890000  0
5       222     890000  150000  250000
3       222     150000  0       890000
7       333     110000  0       0
8       444     10000   0       0

select
pat_id
,dept_id
,ins_amt
,first_value(ins_amt) over (partition by dept_id order by ins_amt asc)
,last_value(ins_amt) over (partition by dept_id order by ins_amt asc)
from patient;

5       111     50000   50000   50000
6       111     90000   50000   90000
1       111     100000  50000   100000
2       111     150000  50000   150000
3       222     150000  150000  150000
4       222     250000  150000  250000
5       222     890000  150000  890000
7       333     110000  110000  110000
8       444     10000   10000   10000

select
pat_id
,dept_id
,ins_amt
,first_value(ins_amt) over (partition by dept_id order by dept_id asc)
,last_value(ins_amt) over (partition by dept_id order by dept_id asc)
from patient;

6       111     90000   90000   100000
2       111     150000  90000   100000
5       111     50000   90000   100000
1       111     100000  90000   100000
4       222     250000  250000  150000
5       222     890000  250000  150000
3       222     150000  250000  150000
7       333     110000  110000  110000
8       444     10000   10000   10000

--#Hive Transactional tables:
----------------------------
> ACID properties are vital and neccesory for transactional tables.
Atomicity: Atomicity means, a transaction should complete successfully or else it should fail completely i.e. it should not be left partially. 

Consistency: Consistency ensures that any transaction will bring the database from one valid state to another state.

Isolation: Isolation states that every transaction should be independent of each other i.e. one transaction should not affect another.

Durability: Durability states that if a transaction is completed, it should be preserved in the database even if the machine state is lost or a system failure might occur.

Some pre-requisites for transactio tables:
> Table should have ORC file format
> It should be bucketed
> Below properties should be set turn ON
set hive.support.concurrency = true;
set hive.enforce.bucketing = true;
set hive.exec.dynamic.partition.mode = nonstrict;
set hive.txn.manager = org.apache.hadoop.hive.ql.lockmgr.DbTxnManager;
set hive.compactor.initiator.on = true;
set hive.compactor.worker.threads = a positive number on at least one instance of the Thrift metastore service;

> Create table:
create table college_trans (clg_id int, clg_name string, clg_loc string) clustered by (clg_id) into 5 buckets stored as orc TBLPROPERTIES('transactional'='true');

> Insert the values into table
insert into table college_trans values(1,'nec','nlr'),(2,'vit','vlr'),(3,'srm','chen'),(4,'lpu','del'),(5,'stanford','uk'),(6,'JNTUA','atp'),(7,'cambridge','us');

-- Update is not possible on bucketed column
> update college_trans set clg_id = 8 where clg_id = 7;
Output:
FAILED: SemanticException [Error 10302]: Updating values of bucketing columns is not supported.  Column clg_id.

--Update is possible in non bucketed column
> update college_trans set clg_name = 'IIT' where clg_id = 7;
output:
5       stanford        uk
6       JNTUA   atp
1       nec     nlr
7       IIT     us
2       vit     vlr
3       srm     chen
4       lpu     del

-- Delete operation
> delete * from college_trans where clg_id = 6;
output:
5       stanford        uk
1       nec     nlr
7       IIT     us
2       vit     vlr
3       srm     chen
4       lpu     del



--# Hie update: Merge strategy
--Part:1 --> SQL Merge
--Merge Syntax:
MERGE INTO <target table>
 USING <table reference>
ON <search condition>
 <merge when clause>...
WHEN MATCHED [ AND <search condition> ]
THEN <merge update or delete specification>
WHEN NOT MATCHED [ AND <search condition> ]
THEN <merge insert specification>

Example: Create tables with attributes : id, name, email, state, signup
--Table 1: customer_partitioned
drop table if exists customer_partitioned;
create table if not exists customer_partitioned(id int, name string, email string, state string) partitioned by (signup date) clustered by (id) into 2 buckets stored as orc tblproperties('transactionl'='true');
--Data:

--Raw table with data
drop table if exists customer_partitioned_raw;
create table customer_partitioned_raw(id int, name string, email string, state string, signup date) row format delimited fields terminated by ',';
1,samiie, samiie@mail.com,'pa',2017-01-09
2,Hazie, samiie@mail.com,'ga',2017-01-05
3,Allyn, samiie@mail.com,'nv',2017-01-08
4,zemlack, samiie@mail.com,'wa',2017-01-03
load data local inpath '/home/vivekyadav/hive_data/merge/customer' into table customer_partitioned_raw;
 
insert into table customer_partitioned partition (signup) select * from customer_partitioned_raw;

--Table 2: customer_updated
drop table if exists customer_updated;
create table customer_updated(id int, name string, email string, state string) partitioned by (signup date) clustered by (id) into 2 buckets stored as orc tblproperties('transactionl'='true');

--Raw table with data
drop table if exists customer_updated_raw;
create table customer_updated_raw(id int, name string, email string, state string, signup date) row format delimited fields terminated by ',';
1,samiie, zammy@mail.com,'pa',2017-01-09
2,Hazie, samiie@mail.com,'ok',2017-01-05
3,Allyn, samiie@mail.com,'nv',2017-01-08
4,zemlack, samiie@mail.com,'wa',2017-01-03
5,zemlack, zem@mail.com,'np',2017-01-10
6,zack, lay@mail.com,'lp',2017-01-11
load data local inpath '/home/vivekyadav/hive_data/merge/customer_updated' into table customer_updated_raw;
 
insert into table customer_updated partition (signup) select * from customer_updated_raw;


--Merge query to do upsert
MERGE into customer_partitioned cp using customer_updated cu on cp.id=cu.id when matched then update set cp.email=cu.email, cp.state=cu.state when not matched then insert values(cu.id,cu.name,cu.email,cu.state,cu.signup);



--# Hie update: 4 step update strategy

--#Optimization techniques in HIVE:
1: Predicate pushdown
2: PARTITIONing
3: De-normalizing data
4: Compress mapreduce output
5: Map Join 
6: Bucketing
7: Parallel execution
8: Vectorization

--#Predicate pushdown strategy
> The basic idea of predicate pushdown is that certain parts of sql queries(the predicates) can be pushed to where data lives.
> Generally when executing SQL queries, a JOIN will be performed before the filtering used in the WHERE clause. In Hive (MapReduce), predicate pushdown is used to filter data in the map phase before sending over the network to the reduce phase.

Ex:For example in this query the WHERE a.country = 'Argentina' will be evaluated in the map phase, reducing the amount data sent over the network:

SELECT
  a.*
FROM
  table1 a
JOIN 
  table2 b ON a.id = b.id
WHERE
  a.country = 'Argentina';

Predicate Pushdown in Parquet/ORC files:
Parquet and ORC files maintain various stats about each column in different chunks of data (such as min and max values). Programs reading these files can use these indexes to determine if certain chunks, and even entire files, need to be read at all.  This allows programs to potentially skip over huge portions of the data during processing.  
