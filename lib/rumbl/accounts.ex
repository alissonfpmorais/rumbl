defmodule Rumbl.Accounts do
  @moduledoc """
  The accounts context
  """

  alias Rumbl.Repo
  alias Rumbl.Accounts.User

  def list_users do
    Repo.all(User)
  end

  def get_user(id) do
    User
    |> Repo.get(id)
  end

  def get_user!(id) do
    User
    |> Repo.get!(id)
  end

  def get_user_by(params) do
    User
    |> Repo.get_by(params)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def change_registration(%User{} = user, attrs) do
    User.registration_changeset(user, attrs)
  end

  def register_user(attrs) do
    %User{}
    |> change_registration(attrs)
    |> Repo.insert()
  end

  def authenticate_by_username_and_password(username, given_pass) do
    user = get_user_by(username: username)

    cond do
      user && Pbkdf2.verify_pass(given_pass, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end
end
