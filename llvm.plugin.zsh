# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name: llvm
# @brief: Set build flag environment variables for LLVM.
# @repository: https://github.com/johnstonskj/zsh-llvm-plugin
# @version: 0.1.1
# @license: MIT AND Apache-2.0
#
# ### Public Variables
#
# * `CPPFLAGS`; standard compiler flags.
# * `LDFLAGS`; standard loader flags.
#

############################################################################
# @section Lifecycle
# @description Plugin lifecycle functions.
#

llvm_plugin_init() {
    builtin emulate -L zsh

    local llvm_prefix="$(homebrew_formula_prefix llvm)"

    @zplugins_add_to_path llvm "${llvm_prefix}/bin"

    @zplugins_envvar_save llvm CPPFLAGS
    typeset -g CPPFLAGS="${CPPFLAGS} -I${llvm_prefix}/include"

    @zplugins_envvar_save llvm LDFLAGS
    typeset -g LDFLAGS="${LDFLAGS} -L${llvm_prefix}/lib  -L${llvm_prefix}/lib/c++ -Wl,-rpath,${llvm_prefix}/lib/c++"
}

# @internal
llvm_plugin_unload() {
    builtin emulate -L zsh

    @zplugins_envvar_restore llvm CPPFLAGS
    @zplugins_envvar_restore llvm LDFLAGS
}
