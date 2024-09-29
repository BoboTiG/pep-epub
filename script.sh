#!/bin/bash -eux
# Dependency: pandoc

convert() {
    local file
    local pep
    local output
    local title
    local date

    file="$1"
    output="$(echo "${file}" | sed s'#.rst$#.epub# ; s#.txt$#.epub#')"
    pep="$(head -1 "${file}")"
    title="$(head -2 "${file}" | tail -1 | sed 's/Title: // ; s/"/\"/g')"
    date="$(grep 'Created:' "${file}" | head -1 | sed 's/Created: // ; s/"/\"/g')"
    date="$(date --date=${date} '+%Y-%m-%d')"

    echo ">>> Processing ${pep} (${title}) ..."
    pandoc \
        --from=rst \
        --to=epub3 \
        --ascii \
        --indented-code-classes=python \
        --table-of-contents \
        --epub-cover-image="../../cover.jpg" \
        --metadata="creator:Python" \
        --metadata="language:en" \
        --metadata="title:${pep} (${title})" \
        --metadata="date:${date}" \
        --output="../../peps_epub/${output}" \
        "${file}"
}

is_valid() {
    local pep

    pep="$1"
    if grep -q 'Status: [Active|Accepted|Final]' "${pep}"; then
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
    git checkout main
    git pull --ff-only origin main

    new_rev="$(git log --oneline --max-count=1 --abbrev | cut -d' ' -f1)"
    git checkout "${new_rev}"

    while IFS= read pep; do
        if is_valid "${pep}"; then
            convert "${pep}"
        else
            echo "* skipping ${pep} ($(grep 'Status: ' "${pep}"))"
        fi
    done < <(git diff --name-only --diff-filter=AM "${current_rev}" "${new_rev}" 'pep-*.rst')
}

main() {
    local arg

    arg="${1}"

    mkdir -p peps_epub
    pushd peps/peps

    if [ "${arg:=unset}" = "--all" ]; then
        for pep in pep-*.rst; do
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
