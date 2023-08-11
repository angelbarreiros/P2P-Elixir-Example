defmodule Interface do
  @moduledoc """
  Entry point for users to use this program.
  """
  def start do
    Api.start_link(0)
    GenServer.call(Api,:start)
  end
  def register(username) do
    case GenServer.call(Api,{:register,username}) do
       :ok->:ok
       :already_exists -> raise ArgumentError ,'UserAlreadyExists'

    end
  end

  def login(username) do
    response= GenServer.call(Api,{:login,username})
    case response do
      {:ok,pids} -> connection(pids,username)
      :not_found -> raise ArgumentError ,'UserNotFound'
    end
  end


  defp connection(pids, username) do
    IO.write("Current peers in your account: ")
    IO.inspect(pids)

    variable =
      IO.gets(
        "Choose a function [connect -pidnumber,accountsynchronize,synchronizewith -username,createpeer]: "
      )

    case String.split(String.downcase(String.trim(variable)), "\s") do
      ["connect" | tail] ->
        IO.write("Connecting..\n")
        IO.write(
      "If you are trying to connect to a Peer, look the list above, pass as second parameter the number in the list, starting in 0\n"
      )
        peerconnection(Enum.at(pids, String.to_integer(List.first(tail))))
        connection(pids, username)

      ["synchronizewith" | tail] ->
        case GenServer.call(Api,{:synchronizewith,username,List.first(tail)}) do
           :ok->:ok
           :not_found-> IO.write("UserNotFound")

        end
        connection(pids,username)

      ["accountsynchronize"] ->
        GenServer.call(Api,{:synchronizeaccount,username})
        connection(pids,username)

      ["createpeer"] ->
        pid=GenServer.call(Api,{:createpeer,username})
        connection([pid | pids], username)

      _ ->
        IO.write("Exited\n")
    end
  end

  defp peerconnection(pid) do
    IO.inspect(pid)



    variable = IO.gets("Choose a function [find -item,save,getvolume,getneighboor]: ")

    case String.split(String.downcase(String.trim(variable)), "\s") do
      ["save" | tail] ->
        :ok = GenServer.call(Api,{:pid_save,pid,List.first(tail)})
        IO.write("Saved\n")
        peerconnection(pid)

      ["getvolume"] ->
        IO.inspect(GenServer.call(Api,{:pid_get_volume,pid}))
        peerconnection(pid)

      ["getneighboor"] ->
        IO.inspect(GenServer.call(Api,{:pid_get_neighboor,pid}))
        peerconnection(pid)

      ["find" | tail] ->
        IO.write("This function is asyncronous so we can not know if the item was found, check your volume\n")
        IO.write("!!!Check your Volume!!!\n")
        GenServer.call(Api,{:pid_find_item,pid,List.first(tail)})



        peerconnection(pid)

      _ ->
        IO.write("Exiting...\n")
    end
  end
end
