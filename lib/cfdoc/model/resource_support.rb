module CFDoc
  module Model
    module ResourceSupport
      ID = "id"
      DISPLAY_NAME = "display_name"
      ICON = "icon"
      MATCH_RULES = "match_rules"

      # maps groups by an internal id to the details and one or more regex-based match rules for a resource's type
      GROUP_MAPPINGS = {
        "identity"         =>  { DISPLAY_NAME=>"Identity",        MATCH_RULES=>["AWS::IAM::.*"],                     ICON=>"IAM_24.png" },
        "load_balancing"   =>  { DISPLAY_NAME=>"Load Balancing",  MATCH_RULES=>["AWS::ElasticLoadBalancing::*"],     ICON=>"NewLB_24.png" },
        "auto_scaling"     =>  { DISPLAY_NAME=>"Auto Scale Compute",    MATCH_RULES=>["AWS::AutoScaling::*"],              ICON=>"Autoscale_24.png" },
        "compute"          =>  { DISPLAY_NAME=>"Compute",         MATCH_RULES=>["AWS::EC2::*"],                      ICON=>"NewBasicServer_24.png" },
        "datastore"        =>  { DISPLAY_NAME=>"Datastore",       MATCH_RULES=>["AWS::RDS::*"],                      ICON=>"NewDB_24.png" },
        "notification"     =>  { DISPLAY_NAME=>"Notification",    MATCH_RULES=>["AWS::SNS::*"],                      ICON=>"NotificationService_24.png" },
        "monitoring"       =>  { DISPLAY_NAME=>"Monitoring",      MATCH_RULES=>["AWS::CloudWatch::*"],               ICON=>"CloudWatch_24.png" },
        "cloud_formation"  =>  { DISPLAY_NAME=>"Cloud Formation", MATCH_RULES=>["AWS::CloudFormation::*"],           ICON=>"CFStack_24.png" },
        "caching"          =>  { DISPLAY_NAME=>"Cache Cluster",   MATCH_RULES=>["AWS::ElastiCache::*"],              ICON=>"CacheNew_24.png" },
        "cdn"              =>  { DISPLAY_NAME=>"Content Distribution", MATCH_RULES=>["AWS::CloudFront::*"],              ICON=>"CloudFront_24.png" },
        "app_deploy"       =>  { DISPLAY_NAME=>"Application Deployment", MATCH_RULES=>["AWS::ElastiBeanstalk::*"],   ICON=>"NewBeanstalk_24.png" },
        "dns"              =>  { DISPLAY_NAME=>"Domain Name Service", MATCH_RULES=>["AWS::Route53::*"],              ICON=>"Route53_24.png" },
        "simple_storage"   =>  { DISPLAY_NAME=>"Simple Storage",  MATCH_RULES=>["AWS::S3::*"],                        ICON=>"NewSimpleStorage_24.png" },
        "simple_db"        =>  { DISPLAY_NAME=>"Simple Database", MATCH_RULES=>["AWS::SDB::*"],                      ICON=>"NewDB_24.png" },
        "queue"            =>  { DISPLAY_NAME=>"Queue",           MATCH_RULES=>["AWS::SQS::*"],                      ICON=>"NewDB_24.png" },
        "other"            =>  { DISPLAY_NAME=>"Other",           MATCH_RULES=>[],                                   ICON=>nil }
      }

      # run each match rule to find the group for the resource, or return 'other' group if not found
      def calc_group
        GROUP_MAPPINGS.keys.each do |group_id|
          # return the details, and include the id for reference
          return group_details(group_id) if self.in_group?(group_id)
        end
        # default: return 'other'
        return group_details('other')
      end

      # returns true if the resource matches any of the rules for a given group
      def in_group?(group_id)
        group_details = GROUP_MAPPINGS[group_id]
        raise "Group not found" if group_details.nil?

        group_details[MATCH_RULES].each do |rule|
          matched = self.type.match(rule)
          return true if matched
        end
        return false
      end

      def group_details(group_id)
        GROUP_MAPPINGS[group_id].merge({ ID=> group_id })
      end

    end
  end
end
