#!/bin/bash
FN="ngsplotdb_hg38_76_3.00.tar.gz"
URLS=(
  "https://depot.galaxyproject.org/software/ngsplotdb-hg38/ngsplotdb-hg38_3.00_src_all.tar.gz"
)
MD5="9d8fd42daef18bfc72131625db901204"

# Use a staging area in the conda dir rather than temp dirs, both to avoid
# permission issues as well as to have things downloaded in a predictable
# manner.
STAGING=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $STAGING
TARBALL=$STAGING/$FN

SUCCESS=0
for URL in ${URLS[@]}; do
  wget -O- -q ${URL} > $TARBALL
  [[ $? == 0 ]] || continue

  # Platform-specific md5sum checks.
  if [[ $(uname -s) == "Linux" ]]; then
    if md5sum -c <<<"$MD5  $TARBALL"; then
      SUCCESS=1
      break
    fi
  else if [[ $(uname -s) == "Darwin" ]]; then
    if [[ $(md5 $TARBALL | cut -f4 -d " ") == "$MD5" ]]; then
      SUCCESS=1
      break
    fi
  fi
fi
done

if [[ $SUCCESS != 1 ]]; then
  echo "ERROR: post-link.sh was unable to download any of the following URLs with the md5sum $MD5:" >> "${PREFIX}/.messages.txt" 2>&1
  printf '%s\n' "${URLS[@]}" >> "${PREFIX}/.messages.txt" 2>&1
  exit 1
fi

# Install and clean up
ngsplotdb.py -y install "${TARBALL}" >> "${PREFIX}/.messages.txt" 2>&1
rm $TARBALL
rmdir $STAGING
