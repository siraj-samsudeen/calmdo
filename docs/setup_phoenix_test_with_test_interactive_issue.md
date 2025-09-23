### Title: `mix test.interactive` fails to find endpoint configuration

### Body:

**Problem:**

When using `phoenix_test` with `mix_test_interactive`, tests can fail with an error indicating the endpoint is not set, even when it is correctly configured in `config/test.exs`. The standard `mix test` command works correctly, but the interactive runner fails.

The error typically looks like this:
```
** (RuntimeError) module attribute @lib/my_app_web/endpoint.ex not set for socket/2
```

This appears to happen because `mix_test_interactive` has a different compile-time vs. runtime configuration loading behavior compared to the standard test runner, and `phoenix_test` requires the endpoint to be available at compile time.

**Proposed Solution for Documentation:**

The fix is to set the configuration in `test/test_helper.exs`, which ensures it is available before the interactive test environment compiles the dependencies.

It would be very helpful to add a note to the `phoenix_test` documentation about this. Here is a suggestion:

---

> #### Using with `mix_test_interactive`
>
> If you use `mix_test_interactive`, you may find that tests fail because the `:endpoint` configuration is not found, even if it is set in `config/test.exs`.
>
> To resolve this, configure the endpoint directly in your `test/test_helper.exs` file using `Application.put_env/3`. This ensures the configuration is set before the interactive test runner compiles the necessary modules.
>
> ```elixir
> # test/test_helper.exs
> ExUnit.start()
>
> # Add this line
> Application.put_env(:phoenix_test, :endpoint, MyAppWeb.Endpoint)
>
> Ecto.Adapters.SQL.Sandbox.mode(MyApp.Repo, :manual)
> ```

---

This would help users avoid confusion and save them debugging time.
