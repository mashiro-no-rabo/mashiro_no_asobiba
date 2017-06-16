defmodule Statem do
  @behaviour :gen_statem

  require Logger

  @interval 5000

  def start_link do
    :gen_statem.start_link(__MODULE__, nil, [])
  end

  def callback_mode, do: [:state_functions, :state_enter]

  ## :gen_statem Callbacks
  def init(_) do
    Logger.enable(self())
    Logger.debug("inited")
    {:ok, :preparing, nil}
  end

  ## States

  def preparing(:enter, _, state) do
    Logger.debug("preparing")

    Process.send(self(), :prepared, [])

    {:keep_state, state}
  end
  def preparing(:info, :prepared, state) do
    Logger.debug("prepared")

    schedule_next_track(2000)
    {:next_state, :resting, state}
  end

  def resting(:info, :track, state), do: {:next_state, :tracking, state}
  def resting(_, _, state), do: {:next_state, :resting, state}

  def tracking(:enter, _, state) do
    Logger.debug("tracking")
    Process.send(self(), :tracked, [])
    {:keep_state, state}
  end

  def tracking(:info, :tracked, state) do
    Logger.debug("tracked")
    {:next_state, :updating, state}
  end

  def updating(:enter, _, state) do
    Logger.debug("updating")
    Process.send(self(), :updated, [])
    {:keep_state, state}
  end
  def updating(_, _, state) do
    Logger.debug("updated")
    schedule_next_track()
    {:next_state, :resting, state}
  end

  ## Private Functions
  defp schedule_next_track(time \\ @interval) do
    Process.send_after(self(), :track, time)
  end

end

Statem.start_link()
