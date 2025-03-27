PHONY: codegen
codegen: ensure-sourcery-installed
	@./vendor/sourcery/bin/sourcery --config AVCaptureClient/Sources/AVCaptureClient/Sourcery.yml
	@./vendor/sourcery/bin/sourcery --config Pipeline/Sources/Pipeline/Sourcery.yml
	@./vendor/sourcery/bin/sourcery --config PermissionsClient/Sources/PermissionsClient/Sourcery.yml
	@./vendor/sourcery/bin/sourcery --config Preferences/Sources/Preferences/Sourcery.yml

PHONY: ensure-sourcery-installed
ensure-sourcery-installed:
	@sh ./Scripts/ensure-sourcery-installed.sh
