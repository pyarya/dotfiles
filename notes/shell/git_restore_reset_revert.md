## Table of Contents
 1. [Git Checkout](#git-checkout)
  - [Checkout](#checkout)
  - [Switch](#switch)
 2. [The 3 Rs of git](#the-3-rs-of-git)
  - [Restore](#restore)
  - [Reset](#reset)
   * [Soft](#soft)
   * [Mixed](#mixed)
   * [Hard](#hard)
  - [Revert](#revert)
  - [Further reading](#further-reading)

# Git Checkout
`git checkout` was, and still is, an overly ubiquitous command with syntax that
wasn't nearly verbose enough. With git v2.23 (2019), this sub-command is now
split into `switch` and `restore`

We also covert `reset` and `revert`, since they're sort of similar

## Checkout
Checkout was/is a way to control the state of the git working tree. It chose the
state of your files, which roughly is their branch and commit. However, this
worked way too broadly, consider these examples

```bash
# Remove all current edits from a file, -- is optional
# It bring back the version at HEAD
git checkout <file-path>
git checkout -- <file-path>
git checkout HEAD <file-path>
git checkout HEAD -- <file-path>
# Bring back files from an older state
git checkout <commit> <file-path>
git checkout <commit> -- <file-path>
# Shift HEAD over to another branch. Stash uncommitted changes
git checkout <branch>
# Shift HEAD over to an old commit (detached HEAD). Stash uncommitted changes
git checkout <commit>
```

## Switch
Git switch is an all-inclusive command to move the HEAD. It requires uncommitted
changes to be stashed

```bash
# Set HEAD to another branch
git switch <branch>
# Set HEAD to an old commit. It's a detached HEAD
git switch --detach <commit>
```

It can also create a new branch like `checkout -b` used to do

```bash
# Create a new branch from HEAD
git switch --create <branch>
git switch --create <branch> HEAD
# Create a new branch off an old commit
git switch --create <branch> <commit>
```

Managing remote branches is simple. The below renames a local and remote branch,
which showcases deleting and pushing to remotes

```bash
git branch -m <old-name> <new-name>  # Rename the branch locally
git push --delete <remote> <old-name>
git push --set-upstream <remote> <new-name>
```

# The 3 Rs of git
The general idea of "undoing" is spread between 3 subcommands. Generally given
commit tree

```
A - B - C - worktree
```

`restore` can make sepecific files look like they looked in commits `A`, `B`, or
`C`. `restore` is the only one that won't modify the commit history and a good
default

`revert` attempts to undo commits backwards, attaching a new commit `D`, in
which files look similar to themselves from `A`, `B`, or `C`, except for merge
conflicts which are manually resolved

`reset` can pop off commits, like `B` and `C` and either add them to an
accumulating worktree, or discard them entirely. This is the most raw "undo",
where we can end up with commit history `A - B`


## Restore
This is the file-only portion of `checkout`. It operates exclusively on files
and will never shift your HEAD

Location can be one of `--worktree` or `--staged`. `--source` default to HEAD

```bash
# Remove unstaged changes from files
git restore <file-paths>
git restore --source HEAD <file-paths...>
git restore --worktree --source HEAD <file-paths...>
# Unstage a file
git restore --staged <file-paths>
# Bring back files from an older state
git restore --source <commit> <file-paths...>
```

## Reset
This moves back in the commit history, changing different things based on its
"hardness". All examples here assume we have commit tree

```
A - B - C <-HEAD
Index: fileA.rs
Worktree: fileB.rs
```

The only difference between hardness really is where the files from the previous
commits go. In `soft` it's the index, in `mixed` it's the worktree, and in
`hard` it's essentially `/dev/null`

### Soft
By softly resetting, all the changes from previous commits go into the index,
alongside current staged changes

```
 $ git reset --soft

A - B <-HEAD
Index: fileA.rs fileModifiedInC.rs
Worktree: fileB.rs
```

### Mixed
This is the default option. It's identical to a soft reset, except all changes
from previous commits are moved into the worktree

```
 $ git reset --mixed

A - B <-HEAD
Index: fileA.rs
Worktree: fileB.rs fileModifiedInC.rs
```

### Hard
This option is the most destructive and effectively wipes out any evidence of
the previous commits. Files are moved into the void. Use a `git reflog` to get
them back

```
 $ git reset --hard

A - B <-HEAD
Index: fileA.rs
Worktree: fileB.rs
Deleted (not there anymore): fileModifiedInC.rs
```

## Revert
This is a sort of inverse to reset. Like reset it undoes entire commits. Unlike
reset, it does this by making a new commit that's the exact opposite of the old
commit

For example with commits

```
A - B - C <-HEAD
```

We can `git revert B` to get

```
A - B - C - B^-1 <-HEAD
```

Which puts us at commit `A` with changes from commit `C`, so it sort of
functions like the below, except our history still clearly shows commit `B`

```
A - C <-HEAD
```

## Further reading
[How checkout became switch and
restore](https://tanzu.vmware.com/developer/blog/git-switch-and-restore-an-improved-user-experience/)
