defmodule MixApidoc.Mixfile do
  use Mix.Project

  def project do
    [app: :mix_apidoc,
     version: "0.5.1",
     description: "A mix task that triggers apidoc to create documentation " <>
                  "for RESTful web APIs from inline code annotations.",
     package: package(),
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     docs: [extras: ["README.md"]],
     deps: deps()]
  end

  def package do
    [maintainers: ["Sławomir Dąbek", "Samar Dhwoj Acharya"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/sldab/mix_apidoc"}]
  end

  def application do
    [applications: []]
  end

  def deps do
    [
      {:poison, "~> 1.5 or ~> 2.0 or ~> 3.0"},
      {:earmark, "~> 0.1 or ~> 1.0", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev}
    ]
  end
end
