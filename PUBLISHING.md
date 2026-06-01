# Automated Publishing to pub.dev

`d3_ui` publishes to [pub.dev](https://pub.dev) automatically via GitHub Actions
using pub.dev's **OIDC-based automated publishing** — no API tokens or long-lived
secrets are stored.

## How it works

```
PR merged to master
        │
        ▼
┌─────────────────────────────┐
│ release-on-merge.yml        │
│  • format / analyze / test  │  ← quality gate
│  • read version: from       │
│    pubspec.yaml             │
│  • CHANGELOG entry check    │
│  • if no tag v<version>:    │
│    create & push the tag    │
└──────────────┬──────────────┘
               │ tag push (via RELEASE_TOKEN)
               ▼
┌─────────────────────────────┐
│ publish.yml                 │
│  • OIDC auth to pub.dev      │
│  • dart pub publish          │
└─────────────────────────────┘
```

The version is the single source of truth: **publishing only happens when you
raise `version:` in `pubspec.yaml`.** Merges that don't change the version do
nothing (the tag already exists).

## Release flow (day-to-day)

1. In your PR, bump `version:` in `pubspec.yaml` (e.g. `0.1.0` → `0.2.0`).
2. Add a matching section to `CHANGELOG.md` (e.g. `## 0.2.0`).
3. Merge the PR into `master`.
4. CI runs the quality gate, tags `v0.2.0`, and the tag triggers publishing.
5. The new version appears on pub.dev within a minute or two.

If the quality gate fails, no tag is created and nothing is published.

---

## One-time setup

These steps must be completed once before the automation works.

### 1. Publish the first version manually

pub.dev automated publishing can only publish to a package that **already
exists**. Publish `0.1.0` once from your machine to claim the package name:

```bash
cd d3_ui
flutter pub publish
```

Follow the browser prompt to authenticate with your Google account.

### 2. Enable automated publishing on pub.dev

1. Go to `https://pub.dev/packages/d3_ui/admin` (you must be an uploader).
2. Under **Automated publishing**, click **Enable publishing from GitHub Actions**.
3. Set:
   - **Repository:** `cruzleedan/d3_ui`
   - **Tag pattern:** `v{{version}}`
4. Save.

This tells pub.dev to trust OIDC tokens from GitHub Actions runs in that repo
that were triggered by a tag matching `v{{version}}`.

### 3. Create the RELEASE_TOKEN secret

GitHub does **not** trigger workflows from tags pushed with the default
`GITHUB_TOKEN` (an anti-recursion safeguard). So the auto-tag job pushes the tag
using a Personal Access Token.

1. Create a **fine-grained PAT**:
   `https://github.com/settings/tokens?type=beta`
   - **Repository access:** Only select repositories → `cruzleedan/d3_ui`
   - **Permissions:** Repository permissions → **Contents: Read and write**
   - Expiry: your preference (set a calendar reminder to rotate)
2. Copy the token.
3. In the repo, go to **Settings → Secrets and variables → Actions → New repository secret**:
   - **Name:** `RELEASE_TOKEN`
   - **Value:** the PAT

> Alternative without a PAT: have the publish workflow trigger on tags you push
> manually (`git tag v0.2.0 && git push origin v0.2.0`). In that case you can
> delete `release-on-merge.yml` and rely on `publish.yml` alone.

### 4. Confirm branch name

These workflows assume the default branch is `master`. If you rename it to
`main`, update the `branches:` field in `release-on-merge.yml`.

---

## Files

| File | Purpose |
|------|---------|
| `.github/workflows/release-on-merge.yml` | Quality gate + auto-tag on merge to master |
| `.github/workflows/publish.yml` | OIDC publish to pub.dev on `v*` tag |

## Troubleshooting

| Symptom | Cause / fix |
|---------|-------------|
| Tag created but nothing publishes | `RELEASE_TOKEN` missing or lacks Contents:write — tags from `GITHUB_TOKEN` don't trigger `publish.yml`. |
| `publish.yml` fails with auth error | Automated publishing not enabled on pub.dev admin page, or repo/tag pattern mismatch. |
| "version already exists" | You merged without bumping `version:`. Raise it in `pubspec.yaml`. |
| Format check fails | Run `dart format .` locally and commit. |
| First publish rejected | The package must be published manually once before automation (step 1). |
