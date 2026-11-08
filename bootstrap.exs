# Run inside an already configured Plinth release with Repo started.
# Adds missing catalog records only. Never launches a run or changes existing records.
import Ecto.Query
alias Plinth.{Catalog, Repo}
alias Plinth.Catalog.{Repository, Template, Environment, Variable}
ensure = fn schema, identity, attrs, create ->
  query = Enum.reduce(identity, schema, fn
    {key, nil}, query -> where(query, [r], is_nil(field(r, ^key)))
    {key, value}, query -> where(query, [r], field(r, ^key) == ^value)
  end)
  case Repo.one(query) do
    nil ->
      case create.(Map.merge(Map.new(identity), attrs)) do
        {:ok, record} -> record
        {:error, changeset} -> Repo.rollback(changeset)
      end
    record -> record
  end
end
{:ok, ids} = Repo.transaction(fn ->
  repo = ensure.(Repository, [owner: "pevrenhq", name: "plinth-examples"], %{default_branch: "main"}, &Catalog.create_repository/1)
  for {name, path, key, default, prod} <- [
    {"Aurora tenant", "eks-tenant/clients/aurora", "release", "v1-demo", "v1-stable"},
    {"Meadow tenant", "eks-tenant/clients/meadow", "release", "v1-demo", "v1-stable"},
    {"Demo cluster", "eks-cluster/config", "node_count", "2", "3"}
  ] do
    template = ensure.(Template, [repository_id: repo.id, name: name], %{
      path: path, binary: :tofu, custom_commands: ["validate -no-color"], author_may_approve: true
    }, &Catalog.create_template/1)
    ensure.(Variable, [template_id: template.id, environment_id: nil, key: key], %{kind: :terraform, value: default, sensitive: false}, &Catalog.create_variable/1)
    for {env_name, position} <- [{"test", 0}, {"prod", 1}] do
      env = ensure.(Environment, [template_id: template.id, name: env_name], %{position: position}, &Catalog.create_environment/1)
      if env_name == "prod" do
        ensure.(Variable, [template_id: template.id, environment_id: env.id, key: key], %{kind: :terraform, value: prod, sensitive: false}, &Catalog.create_variable/1)
      end
    end
    %{name: name, id: template.id, path: path}
  end
end)
IO.inspect(ids, label: "Example templates")
