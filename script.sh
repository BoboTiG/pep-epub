#!/bin/bash -eux
# Dependency: pandoc

convert() {
    local file
    local pep
    local title

    file="$1"
    pep="$(head -1 "${file}")"
    title="$(head -2 "${file}" | tail -1 | sed 's/Title: // ; s/"/\"/g')"

    echo ">>> Processing ${pep} (${title}) ..."
    pandoc \
        --from=rst \
        --to=epub3 \
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

update() {
    local current_rev
    local files
    local new_rev

    current_rev="$(git log --oneline --max-count=1 --abbrev | cut -d' ' -f1)"

    echo ">>> Updating from revision ${current_rev} ..."
    git checkout master
    git pull

    new_rev="$(git log --oneline --max-count=1 --abbrev | cut -d' ' -f1)"
    git checkout "${new_rev}"

    while IFS= read pep; do
        if is_valid "${pep}"; then
            convert "${pep}"
        fi
    done < <(git diff --name-only --diff-filter=AM "${current_rev}" "${new_rev}" 'pep-*.txt')
}

main() {
    local arg

    arg="${1}"

    mkdir -p peps_epub
    pushd peps

    if [ "${arg:=unset}" = "--all" ]; then
        for pep in pep-*.txt; do
            if is_valid "${pep}"; then
                convert "${pep}"
            fi
        done
    else
        update
    fi

    popd
}

main "$@"
