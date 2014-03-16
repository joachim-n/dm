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
  cd sites/all/modules;
  #echo contrib/$1;
  if [ -d "contrib/$1" ]
  then
    cd "contrib/$1";
  elif [ -d "custom/$1" ]
  then
    cd "custom/$1";
  fi
}

# Autocompletion for the above.
function _dm {
  local cur=${COMP_WORDS[COMP_CWORD]}

  drroot;

  cd sites/all/modules/contrib;
  local contrib=`ls -d -1 */`
  #echo $contrib

  cd ../custom;
  local custom=`ls -d -1 */`

  COMPREPLY=( $(compgen -W '$contrib $custom' -- $cur) )
}
complete -F _dm dm
