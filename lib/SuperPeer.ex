defmodule SuperPeer do
  use GenServer

  @moduledoc """
  This module represents a SuperPeer in a P2P arquitecture .
  It manages a registry with all the users and Pids from every Peer.
  It works as a router helping private nets to find items from other private nets.
  The function that help finding items in private nets is builded as a GenServeer.handle_cast for efficiency reasons,
  this process cant never be locked , only for users purposes like getting verfied or getting account pids.

  """

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(map) do
    {:ok, map}
  end


  #Adds a new user to the User pids array


  @spec handle_call({:add_new_user, any()}, pid(), map()) :: :created
  @impl true
  def handle_call({:add_new_user, username}, _from, state) do
    {:reply, :created, Map.put(state, username, [])}
  end


   #Checks if a user exists

  @spec handle_call({:verify, any()}, pid(), map()) :: boolean()
  @impl true
  def handle_call({:verify, username}, _from, state) do
    {:reply, Map.has_key?(state, username), state}
  end


   #Checks if the user have peers


  @spec handle_call({:void, any()}, pid(), map()) :: boolean()
  @impl true
  def handle_call({:void, username}, _from, state) do
    {:reply, length(Map.get(state, username)) == 0, state}
  end


   #Return the pids of a user


  @spec handle_call({:void, any()}, pid(), map()) :: list()
  @impl true
  def handle_call({:pids, username}, _from, state) do
    {:reply, Map.get(state, username), state}
  end


   #Adds a pid to the user

  @spec handle_cast({:save, pid(), any()}, map()) :: no_return()
  @impl true
  def handle_cast({:save, pid, username}, state) do
    users_map = Map.get(state, username)
    updated_map = [pid | users_map]
    {:noreply, Map.put(state, username, updated_map)}
  end

  @impl true

    #First filter the list the pids that had been explored , after this
    #Takes the first pids it has saved and pop it from the list , then it send the list
    #to the poped process to start with the search.


  @spec handle_cast({:spread, any(), pid(), list()}, map()) :: no_return()

  def handle_cast({:spread, what_to_find, where_to_download, drops}, state) do
    pids = List.flatten(Map.values(state))
    filtered_pids = Enum.reject(pids, &Enum.member?(drops, &1))

    if length(filtered_pids) != 0 do
      {pid, popped_list} = List.pop_at(filtered_pids, 0)

      GenServer.cast(
        pid,
        {:try_to_find_via_superpeer, {what_to_find, where_to_download, popped_list}}
      )

      {:noreply, state}
    else
      {:noreply, state}
    end
  end
end
