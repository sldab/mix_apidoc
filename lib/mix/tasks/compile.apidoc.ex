defmodule Mix.Tasks.Compile.Apidoc do
  use Mix.Task

  @moduledoc File.read!("README.md")
  @shortdoc "Create documentation for RESTful web APIs"

  @default_node_bin "node"
  @default_output_dir Path.join(~w"priv static apidoc")

  @phx_version_gt_13_regex ~r/(1\.[3-]\.\d+|[2-]\.\d+\.\d+)/

  @doc false
  def run(_) do

    config = Mix.Project.config[:apidoc]

    unless config do
      Mix.raise "Please specify an apidoc config in your mix.exs"
    end

    cond do
      config == [] ->
        Mix.Shell.IO.info "Omitting apidoc generation for #{Mix.env} environment."
      is_list(config) && not Keyword.keyword?(config) ->
        for c <- config, do: run_for_config(c)
      true ->
        run_for_config(config)
    end
  end

  defp run_for_config(config) do
    unless Keyword.keyword?(config) do
      Mix.raise "The apidoc config in your mix.exs must be a keyword list " <>
                "or list of keyword lists."
    end

    node_bin    = config[:node_bin] || @default_node_bin
    apidoc_bin  = get_apidoc_bin(config)
    input_dir   = get_input_dir(config)
    output_dir  = config[:output_dir] || @default_output_dir
    extra_args  = config[:extra_args] || []

    config_json =
      config
      |> Enum.into(%{})
      |> Map.drop(~w(node_bin apidoc_bin input_dir output_dir extra_args)a)
      |> Poison.encode!

    build_dir = Mix.Project.build_path
    File.mkdir_p! build_dir

    apidoc_json =
      build_dir
      |> Path.join("apidoc.json")
      |> File.open!([:write, :utf8])

    IO.write apidoc_json, config_json
    File.close apidoc_json

    params = ["-i", input_dir, "-o", output_dir, "-c", build_dir] ++ extra_args
    api_title = config[:title] || config[:name] || "api"
    run_apidoc(node_bin, apidoc_bin, params, api_title)
  end

  defp run_apidoc(node_bin, apidoc_bin, params, api_title) do
    if File.exists?(apidoc_bin) do
      exec_apidoc(node_bin, apidoc_bin, params, api_title)
    else
      apidoc_global = System.find_executable(apidoc_bin)
      if apidoc_global |> is_nil do
        Mix.raise "Could not find apidoc executable '#{apidoc_bin}'. " <>
                  "Run 'npm install' or set the 'apidoc_bin' config parameter " <>
                  "in your 'mix.exs' to a different apidoc executable."
      else
        exec_apidoc(node_bin, apidoc_global, params, api_title)
      end
    end
  end

  defp exec_apidoc(node_bin, apidoc_bin, params, api_title) do
    node_bin
    |> System.cmd([apidoc_bin | params])
    |> _handle_result(api_title)
  end

  defp _handle_result({_, 0}, api_title) do
    Mix.Shell.IO.info "Generated apidoc for #{api_title}."
  end

  defp _handle_result(_error, api_title) do
    Mix.raise "apidoc responded with an error for #{api_title}."
  end

  defp get_apidoc_bin(config) do
    phx_ver_req = Mix.Project.config[:deps][:phoenix]
    cond do
      config[:apidoc_bin] != nil ->
        config[:apidoc_bin]
      phx_ver_req != nil && Regex.run(@phx_version_gt_13_regex, phx_ver_req) ->
        Path.join([System.cwd()] ++ ~w"assets node_modules apidoc bin apidoc")
      true ->
        Path.join([System.cwd()] ++ ~w"node_modules apidoc bin apidoc")
    end
  end

  defp get_input_dir(config) do
    phx_ver_req = Mix.Project.config[:deps][:phoenix]
    app_name = Mix.Project.config[:app] |> Atom.to_string
    cond do
      config[:input_dir] != nil ->
        config[:input_dir]
      phx_ver_req != nil && Regex.run(@phx_version_gt_13_regex, phx_ver_req) ->
        Path.join(~w"lib #{app_name}_web controllers")
      true ->
        Path.join(~w"web controllers")
    end
  end
end
