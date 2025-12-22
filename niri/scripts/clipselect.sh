#!/bin/bash

thumbnail_dir="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist/thumbnails"

cliphist_list=$(cliphist list)
if [ -z "$cliphist_list" ]; then
  fuzzel -d --prompt-only "cliphist: please store something first "
  rm -rf "$thumbnail_dir"
  exit
fi

[ -d "$thumbnail_dir" ] || mkdir -p "$thumbnail_dir"

# Write binary image to cache file if it doesn't exist
read -r -d '' thumbnail <<EOF
/^[0-9]+\s<meta http-equiv=/ { next }
match(\$0, /^([0-9]+)\s(\[\[\s)?binary.*(jpg|jpeg|png|bmp)/, grp) {
  cliphist_item_id=grp[1]
  ext=grp[3]
  thumbnail_file=cliphist_item_id"."ext
  system("[ -f ${thumbnail_dir}/"thumbnail_file" ] || echo " cliphist_item_id "\\\\\t | cliphist decode >${thumbnail_dir}/"thumbnail_file)
  print \$0"\0icon\x1f${thumbnail_dir}/"thumbnail_file
  next
}
1
EOF

item=$(echo "$cliphist_list" | gawk "$thumbnail" | fuzzel -d --placeholder "Search clipboard..." --counter --no-sort --with-nth 2)
exit_code=$?

if [ "$exit_code" -eq 0 ]; then
  [ -z "$item" ] || echo "$item" | cliphist decode | wl-copy
# Alt+z to wipe entire clipboard
elif [ "$exit_code" -eq 10 ]; then
  confirmation=$(echo -e "No\nYes" | fuzzel -d --placeholder "Delete entire history?" --lines 2)
  [ "$confirmation" == "Yes" ] && rm ~/.cache/cliphist/db && rm -rf "$thumbnail_dir"
# Alt+x to wipe single clipboard record
elif [ "$exit_code" -eq 11 ]; then
  if [ -n "$item" ]; then
    confirmation=$(echo -e "No\nYes" | fuzzel -d --placeholder "Delete single item?" --lines 2)
    if [ "$confirmation" == "Yes" ]; then
      item_id=$(echo "$item" | cut -f1)
      echo "$item_id" | cliphist delete
      find "$thumbnail_dir" -name "${item_id}.*" -delete
    fi
  fi
# Alt+c to preview image
elif [ "$exit_code" -eq 12 ]; then
  [ -z "$item" ] || echo "$item" | cliphist decode | imv -
fi

# Delete cached thumbnails that are no longer in cliphist db
find "$thumbnail_dir" -type f | while IFS= read -r thumbnail_file; do
  cliphist_item_id=$(basename "${thumbnail_file%.*}")
  if ! grep -q "^${cliphist_item_id}\s\[\[ binary data" <<<"$cliphist_list"; then
    rm "$thumbnail_file"
  fi
done
