import subprocess
import sys
import os

def run_command(command):
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        return None

def main():
    print("=== commit-async Installation Verification ===")
    print()

    # 1. Verify Git is installed
    git_version = run_command("git --version")
    if not git_version:
        print("ERROR: Git is not installed or not in PATH")
        sys.exit(1)
    print(f"[OK] Git found: {git_version}")

    # 2. Verify current directory is a Git repository
    if run_command("git rev-parse --git-dir") is None:
        print("ERROR: Current directory is not a Git repository")
        sys.exit(1)
    print("[OK] Current directory is a Git repository")

    # 3. Display repository root
    repo_root = run_command("git rev-parse --show-toplevel")
    if not repo_root:
        print("ERROR: Could not determine repository root")
        sys.exit(1)
    print(f"[OK] Repository root: {repo_root}")

    # 4. Verify skill can be used
    skill_dir = os.path.join(repo_root, "commit-async")
    if not os.path.isdir(skill_dir):
        print(f"ERROR: commit-async skill directory not found at {skill_dir}")
        sys.exit(1)

    skill_md = os.path.join(skill_dir, "SKILL.md")
    if not os.path.isfile(skill_md):
        print(f"ERROR: SKILL.md not found in commit-async directory")
        sys.exit(1)

    print("[OK] commit-async skill structure verified")

    # 5. No external dependencies to install
    print()
    print("=== Verification Complete ===")
    print("No external dependencies required (no Node.js, npm, or external packages)")
    print("No Git hooks created")
    print("No commits or pushes performed")
    print()
    print("commit-async is ready to use.")

if __name__ == "__main__":
    main()
