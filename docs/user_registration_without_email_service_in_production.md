# Manual User Onboarding (pre-email-provider)

Use this process to confirm accounts and generate login links while the email provider is pending approval.

1. Ask the teammate to visit `https://calmdo.gigalixirapp.com/users/register` and submit their email. The UI may show a warning, but the user row is inserted.
2. In your shell, start a remote console on Gigalixir:
   ```bash
   gigalixir ps:remote_console -a calmdo
   ```
3. For each teammate’s email, run the following in the console:
   ```elixir
   alias Calmdo.{Accounts, Repo}

   email = "teammate@example.com"

   # confirm the user so they can log in
   user =
     Accounts.get_user_by_email(email)
     |> Calmdo.Accounts.User.confirm_changeset()
     |> Repo.update!()

   # create and persist a magic-link token
   {token, token_struct} = Accounts.UserToken.build_email_token(user, "login")
   Repo.insert!(token_struct)

   # share this link with the teammate
   IO.puts("Magic link for #{email}: https://calmdo.gigalixirapp.com/users/log-in/#{token}")
   ```
4. Copy the printed URL and send it to the teammate—they can log in immediately without an email confirmation.

Once the email provider (Postmark) approves your sender/domain, you can remove this manual step and rely on the automated confirmation emails.
