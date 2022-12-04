defmodule AdventOfCode do
  use Application

  @impl true
  def start(_type, _args) do
    # Although we don't use the supervisor name below directly,
    # it can be useful when debugging or introspecting the system.
    AutoReload.watch()
  end

  # Define a function for downloading the input for a day
  # Import the HTTPoison and System modules
  import HTTPoison, only: [get: 3]
  import System, only: [get_env: 1]

  use Memoize
  # Define a function for downloading the input for a day
  defmemo download_input(year, day) do
    # Set the URL for the Advent of Code input page
    url = "https://adventofcode.com/#{year}/day/#{day}/input"

    # Read the value of the "AOC_SESSION" environment variable
    session = System.get_env("AOC_SESSION")

    # Set the request headers
    headers = [{"Cookie", "session=#{session}"}]

    # Make an HTTP GET request to the URL
    {:ok, response} = HTTPoison.get(url, [], hackney: [cookie: ["session=#{session}"]])

    # Check the response status code
    if response.status_code == 200 do
      # The request was successful, so return the response body
      # (which contains the input for the day)
      response.body
    else
      # The request failed, so return an error message
      IO.inspect(response)
    end
  end
end
