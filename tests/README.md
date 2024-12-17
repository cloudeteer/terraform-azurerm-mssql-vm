# Terraform Tests

This directory contains a set of Terraform tests categorized into `local`, `remote`, and `examples` to streamline the development and CI/CD processes.

## `./examples`

This directory contains tests for all Terraform examples in `../examples`. The
following command modifies the `source` path in each example, initializes the test
directory, runs the tests.

```shell
# Run from the root of the repository
make test-examples
```

## `./local`

This directory is for tests intended to run locally during development. Use the
following commands to initialize and run the tests:

```shell
# Run from the root of the repository
make test-local
```

## `./remote`

This directory contains tests designed to be executed by CI/CD pipelines. Use the
following commands to initialize and run the tests:

```shell
# Run from the root of the repository
make test-remote
```
