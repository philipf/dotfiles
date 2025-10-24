# chezmoi dotfiles

My personal dotfiles, managed by [chezmoi](https://chezmoi.io).

## On a New Machine

1.  **Install chezmoi:**
    ```sh
    sh -c "$(curl -fsLS get.chezmoi.io)"
    ```

2.  **Initialize and apply your dotfiles:**
    ```sh
    chezmoi init --apply philipf
    ```

## Usage

**Add a new file:**

```sh
chezmoi add ~/.path/to/your/file
```

**Update and apply changes:**

```sh
# Pull changes from your repo and apply them
chezmoi update

# Re-apply any pending changes
chezmoi apply
```

## Managing with Git

To manually pull or push changes to your dotfiles repository:

1.  Navigate to the source directory:
    ```sh
    chezmoi cd
    ```

2.  Use standard git commands:
    ```sh
    # Pull remote changes
    git pull

    # Stage, commit, and push local changes
    git add .
    git commit -m "Your commit message"
    git push
    ```
