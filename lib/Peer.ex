defmodule Peer do
  use GenServer

  @moduledoc """
  This module represents a Peer in a P2P arquitecture .
  Peer state is made of 2 lists, 1 list called usually map , it is made from all the neighbors the peer has, the other list
  often called volume is used for storing data that later could be finded by other peers.
  It has different functions focused in connecting with other peers, find
  items in his internal storage and save items in his internal storage
  """
  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end


  #Adds the `item` parameter to the `volume` list in the current state.

  @spec handle_cast({atom, any()}, {map, [any()]}) :: {:noreply, {list(), [any()]}}
  @impl true
  def handle_cast({:save, item}, {map, volume}) do
    {:noreply, {map, volume ++ [item]}}
  end


  #This function merges the `pids` list with the internal `map` state,
  #removing any duplicate entries.

  @spec handle_cast({atom, list()}, {map, [any()]}) :: {:noreply, {list(), [any()]}}
  @impl true
  def handle_cast({:add, pids}, {map, volume}) do
    new_map = merge_unique(map, pids)
    {:noreply, {new_map, volume}}
  end


  #Displays a message indicating that the requested item was not found, and prompts the user to try connecting via SuperPeer.
  #If the user confirms, the `what_to_download`, `where_to_download`, and `drops` parameters are sent to the `SuperPeer` process via
  #a cast.


  @spec handle_cast({:not_found, pid(), list(), any()}, {list(), [any()]}) ::
          {:noreply, {list(), [any()]}}
  @impl true
  def handle_cast({:not_found, where_to_download, drops, what_to_download}, state) do
    GenServer.cast(SuperPeer, {:spread, what_to_download, where_to_download, drops})
    {:noreply, state}
  end


  #Displays that the item has not been found by the SuperPeer , it is needed cause the other not_found function would loop another time
  #if the user wants to use the superpeer

  @spec handle_cast(:not_found_via_superpeer, {list(), list()}) ::
          {:noreply, {list(), list()}}
  @impl true
  def handle_cast(:not_found_via_superpeer, state) do
    {:noreply, state}
  end


  #This is how peers find object when superpeer calls them , it consist in a recursion between peers, the SuperPeere has every Peer PID
  #so u can loop by everyone one by one , if one doest have the item it will send a message to the next peer to see if he has the item,
  #every time the pids array is popped with the PID that didnt find the item

  @spec handle_cast(:try_to_find_via_superpeer, {any(), pid(), list()}) :: {:noreply, list()}
  @impl true
  def handle_cast(
        {:try_to_find_via_superpeer, {what_to_find, where_to_download, pids}},
        {map, volume}
      ) do
    if Enum.member?(volume, what_to_find) do

      GenServer.cast(where_to_download, {:save, what_to_find})
      {:noreply, {map, volume}}
    else
      if length(pids) == 0 do
        GenServer.cast(where_to_download, :not_found_via_superpeer)
        {:noreply, {map, volume}}
      else
        {pid, popped_list} = List.pop_at(pids, 0)

        GenServer.cast(
          pid,
          {:try_to_find_via_superpeer, {what_to_find, where_to_download, popped_list}}
        )

        {:noreply, {map, volume}}
      end
    end
  end


  #This function is different to the SuperPeer one because it has to create a search-tree between peers that are connected or
  #transitively connected. Then if the item is not found in the peer called it will insert in the list of explored nodes (drop array)
  #then the next one will not explore that node but will include the ones that were not explored (acc_map).This makes that if a Peer
  #is not connect with other Peer but have a Peer in common it will be possible for them to communicate.

  @spec handle_cast(:try_to_find, {any(), pid(), list()}) :: {:noreply, list()}
  @impl true
  def handle_cast(
        {:try_to_find, {what_to_find, where_to_download, acc_map, drops}},
        {map, volume}
      ) do
    if Enum.member?(volume, what_to_find) do

      GenServer.cast(where_to_download, {:save, what_to_find})
      {:noreply, {map, volume}}
    else
      merged_map = merge_unique(map, acc_map)
      new_map = remove_duplicates(merged_map, drops)
      speak(new_map, {what_to_find, where_to_download, drops})
      {:noreply, {map, volume}}
    end
  end


  #This function starts the find process , if the object is not found it will start the search tree thanks to the speak function
  #else will add the item

  @spec handle_cast(:find, {any(), pid(), list()}) :: {:noreply, list()}
  @impl true
  def handle_cast({:find, what_to_find, where_to_download}, {map, volume}) do
    if Enum.member?(volume, what_to_find) do

      {:noreply, {map, volume ++ [what_to_find]}}
    else
      speak(map, {what_to_find, where_to_download, [where_to_download]})
      {:noreply, {map, volume}}
    end
  end


  #Returns to the internal storage of the peer

  @spec handle_call(:volume, pid(), {list(), list()}) :: {:reply, list(), {list(), list()}}
  @impl true
  def handle_call(:volume, _from, {map, volume}) do
    {:reply, volume, {map, volume}}
  end


  #Returns the internal map of neighboors

  @spec handle_call(:map, pid(), {list(), list()}) :: {:reply, [pid], {list(), list()}}
  @impl true
  def handle_call(:map, _from, {map, volume}) do
    {:reply, map, {map, volume}}
  end







  # If the map given , the frontier of the search is empty then it will stop and will print that the itam is not in the internal net
  # else it will take a random number that represent a random pid from the list and will send him the pids that had been explored
  # the ones that hadnt and it will add himself to the explored.

  @spec speak(list(), {any(), pid(), list()}) :: no_return()

  defp speak(map, {what_to_find, where_to_download, drops}) do
    if length(map) != 0 do
      nrand = Enum.random(0..(length(map) - 1))
      pid = Enum.at(map, nrand)

      GenServer.cast(
        pid,
        {:try_to_find,
         {what_to_find, where_to_download, List.delete_at(map, nrand), [pid | drops]}}
      )
    else
      GenServer.cast(where_to_download, {:not_found, where_to_download, drops, what_to_find})
    end
  end

  # Remove duplicates from a 2 list , used to remove the explored peers turing the search-tree algorithm
  @spec speak(list(), list()) :: list()
  def remove_duplicates(map, drops) do
    Enum.filter(map, fn x -> !Enum.member?(drops, x) end)
  end

  # Takes the uniques values of 2 arrays and merge them  into 1  new
  @spec speak(list(), list()) :: list()
  defp merge_unique(arr1, arr2) do
    case arr1 do
      [] ->
        arr2

      [head | tail] ->
        case Enum.member?(arr2, head) do
          true -> merge_unique(tail, arr2)
          false -> [head | merge_unique(tail, arr2)]
        end
    end
  end
end
