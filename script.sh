#!/bin/sh -eu
# Dependency: pandoc

convert() {
    local file
    local pep
    local title

    file="$1"
    pep="$(head -1 "${file}")"
    title="$(head -2 "${file}" | tail -1 | sed 's/Title: // ; s/"/\"/g')"
    echo "Processing ${pep} (${title}) ..."
    pandoc \
        --from=rst \
        --to=epub3 \
        --normalize \
        --ascii \
        --indented-code-classes=python \
        --table-of-contents \
        --epub-cover-image="../cover.jpg" \
        --metadata="creator:Python" \
        --metadata="language:en" \
        --metadata="title:${pep} (${title})" \
        --output="../peps_epub/${file%txt}epub" \
        "${file}"
}

is_valid() {
    local pep

    pep="$1"
    if grep 'This PEP has partially been superseded by' "${pep}" >/dev/null; then
        return 1
    elif grep 'Status: Active' "${pep}" >/dev/null; then
        return 0
    elif grep 'Status: Approved' "${pep}" >/dev/null; then
        return 0
    elif grep 'Status: Final' "${pep}" >/dev/null; then
        return 0
    fi
    return 1
}

setup() {
    [ ! -d peps ] && git clone --depth=1 https://github.com/python/peps.git
    mkdir -p peps_epub
}

main() {
    setup
    cd peps

    for pep in pep-*.txt; do
        if is_valid "${pep}"; then
            convert "${pep}"
        fi
    done
}

main
