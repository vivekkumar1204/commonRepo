Book meter: 46

Hadoop Basics:
--------------

Data Flow:
> MapReduce jobs split into map and reduce tasks and run over the cluster in different nodes as parallel computing.
> Number of mappers run as equal number of input splits.
> mapper task can run on local node where data resides or in other node so in that case data will travel through network for computation.
> Map tasks try to execute as per data locality feature.
> Map output is intermediate output of job and it stores in local file system of node not in HDFS, if that node get failed so schedular will rerun the same mapper in different node to recumpute the data and will consumed by the reducer.
> All mappers output get merged and shuffle to reducer.
> Reducer consume the intermediate output from mapper and process then store out into HDFS,
> Reducer stores 1 replica of output in local node and others in off-rack nodes. Thats the reason it consume network bandwidth to write the job output data.
> Number of reduce tasks is not governed by size of input. We can set it in job configuration.

Combiner Function:
> 



Hadoop submit commands:
-----------------------
input path: /home/impetus/Desktop/hadoop_input/wordcountinput.txt.txt
output path: /home/impetus/Desktop/hadoop_output
jar name: rampup-0.0.1-SNAPSHOT.jar
fat jar name: rampup-0.0.1-SNAPSHOT-jar-with-dependencies.jar

hadoop jar <fully qualified main class name> input output

hadoop jar /home/impetus/Desktop/hadoop_jars/rampup-0.0.1-SNAPSHOT-jar-with-dependencies.jar com.impetus.wordcount.WordCount /home/impetus/Desktop/hadoop_input/wordcountinput.txt /home/impetus/Desktop/hadoop_output

Hadoop deamons start command:
-----------------------------
start-dfs.sh
start-yarn.sh
mr-jobhistory-daemon.sh start historyserver

Command to run the mr job with local file system input and output:
------------------------------------------------------------------
hadoop jar /home/impetus/Desktop/hadoop_jars/mr-unit-test.jar com.impetus.maxtemp.MaxTemperatureDriver -fs file:/// -jt local /home/impetus/Desktop/hadoop_jars/1901 /home/impetus/Desktop/hadoop_jars/output

Command to run the mr job with HDFS input and output:
------------------------------------------------------------------
hadoop jar /home/impetus/Desktop/hadoop_jars/mr-unit-test.jar com.impetus.maxtemp.MaxTemperatureDriver /input/wd /output/wd

To merge the multiple output files from HDFS to local in a single file:
-----------------------------------------------------------------------
hadoop fs -getmerge max-temp max-temp-local

>Run job in local mode
>Run job in cluster mode
>Resource manager Web UI
>Debugging a job for inaccurate data or missing data
>Custom counter to count the number of records hAVING INACCURATE OR MISSED DATA.


hadoop jar /home/vivekyadav/mrjars/mr-unit-test.jar co.impetus.secsorting.SecondarySortBasicDriver /user/vivekyadav/input/emp/Employee.txt /user/vivekyadav/output/emp


Command to run movie Lense data set for group by clause:
--------------------------------------------------------

hadoop jar /home/vivekyadav/mrjars/mr-unit-test.jar co.impetus.movie.MovieUserRatingDriver /user/vivekyadav/input/movie/u.data /user/vivekyadav/output/movie/

Command to run movie Lense data set for group by and reduce join clause:
------------------------------------------------------------------------
hadoop jar /home/vivekyadav/mrjars/mr-unit-test.jar co.impetus.reducejoin.ReduceJoinDriver /user/vivekyadav/input/movie/u.data /user/vivekyadav/input/movie/u.user /user/vivekyadav/output/movie/

Command to run map join clause:
------------------------------
hadoop jar /home/vivekyadav/mrjars/mr-unit-test.jar mapsidejoin.MapSideDriver /user/vivekyadav/input/mapside/employees_tsv.txt /user/vivekyadav/output/mapside


hadoop jar /home/vivekyadav/mrjars/mr-unit-test.jar co.impetus.matchremove.MatchRemoveDriver /user/vivekyadav/input/match_remove/user_movie.txt /user/vivekyadav/output/match_remove /user/vivekyadav/input/match_remove/movie.txt

Command to run reduce join clause:
------------------------------
/mr/src/main/java/co/impetus/reduce/ReduceJoinDriver.java

hadoop jar /home/vivekyadav/mrjars/mr-unit-test.jar co.impetus.reduce.ReduceJoinDriver /user/vivekyadav/input/reducejoin/cust_details  /user/vivekyadav/input/reducejoin/transaction_details /user/vivekyadav/output/reducesidejoin 
