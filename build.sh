#!/bin/sh
nix-build https://github.com/andrewbaxter/organixm/archive/master.tar.gz \
	--arg version_config ./gears.nix \
	--argstr version_uuid 84742f94-db2b-4184-8670-3a3c851309b2 \
	--argstr version_region $UPLOAD_REGION \
	--argstr version_bucket $UPLOAD_BUCKET \
	--argstr version_object_path gears \
	--argstr version_ro_access_key $UPLOAD_ACCESS_KEY \
	--argstr version_ro_secret_key $UPLOAD_SECRET_KEY \
	--argstr version_success_unit user-kiosk.service \
	--arg version_max_size 10 \
	"$@"