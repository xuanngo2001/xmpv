#!/bin/bash
set -e
# Description: Update Firstboot vbox script.

fb_xmpv_dir=$(readlink -ev /media/master/github/firstboot/firstboot/apps/xmpv)
xmpv_script_dir=$(readlink -ev ./xmpv)

# Update xmpv to firstboot.
  yes | cp -v "${xmpv_script_dir}"/* "${fb_xmpv_dir}"

# Commit xmpv at firstboot.
  (
    cd "${fb_xmpv_dir}"
    # Git commands execution order is important.
    git ls-files --deleted -z | xargs -r -0 git rm && git commit -m 'xmpv: commit deleted files.' || true
    git ls-files --modified -z | xargs -r -0 git commit -m 'xmpv: commit changed files.'
    git ls-files --others -z | xargs -r -0 git add && git commit -m 'xmpv: commit new files.' || true
  )  