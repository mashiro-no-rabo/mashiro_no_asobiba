defmodule SimpleChild do
  @moduledoc """
  iex(1)> {:ok, sup} = NewSup.start_link(nil)
  {:ok, #PID<0.267.0>}
  iex(2)> Supervisor.start_child(NewSup, 123)
  {:error,
   {:EXIT,
    {:badarg,
     [{:erlang, :apply, [SimpleChild, :start_link, 123], []},
      {:supervisor, :do_start_child_i, 3, [file: 'supervisor.erl', line: 381]},
      {:supervisor, :handle_call, 3, [file: 'supervisor.erl', line: 406]},
      {:gen_server, :try_handle_call, 4, [file: 'gen_server.erl', line: 636]},
      {:gen_server, :handle_msg, 6, [file: 'gen_server.erl', line: 665]},
      {:proc_lib, :init_p_do_apply, 3, [file: 'proc_lib.erl', line: 247]}]}}}
  iex(3)> NewSup.child_spec
  ** (UndefinedFunctionError) function NewSup.child_spec/0 is undefined or private. Did you mean one of:

        * child_spec/1

      (mashiro) NewSup.child_spec()
  iex(3)> Supervisor.start_child(NewSup, id: 123)
  {:ok, #PID<0.273.0>}
  iex(4)> :observer.start
  :ok
  """
  use GenServer

  def start_link(id) do
    GenServer.start_link(__MODULE__, id, [])
  end

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      restart: :transient,
      type: :worker,
    }
  end

  def init(id) do
    {:ok, id}
  end
end

defmodule NewSup do
  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_opts) do
    child = [SimpleChild]
    Supervisor.init(child, strategy: :simple_one_for_one)
  end
end
