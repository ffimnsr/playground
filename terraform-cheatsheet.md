Initialize terraform:

```
terraform init
```

This will install the necessary plugins for the provider.

Create a plan:

```
terraform plan
```

Save the plan:

```
terraform plan -out <PLAN_NAME>
```

Saving the plan ensures that the plan is not changed between the time it is created and the time it is applied.

Show the state:

```
terraform show
```

Destroy the infrastructure:

```
terraform destroy
```

Re-create the instance using tainted resources:

```
terraform taint google_compute_instance.vm_instance
terraform apply
```

The `taint` command marks a resource for recreation. The `apply` command will recreate the resource.

Reconcile state:

```
terraform refresh
```

Import docker container state data to terraform:

```
terraform import docker_container.web $(docker inspect -f {{.ID}} <CONTAINER_NAME>)
```

Copy terraform state into a file:

```
terraform show -no-color > main.tf
```
