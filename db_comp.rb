require 'jdbc/postgres'
require 'jdbc/mysql'
require 'lib/config'
require 'lib/checker'
require 'lib/column'
require 'lib/reporter'

check_file = ARGV[0] || './Checkfile'
exit 1 unless check_file

config = DBComp::Config.new
config.instance_eval do
  eval open('./db_comp.conf', 'r').read
end

Jdbc::Postgres.load_driver
url, user, password, db = config.redshift.connection
conn = java.sql.DriverManager.get_connection(url, user, password)
DBComp::RedshiftColumn.class_eval do
  @conn = conn
  @database = db
end

Jdbc::MySQL.load_driver
Java::com.mysql.jdbc.Driver
url, user, password, db = config.mysql.connection
conn = java.sql.DriverManager.get_connection(url, user, password)
DBComp::MySQLColumn.class_eval do
  @conn = conn
  @database = db
end

open(check_file) do |f|
  results = DBComp::Checker.new.execute f.read
  Reporter.report(results, STDOUT)
end
