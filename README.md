# install the yum tool
```sh
# export proxy setting
export http_proxy=http://192.168.2.10:808

base=http://euleros.huawei.com/2.8/aarch64/Packages/
# run
bash scripts/yum_install.sh "$base"

# validate
yum --version
```
