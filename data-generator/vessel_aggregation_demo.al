#----------------------------------------------------------------------------------------------------------------------#
# Using a column for table / column  vessel data example - demonstrate aggregations with data being stored
# :todo:
# - add comments
# - add errors
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/data-generator/vessel_aggregation_demo.al

on error ignore

agg_db = agg_ + !default_dbms

connect dbms !agg_db where type=sqlite

set aggregation where dbms = !default_dbms and table = !agg_db and intervals = 10 and time = 1 minute and time_column = timestamp and value_column = gcurrent and target_dbms = agg_anotherpeak

set aggregation encoding where dbms = !default_dbms and table = battery_pack_logs and value_column = gcurrent and encoding = bounds and tolerance = 0

set aggregation ingest where dbms = !default_dbms  and table = battery_pack_logs and source = true and derived = true

:end-script:
end script
