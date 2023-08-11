defmodule IronmaidenTest do
  use ExUnit.Case
  test "create and login User" do
    username="angel"
    not_found_username="dadsa"
    Api.start_link(0)
    assert  GenServer.call(Api,:start) == :ok
    assert GenServer.call(Api,{:register,username}) == :ok
    assert GenServer.call(Api,{:register,username}) == :already_exists
    {result,pids} = GenServer.call(Api,{:login,username})
    assert result==:ok
    assert is_pid(List.first(pids))
    assert GenServer.call(Api,{:login,not_found_username}) == :not_found

end
test "create new peer" do
  username="angel"
  Api.start_link(0)
    assert  GenServer.call(Api,:start) == :ok
    pid=GenServer.call(Api,{:createpeer,username})
    assert is_pid(pid)

end
test "self sync account" do
  username="angel"
  Api.start_link(0)
    assert  GenServer.call(Api,:start) == :ok
    assert GenServer.call(Api,{:register,username}) == :ok
    GenServer.call(Api,{:login,username})
    pid=GenServer.call(Api,{:createpeer,username})
    assert length(GenServer.call(Api,{:pid_get_neighboor,pid}))==0
    assert GenServer.call(Api,{:synchronizeaccount,username})== :ok
    assert length(GenServer.call(Api,{:pid_get_neighboor,pid}))==1

end

test " sync with other account" do
  username="angel"
  username2="alejandro"
  Api.start_link(0)
    assert  GenServer.call(Api,:start) == :ok
    assert GenServer.call(Api,{:register,username}) == :ok
    GenServer.call(Api,{:login,username})
    pid=GenServer.call(Api,{:createpeer,username})
    assert length(GenServer.call(Api,{:pid_get_neighboor,pid}))==0

    assert GenServer.call(Api,{:register,username2}) == :ok
    GenServer.call(Api,{:login,username2})

    assert GenServer.call(Api,{:synchronizewith,username,username2})== :ok
    assert length(GenServer.call(Api,{:pid_get_neighboor,pid}))==1

end
test " sync with  not valid account " do
  username="angel"
  username2="alejandro"
  Api.start_link(0)
    assert  GenServer.call(Api,:start) == :ok
    assert GenServer.call(Api,{:register,username}) == :ok
    GenServer.call(Api,{:login,username})
    pid=GenServer.call(Api,{:createpeer,username})
    assert length(GenServer.call(Api,{:pid_get_neighboor,pid}))==0

    assert GenServer.call(Api,{:synchronizewith,username,username2})== :not_found
    assert length(GenServer.call(Api,{:pid_get_neighboor,pid}))==0

end
test " item save and get item " do
  username="angel"
  item="libro1"
  Api.start_link(0)
    assert  GenServer.call(Api,:start) == :ok
    assert GenServer.call(Api,{:register,username}) == :ok
    {:ok,pids}=GenServer.call(Api,{:login,username})
    assert GenServer.call(Api,{:pid_save,List.first(pids),item})==:ok

    assert GenServer.call(Api,{:pid_get_volume,List.first(pids)})==[item]
    assert GenServer.call(Api,{:pid_save,List.first(pids),item})==:ok
    assert GenServer.call(Api,{:pid_get_volume,List.first(pids)})==[item,item]

end
test "find in your peer" do
  username="angel"
  item="libro1"
  Api.start_link(0)
    assert  GenServer.call(Api,:start) == :ok
    assert GenServer.call(Api,{:register,username}) == :ok
    {:ok,pids}=GenServer.call(Api,{:login,username})
    assert GenServer.call(Api,{:pid_save,List.first(pids),item})==:ok
    GenServer.call(Api,{:pid_find_item,List.first(pids),item})
    assert GenServer.call(Api,{:pid_get_volume,List.first(pids)})==[item,item]

end
test " find in a private net" do
  item="libro1"
  username="angel"
  username2="alejandro"
  Api.start_link(0)
    assert  GenServer.call(Api,:start) == :ok
    assert GenServer.call(Api,{:register,username}) == :ok
    GenServer.call(Api,{:login,username})
    pid=GenServer.call(Api,{:createpeer,username})
    assert length(GenServer.call(Api,{:pid_get_neighboor,pid}))==0

    assert GenServer.call(Api,{:register,username2}) == :ok
    {:ok,pids}=GenServer.call(Api,{:login,username2})

    assert GenServer.call(Api,{:synchronizewith,username,username2})== :ok
    assert length(GenServer.call(Api,{:pid_get_neighboor,pid}))==1

    assert GenServer.call(Api,{:pid_save,pid,item})==:ok
    GenServer.call(Api,{:pid_find_item,List.first(pids),item})
    :timer.sleep(1000)
    assert GenServer.call(Api,{:pid_get_volume,List.first(pids)})==[item]


end
test " find via SperPeer" do
  item="libro1"
  username="angel"
  username2="alejandro"
  Api.start_link(0)
    assert  GenServer.call(Api,:start) == :ok
    assert GenServer.call(Api,{:register,username}) == :ok
    GenServer.call(Api,{:login,username})
    pid=GenServer.call(Api,{:createpeer,username})
    assert GenServer.call(Api,{:pid_save,pid,item})==:ok

    assert GenServer.call(Api,{:register,username2}) == :ok
    {:ok,pids}=GenServer.call(Api,{:login,username2})



    GenServer.call(Api,{:pid_find_item,List.first(pids),item})
    :timer.sleep(1000)
    assert GenServer.call(Api,{:pid_get_volume,List.first(pids)})==[item]


end
test " not found " do
  item="libro1"
  item_not_found="sdasdsa"
  username="angel"
  username2="alejandro"
  Api.start_link(0)
    assert  GenServer.call(Api,:start) == :ok
    assert GenServer.call(Api,{:register,username}) == :ok
    GenServer.call(Api,{:login,username})
    pid=GenServer.call(Api,{:createpeer,username})
    assert GenServer.call(Api,{:pid_save,pid,item})==:ok

    assert GenServer.call(Api,{:register,username2}) == :ok
    {:ok,pids}=GenServer.call(Api,{:login,username2})



    GenServer.call(Api,{:pid_find_item,List.first(pids),item_not_found})
    :timer.sleep(1000)
    assert GenServer.call(Api,{:pid_get_volume,List.first(pids)})==[]


end


end
