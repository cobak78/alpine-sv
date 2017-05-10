#!/usr/bin/env bash

set -e # Exit on error.

if [[ ${GIT_URL} =~ ([^:]+)\.git ]]
then
    GIT_REPO=${BASH_REMATCH[1]};
else
    echo "Unknown repo ${GIT_URL}"
    exit 1
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

    if [[ "${GIT_BRANCH}" == "origin/hotfix/"* ]]; then
        patch=$((${patch} + 1))
    elif [ "${GIT_BRANCH}" = "origin/develop" ]; then
        patch='0'
        minor=$((${minor} + 1))
    elif [ "${GIT_BRANCH}" = "origin/master" ]; then
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
    tagAndPushNewRelease "${1}" "$(echo -e "Release ${1} created via Jenkins from build ${BUILD_DISPLAY_NAME}\n${BUILD_URL}")"
}

pruneLocalTags() {
    git tag -l | xargs git tag -d && git fetch --tags
}

pruneLocalTags

GIT_TAG=$(getCommitReleaseNum ${GIT_COMMIT})
NEW_TAG=0

if [[ -z ${GIT_TAG} ]]; then
    GIT_MAX_TAG=$(getMaxReleaseNum)
    GIT_TAG=$(getNextReleaseNum "${GIT_MAX_TAG}")
    
    if [ "${GIT_TAG}" != "${GIT_MAX_TAG}" ]; then
        NEW_TAG=1
        echo GIT_TAG=`echo ${GIT_TAG}` >> $LOGFILE
    fi
fi

echo "Actual GIT tag: ${GIT_MAX_TAG}, New GIT tag: ${GIT_TAG}, is new tag ${NEW_TAG}"
