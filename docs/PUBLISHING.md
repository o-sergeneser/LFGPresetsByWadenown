# GitHub and CurseForge publishing

No remote repository, upload, token or ZIP has been created by the agent. Use your personal GitHub account, not your work GitLab account. Browser login and Git command-line authentication are separate.

## 1. GitHub repository

1. Open https://github.com/new and verify that Owner is your personal account.
2. Name the repository `LFGPresetsByWadenown`. Choose Public if you want publicly visible source.
3. Leave generated README, .gitignore and license options empty. The first two already exist locally; choose the source-code license separately. The bundled font retains its OFL license.
4. Create the repository and copy its HTTPS URL. Do not create a release/tag yet.
5. Initialize Git only in this addon folder, authenticate to that GitHub account and push the source to `main`. Do not upload node_modules, caches, research snapshots or WTF data. `.gitignore` excludes development artifacts when using Git; dragging the whole directory into GitHub's website bypasses these rules.
6. Check that the Validate workflow passes in GitHub Actions.

## 2. CurseForge project

1. Create a World of Warcraft addon project named LFG Presets By Wadenown in the CurseForge author dashboard.
2. Add the agreed English description, icon/screenshots, categories and chosen source-code license. Use `docs/branding/CurseForge-Icon.png` for the detailed purple project icon. Add the GitHub repository as its source link.
3. Complete the current onboarding/moderation requirements and copy the numeric Project ID from the dashboard/About Project area.
4. Generate a CurseForge API token at https://www.curseforge.com/account/api-tokens . Keep it out of source files, screenshots, chat and commits.

## 3. Connect GitHub Actions

1. Open the GitHub repository's Settings > Secrets and variables > Actions.
2. Create a repository secret named `CF_API_KEY` containing the CurseForge token.
3. Create a repository variable named `CF_PROJECT_ID` containing the numeric project ID.
4. GitHub supplies `GITHUB_TOKEN` automatically. The prepared release workflow grants contents: write for release assets.
5. Use this Actions approach on its own. Do not also enable CurseForge's packaging webhook for the same tags, which can cause duplicate uploads.

## 4. Publish updates

1. Test the addon in game and run the README validation commands.
2. Update `## Version` in the TOC and add changes to CHANGELOG.md.
3. Commit and push to GitHub.
4. Push an annotated tag matching the TOC version. The current TOC version is 1.0.0:

```text
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0
```

5. The Package and release workflow validates, packages with BigWigs Packager and uploads to GitHub Releases and CurseForge. Missing project ID/token or a tag/TOC version mismatch stops the job before upload.
6. Check Actions, the GitHub release ZIP asset and the CurseForge file status. Uploading is separate from CurseForge moderation/approval.
7. Subsequent updates use a new TOC version and matching tag, for example v1.0.1. Normal commits run validation without publishing a release.

GitHub's automatically generated Source code (zip) is a source snapshot. Users should install the packager's ZIP asset. `.pkgmeta` creates the correct top-level addon directory and excludes tests, docs, CI configuration and the PNG preview while retaining runtime code, TOC, TGA icon, font and font license.

## References

- [Create a CurseForge project](https://support.curseforge.com/support/solutions/articles/9000197241-creating-and-submitting-a-project)
- [CurseForge automatic packaging](https://support.curseforge.com/support/solutions/articles/9000197281)
- [BigWigs Actions workflow](https://github.com/BigWigsMods/packager/wiki/GitHub-Actions-workflow)
- [Package metadata](https://github.com/BigWigsMods/packager/wiki/Preparing-the-PackageMeta-File)
