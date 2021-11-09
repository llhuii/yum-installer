# install the yum tool
```sh
# export proxy setting
export http_proxy=http://192.168.2.10:808
export https_proxy=$http_proxy

# run
bash scripts/yum_install.sh

# validate
yum --version
```
