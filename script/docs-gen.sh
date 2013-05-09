#!/bin/sh
source2swagger -c "##~" -o docs -f config.ru
source2swagger -c "##~" -o docs -f app/account_api_app.rb
source2swagger -c "##~" -o docs -f app/identity_api_app.rb
source2swagger -c "##~" -o docs -f app/cloud_api_app.rb
source2swagger -c "##~" -o docs -f app/cloud_account_api_app.rb
source2swagger -c "##~" -o docs -f app/aws/aws_compute_app.rb
source2swagger -c "##~" -o docs -f app/openstack/openstack_compute_app.rb
#-o api-docs
