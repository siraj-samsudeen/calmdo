# Manual User Onboarding (pre-email-provider)

## Initial Registration

Use this process to insert accounts, confirm them, and generate login links while Postmark is pending approval.

1. Make sure the production machine is running. If `fly machines list` reports a `stopped` state, start it first:
   ```bash
   fly machines list
   fly machines start <machine-id>
   ```
2. Open a remote IEx shell on that machine:
   ```bash
   fly ssh console --select -C "/app/bin/calmdo remote"
   ```
   When prompted, pick the running machine. (Alternatively, run `fly ssh console --select` to open a shell, then execute `/app/bin/calmdo remote` inside it.)
3. At the IEx prompt, run a script like the one below. Update the usernames/domain as needed—the example covers the four bisquared.com teammates you mentioned.
   ```elixir
   alias Calmdo.Accounts
   alias Calmdo.Accounts.{User, UserToken}
   alias Calmdo.Repo

   domain = "bisquared.com"
   usernames = ~w(siraj adhil zaseem sharbudeen)

   for username <- usernames do
     email = "#{username}@#{domain}"

     user =
       Accounts.get_user_by_email(email) ||
         case Accounts.register_user(%{email: email}) do
           {:ok, user} -> user
           {:error, changeset} -> raise "Failed to register #{email}: #{inspect(changeset.errors)}"
         end

     user =
       if is_nil(user.confirmed_at) do
         user
         |> User.confirm_changeset()
         |> Repo.update!()
       else
         user
       end

     {token, token_struct} = UserToken.build_email_token(user, "login")
     Repo.insert!(token_struct)

     IO.puts("Magic link for #{email}: https://calmdo.fly.dev/users/log-in/#{token}")
   end
   ```
4. Copy each printed URL and share it with the teammate. They can log in immediately without waiting for an email.

Once Postmark approves your sender/domain, you can remove this manual workflow and rely on the automated confirmation emails.

## Set up password

```elixir
alias Calmdo.Accounts
domain = "bisquared.com"
usernames = ~w(siraj adhil zaseem sharbudeen)

for username <- usernames do
  email = "#{username}@#{domain}"

  {:ok, {user, _expired}} =
    email
    |> Accounts.get_user_by_email()
    |> Accounts.update_user_password(%{
      password: "12-chars",
      password_confirmation: "12-chars"
    })
end
```