# Drupal shell scripts for getting around a Drupal codebase.

# Change directory to the Drupal root.
# This works by going up a folder until it finds an index.php file.
function drroot {
  until [ -f "index.php"  -o  `pwd` = '\'  ]
  do
    cd ..;
  done
};

# Go to a Drupal module folder, from anywhere in the site hierarchy,
# with autocompletion.
function dm {
  drroot;

  # Look through all 'modules' folders.
  # We expect all 'modules' folders to be subdivided into 'contrib' and 'custom'
  # subfolders (other subfolder names will work too).
  local component_folder_paths=('modules' 'sites/all/modules/*' 'profiles/*/modules/*')
  local modulefolders=""

  for path in ${component_folder_paths[@]}; do
    # Find command:
    # -maxdepth / -mindepth: only find direct subfolders.
    # -type: only look for folders.
    # -L: cause symlinks to be treated as the type of the target, hence here
    #   find folders that are symlinked in. For FKW reason the -L needs to be
    #   before the path.
    modulefolders+=`find -L $path -maxdepth 1 -mindepth 1 -name $1 -type d`

    # If we've found one, stop.
    # TODO: if there is more than one copy, properly handle Drupal module
    # folder location precedence.
    if [ -n "$modulefolders" ]; then
      break
    fi
  done

  echo "Changing directory to $modulefolders."

  # ARGH need to check that what was found is a folder, but ARGH bash:
  # if [ $modulefolders != '' && -d $modulefolders ]; then
  cd $modulefolders

  return;
}

# Autocompletion for the above.
function _dm {
  cwd=`pwd`

  local cur=${COMP_WORDS[COMP_CWORD]}

  drroot;

  # Find all module folders.
  # We expect all 'modules' folders to be subdivided into 'contrib' and 'custom'
  # subfolders (other subfolder names will work too).
  local component_folder_paths=('modules' 'sites/all/modules/*' 'profiles/*/modules/*')
  local modulefolders=""

  for path in ${component_folder_paths[@]}; do
    modulefolders+=`find -L $path -maxdepth 1 -mindepth 1 -type d -exec basename {} \;`
    modulefolders+=' '
  done

  COMPREPLY=( $(compgen -W '$modulefolders' -- $cur) )

  # Restore the original directory, so if the user cancels the command during
  # autocomplete they are not moved.
  cd $cwd
}
complete -F _dm dm
