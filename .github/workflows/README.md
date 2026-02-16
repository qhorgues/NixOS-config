# CI/CD for automatic flake.lock updates

This repository contains CI/CD configurations for GitHub and GitLab that automatically update your NixOS configuration's `flake.lock` with a **24-hour delayed commit**.

## 🎯 How it works

1. **Daily update**: CI runs automatically every day
2. **PR/MR creation**: A Pull Request (GitHub) or Merge Request (GitLab) is created with the changes
3. **24h review period**: You have 24 hours to review the changes
4. **Automatic merge**: After 24h, if the PR/MR is still open, it's automatically merged to master

## 📋 GitHub Actions Setup

### Installation

1. Copy the `.github/workflows/update-flake.yml` file to your repository

2. The workflow requires the following permissions (already configured in the file):
   - `contents: write` - to push changes
   - `pull-requests: write` - to create and merge PRs

3. Ensure GitHub Actions has the necessary permissions:
   - Go to **Settings** > **Actions** > **General**
   - Under "Workflow permissions", select **"Read and write permissions"**
   - Check **"Allow GitHub Actions to create and approve pull requests"**

### Execution

- **Automatic**: Daily at 2 AM UTC (configurable in the cron)
- **Manual**: Via the "Actions" tab > "Update Flake Lock" > "Run workflow"

## 📋 GitLab CI Setup

### Installation

1. Copy the `.gitlab-ci.yml` file to the root of your repository

2. Create an **Access Token**:
   - Go to **Settings** > **Access Tokens**
   - Create a token with the scopes:
     - `api`
     - `write_repository`
   - Copy the generated token

3. Add the token to CI/CD variables:
   - Go to **Settings** > **CI/CD** > **Variables**
   - Add a variable:
     - **Key**: `CI_PUSH_TOKEN`
     - **Value**: your token
     - **Type**: Variable
     - **Flags**: Masked (recommended)

4. Create a **Pipeline Schedule**:
   - Go to **CI/CD** > **Schedules**
   - Click "New schedule"
   - **Description**: "Update flake.lock daily"
   - **Interval Pattern**: Custom `0 2 * * *` (daily at 2 AM UTC)
   - **Target branch**: master
   - Save

### Execution

- **Automatic**: According to the configured schedule
- **Manual**: Via **CI/CD** > **Pipelines** > **Run pipeline**

## 🔧 Customization

### Change execution time

**GitHub**: Modify the cron in `.github/workflows/update-flake.yml`:
```yaml
schedule:
  - cron: '0 14 * * *'  # 2 PM UTC instead of 2 AM
```

**GitLab**: Modify the interval pattern in the schedule via GitLab interface

### Change delay before merge

Modify the `24 hours ago` / `86400` value in the files:

**GitHub**:
```bash
CUTOFF_DATE=$(date -u -d '48 hours ago' --iso-8601=seconds)  # 48h instead of 24h
```

**GitLab**:
```bash
CUTOFF_TIME=$((CURRENT_TIME - 172800))  # 172800 = 48h in seconds
```

### Change target branch

Replace `master` with your main branch (`main`, etc.) in the configuration files.

## 🛡️ Security

- PRs/MRs are created on a separate branch
- You can manually close a PR/MR to cancel the update
- The 24h delay allows you to test changes before merge
- Update branches are automatically deleted after merge

### 🔒 Safety Checks

The auto-merge process includes **multiple safety checks** to ensure only legitimate flake.lock updates are merged:

**GitHub Actions checks:**
1. ✅ Label verification: PR must have `automated` label
2. ✅ Branch name verification: Must start with `flake-update-`
3. ✅ Title verification: Must be "🔄 Automatic flake.lock update"
4. ✅ Author verification: Must be created by `github-actions[bot]`
5. ✅ File changes verification: Only `flake.lock` must be changed
6. ✅ Age verification: PR must be at least 24h old
7. ✅ Mergeable status: PR must be in mergeable state

**GitLab CI checks:**
1. ✅ Label verification: MR must have `automated` label
2. ✅ Branch name verification: Must start with `flake-update-`
3. ✅ Title verification: Must be "🔄 Automatic flake.lock update"
4. ✅ Timestamp verification: Must have valid creation timestamp in description
5. ✅ File changes verification: Only `flake.lock` must be changed
6. ✅ Age verification: MR must be at least 24h old
7. ✅ Mergeable status: MR must be in mergeable state

**If any of these checks fail, the PR/MR will be skipped and will NOT be merged automatically.**

## 📊 Monitoring

### GitHub
- Check the **Actions** tab to see execution history
- Created PRs have the `automated` label

### GitLab
- Check **CI/CD** > **Pipelines** for history
- Created MRs have the `automated` label

## 🐛 Troubleshooting

### GitHub: "Resource not accessible by integration"
→ Check workflow permissions in Settings > Actions > General

### GitLab: "401 Unauthorized"
→ Verify that the `CI_PUSH_TOKEN` token is properly configured with correct scopes

### PRs/MRs are not being merged automatically
→ Check the `auto-merge` job logs for errors

### Nix: "experimental features"
→ Commands automatically use `--experimental-features 'nix-command flakes'`

## 💡 Tips

1. **Test manually first**: Run the workflow manually to verify it works
2. **Monitor first executions**: Make sure updates are working correctly
3. **Configure notifications**: GitHub/GitLab can notify you when PRs/MRs are created
4. **Adjust the delay**: 24h is a good default, but adapt to your needs

## 📝 License

These scripts are provided as-is. Use at your own risk.
