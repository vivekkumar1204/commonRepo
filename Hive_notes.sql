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

 
