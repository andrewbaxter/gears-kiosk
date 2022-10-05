#!/bin/sh -eux
nix-build https://github.com/andrewbaxter/organixm/archive/refs/tags/0.0.3.tar.gz \
	-I nixpkgs=channel:nixos-22.05 \
	--arg version_config ./gears.nix \
	--argstr version_uuid $(cat uuid.txt) \
	--argstr version_region $UPLOAD_REGION \
	--argstr version_bucket $UPLOAD_BUCKET \
	--argstr version_object_path gears \
	--argstr version_ro_access_key $DOWNLOAD_ACCESS_KEY \
	--argstr version_ro_secret_key $DOWNLOAD_SECRET_KEY \
	--argstr version_success_unit user-kiosk.service \
	--arg version_max_size 10 \
	"$@"