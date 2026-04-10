# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name: llvm
# @brief: Set build flag environment variables for LLVM.
# @repository: https://github.com/johnstonskj/zsh-llvm-plugin
# @version: 0.1.1
# @license: MIT AND Apache-2.0
#
# @description
#
# Homebrew notes:
#
# > Using `clang`, `clang++`, etc., requires a CLT installation at `/Library/Developer/CommandLineTools`.
# > If you don't want to install the CLT, you can write appropriate configuration files pointing to your
# > SDK at ~/.config/clang.
# > 
# > To use the bundled libunwind please use the following LDFLAGS:
# >   LDFLAGS="-L/opt/homebrew/opt/llvm/lib/unwind -lunwind"
# > 
# > To use the bundled libc++ please use the following LDFLAGS:
# >   LDFLAGS="-L/opt/homebrew/opt/llvm/lib/c++ -L/opt/homebrew/opt/llvm/lib/unwind -lunwind"
# > Features newer than system libc++ will require the following define to enable
# > (support for this may be removed in a future major LLVM release):
# >   CPPFLAGS="-D_LIBCPP_DISABLE_AVAILABILITY"
# > 
# > NOTE: You probably want to use the libunwind and libc++ provided by macOS unless you know what you're doing.
#
# > llvm is keg-only, which means it was not symlinked into /opt/homebrew,
# > because macOS already provides this software and installing another version in
# > parallel can cause all kinds of trouble.
# > 
# > If you need to have llvm first in your PATH, run:
# >   echo 'export PATH="/opt/homebrew/opt/llvm/bin:$PATH"' >> /Users/s0j0g7m/.zshrc
# > 
# > For compilers to find llvm you may need to set:
# >   export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
# >   export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"
# > 
# > For cmake to find llvm you may need to set:
# >   export CMAKE_PREFIX_PATH="/opt/homebrew/opt/llvm"
#

###################################################################################################
# @section Globals
# @description
#
# Import any globals from other plugins (using `typeset -g`) and initialize any plugin globals
# using either `declare` or `declare -g` for exported values.
#
#
typeset -gi EC_SUCCESS

declare -g CLANG_CONFIG_FILE_SYSTEM_DIR
declare -g CLANG_CONFIG_FILE_USER_DIR
declare -g LDFLAGS
declare -g CPPFLAGS
declare -g CMAKE_PREFIX_PATH

############################################################################
# @section Lifecycle
# @description Plugin lifecycle functions.
#

@zplugins_declare_plugin_dependencies llvm brew shlog xdg

#
# @description
#
# Set environment variables according to Homebrew guidance.
#
# @noargs
#
llvm_plugin_init() {
    builtin emulate -L zsh

    local llvm_home="$(homebrew_formula_prefix llvm)"

    @zplugins_envvar_save llvm CLANG_CONFIG_FILE_SYSTEM_DIR
    CLANG_CONFIG_FILE_SYSTEM_DIR=${CLANG_CONFIG_FILE_SYSTEM_DIR:-${llvm_home}}

    @zplugins_envvar_save llvm CLANG_CONFIG_FILE_USER_DIR
    CLANG_CONFIG_FILE_USER_DIR=${CLANG_CONFIG_FILE_USER_DIR:-"$(xdg_config_for llvm)"}

    @zplugins_add_to_path llvm "${llvm_home}/bin"

    local llvm_lib="${llvm_home}/lib"
    @zplugins_envvar_save llvm LDFLAGS
    LDFLAGS="-L${llvm_lib} -L${llvm_lib}/c++ -L${llvm_lib}/unwind -lunwind ${LDFLAGS}"

    @zplugins_envvar_save llvm CPPFLAGS
    CPPFLAGS="-D_LIBCPP_DISABLE_AVAILABILITY -I${llvm_home}/include ${CPPFLAGS}"

    @zplugins_envvar_save llvm CMAKE_PREFIX_PATH
    CMAKE_PREFIX_PATH="${llvm_home}"

    return ${EC_SUCCESS}
}

#
# @description
#
# Restore all environment variables.
#
# @noargs
#
llvm_plugin_unload() {
    builtin emulate -L zsh

    @zplugins_envvar_restore llvm CLANG_CONFIG_FILE_SYSTEM_DIR
    @zplugins_envvar_restore llvm CLANG_CONFIG_FILE_USER_DIR
    @zplugins_envvar_restore llvm LDFLAGS
    @zplugins_envvar_restore llvm CPPFLAGS
    @zplugins_envvar_restore llvm CMAKE_PREFIX_PATH

    return ${EC_SUCCESS}
}
