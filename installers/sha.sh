verifysha256() {

  FILE=${1}
  SHA=${2}

  if [ "$(sha256sum ${FILE} | cut -d' ' -f 1)" != "${SHA}" ]; then
    echo 1
    return
  fi

  echo 0
}

verifysha1() {

  FILE=${1}
  SHA=${2}

  if [ "$(sha1sum ${FILE} | cut -d' ' -f 1)" != "${SHA}" ]; then
    echo 1
    return
  fi

  echo 0
}
