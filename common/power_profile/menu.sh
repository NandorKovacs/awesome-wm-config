#!/usr/bin/env bash
# rofi script-mode backend for the power profile menu (see init.lua).
#
# rofi calls this script once to get the list, and again when a row is chosen
# (Enter), with ROFI_RETV=1 and ROFI_INFO holding the profile of that row.
# Printing no rows makes rofi close.

prompt=${POWER_PROFILE_PROMPT:-power}
order=${POWER_PROFILE_ORDER:-power-saver balanced performance}

if [ "${ROFI_RETV:-0}" = 1 ] && [ -n "${ROFI_INFO:-}" ]; then
    powerprofilesctl set "$ROFI_INFO"
    exit 0
fi

# One line per profile of this machine: "* name" for the active one, "  name"
list=$(powerprofilesctl list | sed -n 's/^\([* ]\) \([a-z-]*\):$/\1 \2/p')

printf '\0prompt\x1f%s\n' "$prompt"
printf '\0message\x1f%s\n' "⏎ switch   esc close"
printf '\0no-custom\x1ftrue\n'

for profile in $order; do
    if grep -qxF "* $profile" <<<"$list"; then
        marker="● "
    elif grep -qxF "  $profile" <<<"$list"; then
        marker="  "
    else
        continue
    fi
    # The row text is the plain name, which is what typing filters on.
    printf '%s\0info\x1f%s\x1fdisplay\x1f%s%s\n' "$profile" "$profile" "$marker" "$profile"
done
