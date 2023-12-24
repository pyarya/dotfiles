Notes python and IPython

## Python
#### Virtual envs
Virtual environments are the `chroot` and `jails` of python. They essentially
temporarily append to the path and source locally installed versions of packages

    $ python3 -m venv jail
Creates a new python in

    $ source jail/bin/activate
    $ deactivate
Start and stop the venv. The `$PS1` should indicate which one is active

    $ pip install numpy ipython
Installs latest versions of packages to the venv. Use `pip` not `pip3` in venvs

## IPython
For a full blown IDE experience in shell, you'll want to use the IPython REPL.
Follow the vim ipython setup instructions to use it rStudio style

#### Magic in scripts
    >>> from IPython import get_ipython
    >>> get_ipython().magic('reset -f')
Functions exactly like typing `%reset -f` in the IPython interpreter. When
sourcing entire files, percent magic syntax won't work

#### Graphical interface
For certain applications, such as plotting graphs, a gui becomes much more
capable than a terminal. `matplotlib` can be easily set up to open a
live-updating gui window controlled by `ipython`

    >>> get_ipython.magic('pylab')
    In [01]: %pylab
Starts up a gui for plots. It may not open until the first figure is created

[//]: # ex: set ft=markdown tw=80:
