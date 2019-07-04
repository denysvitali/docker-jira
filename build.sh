#!/bin/bash
IMAGE_NAME="jira"
SOFTWARE="jira-core"


# Get latest Jira Version
echo "Getting latest version feed..."
RSS_FILE=$(curl https://my.atlassian.com/download/feeds/${SOFTWARE}.rss)
VERSIONS=$(echo "$RSS_FILE" | xmllint --xpath '/rss/channel/item/guid/text()' -)
LINUX_BIN=$(echo "$VERSIONS" | grep '\.bin')
CURRENT_VERSION=$(echo "$LINUX_BIN" | sed -e "s@https://www.atlassian.com/software/${SOFTWARE/-core/}/downloads/binary/atlassian-$SOFTWARE-@@" -e 's/-x64.bin//')

CURRENT_MAJOR=$(echo "$CURRENT_VERSION" | cut -d '.' -f 1)
CURRENT_MINOR=$(echo "$CURRENT_VERSION" | cut -d '.' -f 2)
CURRENT_PATCH=$(echo "$CURRENT_VERSION" | cut -d '.' -f 3)

echo $RSS_FILE

echo "Current version: ${CURRENT_VERSION}"

echo "Current Major: ${CURRENT_MAJOR}"

docker build --build-arg VERSION=${CURRENT_VERSION} -t dvitali/${IMAGE_NAME}:${CURRENT_VERSION} .
docker tag dvitali/${IMAGE_NAME}:${CURRENT_VERSION} dvitali/${IMAGE_NAME}:${CURRENT_MAJOR}
docker tag dvitali/${IMAGE_NAME}:${CURRENT_VERSION} dvitali/${IMAGE_NAME}:${CURRENT_MAJOR}.${CURRENT_MINOR}

docker push dvitali/${IMAGE_NAME}:${CURRENT_VERSION}
docker push dvitali/${IMAGE_NAME}:${CURRENT_MAJOR}
docker push dvitali/${IMAGE_NAME}:${CURRENT_MAJOR}.${CURRENT_MINOR}
