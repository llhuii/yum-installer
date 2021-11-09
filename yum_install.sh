#!/bin/bash
base=${1:-https://mirrors.huaweicloud.com/euler/2.8/os/aarch64/Packages/}
force=true
echo|awk -v base=$base -v force=$force -v root=${2} '
sub(/.*<a href="/,e) {
  sub(/"/,FS);
  link=$1;
  sub(/-[0-9]+\.[0-9]+.*/,e,$1);
  sub(/\(/,FS);
  name = $1;
  name_dict[name] = name_dict[link]=link
}

function get_package_name(pkg) {
  if(!name_dict[pkg]) {
    pkg = Extra[pkg]
  }
  return name_dict[pkg]
}

function download(pkg, cmd, file) {
  file = get_package_name(pkg)
  url = base file
  
  cmd = "[ -e "file" ] || wget " url
  print "download cmd:", cmd
  system(cmd)
}

function install(pkg, parent, has_error, todo, ndeps, ins_cmd) {

  print "entering install", pkg
  file = get_package_name(pkg)

  if(!file) {
    print" not found package:", pkg ", the parent dependence is ", parent
    return
  }
  download(pkg)

  ins_cmd = "rpm -i " force file
  while(ins_cmd "  2>&1 "| getline) {
    if(has_error&&/needed/) {
      # libyaml-0.so.xxx
      # libdnf(x)
      sub(/\(/,FS)
      sub(/\.so\./,FS);sub(/(-[0-9]+)+$/,e,$1)
      todo[$1] = 1
    } else {
     has_error += /^error/
    }

  }

  for(_pkg in todo) {
    # already installed 
    ndeps++
    if(1 == TODO[_pkg]) continue
    install(_pkg, pkg)
  }
  # mark it
  TODO[pkg] = 1
  print"install cmd:", ins_cmd
  # try to install it
  if (ndeps>0) system(ins_cmd)
}

BEGIN{

  Extra["librpmbuild"] = "rpm-build-libs"
  Extra["librpmsign"] = "rpm-sign-libs"
  Extra["libimaevm"] = "ima-evm-utils"
  force=force?"--force ": ""

  base = base?base:"http://euleros.huawei.com/2.8/aarch64/Packages/"

  system("wget --no-check-certificate "base" -O packages.html")
  ARGC=2
  ARGV[1]="packages.html"

}
END{

  if (root) {
    install(root)
  } else {
    split("yum libnghttp2 glib2 libssh  brotli", pkgs)
    for(i in pkgs) {
      install(pkgs[i]) 
    }
  }
}
'
