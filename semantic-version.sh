#!/usr/bin/env bash

set -e # Exit on error.

if [[ ${GIT_URL} =~ ([^:]+)\.git ]]
then
    GIT_REPO=${BASH_REMATCH[1]};
else
    echo "Unknown repo ${GIT_URL}"
    exit 1
fi

if [[ -z ${HOTFIX} ]]; then
    HOTFIX_BRANCH="origin/hotfix/"
else
    HOTFIX_BRANCH=${HOTFIX}
fi

if [[ -z ${MINOR} ]]; then
    MINOR_BRANCH="origin/develop"
else
    MINOR_BRANCH=${MINOR}
fi

if [[ -z ${MAJOR} ]]; then
    MAJOR_BRANCH="origin/master"
else
    MAJOR_BRANCH=${MAJOR}
fi

altAssignment() {
    if [[ -z ${1} ]]; then
        echo ${2}
    else
        echo ${1}
    fi
}

getNextReleaseNum() {
    [[ ${1} =~ (v)?([0-9]+)\.([0-9]+)\.([0-9]+)(.*) ]] || [[ ${1} =~ (v)?([0-9]+)\.([0-9]+)(.*) ]]

    prefix=$(altAssignment "${BASH_REMATCH[1]}" "v")
    major=$(altAssignment "${BASH_REMATCH[2]}" "0")
    minor=$(altAssignment "${BASH_REMATCH[3]}" "0")
    patch=$(altAssignment "${BASH_REMATCH[4]}" "0")
    suffix=$(altAssignment "${BASH_REMATCH[5]}" "")

    if [[ "${GIT_BRANCH}" = "${HOTFIX_BRANCH}"* ]]; then
        patch=$((${patch} + 1))
    elif [ "${GIT_BRANCH}" = "${MINOR_BRANCH}" ]; then
        patch='0'
        minor=$((${minor} + 1))
    elif [ "${GIT_BRANCH}" = "${MAJOR_BRANCH}" ]; then
        patch='0'
        minor='0'
        major=$((${major} + 1))
    fi

    echo "${prefix}${major}.${minor}.${patch}${suffix}"
}

getMaxReleaseNum() {
    git tag -l --sort=-version:refname "v*" | sed -n 1p
}

getCommitReleaseNum(){
    git tag -l --sort=-version:refname "v*" --contains "${1}" | sed -n 1p
}

tagAndPushNewRelease() {
    git tag -a "${1}" -m "${2}" && git push origin --tags
}

doNewRelease() {
    tagAndPushNewRelease "${1}" "$(echo -e "Release ${1} created via cobak/alpine-sv image")"
}

cloneRepo() {
    git clone -q ${GIT_URL} /app
    cd /app
    git checkout -q ${GIT_BRANCH}
}

if [ ! -d "/app" ]; then
    cloneRepo
else
    cd /app
fi

GIT_TAG=$(getCommitReleaseNum ${GIT_COMMIT})

if [[ -z ${GIT_TAG} ]]; then
    GIT_MAX_TAG=$(getMaxReleaseNum)
    GIT_TAG=$(getNextReleaseNum "${GIT_MAX_TAG}")

    if [ "${GIT_TAG}" != "${GIT_MAX_TAG}" ]; then
        doNewRelease "${GIT_TAG}"
        echo "GIT_TAG=${GIT_TAG}"
    fi
fi


