Wombat colorscheme for Vim
==========================

This colorscheme is an fork/copy of original wombat_ colorscheme by Lars
Nielsen, which has been ported to GUI version of vim with additional changes.

Features
========

* Most colors was slightly changed, most notable changes:

  * search color changed from violet to orange
  * comments are gray instead of yellowish
  * changed diff colors to be less vivid

* Added ``colorColumn`` color
* Added appropriate colors for ShowMarks_ plugin
* Added syntax colors for Syntastic_ plugin

Installation
------------

To install it, any kind of Vim package manager can be used, like NeoBundle_,
Pathogen_, Vundle_ or vim-plug_.

For manual installation, copy subdirectories from this repository to your
``~/.vim`` directory. To use it, just type ``:colorscheme wombat256grf``, or
append line:

.. code:: vim

   ...
   " change colorscheme
   colorscheme wombat256grf
   ...

to make it permanent.

License
-------

This work is licensed on 3-clause BSD license. See LICENSE file for details.

.. _Pathogen: https://github.com/tpope/vim-pathogen
.. _Vundle: https://github.com/gmarik/Vundle.vim
.. _NeoBundle: https://github.com/Shougo/neobundle.vim
.. _vim-plug: https://github.com/junegunn/vim-plug
.. _wombat: http://www.vim.org/scripts/script.php?script_id=1778
.. _desert256.vim: http://www.vim.org/scripts/script.php?script_id=1243
.. _ShowMarks: http://www.vim.org/scripts/script.php?script_id=152
.. _Syntastic: https://github.com/vim-syntastic/syntastic
