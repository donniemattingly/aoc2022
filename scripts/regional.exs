defmodule Regional do
  def text_to_regional() do
    System.argv()
    |> List.first()
    |> String.split("")
    |> Enum.map(&String.downcase/1)
    |> Enum.map(
         fn char -> case char do
                      "" -> ""
                      " " -> "   "
                      char -> ":regional_indicator_#{char}: "
                    end
         end
       )
  end
end


Regional.text_to_regional()
|> IO.puts