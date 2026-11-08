# Plinth example templates

Synthetic examples modeled on the layout of an infrastructure monorepo: independent
root modules, shared modules, structured config/label objects, and per-environment
variable files. These are newly written examples, not copies of client infrastructure.

All resources are built-in `terraform_data` objects. No providers are downloaded;
no cloud accounts, Kubernetes resources, databases, or infrastructure are created.
Resource names describe simulated components, not live services.

## Templates

| Name | Plinth template path | Environments | What it exercises |
| --- | --- | --- | --- |
| Aurora tenant | `eks-tenant/clients/aurora` | test, prod | Shared tenant module, application, simulated database/cache, structured inputs |
| Meadow tenant | `eks-tenant/clients/meadow` | test, prod | Same module with optional database/cache disabled |
| Demo cluster | `eks-cluster/config` | test, prod | config/module split, dependency ordering, input validation |

Use repository `pevrenhq/plinth-examples`, branch `main`, binary **tofu**,
and your configured runner image. No clone token is required for this public repo.
`bootstrap.exs` registers these templates and environments in an existing Plinth
installation. It adds only missing records, preserves edits, and never starts runs.

## Try it in Plinth

1. Open **Templates → Aurora tenant → New run**. Choose `plan`, select test,
   and start it. Inspect clone/init/plan logs and the four simulated additions.
2. Plan test and prod together. Compare replicas (1 versus 3) and namespace names.
3. Try Meadow: it should have two additions rather than four.
4. Change the declared `release` run override to `v2-demo`. Inspect the application
   input in the plan. The prod environment has a different default release to
   demonstrate an environment override.
5. On Demo cluster, override `node_count` to `0`. The plan should fail with a
   readable validation message. Start a fresh run with `2` to recover.
6. To test approval yourself, choose `plan_apply`. Review the plan, then approve
   or reject it. Approving only records synthetic data in Terraform state; it
   does not provision infrastructure. Author approval is enabled for this demo.
7. The whitelisted custom command is `validate`; use `custom` to exercise it.

### State limitation

These templates intentionally use the local backend. Plinth runs in disposable
workspaces, so state is **not retained between runs**. Each new plan starts empty.
Do not use these examples to judge cross-run no-op, drift, or destroy behavior.
A real template needs a persistent remote backend with a separate state key for
its template/environment. The examples contain no real backend addresses or credentials.

### Variable precedence

OpenTofu loads `terraform.tfvars` for common labels. Plinth additionally supplies
`-var-file=test.tfvars` or `-var-file=prod.tfvars`. Plinth variables become `TF_VAR_*`;
explicit tfvars win over those environment variables. Therefore `release` and
`node_count`, the suggested UI overrides, are deliberately absent from tfvars.

## Local verification (no apply)

From a root module directory:

```sh
tofu init -backend=false -input=false
tofu validate
tofu plan -input=false -var-file=test.tfvars
tofu plan -input=false -var-file=prod.tfvars
```

The repository was checked with the same `plinth-runner:local` image as the Mac
installation. No apply was run while preparing these examples.
