# Original file resides in r-hyperspec/pkg-skelton. Do not edit in any other repo.
# Edit at r-hyperspec/pkg-skelton, then push there and this file will be deployed.
# =========================================================================
#   Use this bash script to copy labels from one GitHub repo to another
# =========================================================================

# This bash script:
#   - reads labels from a GitHub repository and writes them to a file;
#   - copies the labels from the file to a new repository.

# NOTE: this script is useful when you need to delete old labels.
#       Works for non-private repos only.

# Authors: Vilmantas Gegzna & Erick Oduniyi


## Define variables

# pat - GitHub PAT (personal access token)
# You can generate PAT by running R code:
#    usethis::create_github_token()
# You can access PAT (if it is saved locally) by using R code:
#    gitcreds::gitcreds_set()

# Get PAT from R, if it is saved there
pat=$(Rscript -e 'gitcreds::gitcreds_get()$password')

# Or paste your pat instead of ???
pat=???

# Source repo:
from_repo=r-hyperspec/hyperSpec
# Destination repo:
to_repo=r-hyperspec/hySpc.repo
# Temporary directory name:
dest_dir=github-helpers
# File name for labels:
new_json_file=r-hyperspec-github-labels.json


## Make sure github-labels node package is installed
npm install github-labels -g

## Create directory
mkdir ${dest_dir}

## Construct file name and URL
file=${dest_dir}/${new_json_file}
url=https://api.github.com/repos/${from_repo}/labels

## Get the new url if labels were moved to a new place
## (this may happen with some repos):
# url=$(
#     curl -s $url |\
#     sed '3!d'    |\ # get only row 3
#     sed "s/^.*\"url\": \"\(.*\)\"\,.*$/\1/"
#   )

## Read labels and write to the file:
curl -s $url |\
  grep -ve '\"id\":' -      |\
  grep -ve '\"node_id\":' - |\
  grep -ve '\"url\":' -     |\
  grep -ve '\"default\":' - > ${file}


## To preview 6 rows (if needed):
# head -6 ${file}


### Select either A or B:

## (A) Just copy new labels (w/o deleting the old ones):
labels -c ${file} $to_repo -t $pat

## (B) Delete all old labels and then copy new ones:
# labels -c ${file} $to_repo -t $pat -f


## Remove folder with all its contents (if needed):
rm -rf ${dest_dir}
