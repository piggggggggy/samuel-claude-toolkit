---
name: dep-security
description: >-
  Checks external packages for supply-chain risks before installation or
  recommendation, across all ecosystems and programming languages.

  Use this skill whenever a package is being added, a version is being changed,
  or a library is being recommended — even if the user did not explicitly ask
  for a security check. Trigger on any of these signals:

  - npm install / yarn add / pnpm add (JavaScript/TypeScript)
  - pip install / uv add / poetry add (Python)
  - implementation() / compile() in build.gradle, or dependency tag in pom.xml (Kotlin/Java)
  - cargo add / Cargo.toml changes (Rust)
  - go get / go.mod changes (Go)
  - gem install / Gemfile changes (Ruby)
  - composer require (PHP)
  - suggesting a library to solve a problem
  - upgrading a package to a specific version

  Run this check silently before proceeding. Do not wait for the user to ask.
---

# Dependency Security Check

Run this workflow whenever an external package is about to be installed or
recommended. The goal is to catch supply-chain risks — malicious versions,
typosquatting, account hijacks — before they reach the codebase.

## Workflow

### Step 1: Identify ecosystem and look up the package

Find the official registry page for the package. Use the table below.

| Ecosystem     | Registry URL                                          |
|---------------|-------------------------------------------------------|
| npm (JS/TS)   | `https://npmjs.com/package/{name}`                   |
| PyPI (Python) | `https://pypi.org/project/{name}`                    |
| Maven/Gradle  | `https://mvnrepository.com/artifact/{group}/{name}`  |
| crates.io     | `https://crates.io/crates/{name}`                    |
| Go modules    | `https://pkg.go.dev/{module}`                        |
| RubyGems      | `https://rubygems.org/gems/{name}`                   |
| Packagist     | `https://packagist.org/packages/{vendor}/{name}`     |

On the registry page, verify:
- The package name matches exactly (watch for one-letter swaps like `reqeusts`, `lodahs`)
- The target version exists and is marked stable
- The most recent publish timestamp is not anomalously fresh for a mature package
  (hours-old publish on a popular package is a hijack signal)

### Step 2: Check for security signals

Run a behavior-based check using the appropriate tool for the ecosystem.

**npm, PyPI, Ruby → Socket.dev**

```
https://socket.dev/npm/package/{name}
https://socket.dev/pypi/package/{name}
https://socket.dev/ruby/package/{name}
```

Socket analyzes every publish event in real time. Look for:
- 🔴 Malware, backdoor, obfuscated code → do not proceed, report to user
- 🟠 Unexpected install script, network access, or env variable read → warn user
- 🟡 New maintainer or ownership transfer → flag and ask user to confirm

**Go, Rust, PHP → deps.dev**

```
https://deps.dev/go/{module}
https://deps.dev/cargo/{name}
https://deps.dev/packagist/{vendor}/{name}
```

Check for known CVEs and unusual dependency changes in recent versions.

**Maven/Gradle → OSS Index**

```
https://ossindex.sonatype.org/
```

Search by `group:artifact` and review reported vulnerabilities.

**Universal fallback → OSV.dev**

```
https://osv.dev/
```

Covers npm, PyPI, Maven, Go, Rust, Ruby, and more. Use when the
ecosystem-specific tool returns no result or is unavailable.

### Step 3: Recommend exact version pinning

Suggest pinning the exact version for any newly introduced package.
Version ranges silently resolve to newer releases and are a common
attack surface for supply-chain injection.

| Ecosystem | Pinned form                              | Avoid                        |
|-----------|------------------------------------------|------------------------------|
| npm       | `npm install --save-exact pkg@1.2.3`    | `npm install pkg`            |
| pip       | `pkg==1.2.3` in requirements.txt        | `pip install pkg`            |
| Gradle    | `implementation 'group:pkg:1.2.3'`      | `'group:pkg:1.+'`            |
| Maven     | `<version>1.2.3</version>`              | `<version>LATEST</version>`  |
| Cargo     | `pkg = "=1.2.3"`                        | `pkg = "1"`                  |
| Go        | `go get module@v1.2.3`                  | `go get module@latest`       |
| Gem       | `gem 'pkg', '1.2.3'`                    | `gem 'pkg'`                  |

### Step 4: Suggest an audit after install

After installation, recommend running the ecosystem's audit tool.

| Ecosystem     | Command                               |
|---------------|---------------------------------------|
| npm           | `npm audit --audit-level=high`        |
| pip           | `pip-audit`                           |
| Gradle/Maven  | `./gradlew dependencyCheckAnalyze`    |
| Cargo         | `cargo audit`                         |
| Go            | `govulncheck ./...`                   |
| Ruby          | `bundle audit`                        |

Surface any high or critical findings to the user before moving on.

---

## Decision table

| Signal                                              | Action                              |
|-----------------------------------------------------|-------------------------------------|
| 🔴 Malware confirmed on Socket / deps.dev           | Block. Do not install. Report.      |
| Publish timestamp < 24h on a mature package         | Warn. Ask user to confirm.          |
| Package name is a near-misspelling of a popular one | Block. Flag as likely typosquatting.|
| Maintainer or ownership changed recently            | Warn. Let user decide.              |
| Audit returns critical CVE                          | Warn. Show findings. Let user decide.|
| All clear                                           | Proceed normally.                   |

---

## Scope

Skip Steps 1–2 for packages sourced from a private or internal registry
(e.g., `@company/` scope, corporate Artifactory, private PyPI mirror).
Internal packages are assumed pre-vetted. Go straight to version pinning.