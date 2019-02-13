all: package
change-version:
	bin/change-version.sh $(version)
package:
	bin/package.sh $(version)

