#-----------------------------------------------------------------------------------------------------------------------
# The following file is intended as a placeholder for user implemented code. The file is automatically called by master,
# operator, publisher, query or single_node (operator / publisher) files. If not is written then nothing runs.
#
# Sample commands could include things like;
#   * complicated MQTT calls
#   * Kafka requests
#   * non-standard schedule processes, such as recording disk usage and automated queries
#
# Documentation: https://github.com/AnyLog-co/documentation
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/node-deployment/local_script.al


connect dbms agg_anotherpeak where type=sqlite

set aggregation where dbms = anotherpeak and table = battery_pack_logs and intervals = 10 and time = 1 minute and time_column = timestamp and value_column = gcurrent and target_dbms = agg_anotherpeak

set aggregation encoding where dbms = anotherpeak and table = battery_pack_logs and value_column = gcurrent and encoding = bounds and tolerance = 0