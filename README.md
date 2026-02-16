# Kaptain Shared Scripts

Shared script library distributed as a `FROM scratch` OCI image.

Used by [buildon-github-actions](https://github.com/kube-kaptain/buildon-github-actions) at build
time and [kaptain-deploy-scripts](https://github.com/kube-kaptain/kaptain-deploy-scripts) at deploy
time to perform token substitution in Kubernetes manifests and configuration files.


## Features

### Token Name Formatting

Convert token names between 8 naming styles:

| Style         |
|---------------|
| `UPPER_SNAKE` |
| `lower_snake` |
| `UPPER-KEBAB` |
| `lower-kebab` |
| `PascalCase`  |
| `camelCase`   |
| `UPPER.DOT`   |
| `lower.dot`   |


### Token Reference Formatting

Wrap token names with delimiters for 10 substitution styles:

| Style          | Format               |
|----------------|----------------------|
| shell          | `${NAME}`            |
| mustache       | `{{ NAME }}`         |
| helm           | `{{ .Values.NAME }}` |
| erb            | `<%= NAME %>`        |
| github-actions | `${{ NAME }}`        |
| blade          | `{{ $NAME }}`        |
| stringtemplate | `$NAME$`             |
| ognl           | `%{NAME}`            |
| t4             | `<#= NAME #>`        |
| swift          | `\(NAME)`            |


### Token Name Validation

9 validator plugins enforce naming conventions on token directories, plus an ALL
validator that accepts any valid style.


### Token Substitution

Replace token references in files with values from a token directory. Handles multi-line
values, trailing newline control, nested token paths, and rejects symlinks and binary files.


## Distribution

Scripts are packaged in a `FROM scratch` OCI image at `/scripts/`. Consuming images use
multi-stage builds to COPY scripts from this image or unpack them prior to packaging.


## Structure

```
src/scripts/
  lib/                                  # Sourced libraries (not executable)
    token-format.bash                   # Name conversion and reference formatting
    prepare-token-name-and-value.bash   # Token file reading and preparation
  plugins/
    token-name-validators/              # One executable per naming style
    token-substitution-providers/       # One executable per delimiter style
  util/
    substitute-tokens-from-dir          # Orchestrator for multi-token substitution
```


## Testing

Run specific tests:

```bash
bats src/test/token-format.bats
```

Run the full suite (shellcheck + portability + BATS):

```bash
.github/bin/run-tests.bash
```

The latter is what the build process runs every PR and release.
