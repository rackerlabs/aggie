require IEx

defmodule Aggie.Config do

  @moduledoc """
  Aggie.Config pulls env variables for app configuration during runtime.
  """

  @required %{
    tenant_id: "AGGIE_TENANT_ID",
    source_ip: "AGGIE_SOURCE_IP",
    source_port: "AGGIE_SOURCE_PORT",
    source_timeout: "AGGIE_SOURCE_TIMEOUT",
    source_range: "AGGIE_SOURCE_RANGE",
    source_chunks: "AGGIE_SOURCE_CHUNKS",
    destination_ip: "AGGIE_DESTINATION_IP",
    destination_port: "AGGIE_DESTINATION_PORT"
  }

  @doc """
  Goes through aggie environment variables and populates the application config
  """
  def populate_app_config do
    Enum.each @required, fn(tuple) ->
      var     = elem(tuple, 0)
      env_var = elem(tuple, 1)
      expr    = quote do
        Application.put_env(:aggie, unquote(var), System.get_env(unquote(env_var)))
      end

      Code.eval_quoted(expr)
    end

    validate_env_vars_present?()
  end

  defp validate_env_vars_present? do
    Enum.all? @required, fn(tuple) ->
      atom  = elem(tuple, 0)
      value = Application.get_env(:aggie, atom)

      unless value do
        raise "Missing ENV['#{atom}']"
      end
    end
  end

end
