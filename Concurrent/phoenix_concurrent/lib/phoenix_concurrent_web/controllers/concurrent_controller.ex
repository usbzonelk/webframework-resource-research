defmodule PhoenixConcurrentWeb.ConcurrentController do
  use PhoenixConcurrentWeb, :controller

  def readFile(conn, _params) do
    file_to_read = "textFile.txt"

    task = Task.async(fn -> read_file(file_to_read) end)
    IO.inspect(task.pid, label: "New Task PID")

    result = Task.await(task, 5000)

    case result do
      {:ok, content} ->
        json(conn, %{success: true, message: content})

      {:error, reason} ->
        json(conn, %{success: false, message: "Error reading file: #{reason}"})
    end
  end

  defp read_file(file) do
    try do
      file_path = Path.join([:code.priv_dir(:phoenix_concurrent), "static", file])
      file_content = File.read!(file_path)

      :timer.sleep(2000)

      {:ok, file_content}
    rescue
      e ->
        {:error, e.message}
    end
  end
end
