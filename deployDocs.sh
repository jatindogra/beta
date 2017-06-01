#!/bin/bash -e

export DOCS_BUCKET=$1
export DOCS_REGION=$2
export AWS_S3_LOCAL_PATH="site"
export REDIRECT_MAPPINGS_FILE="mapping.txt"
export REDIRECT_MAPPINGS_SCRIPT="createredirect.sh"

sync_docs() {
  pushd IN/docs_repo/gitRepo/

  echo "Installing requirements with pip"
  pip install -r requirements.txt

  echo "Building docs"
  mkdocs build

  if [ -f $REDIRECT_MAPPINGS_FILE ]; then
    echo "Setting up redirects"
    ./$REDIRECT_MAPPINGS_SCRIPT $REDIRECT_MAPPINGS_FILE $AWS_S3_LOCAL_PATH
    # TODO: Added for debug. Remove this once done.
    ls -R $AWS_S3_LOCAL_PATH
  fi

  echo "Syncing with S3"
  aws s3 sync $AWS_S3_LOCAL_PATH $DOCS_BUCKET --delete --acl public-read --region $DOCS_REGION
  popd
}

sync_docs