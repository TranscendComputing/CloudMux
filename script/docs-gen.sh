#!/bin/sh
bundle exec source2swagger -c "##~" -o docs -f config.ru || exit 1
bundle exec source2swagger -c "##~" -o docs -i app -e "rb" || exit 2
