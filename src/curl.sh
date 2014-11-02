format_http_code_description () {
	local code
	expect_args code -- "$@"

	case "${code}" in
	'200')	echo 'done';;
	'201')	echo '201 (created)';;
	'202')	echo '202 (accepted)';;
	'203')	echo '203 (non-authoritative information)';;
	'204')	echo '204 (no content)';;
	'205')	echo '205 (reset content)';;
	'206')	echo '206 (partial content)';;
	'400')	echo '400 (bad request)';;
	'401')	echo '401 (unauthorized)';;
	'402')	echo '402 (payment required)';;
	'403')	echo '403 (forbidden)';;
	'404')	echo '404 (not found)';;
	'405')	echo '405 (method not allowed)';;
	'406')	echo '406 (not acceptable)';;
	'407')	echo '407 (proxy authentication required)';;
	'408')	echo '408 (request timeout)';;
	'409')	echo '409 (conflict)';;
	'410')	echo '410 (gone)';;
	'411')	echo '411 (length required)';;
	'412')	echo '412 (precondition failed)';;
	'413')	echo '413 (request entity too large)';;
	'414')	echo '414 (request URI too long)';;
	'415')	echo '415 (unsupported media type)';;
	'416')	echo '416 (requested range)';;
	'417')	echo '417 (expectation failed)';;
	'418')	echo "418 (I'm a teapot)";;
	'419')	echo '419 (authentication timeout)';;
	'420')	echo '420 (enhance your calm)';;
	'426')	echo '426 (upgrade required)';;
	'428')	echo '428 (precondition required)';;
	'429')	echo '429 (too many requests)';;
	'431')	echo '431 (request header fields too large)';;
	'451')	echo '451 (unavailable for legal reasons)';;
	'500')	echo '500 (internal server error)';;
	'501')	echo '501 (not implemented)';;
	'502')	echo '502 (bad gateway)';;
	'503')	echo '503 (service unavailable)';;
	'504')	echo '504 (gateway timeout)';;
	'505')	echo '505 (HTTP version not supported)';;
	'506')	echo '506 (variant also negotiates)';;
	'510')	echo '510 (not extended)';;
	'511')	echo '511 (network authentication required)';;
	*)	echo "${code} (unknown)"
	esac
}


curl_do () {
	local url
	expect_args url -- "$@"
	shift

	local status code
	status=0
	if ! code=$(
		curl "${url}"                      \
			--fail                     \
			--location                 \
			--silent                   \
			--show-error               \
			--write-out '%{http_code}' \
			"$@"                       \
			2>'/dev/null'
	); then
		status=1
	fi

	local code_description
	code_description=$( format_http_code_description "${code}" ) || die
	log_end "${code_description}"

	return "${status}"
}


curl_download () {
	local src_file_url dst_file
	expect_args src_file_url dst_file -- "$@"

	log_indent_begin "Downloading ${src_file_url}..."

	local dst_dir
	dst_dir=$( dirname "${dst_file}" ) || die

	rm -f "${dst_file}" || die
	mkdir -p "${dst_dir}" || die

	if ! curl_do "${src_file_url}" \
		--output "${dst_file}"
	then
		rm -f "${dst_file}" || die
		return 1
	fi
}


curl_check () {
	local src_url
	expect_args src_url -- "$@"

	log_indent_begin "Checking ${src_url}..."

	curl_do "${src_url}"         \
		--output '/dev/null' \
		--head || return 1
}


curl_upload () {
	local src_file dst_file_url
	expect_args src_file dst_file_url -- "$@"
	expect_existing "${src_file}"

	log_indent_begin "Uploading ${dst_file_url}..."

	curl_do "${dst_file_url}"    \
		--output '/dev/null' \
		--upload-file "${src_file}" || return 1
}


curl_delete () {
	local dst_url
	expect_args dst_url -- "$@"

	log_indent_begin "Deleting ${dst_url}..."

	curl_do "${dst_url}"         \
		--output '/dev/null' \
		--request DELETE || return 1
}
