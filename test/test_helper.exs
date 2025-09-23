ExUnit.start()

Application.put_env(:phoenix_test, :endpoint, CalmdoWeb.Endpoint)

Ecto.Adapters.SQL.Sandbox.mode(Calmdo.Repo, :manual)
