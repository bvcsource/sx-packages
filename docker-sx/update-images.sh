for i in centos6 centos7 fedora23 wheezy jessie-32 precise yakkety;do
	pushd $i
	docker build --rm -t registry.sxps.vpn.skylable.com/pkg-${i}_sx .
	if [ $? -ne 0 ]; then
		echo Failed to build $i . Press ENTER to continue.
		read
	fi
	popd
done
