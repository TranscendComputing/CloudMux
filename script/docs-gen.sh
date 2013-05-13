#!/bin/sh
source2swagger -c "##~" -o docs -f config.ru
source2swagger -c "##~" -o docs -i app -e "rb"
