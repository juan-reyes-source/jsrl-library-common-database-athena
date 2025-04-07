PYPI_ACCOUNT=pypi

_extract_build_number_tag () {
    echo $(python3 -B -c "from setup import INTERNAL_VERSION;print(INTERNAL_VERSION)")
}


_extract_library_name () {
    echo $(python3 -B -c "from setup import LIBRARY_NAME;print(LIBRARY_NAME)")
}


_extract_library_version () {
    echo $(python3 -B -c "from setup import LIBRARY_VERSION;print(LIBRARY_VERSION)")
}


get_library_configuration () {
    LIBRARY_NAME=$(_extract_library_name)
    LIBRARY_BUILD_NAME_TAG=$(_extract_build_number_tag)
    LIBRARY_VERSION=$(_extract_library_version)
}


generate_package_files () {
    echo -e "\033[38;5;82;1m ***** Building for $LIBRARY_NAME v$LIBRARY_VERSION Build number: $LIBRARY_BUILD_NAME_TAG - Library packages ***** \033[0;m \n"
    python3 -m pip install --upgrade build
    python3 -B -m build
}


add_build_number () {
    echo -e "\033[38;5;82;1m ***** Building for $LIBRARY_NAME v$LIBRARY_VERSION Build number: $LIBRARY_BUILD_NAME_TAG - Build number packages ***** \033[0;m \n"
    cd dist
    ls . | { while read file; do 
                mv $file $(echo $file | sed 's/\(jsrl_library_common-0.0.1\)\(.*\)/\1'"-$LIBRARY_BUILD_NAME_TAG"'\2/g'); 
            done }
    cd ..
}


update_to_pypi () {
    echo -e "\033[38;5;82;1m ***** Uploading the $LIBRARY_NAME v$LIBRARY_VERSION Build number: $LIBRARY_BUILD_NAME_TAG - Pypi repository ***** \033[0;m \n"
    python3 -m pip install --upgrade twine
    python3 -m twine upload --repository $PYPI_ACCOUNT dist/* \
                            --config-file $(PWD)/.pypirc
}


update_tag_info () {
    echo -e "\033[38;5;82;1m ***** Updating the $LIBRARY_NAME v$LIBRARY_VERSION Build number: $LIBRARY_BUILD_NAME_TAG - Git repository tag ***** \033[0;m \n"
    git tag -d $LIBRARY_VERSION
    git tag $LIBRARY_VERSION

    git push origin :$LIBRARY_VERSION
    git push origin $LIBRARY_VERSION

    git fetch --tags
}


clean () {
    rm -r dist
    rm -r $LIBRARY_NAME.egg-info
}


main () {
    cd ..
    get_library_configuration
    clean
    generate_package_files
    add_build_number
    update_to_pypi
    update_tag_info
    cd deploy
}

main