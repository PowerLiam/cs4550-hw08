# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Events.Repo.insert!(%Events.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Events.Repo
alias Events.Admin.User
alias Events.Users.Event

john = Repo.insert!(%User{name: "john", email: "john@johndeere.com", password: "1234"})
deere = Repo.insert!(%User{name: "deere", email: "deere@johndeere.com", password: "5678"})

Repo.insert!(%Event{user_id: john.id, name: "John's tractor gathering!", date: "2018-12-08 20:03:00Z", description: "Exciting!"})
Repo.insert!(%Event{user_id: deere.id, name: "Deere's tractor gathering!", date: "2018-12-08 20:03:00Z", description: "Fun!"})
