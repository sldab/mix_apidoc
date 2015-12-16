# Mix Apidoc Task

A mix task that triggers [apidoc](http://apidocjs.com "apidoc") to create
documentation for RESTful web APIs.

## Usage

  1. Configure apidoc in your `mix.exs`:

  ```elixir
    def project do
      [app: :your_app,
       apidoc: apidoc(Mix.env)
       # Add `:apidoc` to your compilers if you want it to run upon `mix compile`
       compilers: [:apidoc] ++ Mix.compilers,
       deps: deps
       ...]
    end

    # It makes sense to have an apidoc config per mix environment as URLs will
    # most likely differ between your environments.
    defp apidoc(:dev) do
      # Omit `sampleUrl` if you don't want to have sample requests in the
      # documentation.
      [url: "http://localhost:4000/api",
       sampleUrl: "http://localhost:4000/api"] ++ apidoc
    end

    defp apidoc do
      # See http://apidocjs.com/#configuration-settings for a full list of
      # parameters. Note: Use Elixir terms as values. They will be translated
      # to JSON and stored in `_build/dev/apidoc.json`.
      [name: "Your API",
       version: "1.0.0",
       description: "Your API description",
       title: "Your API Title"]
    end

    def deps do
      # Add it to your dependencies
      [{:mix_apidoc, "~> 0.1"},
       ...]
    end
  ```

  2. Create a file called `package.json` in your project directory.
     If you're in a Phoenix project, Phoenix creates it for you.

  3. Add apidoc as a dependency to your `package.json`

```json
{
  "repository": {
  },
  "dependencies": {
    "apidoc": ">= 0.14.0"
  }
}
```

4. Install apidoc using the node package manager:

    `$ npm install`

## Task-specific configuration options

By default, the apidoc task will look for apidoc comments in `web/controllers`
and generate the documentation into `priv/static/apidoc`. You may override those
paths in the config:

```elixir
input_dir: "web",
output_dir: "priv/static/html"
```

The mix task also assumes that your apidoc binary is
`node_modules/apidoc/bin/apidoc`. This is where it installs in step 4. If you
prefer to use your system-wide apidoc installation instead, change the
`apidoc_bin` config parameter:

```elixir
apidoc_bin: "apidoc"
```

Apart from those mix task specific parameters, you can set all apidoc parameters
as described on the [apidoc](http://apidocjs.com "apidoc/#configuration-settings")
webpage.

## Running the task

If you added the task to the list of compilers, just run

  `$ mix compile`

If not, or if you want to run it separately, run it with

`$ mix compile.apidoc`
