class AwsCfMappingImporter

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

####### Mapping Constants ########
# Types
CF_IMAGE_MAP        = "CloudFormation Image Map"
# Regions and region displays
US_EAST1            = "us-east-1"
US_EAST1_DISP       = "US EAST"
US_WEST1            = "us-west-1"
US_WEST1_DISP       = "US West (Oregon)"
US_WEST2            = "us-west-2"
US_WEST2_DISP       = "US West (N. California)"
EU_WEST             = "eu-west-1"
EU_WEST_DISP        = "EU (Ireland)"
AP_SOUTHEAST        = "ap-southeast-1"
AP_SOUTHEAST_DISP   = "Asia Pacific (Singapore)"
AP_NORTHEAST		= "ap-northeast-1"
AP_NORTHEAST_DISP	= "Asia Pacific (Tokyo)"
SA_EAST			    = "sa-east-1"
SA_EAST_DISP		= "South America (Sao Paulo)"
# Properties
IMAGE_ID		    = "image_id"
REGION              = "region"
REGION_DISP         = "region_display"
OS                  = "operating_system"
ICON                = "icon"
VT                  = "virtualization_type"
HYP                 = "hypervisor"
ARCH                = "architecture"
RDT                 = "root_device_type"
# Property Values
ARCH_64             = "x86_64"
ARCH_32             = "i386"
RDT_S3              = "S3"
RDT_EBS             = "EBS"
LINUX               = "Linux"
WINDOWS             = "Windows"

###### AWS Mappings ######
# AWS Linux AMI 32-bit S3
AWS_32_S3 = [
	{IMAGE_ID => "ami-b6cd60df", REGION => US_EAST1,     REGION_DISP => US_EAST1_DISP},
	{IMAGE_ID => "ami-b0da5580", REGION => US_WEST2,     REGION_DISP => US_WEST2_DISP},
	{IMAGE_ID => "ami-7b4c693e", REGION => US_WEST1,     REGION_DISP => US_WEST1_DISP},
	{IMAGE_ID => "ami-6b55511f", REGION => EU_WEST,      REGION_DISP => EU_WEST_DISP},
	{IMAGE_ID => "ami-2a0b4a78", REGION => AP_SOUTHEAST, REGION_DISP => AP_SOUTHEAST_DISP},
	{IMAGE_ID => "ami-3019aa31", REGION => AP_NORTHEAST, REGION_DISP => AP_NORTHEAST_DISP},
	{IMAGE_ID => "ami-e036e8fd", REGION => SA_EAST,      REGION_DISP => SA_EAST_DISP}
]
# AWS Linux AMI 64-bit S3
AWS_64_S3 = [
	{IMAGE_ID => "ami-94cd60fd", REGION => US_EAST1,     REGION_DISP => US_EAST1_DISP},
	{IMAGE_ID => "ami-bada558a", REGION => US_WEST2,     REGION_DISP => US_WEST2_DISP},
	{IMAGE_ID => "ami-074c6942", REGION => US_WEST1,     REGION_DISP => US_WEST1_DISP},
	{IMAGE_ID => "ami-53555127", REGION => EU_WEST,      REGION_DISP => EU_WEST_DISP},
	{IMAGE_ID => "ami-d40b4a86", REGION => AP_SOUTHEAST, REGION_DISP => AP_SOUTHEAST_DISP},
	{IMAGE_ID => "ami-3419aa35", REGION => AP_NORTHEAST, REGION_DISP => AP_NORTHEAST_DISP},
	{IMAGE_ID => "ami-f236e8ef", REGION => SA_EAST,      REGION_DISP => SA_EAST_DISP}
]
# AWS Linux AMI 32-bit EBS
AWS_32_EBS = [
	{IMAGE_ID => "ami-a0cd60c9", REGION => US_EAST1,     REGION_DISP => US_EAST1_DISP},
	{IMAGE_ID => "ami-46da5576", REGION => US_WEST2,     REGION_DISP => US_WEST2_DISP},
	{IMAGE_ID => "ami-7d4c6938", REGION => US_WEST1,     REGION_DISP => US_WEST1_DISP},
	{IMAGE_ID => "ami-61555115", REGION => EU_WEST,      REGION_DISP => EU_WEST_DISP},
	{IMAGE_ID => "ami-220b4a70", REGION => AP_SOUTHEAST, REGION_DISP => AP_SOUTHEAST_DISP},
	{IMAGE_ID => "ami-2a19aa2b", REGION => AP_NORTHEAST, REGION_DISP => AP_NORTHEAST_DISP},
	{IMAGE_ID => "ami-f836e8e5", REGION => SA_EAST,      REGION_DISP => SA_EAST_DISP}
]
# AWS Linux AMI 64-bit EBS
AWS_64_EBS = [
	{IMAGE_ID => "ami-aecd60c7", REGION => US_EAST1,     REGION_DISP => US_EAST1_DISP},
	{IMAGE_ID => "ami-48da5578", REGION => US_WEST2,     REGION_DISP => US_WEST2_DISP},
	{IMAGE_ID => "ami-734c6936", REGION => US_WEST1,     REGION_DISP => US_WEST1_DISP},
	{IMAGE_ID => "ami-6d555119", REGION => EU_WEST,      REGION_DISP => EU_WEST_DISP},
	{IMAGE_ID => "ami-3c0b4a6e", REGION => AP_SOUTHEAST, REGION_DISP => AP_SOUTHEAST_DISP},
	{IMAGE_ID => "ami-2819aa29", REGION => AP_NORTHEAST, REGION_DISP => AP_NORTHEAST_DISP},
	{IMAGE_ID => "ami-fe36e8e3", REGION => SA_EAST,      REGION_DISP => SA_EAST_DISP}
]
# Ubuntu AMI 32-bit
UBUNTU_32 = [
	{IMAGE_ID => "ami-06ad526f", REGION => US_EAST1,     REGION_DISP => US_EAST1_DISP},
	{IMAGE_ID => "ami-7ef9744e", REGION => US_WEST2,     REGION_DISP => US_WEST2_DISP},
	{IMAGE_ID => "ami-116f3c54", REGION => US_WEST1,     REGION_DISP => US_WEST1_DISP},
	{IMAGE_ID => "ami-359ea941", REGION => EU_WEST,      REGION_DISP => EU_WEST_DISP},
	{IMAGE_ID => "ami-62582130", REGION => AP_SOUTHEAST, REGION_DISP => AP_SOUTHEAST_DISP},
	{IMAGE_ID => "ami-d8b812d9", REGION => AP_NORTHEAST, REGION_DISP => AP_NORTHEAST_DISP},
	{IMAGE_ID => "ami-e23ae5ff", REGION => SA_EAST,      REGION_DISP => SA_EAST_DISP}
]
# Ubuntu AMI 64-bit
UBUNTU_64 = [
	{IMAGE_ID => "ami-1aad5273", REGION => US_EAST1,     REGION_DISP => US_EAST1_DISP},
	{IMAGE_ID => "ami-60f97450", REGION => US_WEST2,     REGION_DISP => US_WEST2_DISP},
	{IMAGE_ID => "ami-136f3c56", REGION => US_WEST1,     REGION_DISP => US_WEST1_DISP},
	{IMAGE_ID => "ami-379ea943", REGION => EU_WEST,      REGION_DISP => EU_WEST_DISP},
	{IMAGE_ID => "ami-60582132", REGION => AP_SOUTHEAST, REGION_DISP => AP_SOUTHEAST_DISP},
	{IMAGE_ID => "ami-dab812db", REGION => AP_NORTHEAST, REGION_DISP => AP_NORTHEAST_DISP},
	{IMAGE_ID => "ami-1e39e603", REGION => SA_EAST,      REGION_DISP => SA_EAST_DISP}
]

####### Creates default CF Template Image Mappings ############ 
  def import(cloud)
    puts "Creating AWS CF Template Default Image Mappings"

    mappings = []
    s3_properties = {
        OS   => LINUX,
        ICON => "amazon",
        RDT  => RDT_S3,
        VT   => "paravirtual",
        HYP  => "xen"
    }

    ebs_properties = {
        OS   => LINUX,
        ICON => "amazon",
        RDT  => RDT_EBS,
        VT   => "paravirtual",
        HYP  => "xen", 
    }
    
    ubuntu_properties = {
        OS   => LINUX,
        ICON => "ubuntu",
        RDT  => RDT_EBS
    }

    s3_properties[ARCH] = ARCH_32
    s3_32_mapping = CloudMapping.new
    s3_32_mapping.name = "Amazon Linux Instance Store 32-bit"
    s3_32_mapping.mapping_type = CF_IMAGE_MAP
    s3_32_mapping.properties = s3_properties
    s3_32_mapping.mapping_entries = AWS_32_S3
    mappings << s3_32_mapping

    s3_properties[ARCH] = ARCH_64
    s3_64_mapping = CloudMapping.new
    s3_64_mapping.name = "Amazon Linux Instance Store 64-bit"
    s3_64_mapping.mapping_type = CF_IMAGE_MAP
    s3_64_mapping.properties = s3_properties
    s3_64_mapping.mapping_entries = AWS_64_S3
    mappings << s3_64_mapping

    ebs_properties[ARCH] = ARCH_32
    ebs_32_mapping = CloudMapping.new
    ebs_32_mapping.name = "Amazon Linux EBS Backed 32-bit"
    ebs_32_mapping.mapping_type = CF_IMAGE_MAP
    ebs_32_mapping.properties = ebs_properties
    ebs_32_mapping.mapping_entries = AWS_32_EBS
    mappings << ebs_32_mapping

    ebs_properties[ARCH] = ARCH_64
    ebs_64_mapping = CloudMapping.new
    ebs_64_mapping.name = "Amazon Linux EBS Backed 64-bit"
    ebs_64_mapping.mapping_type = CF_IMAGE_MAP
    ebs_64_mapping.properties = ebs_properties
    ebs_64_mapping.mapping_entries = AWS_64_EBS
    mappings << ebs_64_mapping
    
    ubuntu_properties[ARCH] = ARCH_32
    ubuntu_32_mapping = CloudMapping.new
    ubuntu_32_mapping.name = "Ubuntu 32-bit"
    ubuntu_32_mapping.mapping_type = CF_IMAGE_MAP
    ubuntu_32_mapping.properties = ubuntu_properties
    ubuntu_32_mapping.mapping_entries = UBUNTU_32
    mappings << ubuntu_32_mapping
    
    ubuntu_properties[ARCH] = ARCH_64
    ubuntu_64_mapping = CloudMapping.new
    ubuntu_64_mapping.name = "Ubuntu 64-bit"
    ubuntu_64_mapping.mapping_type = CF_IMAGE_MAP
    ubuntu_64_mapping.properties = ubuntu_properties
    ubuntu_64_mapping.mapping_entries = UBUNTU_64
    mappings << ubuntu_64_mapping

    mappings.each do |map|
        puts "Adding \"#{map.name}\" to #{cloud.name} cloud mappings"
        map.mappable = cloud
        begin
            map.save!
        rescue => e
            log " skipping - failed to save: #{e}\n#{e.backtrace.join("\n")}"
        end
    end
  end
  
  def log(message)
    puts message unless ENV["RACK_ENV"] == "test"
  end
end
