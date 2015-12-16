defmodule Mix.Tasks.Compile.Apidoc do
  use Mix.Task

  @moduledoc File.read!("README.md")
  @shortdoc "Create documentation for RESTful web APIs"

  @default_apidoc_bin  Path.join(~w"node_modules apidoc bin apidoc")
  @default_input_dir Path.join(~w"web controllers")
  @default_output_dir  Path.join(~w"priv static apidoc")

  def run(_) do

    config = Mix.Project.config[:apidoc]

    unless config do
      Mix.raise "Please specify an apidoc config in your mix.exs"
    end

    apidoc_bin  = config[:apidoc_bin] || Path.join(System.cwd(), @default_apidoc_bin)
    input_dir   = config[:input_dir]  || @default_input_dir
    output_dir  = config[:output_dir] || @default_output_dir

    config_json =
      config
      |> Enum.into(%{})
      |> Map.delete(:apidoc_bin)
      |> Map.delete(:input_dir)
      |> Map.delete(:output_dir)
      |> Poison.encode!

    build_dir = Mix.Project.build_path
    File.mkdir_p! build_dir

    apidoc_json =
      build_dir
      |> Path.join("apidoc.json")
      |> File.open!([:write, :utf8])

    IO.write apidoc_json, config_json
    File.close apidoc_json

    params = ["-i", input_dir, "-o", output_dir, "-c", build_dir]
    run_apidoc(apidoc_bin, params)
  end

  defp run_apidoc(apidoc_bin, params) do
    if File.exists? apidoc_bin do
      case System.cmd(apidoc_bin, params) do
        {_, 0} ->
          Mix.Shell.IO.info "Generated apidoc"
        error ->
          Mix.raise "apidoc responded with an error"
      end
    else
      Mix.raise "Could not find apidoc executable '#{apidoc_bin}'. " <>
                "Run 'npm install' or set the 'apidoc_bin' config parameter " <>
                "in your 'mix.exs' to a different apidoc executable."
    end
  end
end
