ExUnit.start()

redis_keys = Redix.command!(:redix, ["DBSIZE"])
if Redix.command!(:redix, ["DBSIZE"]) > 0 do
  redis_database = Application.get_env(:rank, :redis_database)
  raise "Redis database number #{redis_database} has #{redis_keys} key(s) in it"
end
