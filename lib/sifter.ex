defmodule Aggie.Sifter do

  @doc """
  Sift through the List, collecting those logs that are interesting.
  """
  def sift!([h|t], acc) do
    out = case is_interesting?(h) do
      true -> acc ++ [h]
      _    -> acc
    end

    sift!(t, out)
  end
  def sift!([], acc) do; acc end
  def sift!(nil, _) do; [] end

  defp is_interesting?(elk_log) do
    Aggie.Judge.verdict?(elk_log)
  end

end
