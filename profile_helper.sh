#!/usr/bin/env bash
if [ -s "$BASH" ]; then
    file_name=${BASH_SOURCE[0]}
elif [ -s "$ZSH_NAME" ]; then
    file_name=${(%):-%x}
fi
script_dir=$(cd "$(dirname "$file_name")" && pwd)

. "$script_dir/realpath/realpath.sh"

if [ -f ~/.base16_theme ]; then
  script_name=$(basename "$(realpath ~/.base16_theme)" .sh)
  echo "export BASE16_THEME=${script_name#*-}"
  echo ". ~/.base16_theme"
fi
cat <<'FUNC'
_base16()
{
  local script=$1
  local theme=$2
  [ -f $script ] && . $script
  ln -fs $script ~/.base16_theme
  export BASE16_THEME=${theme}
  echo -e "if \0041exists('g:colors_name') || g:colors_name != 'base16-$theme'\n  colorscheme base16-$theme\nendif" >| ~/.vimrc_background
  if [ -n ${BASE16_SHELL_HOOKS:+s} ] && [ -d "${BASE16_SHELL_HOOKS}" ]; then
    for hook in $BASE16_SHELL_HOOKS/*; do
      [ -f "$hook" ] && [ -x "$hook" ] && "$hook"
    done
  fi

  zathura_config=${script##*/}
  zathura_config=${zathura_config%.sh}
  zathura_config="${zathura_config}.config"
  zathura_config_path="$HOME/admin/base16-builder-php/templates/zathura/colors/$zathura_config"
  ln -fs $zathura_config_path ~/.config/zathura/zathurarc

  tmux_config=${script##*/}
  tmux_config=${tmux_config%.sh}
  tmux_config="${tmux_config}.conf"
  tmux_config_path="$HOME/admin/base16-builder-php/templates/tmux/colors/$tmux_config"
  ln -fs $tmux_config_path ~/.tmux.conf
  tmux source-file ~/.tmux.conf

  dwm_config=${script##*/}
  dwm_config=${dwm_config%.sh}
  dwm_config="${dwm_config}.diff"
  dwm_config_path="$HOME/admin/base16-builder-php/templates/dwm/diffs/$dwm_config"
  if [[ -f ~/admin/dwm/base16.diff ]];
  then
  	(cd ~/admin/dwm && patch -p1 -R <base16.diff)
  fi
  cp $dwm_config_path ~/admin/dwm/base16.diff
  CURDIR=$(pwd)
  (cd ~/admin/dwm && patch -p1 <base16.diff && make) >/dev/null && echo 'dwm patched!'

  gtk2_config=${script##*/}
  gtk2_config=${gtk2_config%.sh}
  gtk2_config="${gtk2_config}-gtkrc"
  gtk2_config_path="/home/vector/admin/base16-builder-php/templates/gtk-flatcolor/gtk-2/$gtk2_config"
  ln -fs $gtk2_config_path ~/.local/share/themes/flatcolor/gtk-2.0/gtkrc

  gtk3_config=${script##*/}
  gtk3_config=${gtk3_config%.sh}
  gtk3_config="${gtk3_config}-gtk.css"
  gtk3_config_path="/home/vector/admin/base16-builder-php/templates/gtk-flatcolor/gtk-3/$gtk3_config"
  ln -fs $gtk3_config_path ~/.local/share/themes/flatcolor/gtk-3.0/gtk.css
  ln -fs $gtk3_config_path ~/.local/share/themes/flatcolor/gtk-3.20/gtk.css
}
FUNC
for script in "$script_dir"/scripts/base16*.sh; do
  script_name=${script##*/}
  script_name=${script_name%.sh}
  theme=${script_name#*-}
  func_name="base16_${theme}"
  echo "alias $func_name=\"_base16 \\\"$script\\\" $theme\""
done;
