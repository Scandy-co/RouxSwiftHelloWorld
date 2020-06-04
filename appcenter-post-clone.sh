#!/bin/sh

# make sure we always run from the bash script path
_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd $_dir

repo_name="RouxSwiftHelloWorld"

test_dir=$_dir/tmp
mkdir -p $test_dir

# download the license and SDK
roux_license_name="ScandyCoreLicense.txt"
roux_license_path="$_dir/$repo_name/$roux_license_name"
roux_tar_name=$(echo $S3_ROUX_TAR | awk -F "s3://roux-builds/" '{print $2}')
roux_dir_name=$(echo $roux_tar_name | awk -F ".tar.gz" '{print $1'})
roux_dir_path=$test_dir/$roux_dir_name
framework_name="ScandyCore.framework"

echo "get $S3_ROUX_LICENSE to $roux_license_path"
aws s3 cp --quiet $S3_ROUX_LICENSE $roux_license_path
echo "get $S3_ROUX_TAR"
aws s3 cp --quiet $S3_ROUX_TAR $test_dir/$roux_tar_name

pushd $test_dir
# extract the tar
tar -zxf $roux_tar_name
popd

# remove the framework if its already there
framework_dst=$_dir/Frameworks/$framework_name

if [ -e $framework_dst ]; then
  rm -rf $framework_dst
fi

ln -s $roux_dir_path/$framework_name $framework_dst
echo "Linked $framework_dst"
