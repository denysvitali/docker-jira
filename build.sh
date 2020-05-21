#!/bin/bash
set -e
IMAGE_NAME="jira"
SOFTWARE="jira-software"

BUILD_EAP=0

function usage(){
  echo "Usage $0 [-e]"
  exit 0
}

while getopts ":e" o; do
    case "${o}" in
        e)
            BUILD_EAP=1
            ;;
        *)
            usage
            ;;
    esac
done

if [ $BUILD_EAP -eq 1 ]; then
  echo "Building EAP"
fi

# Get latest Jira Version
echo "Getting latest version feed..."
if [ $BUILD_EAP -eq 1 ]; then
  RSS_URL="https://my.atlassian.com/download/feeds/eap/${SOFTWARE}.rss"
  echo "Building EAP"
	RSS_FILE=$(curl $RSS_URL)
  VERSIONS=$(echo -en "$RSS_FILE" | xmlstarlet sel -t -v '/rss/channel/item/link/text()' -n -)
else
  RSS_URL="https://my.atlassian.com/download/feeds/${SOFTWARE}.rss"
	RSS_FILE=$(curl $RSS_URL)
	VERSIONS=$(echo "$RSS_FILE" | xmlstarlet sel -t -v '/rss/channel/item/guid/text()' -)
fi

LINUX_BIN=$(echo -n "$VERSIONS" | grep '\.bin$')
LINUX_BIN=$(echo -e "$LINUX_BIN" | grep $SOFTWARE)

CURRENT_VERSION=$(echo "$LINUX_BIN" | sed -e "s@https://www.atlassian.com/software/${SOFTWARE/-software/}/downloads/binary/atlassian-$SOFTWARE-@@" -e 's/-x64.bin//' | head -n 1)
CURRENT_MAJOR=$(echo "$CURRENT_VERSION" | cut -d '.' -f 1)
CURRENT_MINOR=$(echo "$CURRENT_VERSION" | cut -d '.' -f 2)
CURRENT_PATCH=$(echo "$CURRENT_VERSION" | cut -d '.' -f 3)


echo "Current version: ${CURRENT_VERSION}"
echo "Current Major: ${CURRENT_MAJOR}"
echo "Current Minor: ${CURRENT_MINOR}"
echo "Current Patch: ${CURRENT_PATCH}"

if [ $BUILD_EAP -eq 1 ]; then
	docker build \
	--build-arg "VERSION=${CURRENT_VERSION}" \
	--build-arg "EAP=1" -t "dvitali/${IMAGE_NAME}:${CURRENT_VERSION}" .
	docker tag "dvitali/${IMAGE_NAME}:${CURRENT_VERSION}" "dvitali/${IMAGE_NAME}:eap"
	docker tag "dvitali/${IMAGE_NAME}:${CURRENT_VERSION}" "dvitali/${IMAGE_NAME}:${CURRENT_MAJOR}-eap"
	docker tag "dvitali/${IMAGE_NAME}:${CURRENT_VERSION}" "dvitali/${IMAGE_NAME}:${CURRENT_MAJOR}.${CURRENT_MINOR}-eap"
	docker tag "dvitali/${IMAGE_NAME}:${CURRENT_VERSION}" "dvitali/${IMAGE_NAME}:${CURRENT_MAJOR}.${CURRENT_MINOR}.${CURRENT_PATCH}-eap"

	docker push "dvitali/${IMAGE_NAME}:${CURRENT_VERSION}"
	docker push "dvitali/${IMAGE_NAME}:eap"
	docker push "dvitali/${IMAGE_NAME}:${CURRENT_MAJOR}-eap"
	docker push "dvitali/${IMAGE_NAME}:${CURRENT_MAJOR}.${CURRENT_MINOR}-eap"
	docker push "dvitali/${IMAGE_NAME}:${CURRENT_MAJOR}.${CURRENT_MINOR}.${CURRENT_PATCH}-eap"
else
	docker build --build-arg VERSION="${CURRENT_VERSION}" -t "dvitali/${IMAGE_NAME}:${CURRENT_VERSION}" .
	docker tag "dvitali/${IMAGE_NAME}:${CURRENT_VERSION}" "dvitali/${IMAGE_NAME}:${CURRENT_MAJOR}"
	docker tag "dvitali/${IMAGE_NAME}:${CURRENT_VERSION}" "dvitali/${IMAGE_NAME}:${CURRENT_MAJOR}.${CURRENT_MINOR}"
	docker tag "dvitali/${IMAGE_NAME}:${CURRENT_VERSION}" "dvitali/${IMAGE_NAME}:latest"

	docker push "dvitali/${IMAGE_NAME}:${CURRENT_MAJOR}"
	docker push "dvitali/${IMAGE_NAME}:${CURRENT_MAJOR}.${CURRENT_MINOR}"
	docker push "dvitali/${IMAGE_NAME}:latest"
fi
