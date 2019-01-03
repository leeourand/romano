defmodule Mix.Tasks.Draw do
  use Mix.Task

  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean],
                               aliases: [h: :help])

    case parse do
      {[help: true], _, _} ->
        :help

      {_, [scene_name], _} ->
        scene_name

      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage: mix draw <scene name>
    """
    System.halt(0)
  end

  def process(scene) do
    case scene do
      "snowman" ->
        Romano.draw_snowman_scene()
      "spheres" ->
        Romano.draw_spheres_scene()
      _ ->
        Romano.draw_circle_scene()
    end
  end
end
