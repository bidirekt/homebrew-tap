#!/usr/bin/env python3
"""Renders Formula/*.rb from templates/ with the latest release of each repository.

    scripts/update.py                         latest GitHub releases (CI)
    scripts/update.py FORMULA VERSION DIR     local archives in DIR (testing)

A release without checksums.txt (one published before binaries existed) is
skipped, and the formula keeps its current version.
"""

import json
import os
import pathlib
import sys
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent.parent
PLATFORMS = ["darwin_arm64", "darwin_amd64", "linux_arm64", "linux_amd64"]
FORMULAS = {
    "bidirekt": {"repo": "cli", "archive": "bidirekt"},
    "bidirekt-broker": {"repo": "broker", "archive": "bidirekt-broker"},
}


def fetch(url):
    request = urllib.request.Request(url, headers={"Accept": "application/vnd.github+json"})
    token = os.environ.get("GITHUB_TOKEN")
    if token and url.startswith("https://api.github.com/"):
        request.add_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(request) as response:
        return response.read().decode()


def checksums_by_archive(text):
    return {name: digest for digest, name in (line.split() for line in text.splitlines() if line.strip())}


def render(formula, version, base_url, checksums):
    archive = FORMULAS[formula]["archive"]
    content = (ROOT / "templates" / f"{formula}.rb.tmpl").read_text()
    content = content.replace("{{VERSION}}", version).replace("{{BASE_URL}}", base_url)
    for platform in PLATFORMS:
        name = f"{archive}_{version}_{platform}.tar.gz"
        if name not in checksums:
            raise SystemExit(f"{formula} {version}: checksums.txt has no {name}")
        content = content.replace(f"{{{{SHA256_{platform.upper()}}}}}", checksums[name])
    target = ROOT / "Formula" / f"{formula}.rb"
    changed = not target.exists() or target.read_text() != content
    target.write_text(content)
    return changed


def update_from_github():
    for formula, info in FORMULAS.items():
        release = json.loads(fetch(f"https://api.github.com/repos/bidirekt/{info['repo']}/releases/latest"))
        tag = release["tag_name"]
        assets = {asset["name"]: asset["browser_download_url"] for asset in release["assets"]}
        if "checksums.txt" not in assets:
            print(f"{formula}: {tag} has no binaries, skipped")
            continue
        base_url = f"https://github.com/bidirekt/{info['repo']}/releases/download/{tag}"
        changed = render(formula, tag.removeprefix("v"), base_url, checksums_by_archive(fetch(assets["checksums.txt"])))
        print(f"{formula}: {tag} {'updated' if changed else 'unchanged'}")


def update_from_directory(formula, version, directory):
    path = pathlib.Path(directory).resolve()
    checksums = checksums_by_archive((path / "checksums.txt").read_text())
    render(formula, version, path.as_uri(), checksums)
    print(f"{formula}: {version} from {path}")


if __name__ == "__main__":
    if len(sys.argv) == 4:
        update_from_directory(*sys.argv[1:])
    else:
        update_from_github()
