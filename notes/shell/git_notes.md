## Quick start
Git is an indispensable tool for code development, though in reality you'll only
use a few commands on a day to day basis. This section provides a quick overview
of those commands
```
    $ git fetch
    $ git status -s
    $ git diff file_1
    $ git add some_dir
    $ git commit -m "Changed some directory"
    $ git switch -c new_branch
    $ git restore file_2
    $ git commit -a
    $ git log --graph --all --oneline --decorate | less
    $ git push
```
The above represent ~90% of git commands you'll use. For some of these, like the
`git log` command, you should setup aliases

#### Manual pages
    $ man gittutorial
    $ man giteveryday
Some useful manual pages for referencing non-specifics

    $ man git-rebase
    $ git help rebase
    $ tldr git rebase
For information on a single command, add a hyphen to separate out the
subcommand. If using `tldr` type the command as you normally would

#### Referencing commits
While most git commands default to `HEAD` without a commit passed, they often
accept other commits to operate on. Some commands also need another commit to
operate, like `git merge`

    $ git show HEAD      # References the current HEAD
    $ git show HEAD^     # References one commit above the HEAD
    $ git show HEAD^^    # Two commits above HEAD
    $ git show HEAD~4    # 4 commits above HEAD
    $ git show a22a398   # Commit starting with SHA1 a22a398
    $ git show v0.2.0    # Commit tagged with v0.2.0
    $ git show master    # Tip of the master branch
    $ git show origin/dev  # Tip of the local copy of the origin's dev branch
Various examples of referencing commits. These can be mixed together for more
complicated referencing, though that's not too common

    $ git show HEAD~4..     # All commits from 4 commits before to HEAD
    $ git show v2.0..HEAD^  # Commits from tag v2.0 to one before HEAD
Some commands accept ranges of references. As expected, if one end of the range
is missing, it'll use a default upper/lower bound

    $ git merge origin/master^
Merges one before the tip of the local copy of the origin's, possibly outdated,
master branch to the current branch. Very useful when working offline

## Project setup
#### New projects
    $ git init
Create a new git repository in the current directory with a master branch

    $ git remote add origin git@github.com:Aizuko/configs.git
    $ git remote add origin ssh://git@github.com:22/Aizuko/configs.git
Sets up a remote origin on GitHub. This example uses ssh to connect, though
often http will also be supported. The second example specifies port 22

    $ git push --set-upstream origin master
Pushes the master branch to the remote origin

#### Using a previous project
    $ git clone ssh://git@github.com/Aizuko/configs.git
    $ git clone https://github.com/Aizuko/configs.git
Clone a git repository from a remote. Everything will automatically be setup

    $ git clone -b dev --single-branch --depth=1 ssh://git@github.com:22/Aizuko/configs.git
Clone the tip of the dev branch. Useful for saving storage, if you only need the
latest commit

    .git/config
    [remote "origin"]
     - fetch = +refs/heads/dev:refs/remotes/origin/dev
     + fetch = +refs/heads/*:refs/remotes/origin/*
Sets git to synchronize all branches from origin, instead of just `dev`

    $ git remote -v
List the remotes for this repository. Often useful if you want to change the
connection protocol

    $ git remote set-url origin git@github.com:Aizuko/configs.git
Changes a remote. You'll rarely use this outside of changing protocols

    $ git clone --depth=1 git://github.com/Aizuko/configs.git
Quick way to clone a Github repository without needing to login

    $ git remote add upstream git@github.com:22/Aizuko/configs.git
Sets up another remote to track. Particularly important with forked branches

## Branches
Branches are a way to organize workflow into separate goals. This allows commits
for a feature that is still in development. Git recommends making a lot of cheap
branches and deleting them once merged

    $ git branch -a
Lists all the branches on the local system

#### Git checkout changes
`git checkout` was one of the most common commands to run in git, since it
handled way too much. Starting in git 2.23 the command has been split into two
new commands. `switch` deals with branches while `restore` resets files

    $ git restore file.txt
    $ git checkout file.txt
Restore a file to how it was in the `HEAD's` commit

    $ git restore --source HEAD^ file.txt
    $ git checkout HEAD^ file.txt
Restore the file to match the commit one before the `HEAD`

    $ git switch master
    $ git checkout master
Switch to the `master` branch

    $ git switch -c dev
    $ git checkout -b dev
Create a new branch called `dev`

#### Removing branches
Once a branch's goal has been achieved and merged, there's no use in keeping it
around. Having a bunch of old branches is simply confusing

    $ git branch --merged
Shows which branches have been merged. Many of these are often safe to delete

    $ git branch -d merged_branch
Deletes a branch locally. Only deletes branches that have been fully merged into
an upstream, so often the remote. There's no fear in losing commits this way

    $ git branch -D deadend_branch
    $ git branch -f -d deadend_branch
Force deletes a local branch, regardless of whether it's been merged. You can,
and likely will, lose commits this way. This should only be used for local
experimental branches that quickly hit a dead end in development

    $ git push origin --delete merged_branch
Deletes the branch on the remote repository as well

#### Tagging
Tags can be added to make referencing certain commits easier. Tags can often be
used instead of the rather complicated SHA1 to reference commits

    $ git tag -a v0.1.0 a22a398
    $ git tag -a v0.1.0 a22a398 -m "First version"
Creates an annotated tag for the commit `a22a398`. The tag will be automatically
signed

    $ git tag -a -f v0.2.0 a22a398 -m "Add compact statusline"
Overwrite previous tag for a commit with a new tag. This isn't a problem for
tags that are only local to the system. Do not attempt for remote tags

    $ git push origin v0.1.0
    $ git push origin --tags v0.1.0 v0.2.0
Push up locally created tags to the remote. Tags need to be explicitly pushed.
Note that undoing tag pushes is really hard and shouldn't be done

## Ignoring files
In general there are 2 types of files you won't want to track with git: build
artifacts and files specific to your computer. Stopping git from tracking these
is done through git ignore pattern files

    ./.gitignore
Sits in the root of a git repository as a local ignore file. This will be
committed to the repository, so other users will ignore the same files

    ./.git/info/exclude
Acts like a `.gitignore` file specific to your system's repository. It will not
be committed. Useful for random files you have lying around

    ~/.gitignore_global
A `gitignore` that applies to every repository for the user. It will not be
committed to any particular repository, so it's more similar to a git exclude
file. It doesn't need any particular name, just source it in `~/.gitconfig`:
```
[core]
	excludesfile = ~/.gitignore_global
```

`.gitignore` files use pattern matching similar to regex

    target
    target/**/*
Ignores anything in and including the `./target` directory

    target/notes_[0-9].md
    target/notes_?.md
Doesn't track any note files from 0-9, though will track anything higher, such
as `target/notes_12.md`. A `?` matches any one character, in this case also
matching `target/notes_a.md`

    !target/*_notes_*/lec_*.md
Track any lecture file in any notes directory in `target`. This can match paths
like `target/cmput_notes_1/lec_2.md` and `target/japan_notes_12/lec_passive.md`

    $ git rm --cached file.txt
In shell, removes a currently tracked file from tracking. This won't remove the
file from your system. Useful when you start ignoring a previously tracked file

[//]: # ex: set ft=markdown:tw=80:
