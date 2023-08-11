defmodule Api do use GenServer
@moduledoc """
  Facade class , the one who calls the peer precesses or the SuperPeer
"""
def start_link(state) do
  GenServer.start_link(__MODULE__, state, name: __MODULE__)
end

@impl true
def init(state) do
  {:ok, state}
end
@impl true
def handle_call(:start, _from, state) do
  SuperPeer.start_link(%{})
  {:reply,:ok,state}

end
@impl true
def handle_call({:register,username}, _from, state) do
  if !GenServer.call(SuperPeer, {:verify, username}) do
    GenServer.call(SuperPeer, {:add_new_user, username})
    {:reply,:ok,state}
  else
    {:reply,:already_exists,state}
  end

end
@impl true
def handle_call({:login,username}, _from, state) do
  if GenServer.call(SuperPeer, {:verify, username}) do
    if GenServer.call(SuperPeer, {:void, username}) do
      {:ok, pids} = Peer.start_link({[], []})
      GenServer.cast(SuperPeer, {:save, pids, username})
      {:reply,{:ok,[pids]},state}
    else
      {:reply,{:ok,GenServer.call(SuperPeer, {:pids, username})},state}
    end
  else
    {:reply,:not_found,state}

  end
end

@impl true
def handle_call({:synchronizewith,username1,username2}, _from, state) do
  user_pids1 = GenServer.call(SuperPeer, {:pids, username1})
  user_pids2 = GenServer.call(SuperPeer, {:pids, username2})


  if user_pids2 != nil && user_pids1 != nil do
    sincrowith(user_pids2,user_pids1)
    {:reply,:ok,state}
  else {:reply,:not_found,state}
end

end
@impl true
def handle_call({:synchronizeaccount,username}, _from, state) do
  pids = GenServer.call(SuperPeer, {:pids, username})
  if pids != nil do
    sincrowith(pids,pids)
    {:reply,:ok,state}
  else {:reply,:not_found,state}
  end


end
@impl true
def handle_call({:createpeer,username}, _from, state) do
  {:ok, pid} = Peer.start_link({[], []})
  GenServer.cast(SuperPeer, {:save, pid, username})
  {:reply,pid,state}

end

@impl true
def handle_call({:pid_save,pid,item}, _from, state) do
  GenServer.cast(pid, {:save, item})
  {:reply,:ok,state}

end

@impl true
def handle_call({:pid_get_volume,pid}, _from, state) do
  volume = GenServer.call(pid, :volume)
  {:reply,volume,state}

end

@impl true
def handle_call({:pid_get_neighboor,pid}, _from, state) do
  map = GenServer.call(pid, :map)
  {:reply,map,state}
end

@impl true
def handle_call({:pid_find_item,pid,item}, _from, state) do
  GenServer.cast(pid, {:find, item, pid})
  {:reply,:ok,state}
end


# Esta funcion permite crear red privadas de peers.
  # Por cada peer del usuario loggeado se añaden a la lista de vecinos(map en el modulo Peer) los peers del usuario seleccionado.
  # Teniendo en cuenta que se puede hacer a si mismo , se ha creado tambien la funcion 'accountsynchronize' que se sincroniza a
  # si mismo formando una red privada.

  @spec sincrowith(list(), list()) :: no_return()
  defp sincrowith(mypids, pids) do
    for pid <- mypids do
      others = Enum.reject(pids, fn other_pid -> other_pid == pid end)
      GenServer.cast(pid, {:add, others})
    end

    for pid <- pids do
      others = Enum.reject(mypids, fn other_pid -> other_pid == pid end)
      GenServer.cast(pid, {:add, others})
    end

  end

end
