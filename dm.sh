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
  local module_folder_paths="sites/all/modules/* profiles/*/modules/*"
  local modulefolders=""

  for path in $module_folder_paths; do
    modulefolders+=`find $path -maxdepth 1 -mindepth 1 -name $1 -type d`
  done

  # TODO: handle the case where there is more than one copy.
  echo "cd $modulefolders"

  # ARGH need to check that what was found is a folder, but ARGH bash:
  # if [ $modulefolders != '' && -d $modulefolders ]; then
  cd $modulefolders

  return;
}

# Autocompletion for the above.
function _dm {
  local cur=${COMP_WORDS[COMP_CWORD]}

  drroot;

  # Find all module folders.
  # We expect all 'modules' folders to be subdivided into 'contrib' and 'custom'
  # subfolders (other subfolder names will work too).
  local module_folder_paths="sites/all/modules/* profiles/*/modules/*"
  local modulefolders=""

  for path in $module_folder_paths; do
    modulefolders+=`find $path -maxdepth 1 -mindepth 1   -type d -exec basename {} \;`
    modulefolders+=' '
  done

  COMPREPLY=( $(compgen -W '$modulefolders' -- $cur) )
}
complete -F _dm dm
