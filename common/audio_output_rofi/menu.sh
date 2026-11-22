#!/usr/bin/env bash
# rofi script-mode backend for the audio output menu (see init.lua).
#
# rofi calls this script once to get the list, and again on every action with
# ROFI_RETV telling what happened and ROFI_INFO holding the sink name of the
# highlighted row:
#   1   Enter          -> make that output the default, close
#   10  kb-custom-1    -> volume down   (bound to Left by init.lua)
#   11  kb-custom-2    -> volume up     (bound to Right)
#   12  kb-custom-3    -> toggle mute   (bound to Alt+m)
# Printing no rows makes rofi close.

step=${AUDIO_OUTPUT_STEP:-5}
max=${AUDIO_OUTPUT_MAX:-100}
cells=${AUDIO_OUTPUT_BAR_CELLS:-10}
prompt=${AUDIO_OUTPUT_PROMPT:-output}
name_max=${AUDIO_OUTPUT_NAME_MAX:-32}

# One line per sink: name <TAB> volume <TAB> yes|no (muted) <TAB> description
list_sinks() {
    LC_ALL=C pactl list sinks | awk '
        function emit() {
            if (name != "")
                printf "%s\t%d\t%s\t%s\n", name, vol, mute, (desc != "" ? desc : name)
        }
        /^Sink #/          { emit(); name = ""; desc = ""; vol = 0; mute = "no" }
        /^\tName: /        { name = substr($0, 8) }
        /^\tDescription: / { desc = substr($0, 15) }
        /^\tMute: /        { mute = $2 }
        /^\tVolume: /      { if (match($0, /[0-9]+%/)) vol = substr($0, RSTART, RLENGTH - 1) + 0 }
        END                { emit() }'
}

sink=${ROFI_INFO:-}
retv=${ROFI_RETV:-0}

if [ -n "$sink" ]; then
    case "$retv" in
        1)
            pactl set-default-sink "$sink"
            exit 0
            ;;
        10 | 11)
            cur=$(list_sinks | awk -F'\t' -v n="$sink" '$1 == n { print $2; exit }')
            if [ -n "$cur" ]; then
                if [ "$retv" = 10 ]; then new=$((cur - step)); else new=$((cur + step)); fi
                [ "$new" -lt 0 ] && new=0
                [ "$new" -gt "$max" ] && new=$max
                pactl set-sink-volume "$sink" "${new}%"
            fi
            ;;
        12)
            pactl set-sink-mute "$sink" toggle
            ;;
    esac
fi

default=$(pactl get-default-sink)

names=() vols=() mutes=() descs=()
width=0
while IFS=$'\t' read -r name vol mute desc; do
    [ -z "$name" ] && continue
    if [ "${#desc}" -gt "$name_max" ]; then
        desc="${desc:0:name_max-1}…"
    fi
    [ "${#desc}" -gt "$width" ] && width=${#desc}
    names+=("$name") vols+=("$vol") mutes+=("$mute") descs+=("$desc")
done < <(list_sinks)

printf '\0prompt\x1f%s\n' "$prompt"
printf '\0message\x1f%s\n' "←→ volume   alt+m mute   ⏎ set default   esc close"
printf '\0markup-rows\x1ffalse\n'
printf '\0no-custom\x1ftrue\n'
printf '\0use-hot-keys\x1ftrue\n'
printf '\0keep-selection\x1ftrue\n'
printf '\0keep-filter\x1ftrue\n'

for i in "${!names[@]}"; do
    vol=${vols[i]}
    shown=$vol
    [ "$shown" -gt 100 ] && shown=100
    filled=$(((shown * cells + 50) / 100))
    bar=
    for ((c = 0; c < cells; c++)); do
        if [ "$c" -lt "$filled" ]; then bar+="█"; else bar+="░"; fi
    done

    if [ "${mutes[i]}" = yes ]; then
        label=" mute"
        urgent=true
    else
        label=$(printf ' %3d%%' "$vol")
        urgent=false
    fi

    if [ "${names[i]}" = "$default" ]; then marker="● "; else marker="  "; fi

    # pad by characters, not bytes, so the bars line up
    desc=${descs[i]}
    pad=$((width - ${#desc}))
    padding=
    for ((c = 0; c < pad; c++)); do padding+=" "; done

    # muted rows are flagged "urgent"; the theme draws those dimmed
    printf '%s%s%s  %s%s\0info\x1f%s\x1furgent\x1f%s\n' \
        "$marker" "$desc" "$padding" "$bar" "$label" "${names[i]}" "$urgent"
done
