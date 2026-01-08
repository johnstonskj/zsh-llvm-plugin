# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# Plugin Name: llvm
# Description: Zsh plugin to set up build flags for LLVM.
# Repository: https://github.com/johnstonskj/zsh-llvm-plugin
#
# Public variables:
#
# * `LLVM`; plugin-defined global associative array with the following keys:
#   * `_ALIASES`; a list of all aliases defined by the plugin.
#   * `_FUNCTIONS`; a list of all functions defined by the plugin.
#   * `_PLUGIN_DIR`; the directory the plugin is sourced from.
#   * `_PREFIX`; the installation prefix of LLVM.
#   * `_OLD_CPPFLAGS`; the previous value of the `CPPFLAGS` environment variable.
#   * `_OLD_LDFLAGS`; the previous value of the `LDFLAGS` environment variable.
# * `CPPFLAGS`; standard compiler flags.
# * `LDFLAGS`; standard loader flags.
#

############################################################################
# Standard Setup Behavior
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# See https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
declare -gA LLVM
LLVM[_PLUGIN_DIR]="${0:h}"
LLVM[_FUNCTIONS]=""

# Set the path for any custom directories here.
LLVM[_PREFIX]="$(homebrew_formula_prefix llvm)"

# Saving the current state for any modified global environment variables.
LLVM[_OLD_CPPFLAGS]="${CPPFLAGS:-}"
LLVM[_OLD_LDFLAGS]="${LDFLAGS:-}"

############################################################################
# Internal Support Functions
############################################################################

#
# This function will add to the `LLVM[_FUNCTIONS]` list which is
# used at unload time to `unfunction` plugin-defined functions.
#
# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
# See https://wiki.zshell.dev/community/zsh_plugin_standard#the-proposed-function-name-prefixes
#
.llvm_remember_fn() {
    builtin emulate -L zsh

    local fn_name="${1}"
    if [[ -z "${LLVM[_FUNCTIONS]}" ]]; then
        LLVM[_FUNCTIONS]="${fn_name}"
    elif [[ ",${LLVM[_FUNCTIONS]}," != *",${fn_name},"* ]]; then
        LLVM[_FUNCTIONS]="${LLVM[_FUNCTIONS]},${fn_name}"
    fi
}
.llvm_remember_fn .llvm_remember_fn

#
# This function does the initialization of variables in the global variable
# `LLVM`. It also adds to `path` and `fpath` as necessary.
#
llvm_plugin_init() {
    builtin emulate -L zsh
    builtin setopt extended_glob warn_create_global typeset_silent no_short_loops rc_quotes no_auto_pushd

    path+=( "${LLVM[_PREFIX]}/bin" )

    export CPPFLAGS="${LLVM[_OLD_CPPFLAGS]} -I${LLVM[_PREFIX]}/include"
    export LDFLAGS="${LLVM[_OLD_LDFLAGS]} -L${LLVM[_PREFIX]}/lib  -L${LLVM[_PREFIX]}/lib/c++ -Wl,-rpath,${LLVM[_PREFIX]}/lib/c++"
}
.llvm_remember_fn llvm_plugin_init

############################################################################
# Plugin Unload Function
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
llvm_plugin_unload() {
    builtin emulate -L zsh

    # Remove all remembered functions.
    local plugin_fns
    IFS=',' read -r -A plugin_fns <<< "${LLVM[_FUNCTIONS]}"
    local fn
    for fn in ${plugin_fns[@]}; do
        whence -w "${fn}" &> /dev/null && unfunction "${fn}"
    done

    # Reset global environment variables .
    export CPPFLAGS="${LLVM[_OLD_CPPFLAGS]}"
    export LDFLAGS="${LLVM[_OLD_LDFLAGS]}"

    path=( "${(@)path:#${LLVM[_PREFIX]}/bin}" )

    # Remove the global data variable.
    unset LLVM

    # Remove this function.
    unfunction llvm_plugin_unload
}

############################################################################
# Initialize Plugin
############################################################################

llvm_plugin_init

true
