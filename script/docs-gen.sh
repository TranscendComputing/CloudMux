#!/bin/sh
source2swagger -c "##~" -o docs -f config.ru || exit 1
source2swagger -c "##~" -o docs -i app -e "rb" || exit 2
